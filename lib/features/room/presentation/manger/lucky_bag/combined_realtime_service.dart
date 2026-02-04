import 'dart:async';
import 'package:lklk/core/utils/logger.dart';
import 'dart:math' as math;

import 'package:appwrite/appwrite.dart';
import 'package:lklk/core/config/appwrite_config.dart';
import 'package:lklk/core/service_locator.dart';
import 'package:lklk/features/home/presentation/manger/top_bar_room_cubit/money_bag_top_bar_cubit.dart';
import 'package:lklk/features/home/presentation/manger/top_bar_room_cubit/top_bar_room_cubit.dart';
import 'package:lklk/features/home/presentation/manger/room_cubit/room_cubit_cubit.dart';
import 'package:lklk/features/profile_users/presentaion/manger/user_cubit/user_cubit_cubit.dart';
import 'package:lklk/features/room/domain/entities/topbar_meesage_entity.dart';
import 'package:lklk/features/room/presentation/manger/lucky_bag/luck_bag_cubit.dart';
import 'package:lklk/core/realtime/notification_realtime_service.dart';

class CombinedRealtimeService {
  RealtimeSubscription? _subscription;
  final StreamController<Map<String, dynamic>> _resultController =
      StreamController<Map<String, dynamic>>.broadcast();
  final MoneyBagTopBarCubit? moneyBagTopBarCubit;
  final TopBarRoomCubit? topBarCubit;
  final RoomCubit? roomCubit;
  final String roomID;
  // Track per-room last scheduled display end (ms) so we can chain bags
  final Map<String, int> _roomLastQueueEndMs = {};

  int _reconnectAttempts = 0;
  final int _maxReconnectAttempts = 10;
  final Duration _initialReconnectDelay = const Duration(seconds: 1);
  bool _isDisposed = false;
  Timer? _reconnectTimer;

  Stream<Map<String, dynamic>> get resultsStream => _resultController.stream;

  CombinedRealtimeService(
      {this.topBarCubit,
      this.moneyBagTopBarCubit,
      this.roomCubit,
      required this.roomID});

  /// Trigger active bags backfill on demand (e.g., after UI subscribes)
  Future<void> resyncActiveBags() async {
    if (_isDisposed) return;
    await _syncActiveBagsOnJoin();
  }

  void initRealtime() {
    if (_isDisposed) return;

    log('[CombinedRealtimeService] Subscribing to realtime for room: $roomID');

    try {
      _subscription = AppwriteConfig.subscribe([
        'databases.687d45af00221673b1c4.collections.687d45d4000515f34e76.documents'
      ]);

      _subscription?.stream.listen(
        (response) {
          _reconnectAttempts = 0;
          log('[CombinedRealtimeService] 🔔 Received response: ${response.events}');

          final hasCreateOrUpdate = response.events.any((event) => event.contains('.create') || event.contains('.update'));
          if (hasCreateOrUpdate) {
            final data = response.payload;
            final type = data['type'];
            final sender = data['sender'].toString();

            log('[CombinedRealtimeService] 📦 Payload data: $data');

            // Forward to NotificationRealtimeService for unified badge counting.
            // Safe with dedup: the service ignores duplicates via its _recentIds.
            try {
              NotificationRealtimeService.instance.processExternalPayload(
                Map<String, dynamic>.from(data),
              );
            } catch (_) {}

            // Handle admin messages (sender == '0101' || sender == '101')
            if (sender == '0101' || sender == '101') {
              _handleAdminMessage(data, type, sender);
            }
            // Handle money bag messages
            else if (type == 'money_bag_result' || type == 'money_bag') {
              _handleMoneyBagMessage(data, type, sender);
            }
            // Handle other top bar messages
            else if (type == 'huge_gift_recive' || type == 'huge_game_recive' || type == 'huge_luck_recive') {
              _handleTopBarMessage(data, type, sender);
            } else {
              log('[CombinedRealtimeService] ⏩ Skipping type: $type, sender: $sender');
            }
          }
        },
        onError: (e, stackTrace) {
          log('[CombinedRealtimeService] ❌ Realtime error: $e',
              error: e, stackTrace: stackTrace);
          _reconnectWithDelay();
        },
        onDone: () {
          log('[CombinedRealtimeService] 🔌 Connection closed, reconnecting...');
          _reconnectWithDelay();
        },
        cancelOnError: false,
      );
    } catch (e, stackTrace) {
      log('[CombinedRealtimeService] ❌ Failed to subscribe: $e',
          error: e, stackTrace: stackTrace);
      _reconnectWithDelay();
    }

    // Backfill currently active bags so late joiners can see the button immediately
    _syncActiveBagsOnJoin();
  }

