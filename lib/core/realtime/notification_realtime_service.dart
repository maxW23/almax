import 'dart:async';
import 'package:flutter/foundation.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:appwrite/appwrite.dart';
import 'package:lklk/core/config/appwrite_config.dart';
import 'package:lklk/core/utils/logger.dart';
import 'package:lklk/core/services/auth_service.dart';

/// Global realtime notifications service that listens to Appwrite events
/// and maintains an unread notifications counter.
///
/// Payload example (message can vary: 'newvisitor', 'chat', ...):
/// {
///   'sender': '00055',
///   'message': 'newvisitor' | 'chat' | ...,
///   'timestamp': null,
///   'type': 'notification' | 'notfication',
///   'reciver': null,
///   'room_id': null,
///   'img': null,
///   'gift_sender': '...id...',
///   'selected_usr': null,
///   'timer': null,
///   'gift_img': null,
///   'gift_id': null,
///   '$id': 'documentId'
/// }

extension _FlushSupport on NotificationRealtimeService {
  void _markDirty() {
    _dirtyPending = true;
    _flushTimer?.cancel();
    _flushTimer = Timer(NotificationRealtimeService._flushInterval, () {
      // ignore: discarded_futures
      this._flushNow();
    });
  }

  Future<void> _flushNow() async {
    _flushTimer?.cancel();
    _flushTimer = null;
    if (!_dirtyPending && _prefs != null) {
      return;
    }
    final prefs = _prefs ?? await SharedPreferences.getInstance();
    _prefs = prefs;
    try {
      await prefs.setInt(NotificationRealtimeService._prefsUnreadKey, unreadCount.value);
      await prefs.setInt(NotificationRealtimeService._prefsChatUnreadKey, chatUnread.value);
      await prefs.setInt(NotificationRealtimeService._prefsVisitorUnreadKey, visitorUnread.value);
      await prefs.setInt(NotificationRealtimeService._prefsFriendUnreadKey, friendUnread.value);
      await prefs.setInt(NotificationRealtimeService._prefsRelationUnreadKey, relationUnread.value);
      await prefs.setStringList(NotificationRealtimeService._prefsLastSeenIdsKey, _recentIds.toList(growable: false));
    } catch (_) {
      // ignore persistence errors silently
    } finally {
      _dirtyPending = false;
    }
  }
}
class NotificationRealtimeService {
  NotificationRealtimeService._();
  static final NotificationRealtimeService instance = NotificationRealtimeService._();

  static const _prefsUnreadKey = 'notifications_unread_count';
  static const _prefsLastSeenIdsKey = 'notifications_seen_ids';
  static const _prefsChatUnreadKey = 'rt_unread_chat';
  static const _prefsVisitorUnreadKey = 'rt_unread_visitor';
  static const _prefsFriendUnreadKey = 'rt_unread_friend';
  static const _prefsRelationUnreadKey = 'rt_unread_relation';
  // Baseline snapshot (server totals at app start) — used only for reference, not to show unread
  static const _prefsBaselineChatKey = 'rt_baseline_chat_total';
  static const _prefsBaselineVisitorKey = 'rt_baseline_visitor_total';
  static const _prefsBaselineFriendKey = 'rt_baseline_friend_total';
  static const _prefsBaselineRelationKey = 'rt_baseline_relation_total';
  static const _prefsMigrationKey = 'rt_unread_migration_v2_done';
  static const _prefsBaselineInitializedKey = 'rt_baseline_initialized_v1';

  final ValueNotifier<int> unreadCount = ValueNotifier<int>(0);
  // Per-category unread counters
  final ValueNotifier<int> chatUnread = ValueNotifier<int>(0);
  final ValueNotifier<int> visitorUnread = ValueNotifier<int>(0);
  final ValueNotifier<int> friendUnread = ValueNotifier<int>(0);
  final ValueNotifier<int> relationUnread = ValueNotifier<int>(0);
  // Aggregate for user tab: visitor + friend + relation
  final ValueNotifier<int> userTabUnread = ValueNotifier<int>(0);

  bool _initialized = false;
  RealtimeSubscription? _subscription;
  Timer? _reconnectTimer;
  int _reconnectAttempts = 0;
  static const int _maxReconnectAttempts = 10;
  // Debounced persistence to avoid frequent disk writes on UI isolate
  SharedPreferences? _prefs;
  Timer? _flushTimer;
  bool _dirtyPending = false;
  static const Duration _flushInterval = Duration(seconds: 2);

  // Track recently seen IDs to avoid double counting when connection flaps
  final Set<String> _recentIds = <String>{};
  // Current logged-in user identifiers allowed to receive notifications
  final Set<String> _allowedUserIds = <String>{};

  Future<void> init() async {
    if (_initialized) return;
    try {
      await AppwriteConfig.init();
      // restore unread from preferences
      final prefs = await SharedPreferences.getInstance();
      _prefs = prefs;
      unreadCount.value = prefs.getInt(_prefsUnreadKey) ?? 0;
      chatUnread.value = prefs.getInt(_prefsChatUnreadKey) ?? 0;
      visitorUnread.value = prefs.getInt(_prefsVisitorUnreadKey) ?? 0;
      friendUnread.value = prefs.getInt(_prefsFriendUnreadKey) ?? 0;
      relationUnread.value = prefs.getInt(_prefsRelationUnreadKey) ?? 0;
      // One-time migration: in previous versions baseline could be written into unread.
      // Reset to zero exactly once so first launch doesn't show everything as unread.
      final migrated = prefs.getBool(_prefsMigrationKey) ?? false;
      if (!migrated) {
        chatUnread.value = 0;
        visitorUnread.value = 0;
        friendUnread.value = 0;
        relationUnread.value = 0;
        await prefs.setInt(_prefsChatUnreadKey, 0);
        await prefs.setInt(_prefsVisitorUnreadKey, 0);
        await prefs.setInt(_prefsFriendUnreadKey, 0);
        await prefs.setInt(_prefsRelationUnreadKey, 0);
        await prefs.setBool(_prefsMigrationKey, true);
        debugAppLogger.debug('[NotificationsRT] 🔄 migration v2 applied: unread reset to 0');
      }
      _recomputeUserTabUnread();

      // best-effort restore of seen ids to reduce duplicates across short restarts
      final seen = prefs.getStringList(_prefsLastSeenIdsKey) ?? const <String>[];
      _recentIds.addAll(seen.take(50));

      // Load current user identifiers for filtering (iduser and id)
      try {
        final user = await AuthService.getUserFromSharedPreferences();
        if (user != null) {
          final iduser = user.iduser.toString();
          final id = (user.id ?? '').toString();
          if (iduser.isNotEmpty) _allowedUserIds.add(iduser);
          if (id.isNotEmpty) _allowedUserIds.add(id);
          debugAppLogger.debug('[NotificationsRT] 👤 currentUserIds=$_allowedUserIds');
        } else {
          debugAppLogger.debug('[NotificationsRT] ⚠️ No current user found for filtering; will skip payloads requiring gift_sender');
        }
      } catch (e) {
        debugAppLogger.debug('[NotificationsRT] ⚠️ Failed to load current user for filtering: $e');
      }

      _subscribe();
      _initialized = true;
      debugAppLogger.debug('[NotificationsRT] ✅ Initialized with unread=${unreadCount.value}');
    } catch (e, st) {
      debugAppLogger.debug('[NotificationsRT] ❌ init error: $e');
      debugAppLogger.debug(st.toString());
      _scheduleReconnect();
    }
  }