  /// One-time sync for late joiners: fetch recent money_bag docs for this room
  /// and emit any still-active bags so the UI button appears immediately.
  Future<void> _syncActiveBagsOnJoin() async {
    try {
      // Ensure Appwrite is initialized (safe if already initialized)
      await AppwriteConfig.init();

      final db = AppwriteConfig.databases;
      if (db == null) {
        log('[CombinedRealtimeService] ❌ Databases client not initialized; cannot backfill');
        return;
      }

      log('[CombinedRealtimeService] 🔎 Backfilling active bags for room $roomID');

      final resp = await db.listDocuments(
        databaseId: '687d45af00221673b1c4',
        collectionId: '687d45d4000515f34e76',
        queries: [
          Query.equal('type', 'money_bag'),
          Query.equal('room_id', roomID),
          Query.orderDesc(r'$createdAt'),
          Query.limit(5),
        ],
      );

      final nowMs = DateTime.now().millisecondsSinceEpoch;
      for (final doc in resp.documents) {
        final data = Map<String, dynamic>.from(doc.data);

        // Normalize required fields
        data['type'] = data['type'] ?? 'money_bag';
        data['room_id'] = (data['room_id'] ?? roomID).toString();

        // Compute createdAt (ms) from custom or meta field
        final rawCreated =
            data['createdAt'] ?? data['timestamp'] ?? doc.data[r'$createdAt'];
        int createdAtMs = nowMs;
        if (rawCreated is int) {
          createdAtMs =
              rawCreated < 100000000000 ? rawCreated * 1000 : rawCreated;
        } else if (rawCreated is String) {
          final parsedInt = int.tryParse(rawCreated);
          if (parsedInt != null) {
            createdAtMs =
                parsedInt < 100000000000 ? parsedInt * 1000 : parsedInt;
          } else {
            try {
              createdAtMs = DateTime.parse(rawCreated).millisecondsSinceEpoch;
            } catch (_) {}
          }
        }

        // Skip expired bags
        final naturalEnd = createdAtMs + (17 * 1000);
        if (naturalEnd <= nowMs) {
          continue;
        }

        // Assign a display window consistent with realtime scheduling
        final lastEnd = _roomLastQueueEndMs[roomID] ?? 0;
        final startMs = createdAtMs > lastEnd ? createdAtMs : lastEnd;
        final endMs = startMs + (17 * 1000);
        _roomLastQueueEndMs[roomID] = endMs;

        data['createdAt'] = createdAtMs;
        data['_displayStartAt'] = startMs;
        data['_displayEndAt'] = endMs;

        log('[CombinedRealtimeService] 📥 Backfilled bag ${data[r'$id']} (start: ${DateTime.fromMillisecondsSinceEpoch(startMs)}, end: ${DateTime.fromMillisecondsSinceEpoch(endMs)})');

        // Emit to UI so MoneyBagButton can show immediately
        _resultController.add(data);

        // Ensure Cubit session exists for this bag (to collect users / timing)
        final luckBagCubit = sl<LuckBagCubit>();
        final bagId = data[r'$id']?.toString();
        if (bagId != null &&
            luckBagCubit.manager.findSession(roomID, bagId) == null) {
          luckBagCubit.handleMoneyBag(data);
        }
      }
    } catch (e, st) {
      log('[CombinedRealtimeService] ❌ Backfill error: $e',
          error: e, stackTrace: st);
    }
  }

  void _handleAdminMessage(
      Map<String, dynamic> data, String type, String sender) async {
    try {
      log('[CombinedRealtimeService] 🔄 Admin update for room: $roomID');

      if (roomCubit != null) {
        roomCubit!.refreshRoomData(int.parse(roomID));
        final UserCubit userCubit = sl<UserCubit>();
        await userCubit.getProfileUser("CombinedRealtimeService");
        roomCubit?.refreshAllUsersInRoom(roomID);
      }
    } catch (e, stackTrace) {
      log('[CombinedRealtimeService] ❌ Error handling admin message: $e',
          error: e, stackTrace: stackTrace);
    }
  }