  void _subscribe() {
    try {
      // Subscribe to the same collection used by CombinedRealtimeService
      _subscription = AppwriteConfig.subscribe([
        'databases.687d45af00221673b1c4.collections.687d45d4000515f34e76.documents',
      ]);
      debugAppLogger.debug('[NotificationsRT] 🔗 Subscribed to notifications channel');

      _subscription?.stream.listen(
        (message) {
          _reconnectAttempts = 0;
          final events = message.events;
          final data = message.payload;

          // Full logging for debugging field names
          try {
            debugAppLogger.debug('[NotificationsRT] 🔔 events=$events');
            debugAppLogger.debug('[NotificationsRT] 📦 payload=$data');
          } catch (_) {}

          // Count on create or update to be tolerant with backend behavior
          final bool isCreateOrUpdate = events.any((e) => e.contains('.create') || e.contains('.update'));
          if (!isCreateOrUpdate) return;

          final String? type = data['type']?.toString();
          final String rawMsg = (data['message'] ?? data['Massage'] ?? data['massage'] ?? data['msg'])?.toString() ?? '';
          final bool isNotifType = _matchesNotificationType(type);
          final bool hasCategory = _resolveCategoryKey(rawMsg) != null;
          if (isNotifType || hasCategory) {
            // Filter to only process notifications intended for current user (via gift_sender)
            if (!_isForCurrentUser(data)) {
              try {
                debugAppLogger.debug('[NotificationsRT] ⏭️ skip (gift_sender mismatch) gift_sender=${data['gift_sender']} allowed=$_allowedUserIds');
              } catch (_) {}
              return;
            }
            // Build a robust dedup key including id + message + updated/created timestamp
            final String baseId = (data[r'$id']?.toString() ?? '')
                .ifEmpty(() => '${data['sender']}_${rawMsg}_${DateTime.now().microsecondsSinceEpoch}');
            final String ts = (data[r'$updatedAt']?.toString() ?? data[r'$createdAt']?.toString() ?? '');
            final String dedupKey = '$baseId|$rawMsg|$ts';

            // Avoid duplicates
            if (_recentIds.contains(dedupKey)) return;
            _recentIds.add(dedupKey);
            if (_recentIds.length > 50) {
              _recentIds.remove(_recentIds.first);
            }

            // Increment unread counters according to category
            _incrementForPayload(data);

            // Extra field-level logs to help backend align key names
            try {
              final altMsg = (data['message'] ?? data['Massage'] ?? data['massage'] ?? data['msg']);
              debugAppLogger.debug('[NotificationsRT] 📨 notification: sender=${data['sender']}, message=$altMsg, timestamp=${data['timestamp']}, reciver=${data['reciver']}, room_id=${data['room_id']}, img=${data['img']}');
            } catch (_) {}
          } else {
            // If type didn't match, log more context to help backend alignment
            try {
              debugAppLogger.debug('[NotificationsRT] ⏭️ skipped type=$type, message=${data['message'] ?? data['Massage'] ?? data['massage'] ?? data['msg']}');
            } catch (_) {}
          }
        },
        onError: (e, st) {
          debugAppLogger.debug('[NotificationsRT] ❌ stream error: $e');
          _scheduleReconnect();
        },
        onDone: () {
          debugAppLogger.debug('[NotificationsRT] 🔌 stream closed');
          _scheduleReconnect();
        },
        cancelOnError: false,
      );
    } catch (e, st) {
      debugAppLogger.debug('[NotificationsRT] ❌ subscribe error: $e');
      debugAppLogger.debug(st.toString());
      _scheduleReconnect();
    }
  }

  void _incrementUnread() async {
    unreadCount.value = unreadCount.value + 1;
    debugAppLogger.debug('[NotificationsRT] 🔴 unread++ → ${unreadCount.value}');
    this._markDirty();
  }

  void _incrementForPayload(Map<String, dynamic> data) async {
    // Always increment global unread
    _incrementUnread();
    final rawMsg = (data['message'] ?? data['Massage'] ?? data['massage'] ?? data['msg'])?.toString();
    final category = _resolveCategoryKey(rawMsg);

    switch (category) {
      case 'chat':
        chatUnread.value = chatUnread.value + 1;
        debugAppLogger.debug('[NotificationsRT] ✉️ chat++ → ${chatUnread.value} (message=$rawMsg)');
        break;
      case 'visitor':
        visitorUnread.value = visitorUnread.value + 1;
        debugAppLogger.debug('[NotificationsRT] 👀 visitor++ → ${visitorUnread.value} (message=$rawMsg)');
        break;
      case 'friend':
        friendUnread.value = friendUnread.value + 1;
        debugAppLogger.debug('[NotificationsRT] 🤝 friend++ → ${friendUnread.value} (message=$rawMsg)');
        break;
      case 'relation':
        relationUnread.value = relationUnread.value + 1;
        debugAppLogger.debug('[NotificationsRT] 🧭 relation++ → ${relationUnread.value} (message=$rawMsg)');
        break;
      default:
        debugAppLogger.debug('[NotificationsRT] ⏩ Unknown message category: $rawMsg');
        break;
    }
    _recomputeUserTabUnread();
    this._markDirty();
  }

  void _recomputeUserTabUnread() {
    final total = visitorUnread.value + friendUnread.value + relationUnread.value;
    if (userTabUnread.value != total) {
      userTabUnread.value = total;
      debugAppLogger.debug('[NotificationsRT] 👤 userTabUnread = $total');
    }
  }

  // Return true only if the payload is addressed to the current logged-in user
  bool _isForCurrentUser(Map<String, dynamic> data) {
    final dynamic raw = data['gift_sender'];
    final String senderId = raw?.toString() ?? '';
    if (senderId.isEmpty) {
      // Backend sends app-wide notifications; we only accept ones with gift_sender matching current user
      return false;
    }
    return _allowedUserIds.contains(senderId);
  }

  String? _resolveCategoryKey(String? message) {
    final m = message?.trim().toLowerCase();
    if (m == null) return null;
    // chat synonyms: chat, message, massage (backend typo), msg
    if (m == 'chat' || m.contains('chat') || m == 'message' || m == 'massage' || m == 'msg') return 'chat';
    // visitors: visitor, visitorlist
    if (m.contains('visitor')) return 'visitor';
    // friend: friend, friendrequest
    if (m.contains('friend')) return 'friend';
    // relation
    if (m.contains('relation')) return 'relation';
    return null;
  }

  Future<void> markAllRead() async {
    unreadCount.value = 0;
    chatUnread.value = 0;
    visitorUnread.value = 0;
    friendUnread.value = 0;
    relationUnread.value = 0;
    _recomputeUserTabUnread();
    debugAppLogger.debug('[NotificationsRT] ✅ markAllRead');
    await this._flushNow();
  }

  Future<void> markChatRead() async {
    chatUnread.value = 0;
    debugAppLogger.debug('[NotificationsRT] ✅ markChatRead');
    await this._flushNow();
  }

  Future<void> markUserTabRead() async {
    visitorUnread.value = 0;
    friendUnread.value = 0;
    relationUnread.value = 0;
    _recomputeUserTabUnread();
    debugAppLogger.debug('[NotificationsRT] ✅ markUserTabRead');
    await this._flushNow();
  }

  Future<void> markVisitorRead() async {
    visitorUnread.value = 0;
    _recomputeUserTabUnread();
    debugAppLogger.debug('[NotificationsRT] ✅ markVisitorRead');
    await this._flushNow();
  }

  Future<void> markFriendRead() async {
    friendUnread.value = 0;
    _recomputeUserTabUnread();
    debugAppLogger.debug('[NotificationsRT] ✅ markFriendRead');
    await this._flushNow();
  }

  Future<void> markRelationRead() async {
    relationUnread.value = 0;
    _recomputeUserTabUnread();
    debugAppLogger.debug('[NotificationsRT] ✅ markRelationRead');
    await this._flushNow();
  }

  // Integrate REST baseline with unread counters to avoid losing data between sessions.
  // First baseline only stores snapshot (no unread changes). Subsequent baselines add positive deltas.
  Future<void> setBaselineCounts({int? chat, int? visitor, int? friend, int? relation}) async {
    final prefs = await SharedPreferences.getInstance();
    final bool initialized = prefs.getBool(_prefsBaselineInitializedKey) ?? false;

    final int prevChat = prefs.getInt(_prefsBaselineChatKey) ?? 0;
    final int prevVisitor = prefs.getInt(_prefsBaselineVisitorKey) ?? 0;
    final int prevFriend = prefs.getInt(_prefsBaselineFriendKey) ?? 0;
    final int prevRelation = prefs.getInt(_prefsBaselineRelationKey) ?? 0;

    final int newChat = chat ?? prevChat;
    final int newVisitor = visitor ?? prevVisitor;
    final int newFriend = friend ?? prevFriend;
    final int newRelation = relation ?? prevRelation;

    if (!initialized) {
      // First baseline: store snapshot only
      await prefs.setInt(_prefsBaselineChatKey, newChat);
      await prefs.setInt(_prefsBaselineVisitorKey, newVisitor);
      await prefs.setInt(_prefsBaselineFriendKey, newFriend);
      await prefs.setInt(_prefsBaselineRelationKey, newRelation);
      await prefs.setBool(_prefsBaselineInitializedKey, true);
      debugAppLogger.debug('[NotificationsRT] 🟢 baseline initialized (no unread changes)');
      return;
    }

    // Compute positive deltas and add to unread counters
    int dChat = newChat - prevChat; if (dChat < 0) dChat = 0;
    int dVisitor = newVisitor - prevVisitor; if (dVisitor < 0) dVisitor = 0;
    int dFriend = newFriend - prevFriend; if (dFriend < 0) dFriend = 0;
    int dRelation = newRelation - prevRelation; if (dRelation < 0) dRelation = 0;

    bool changed = false;
    if (dChat > 0) { chatUnread.value += dChat; await prefs.setInt(_prefsChatUnreadKey, chatUnread.value); changed = true; }
    if (dVisitor > 0) { visitorUnread.value += dVisitor; await prefs.setInt(_prefsVisitorUnreadKey, visitorUnread.value); changed = true; }
    if (dFriend > 0) { friendUnread.value += dFriend; await prefs.setInt(_prefsFriendUnreadKey, friendUnread.value); changed = true; }
    if (dRelation > 0) { relationUnread.value += dRelation; await prefs.setInt(_prefsRelationUnreadKey, relationUnread.value); changed = true; }
    if (changed) _recomputeUserTabUnread();

    // Update stored baseline to the latest snapshot
    await prefs.setInt(_prefsBaselineChatKey, newChat);
    await prefs.setInt(_prefsBaselineVisitorKey, newVisitor);
    await prefs.setInt(_prefsBaselineFriendKey, newFriend);
    await prefs.setInt(_prefsBaselineRelationKey, newRelation);
    debugAppLogger.debug('[NotificationsRT] 📊 baseline reconciled Δchat=$dChat Δvisitor=$dVisitor Δfriend=$dFriend Δrelation=$dRelation');
  }