  void _handleMoneyBagMessage(
      Map<String, dynamic> data, String type, String sender) {
    try {
      log('[CombinedRealtimeService] 💰 Money bag message detected: $type');

      // Ensure room_id is a string
      if (data.containsKey('room_id')) {
        data['room_id'] = data['room_id'].toString();
      } else {
        log('[CombinedRealtimeService] ❌ Missing room_id in payload');
        return;
      }

      // Normalize createdAt
      if (!data.containsKey('createdAt')) {
        data['createdAt'] = DateTime.now().millisecondsSinceEpoch;
      } else {
        final created = data['createdAt'];
        if (created is String) {
          data['createdAt'] =
              int.tryParse(created) ?? DateTime.now().millisecondsSinceEpoch;
        } else if (created is int) {
          data['createdAt'] =
              (created < 100000000000) ? created * 1000 : created;
        }
      }

      final luckBagCubit = sl<LuckBagCubit>();
      final roomId = data['room_id'].toString();
      String? bagId;

      if (type == 'money_bag') {
        bagId = data[r'$id']?.toString();
        log('[CombinedRealtimeService] 📥 New money_bag detected → bagId: $bagId, roomId: $roomId');

        // Ensure display scheduling is consistent across clients
        final createdAt =
            data['createdAt'] as int? ?? DateTime.now().millisecondsSinceEpoch;
        final lastEnd = _roomLastQueueEndMs[roomId] ?? 0;
        final startMs = createdAt > lastEnd ? createdAt : lastEnd;
        final endMs = startMs + (17 * 1000);
        data['_displayStartAt'] = startMs;
        data['_displayEndAt'] = endMs;
        _roomLastQueueEndMs[roomId] = endMs;
        log('[CombinedRealtimeService] ⏱ Scheduled display window for bag $bagId in room $roomId → start:${DateTime.fromMillisecondsSinceEpoch(startMs)} end:${DateTime.fromMillisecondsSinceEpoch(endMs)}');

        // TopBar message
        if (moneyBagTopBarCubit != null) {
          final message = TopBarMessageEntity.fromMap(data);
          moneyBagTopBarCubit!.updateTopBar(message);
          log('[CombinedRealtimeService] 🚀 TopBar updated with bag $bagId');
        }

        // Emit annotated event to listeners so UI receives the display window
        _resultController.add(data);

        if (bagId != null && bagId.isNotEmpty && roomId.isNotEmpty) {
          final existingSession =
              luckBagCubit.manager.findSession(roomId, bagId);
          if (existingSession == null) {
            log('[CombinedRealtimeService] 🎯 Forwarding money_bag → LuckBagCubit');
            luckBagCubit.handleMoneyBag(data);
          } else {
            log('[CombinedRealtimeService] ⚠️ Skipping duplicate money_bag: $bagId');
          }
        }
      } else if (type == 'money_bag_result') {
        bagId = data['gift_id']?.toString();
        log('[CombinedRealtimeService] 📥 money_bag_result detected → bagId: $bagId, roomId: $roomId');

        // Emit result to listeners first so UI/dialog can react
        _resultController.add(data);

        if (bagId != null && bagId.isNotEmpty && roomId.isNotEmpty) {
          log('[CombinedRealtimeService] 🎯 Forwarding money_bag_result → LuckBagCubit');
          luckBagCubit.handleMoneyBag(data);
        }
      }
    } catch (e, st) {
      log('[CombinedRealtimeService] ❌ Error handling money bag message: $e',
          error: e, stackTrace: st);
    }
  }

  void _handleTopBarMessage(
      Map<String, dynamic> data, String type, String sender) {
    try {
      // Handle top bar display messages
      if (topBarCubit != null) {
        final message = TopBarMessageEntity.fromMap(data);
        log('[CombinedRealtimeService] 🚀 Adding top bar message to queue: ${message.id} → ${message.message}');
        topBarCubit!.updateTopBar(message); // تم إزالة تمرير المدة
      }
    } catch (e, stackTrace) {
      log('[CombinedRealtimeService] ❌ Error handling top bar message: $e',
          error: e, stackTrace: stackTrace);
    }
  }

  void _reconnectWithDelay() {
    if (_isDisposed || _reconnectAttempts >= _maxReconnectAttempts) {
      log('[CombinedRealtimeService] 🛑 Max reconnection attempts reached or service disposed.');
      return;
    }

    // Cancel any pending reconnect timer
    _reconnectTimer?.cancel();

    // زيادة التأخير بشكل أسي مع كل محاولة إعادة اتصال فاشلة
    final delay = Duration(
        seconds: math.min(
            60,
            _initialReconnectDelay.inSeconds *
                math.pow(2, _reconnectAttempts).toInt()));
    log('[CombinedRealtimeService] ⏳ Attempting to reconnect in ${delay.inSeconds} seconds (attempt ${_reconnectAttempts + 1}/$_maxReconnectAttempts)...');

    _reconnectTimer = Timer(delay, () {
      if (!_isDisposed) {
        _reconnectAttempts++;

        // Close existing subscription before creating new one
        _subscription?.close();
        _subscription = null;

        initRealtime();
      }
    });
  }

  void dispose() {
    _isDisposed = true;
    _reconnectTimer?.cancel();
    _subscription?.close();
    _resultController.close();
    log('[CombinedRealtimeService] 🚮 Service disposed');
  }
}