  void _scheduleReconnect() {
    if (_reconnectAttempts >= _maxReconnectAttempts) return;
    _reconnectTimer?.cancel();
    final delay = Duration(seconds: (1 << _reconnectAttempts).clamp(1, 60));
    _reconnectAttempts++;
    _reconnectTimer = Timer(delay, () {
      try {
        _subscription?.close();
      } catch (_) {}
      _subscribe();
    });
  }

  bool _matchesNotificationType(String? raw) {
    final t = raw?.trim().toLowerCase();
    if (t == null) return false;
    // Accept common typo and any string containing 'notif'
    return t == 'notification' || t == 'notfication' || t.contains('notif');
  }

  // Allow external callers (e.g., UserCubit) to update the current user IDs for filtering
  void updateCurrentUserIds({String? iduser, String? id}) {
    _allowedUserIds.clear();
    if (iduser != null && iduser.isNotEmpty) {
      _allowedUserIds.add(iduser);
    }
    if (id != null && id.isNotEmpty) {
      _allowedUserIds.add(id);
    }
    try {
      debugAppLogger.debug('[NotificationsRT] 🔄 update currentUserIds=$_allowedUserIds');
    } catch (_) {}
  }

  Future<void> dispose() async {
    try {
      await _subscription?.close();
    } catch (_) {}
    _subscription = null;
    _reconnectTimer?.cancel();
    _reconnectTimer = null;
    // Ensure any pending counters are flushed once before shutdown
    try {
      await this._flushNow();
    } catch (_) {}
    _flushTimer?.cancel();
    _flushTimer = null;
    _initialized = false;
  }
}

extension _StringExt on String {
  String ifEmpty(String Function() orElse) => isEmpty ? orElse() : this;
}

/// Public helper to allow other realtime listeners to forward payloads here
/// so we can keep a single source of truth for unread count and logs.
extension NotificationRealtimeServiceExternal on NotificationRealtimeService {
  void processExternalPayload(Map<String, dynamic> data) {
    try {
      debugAppLogger.debug('[NotificationsRT] 🔄 external payload=$data');
      final String? type = data['type']?.toString();
      final String rawMsg = (data['message'] ?? data['Massage'] ?? data['massage'] ?? data['msg'])?.toString() ?? '';
      final bool isNotifType = _matchesNotificationType(type);
      final bool hasCategory = _resolveCategoryKey(rawMsg) != null;
      if (isNotifType || hasCategory) {
        // Filter to only process notifications intended for current user (via gift_sender)
        if (!_isForCurrentUser(data)) {
          try {
            debugAppLogger.debug('[NotificationsRT] ⏭️ external skip (gift_sender mismatch) gift_sender=${data['gift_sender']} allowed=$_allowedUserIds');
          } catch (_) {}
          return;
        }
        final String baseId = (data[r'$id']?.toString() ?? '')
            .ifEmpty(() => '${data['sender']}_${rawMsg}_${DateTime.now().microsecondsSinceEpoch}');
        final String ts = (data[r'$updatedAt']?.toString() ?? data[r'$createdAt']?.toString() ?? '');
        final String dedupKey = '$baseId|$rawMsg|$ts';

        if (_recentIds.contains(dedupKey)) return;
        _recentIds.add(dedupKey);
        if (_recentIds.length > 50) {
          _recentIds.remove(_recentIds.first);
        }
        _incrementForPayload(data);
      } else {
        debugAppLogger.debug('[NotificationsRT] ⏩ external skip type=$type');
      }
    } catch (e, st) {
      debugAppLogger.debug('[NotificationsRT] ❌ external process error: $e');
      debugAppLogger.debug(st.toString());
    }
  }
}
