import 'dart:async';
import 'dart:convert';
import 'dart:collection';

import 'package:auto_size_text/auto_size_text.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:focused_menu_custom/focused_menu.dart';
import 'package:focused_menu_custom/modals.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:lklk/core/animations/animation_slide_transition_widget.dart';
import 'package:lklk/core/constants/app_colors.dart';
import 'package:lklk/core/constants/assets.dart';
import 'package:lklk/core/player/svga_custom_player.dart';
import 'package:lklk/core/service_locator.dart';
import 'package:lklk/core/services/auth_service.dart';
import 'package:lklk/core/utils/functions/snackbar_helper.dart';
import 'package:lklk/core/utils/logger.dart';

import 'package:lklk/features/auth/domain/entities/user_entity.dart';
import 'package:lklk/features/home/presentation/manger/room_cubit/room_cubit_cubit.dart';
import 'package:lklk/features/home/presentation/manger/top_bar_room_cubit/money_bag_top_bar_cubit.dart';
import 'package:lklk/features/home/presentation/manger/top_bar_room_cubit/top_bar_room_cubit.dart';
import 'package:lklk/features/profile_users/presentaion/manger/user_cubit/user_cubit_cubit.dart';
import 'package:lklk/features/room/domain/entities/room_entity.dart';
import 'package:lklk/features/room/presentation/manger/lucky_bag/combined_realtime_service.dart';
import 'package:lklk/features/room/presentation/manger/lucky_bag/luck_bag_cubit.dart';
import 'package:lklk/features/room/presentation/views/widgets/enter_message_room_v_i_p_body.dart';
import 'package:lklk/features/room/presentation/views/widgets/lucky_message_item.dart';
import 'package:lklk/features/room/presentation/views/widgets/message_item_gifts_widget.dart';
import 'package:lklk/features/room/presentation/views/widgets/message_item_v_i_p_widget.dart';
import 'package:lklk/features/room/presentation/views/widgets/message_item_widget.dart';
import 'package:lklk/features/room/presentation/views/widgets/money_bag_button.dart';
import 'package:lklk/features/room/presentation/views/widgets/user_v_i_p_bottom_sheet_widget.dart';
import 'package:lklk/features/room/presentation/views/widgets/optimized_message_manager.dart';
import 'package:lklk/generated/l10n.dart';
import 'package:lklk/zego_sdk_manager.dart';

// عنصر تمثيلي لواجهة دخول نشطة (Top-level)
class _EntryOverlayItem {
  final int id;
  final String userName;
  final int vipLevel;
  final String text;
  Timer? timer;
  _EntryOverlayItem({
    required this.id,
    required this.userName,
    required this.vipLevel,
    required this.text,
  });
}

class ChatSection extends StatefulWidget {
  final RoomEntity room;
  final ZegoLiveAudioRoomRole role;
  final bool? fromOverlay;
  final RoomCubit roomCubit;
  final UserCubit userCubit;
  final String roomID;
  final void Function(ZIMMessage) onSend;
  final LuckBagCubit luckBagCubit;
  const ChatSection({
    super.key,
    required this.room,
    required this.role,
    this.fromOverlay,
    required this.roomCubit,
    required this.userCubit,
    required this.roomID,
    required this.onSend,
    required this.luckBagCubit,
  });

  @override
  State<ChatSection> createState() => _ChatSectionState();
}

class _ChatSectionState extends State<ChatSection> {
  late ScrollController _scrollController;
  bool _isFetchingUserProfile = false;
  int? _lastDeleteMessageId;
  late CombinedRealtimeService moneyBagResultService;
  final luckBagCubit = sl<LuckBagCubit>();
  final Set<String> _recentlyHandledBags = {};
  // Cache parsed extendedData to avoid repeated jsonDecode on same messages
  final Map<int, Map<String, dynamic>> _parsedBarrageCache = {};
  // Defer heavy UI (player, buttons) until after first frame for faster first paint
  bool _deferHeavyUi = true;
  // Adjustable delay (ms) before showing heavy UI after first frame
  static const int _heavyUiDelayMs = 300; // تقليل التأخير لتحسين السرعة

  // اشتراك رسائل ZIM لتغذية OptimizedMessageManager
  StreamSubscription<List<ZIMMessage>>? _zimMsgSub;

  // متغيرات للتحكم في التمرير التلقائي
  bool _userIsScrolling = false;
  bool _autoScrollEnabled = true;
  Timer? _scrollResetTimer;
  static const Duration _scrollResetDelay = Duration(seconds: 3);

  // إعدادات حركة التمرير البطيئة والسلسة
  bool _isAnimatingScroll = false;
  static const Curve _slowScrollCurve = Curves.easeInOutCubicEmphasized;
  static const double _scrollSpeedPxPerSec =
      120.0; // سرعة ثابتة أبطأ بكثير (px/second)
  static const int _minScrollDurationMs = 2500; // حد أدنى أطول لإبراز الحركة
  bool _pendingAutoScroll =
      false; // لجدولة تمرير لاحق إن وصلت رسائل أثناء الحركة

  // استخدام OptimizedMessageManager بدلاً من RoomMessagesStore
  late OptimizedMessageManager _messageManager;
  // مدة عرض واجهة رسالة الدخول (ms)
  static const int _entryUiDurationMs = 6000; // مدة ثابتة 5.5 ثوانٍ لكل مستخدم
  // نافذة منع تكرار عرض دخول لنفس المستخدم (ms)
  static const int _entryDedupWindowMs = 6000;
  // تتبع المعروض حالياً + المعرّفات التي تمت معالجتها لتجنّب التكرار
  final List<_EntryOverlayItem> _activeEntryOverlays = [];
  final ValueNotifier<List<_EntryOverlayItem>> _activeEntryOverlaysNotifier =
      ValueNotifier<List<_EntryOverlayItem>>(<_EntryOverlayItem>[]);
  // نستخدم مفتاحاً قائماً على المحتوى لتفادي مشكلة messageID == 0
  final Set<String> _seenEntryMessageKeys = {};
  // قائمة انتظار كي نعرض واجهات الدخول بالتتالي
  final Queue<_EntryOverlayItem> _overlayQueue = Queue<_EntryOverlayItem>();
  bool _isShowingEntry = false;
  // تتبع الرسائل التي تم تشغيل أنيميشن ظهورها حتى لا يُعاد تشغيله
  final Set<String> _animatedMessageKeys = {};
  // حفظ مفاتيح واجهات الدخول التي تم عرضها بالفعل (عبر دورات البناء/الاسترجاع)
  static final Set<String> _displayedEntryOverlayKeys = <String>{};
  // حفظ نصوص واجهات الدخول المعروضة لكل غرفة لمنع إعادة عرض آخر عنصر بعد الاسترجاع
  static final Set<String> _displayedEntryOverlayTextsByRoom = <String>{};
  // تتبع آخر وقت عرض دخول لكل مستخدم لمنع التكرار القصير الذي يزيد الزمن الظاهر
  final Map<String, int> _lastEntryShownAtMs = <String, int>{};

  @override
  void initState() {
    super.initState();
    _scrollController = ScrollController();

    // تهيئة OptimizedMessageManager
    _messageManager = OptimizedMessageManager.instance;
    _messageManager.initializeForRoom(widget.roomID);
    // راقب أي تحديثات على الرسائل لإضافة رسائل الدخول (entry) الجديدة إلى قائمة العرض
    // هذا يضمن ظهور واجهات الدخول فور وصولها، وليس فقط عند التشغيل الأول
    _messageManager.addListener(_onMessageManagerUpdated);
    // ملاحظة: لا نقوم بمسح الرسائل هنا حتى لا تختفي رسائل الدخول المبكرة
    // RoomViewBody هو المسؤول عن إعادة التهيئة عند تبديل الغرفة

    // إضافة مستمع للتمرير لتتبع تفاعل المستخدم
    _scrollController.addListener(_onScrollChanged);

    moneyBagResultService = CombinedRealtimeService(
      moneyBagTopBarCubit: context.read<MoneyBagTopBarCubit>(),
      topBarCubit: context.read<TopBarRoomCubit>(),
      roomCubit: widget.roomCubit,
      roomID: widget.roomID,
    );
    moneyBagResultService.initRealtime();
    // لا حاجة لمؤقت دوري؛ كل عنصر يملك مؤقته الخاص للإزالة بعد 6 ثوانٍ
    // قم بالمزامنة مبدئياً دائماً لالتقاط الرسائل الحالية (الفلترة بالتكرار تمنع الإعادة)
    _syncEntryOverlays();
    // Defer heavy UI to improve first frame time
    WidgetsBinding.instance.addPostFrameCallback((_) async {
      await Future.delayed(Duration(milliseconds: _heavyUiDelayMs));
      if (mounted) setState(() => _deferHeavyUi = false);
    });

    // الاستماع لرسائل ZIM وإضافتها إلى OptimizedMessageManager للغرفة الحالية
    _zimMsgSub = ZIMService.instance.onRoomMessageReceivedStreamCtrl.stream
        .listen((List<ZIMMessage> list) {
      if (!mounted) return;
      for (final m in list) {
        _messageManager.addMessage(widget.roomID, m);
      }
    });
  }

  @override
  void dispose() {
    _scrollController.removeListener(_onScrollChanged);
    _scrollController.dispose();
    _scrollResetTimer?.cancel();
    moneyBagResultService.dispose();
    _zimMsgSub?.cancel();
    // أزل المستمع من مدير الرسائل لتفادي التسريبات
    _messageManager.removeListener(_onMessageManagerUpdated);
    // ألغِ كل مؤقتات العناصر النشطة
    for (final it in _activeEntryOverlays) {
      it.timer?.cancel();
    }
    _activeEntryOverlaysNotifier.dispose();
    _parsedBarrageCache.clear();
    _overlayQueue.clear();
    _isShowingEntry = false;
    super.dispose();
  }

  /// معالج تغيير التمرير لتتبع تفاعل المستخدم
  void _onScrollChanged() {
    if (!mounted) return;
    // تجاهل التمرير الناتج عن الأنيميشن نفسه حتى لا نعطّل التمرير التلقائي بالخطأ
    if (_isAnimatingScroll) return;

    // تحديد ما إذا كان المستخدم يتمرر يدوياً
    final isAtBottom = _scrollController.position.pixels <= 50.0;

    if (!isAtBottom && _autoScrollEnabled) {
      // المستخدم يتمرر للأعلى، أوقف التمرير التلقائي مؤقتاً
      _userIsScrolling = true;
      _autoScrollEnabled = false;

      // إعادة تفعيل التمرير التلقائي بعد فترة من عدم النشاط
      _scrollResetTimer?.cancel();
      _scrollResetTimer = Timer(_scrollResetDelay, () {
        if (mounted) {
          _userIsScrolling = false;
          _autoScrollEnabled = true;
        }
      });
    } else if (isAtBottom && !_autoScrollEnabled) {
      // المستخدم عاد للأسفل، أعد تفعيل التمرير التلقائي
      _userIsScrolling = false;
      _autoScrollEnabled = true;
      _scrollResetTimer?.cancel();
    }
  }

  /// التمرير التلقائي للأسفل عند وصول رسالة جديدة (انيميشن بطيء وسلس)
  void _autoScrollToBottom() {
    if (!mounted || !_autoScrollEnabled || _userIsScrolling) return;
    if (_isAnimatingScroll) {
      // إذا كانت هناك حركة جارية، نحدد علماً لنعيد الحركة بعد انتهائها
      _pendingAutoScroll = true;
      return;
    }

    // تأخير بسيط جداً لضمان إضافة الرسالة للقائمة قبل بدء التمرير
    Future.delayed(const Duration(milliseconds: 50), () {
      if (!mounted || !_scrollController.hasClients) return;

      WidgetsBinding.instance.addPostFrameCallback((_) {
        if (!mounted || !_scrollController.hasClients) return;
        // بدأنا حركة جديدة، امسح انتظار سابق
        _pendingAutoScroll = false;

        // المسافة الحالية من الأسفل (مع reverse: true، الأسفل = 0.0)
        final double distance = _scrollController.position.pixels;

        // دالة مساعدة لحساب مدة ثابتة السرعة مع حد أدنى
        int durationMsFor(double px) {
          final ms = (1000.0 * (px / _scrollSpeedPxPerSec)).round();
          return ms < _minScrollDurationMs ? _minScrollDurationMs : ms;
        }

        // حركة باتجاه الأسفل بسرعة ثابتة وواضحة في جميع الحالات
        final Duration duration =
            Duration(milliseconds: durationMsFor(distance));

        _isAnimatingScroll = true;
        _scrollController
            .animateTo(
          0.0,
          duration: duration,
          curve: _slowScrollCurve,
        )
            .whenComplete(() {
          if (mounted) {
            _isAnimatingScroll = false;
            if (_pendingAutoScroll) {
              _pendingAutoScroll = false;
              _autoScrollToBottom();
            }
          }
        });
      });
    });
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.end,
      children: [
        Expanded(
          child: Stack(
            children: [
              Positioned.fill(child: _buildMessageList()),
              Align(
                alignment: Alignment.topRight,
                child: IgnorePointer(child: _buildEntryOverlays()),
              ),
              // if (!_deferHeavyUi)
              //   Positioned(
              //     left: -10,
              //     top: 0,
              //     child: RepaintBoundary(
              //       child: SizedBox(
              //         height: 240.h,
              //         width: 220.w,
              //         child: PlayerRoom(
              //           fromOverlay: widget.fromOverlay ?? false,
              //         ),
              //       ),
              //     ),
              //   ),
              if (!_deferHeavyUi)
                Positioned(
                  left: 0,
                  bottom: 90.h,
                  child: MoneyBagButton(
                    key: ValueKey(widget.roomID),
                    resultService: moneyBagResultService,
                    onSendMessage: widget.onSend,
                    isVisible: true,
                    currentRoomId: widget.roomID,
                  ),
                ),
            ],
          ),
        ),
      ],
    );
  }

  // هل نحن قريبون من أسفل القائمة لاعتبار الرسائل الجديدة ضمن سيناريو "الظهور من الأسفل"؟
  bool _isNearBottom() {
    if (!_scrollController.hasClients) return false;
    return _scrollController.position.pixels <= 4.0;
  }

  // مفتاح فريد للرسالة حتى مع messageID == 0 لبعض رسائل النظام/المحلية
  String _messageUniqueKey(ZIMMessage m) {
    if (m.messageID != 0) return 'id:${m.messageID}';
    if (m is ZIMBarrageMessage) {
      return 'id0:${m.extendedData.hashCode}:${m.message.hashCode}';
    }
    return 'hash:${m.hashCode}';
  }

  // لف الرسالة بأنيميشن ظهور بطيء من الأسفل عندما نكون عند نهاية القائمة
  Widget _wrapWithAppearAnimation(ZIMMessage m, Widget child) {
    final String key = _messageUniqueKey(m);

    // تحقق إذا كانت الرسالة من نوع lucky_bag
    bool isLuckyBag = false;
    try {
      if (m is ZIMBarrageMessage && m.extendedData.isNotEmpty) {
        final data = jsonDecode(m.extendedData);
        isLuckyBag = data["gift_type"] == "lucky_bag";
      }
    } catch (_) {}

    // تحقق من الشروط
    final bool isNear = _isNearBottom();
    final bool autoEnabled = _autoScrollEnabled;

    // فعّل الأنيميشن دائماً لرسائل lucky_bag، أو إذا كنا عند الأسفل للرسائل الأخرى
    final bool shouldAnimate = isLuckyBag || (autoEnabled && isNear);

    // Debug log
    try {
      if (isLuckyBag) {
        dlog(
            '[Animation] lucky_bag: shouldAnimate=$shouldAnimate, isNear=$isNear, autoEnabled=$autoEnabled, key=$key, alreadyAnimated=${_animatedMessageKeys.contains(key)}');
      }
    } catch (_) {}

    if (!shouldAnimate) return child;
    if (_animatedMessageKeys.contains(key)) return child;
    _animatedMessageKeys.add(key);

    try {
      if (isLuckyBag) {
        dlog('[Animation] ✅ Applying animation to lucky_bag key=$key');
      }
    } catch (_) {}

    // أنيميشن بطيء: الرسالة مخفية تماماً أسفل الشاشة ثم تظهر تدريجياً
    return TweenAnimationBuilder<double>(
      tween: Tween<double>(begin: 0.0, end: 1.0),
      duration: const Duration(milliseconds: 2800),
      curve: _slowScrollCurve,
      builder: (context, t, _) {
        // الرسالة تبدأ مخفية تماماً (heightFactor = 0) ثم تظهر تدريجياً
        return ClipRect(
          child: Align(
            alignment: Alignment.topCenter,
            heightFactor: t, // من 0.0 (مخفية) إلى 1.0 (ظاهرة بالكامل)
            child: Opacity(
              opacity: 0.3 + (t * 0.7), // تلاشي خفيف من 0.3 إلى 1.0
              child: child,
            ),
          ),
        );
      },
    );
  }

  @override
  void didUpdateWidget(covariant ChatSection oldWidget) {
    super.didUpdateWidget(oldWidget);
    // Resync overlays when room changes
    if (oldWidget.roomID != widget.roomID) {
      // إعادة تهيئة خدمة Appwrite للغرفة الجديدة لضمان backfill فوري
      try {
        moneyBagResultService.dispose();
      } catch (_) {}
      moneyBagResultService = CombinedRealtimeService(
        moneyBagTopBarCubit: context.read<MoneyBagTopBarCubit>(),
        topBarCubit: context.read<TopBarRoomCubit>(),
        roomCubit: widget.roomCubit,
        roomID: widget.roomID,
      );
      moneyBagResultService.initRealtime();

      _messageManager.initializeForRoom(widget.roomID);
      // إعادة تهيئة حالة واجهات الدخول عند تغيير الغرفة
      _seenEntryMessageKeys.clear();
      _overlayQueue.clear();
      _activeEntryOverlays.clear();
      _activeEntryOverlaysNotifier.value = const <_EntryOverlayItem>[];
      _isShowingEntry = false;
      _syncEntryOverlays();
    }
  }

  Widget _buildMessageList() {
    return AnimatedBuilder(
      animation: _messageManager,
      builder: (context, _) {
        final messages = _messageManager.messages;
        if (messages.isEmpty) {
          return const SizedBox();
        }

        // إنشاء نسخة محلية من القائمة لتجنب التغييرات أثناء البناء
        final messagesCopy = List<ZIMMessage>.from(messages);

        // تفعيل التمرير التلقائي عند وصول رسائل جديدة
        WidgetsBinding.instance.addPostFrameCallback((_) {
          _autoScrollToBottom();
        });

        return ListView.builder(
          controller: _scrollController,
          reverse: true,
          addAutomaticKeepAlives: false,
          addRepaintBoundaries: true,
          addSemanticIndexes: false,
          physics: const ClampingScrollPhysics(), // تحسين سلوك التمرير
          itemCount: messagesCopy.length,
          itemBuilder: (context, index) {
            // فحص أمان لتجنب RangeError عند تغيير القائمة أثناء البناء
            if (index >= messagesCopy.length) {
              return const SizedBox();
            }
            final message = messagesCopy[index];
            return RepaintBoundary(
              // تحسين الأداء
              child: KeyedSubtree(
                key: ValueKey(_messageUniqueKey(message)),
                child: _wrapWithAppearAnimation(
                  message,
                  _buildMessageItem(message) ?? const SizedBox(),
                ),
              ),
            );
          },
        );
      },
    );
  }

  // ignore: unused_element
  Widget _buildEntryList(List<ZIMBarrageMessage> entryMessages) {
    return const SizedBox.shrink();
  }

  // مزامنة الرسائل مع قائمة انتظار واجهات الدخول
  void _syncEntryOverlays() {
    final messages = _messageManager.messages;
    try {
      dlog(
          '[EntryOverlay] sync start: total=${messages.length}, seen=${_seenEntryMessageKeys.length}');
    } catch (_) {}
    for (final m in messages.whereType<ZIMBarrageMessage>()) {
      try {
        if (m.extendedData.isEmpty) continue;
        final data = jsonDecode(m.extendedData);
        if (data['gift_type'] != 'entry') continue;

        // اصنع مفتاحاً فريداً حتى لو كان messageID == 0
        final String baseKey = m.messageID != 0
            ? 'id:${m.messageID}'
            : 'id0:${m.extendedData.hashCode}:${m.message.hashCode}';
        final String roomScopedKey = '${widget.roomID}:$baseKey';

        // استخرج معرف المستخدم لنوافذ منع التكرار
        final String entryUserId = data['UserID']?.toString() ?? '';

        // في حالة العودة من التصغير: فلترة صارمة (≤ 1 ثانية) بناءً على extendedData.dateTime أولاً
        if ((widget.fromOverlay ?? false)) {
          final now = DateTime.now();
          bool tooOld = false;
          try {
            final String? dtStr = data['dateTime']?.toString();
            if (dtStr != null && dtStr.isNotEmpty) {
              final DateTime dt = DateTime.tryParse(dtStr)?.toLocal() ?? now;
              if (now.difference(dt).inMilliseconds > 1000) {
                tooOld = true;
              }
            } else if (m.timestamp > 0) {
              final int diffMs = now.millisecondsSinceEpoch - m.timestamp;
              if (diffMs > 1000) tooOld = true;
            } else {
              // بدون أي طابع وقت موثوق، لا نكرر عرض الرسالة عند الاسترجاع
              tooOld = true;
            }
          } catch (_) {
            tooOld = true;
          }

          if (tooOld) {
            _seenEntryMessageKeys.add(baseKey);
            try {
              dlog('[EntryOverlay] skipped old(>1s) entry on restore: ${data['UserName']?.toString() ?? 'unknown'}');
            } catch (_) {}
            continue;
          }

          // لا تعيد عرض رسائل تم عرضها سابقاً في نفس الجلسة
          if (_displayedEntryOverlayKeys.contains(roomScopedKey)) {
            _seenEntryMessageKeys.add(baseKey);
            try {
              dlog('[EntryOverlay] dedup across overlays: $roomScopedKey');
            } catch (_) {}
            continue;
          }

          // كذلك لا تعرض شريط دخول المستخدم الحالي عند الاسترجاع
          final String currentUserId = ZEGOSDKManager().currentUser?.iduser ?? '';
          if (currentUserId.isNotEmpty && entryUserId == currentUserId) {
            _seenEntryMessageKeys.add(baseKey);
            try {
              dlog('[EntryOverlay] suppressed own entry on overlay restore: $entryUserId');
            } catch (_) {}
            continue;
          }
        }

        // نافذة منع التكرار القصير لنفس المستخدم في نفس الغرفة لمنع الشعور بزمن عرض أطول
        final String dedupKey = '${widget.roomID}:${entryUserId.isNotEmpty ? entryUserId : (data['UserName']?.toString() ?? '')}';
        final int nowMs = DateTime.now().millisecondsSinceEpoch;
        final int lastMs = _lastEntryShownAtMs[dedupKey] ?? 0;
        if (lastMs > 0 && (nowMs - lastMs) < _entryDedupWindowMs) {
          try {
            dlog('[EntryOverlay] dedup within ${_entryDedupWindowMs}ms for user=$dedupKey');
          } catch (_) {}
          _seenEntryMessageKeys.add(baseKey);
          continue;
        }
        _lastEntryShownAtMs[dedupKey] = nowMs;

        if (_seenEntryMessageKeys.contains(baseKey)) continue;
        _seenEntryMessageKeys.add(baseKey);

        final userName = data['UserName']?.toString() ?? '';
        final vip = data['UserVipLevel'] is int
            ? (data['UserVipLevel'] as int)
            : int.tryParse(data['UserVipLevel']?.toString() ?? '') ?? 0;
        final int syntheticId = m.messageID != 0
            ? m.messageID
            : (m.extendedData.hashCode ^ m.message.hashCode);
        final item = _EntryOverlayItem(
          id: syntheticId,
          userName: userName,
          vipLevel: vip,
          text: m.message,
        );
        _overlayQueue.add(item);
        // علّم المفتاح كمعروض لمنع الإعادة عند أي استرجاع لاحق
        _displayedEntryOverlayKeys.add(roomScopedKey);
        try {
          dlog('[EntryOverlay] queued key=$baseKey, room=${widget.roomID}, user=$userName, vip=$vip, queueLen=${_overlayQueue.length}');
        } catch (_) {}
      } catch (e, st) {
        try {
          dlog('[EntryOverlay] parse error for message id=${m.messageID}: $e',
              error: e, stackTrace: st);
        } catch (_) {}
        // تجاهل الرسائل غير القابلة للبارس
      }
    }
    _tryShowNextEntry();
  }

  // يتم استدعاؤها كلما تغيرت قائمة الرسائل في OptimizedMessageManager
  void _onMessageManagerUpdated() {
    // امسح الرسائل الجديدة بحثاً عن رسائل دخول لم تتم معالجتها بعد
    // آمن بفضل _seenEntryMessageIds لمنع التكرار
    _syncEntryOverlays();
  }

  void _tryShowNextEntry() {
    if (!mounted) return;
    if (_isShowingEntry) return;
    if (_overlayQueue.isEmpty) {
      // لا يوجد عناصر لعرضها
      return;
    }
    _isShowingEntry = true;
    final item = _overlayQueue.removeFirst();

    // في حالة العودة من التصغير: لا تعيد عرض نفس النص الذي تم عرضه سابقاً لهذه الغرفة
    if ((widget.fromOverlay ?? false)) {
      final textKey = '${widget.roomID}:${item.text}';
      if (_displayedEntryOverlayTextsByRoom.contains(textKey)) {
        try {
          dlog('[EntryOverlay] skip duplicate by text on restore: $textKey');
        } catch (_) {}
        _isShowingEntry = false;
        // جرب العنصر التالي مباشرة
        scheduleMicrotask(_tryShowNextEntry);
        return;
      }
      _displayedEntryOverlayTextsByRoom.add(textKey);
    }
    try {
      dlog(
          '[EntryOverlay] show id=${item.id}, name=${item.userName}, vip=${item.vipLevel}');
    } catch (_) {}
    _activeEntryOverlays
      ..clear()
      ..add(item);
    _activeEntryOverlaysNotifier.value = List<_EntryOverlayItem>.from(
      _activeEntryOverlays,
    );
    // حدد مؤقت لإزالة العنصر ثم عرض التالي
    final int _shownAtMs = DateTime.now().millisecondsSinceEpoch;
    item.timer = Timer(const Duration(milliseconds: _entryUiDurationMs), () {
      if (!mounted) return;
      _activeEntryOverlays.clear();
      _activeEntryOverlaysNotifier.value = List<_EntryOverlayItem>.from(
        _activeEntryOverlays,
      );
      try {
        final _endedAtMs = DateTime.now().millisecondsSinceEpoch;
        final _displayedMs = _endedAtMs - _shownAtMs;
        dlog('[EntryOverlay] end id=${item.id} | displayedMs=${_displayedMs} | targetMs=$_entryUiDurationMs');
      } catch (_) {}
      _isShowingEntry = false;
      // أعرض العنصر التالي إن وجد
      // استخدم microtask لضمان اكتمال إعادة البناء قبل العنصر التالي
      scheduleMicrotask(_tryShowNextEntry);
    });
  }

  // بناء واجهات الدخول النشطة فقط بناءً على _activeEntryOverlays
  Widget _buildEntryOverlays() {
    return ValueListenableBuilder<List<_EntryOverlayItem>>(
      valueListenable: _activeEntryOverlaysNotifier,
      builder: (context, overlays, _) {
        if (overlays.isEmpty) {
          try {
            dlog('[EntryOverlay] rendering 0 item(s)');
          } catch (_) {}
          return const SizedBox.shrink();
        }
        // نعرض عنصراً واحداً فقط في كل مرة وفق نظام الطابور
        final List<_EntryOverlayItem> visible = overlays.take(1).toList();
        try {
          dlog('[EntryOverlay] rendering ${visible.length} item(s)');
        } catch (_) {}
        return ListView.builder(
          padding: const EdgeInsets.symmetric(vertical: 4),
          shrinkWrap: true,
          physics: const NeverScrollableScrollPhysics(),
          itemCount: visible.length,
          itemBuilder: (context, index) {
            final item = visible[index];
            return enterNameUserMessageSitulations(
              item.vipLevel,
              item.userName,
              item.text,
            );
          },
        );
      },
    );
  }

  Widget? _buildMessageItem(ZIMMessage message) {
    if (message is ZIMBarrageMessage) {
      try {
        // محاولة parse extendedData فقط إذا لم يكن فارغاً
        if (message.extendedData.isNotEmpty) {
          // Use cache to avoid repeated jsonDecode for same message
          // NOTE: Some local/system messages may have messageID == 0.
          // Caching by 0 will cause stale data to be reused across different messages.
          Map<String, dynamic> customData;
          if (message.messageID == 0) {
            // Parse fresh without caching for ID 0
            customData = jsonDecode(message.extendedData);
          } else {
            customData = _parsedBarrageCache[message.messageID] ??= jsonDecode(
              message.extendedData,
            );
          }

          // Debug: log join (entry) message payload after parsing
          if (customData["gift_type"] == "entry") {
            try {
              dlog(
                '[Chat][entry][parse] id=${message.messageID}, userName=${customData['UserName']?.toString() ?? ''}, userID=${customData['UserID']?.toString() ?? ''}, vip=${customData['UserVipLevel']?.toString() ?? '0'}, img=${customData['UserImage']?.toString() ?? ''}, msg=${message.message}',
              );
            } catch (_) {}
          }

          if (customData["gift_type"] == "deleteAllMessages") {
            if (_lastDeleteMessageId != message.messageID) {
              _lastDeleteMessageId = message.messageID;
              // Clear messages locally for everyone upon receiving the command
              OptimizedMessageManager.instance.clearMessages();
            }
            dlog(
                '[ChatSection:660] 📨 Displaying deleteAllMessages widget | msgID=${message.messageID} | content="${message.message}"');
            return Align(
              alignment: Alignment.topRight,
              child: Container(
                width: MediaQuery.of(context).size.width / 2.05,
                margin: const EdgeInsets.only(
                  right: 8,
                  left: 8,
                  top: 4,
                  bottom: 4,
                ),
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: Color(0x30F5E6C8),
                  borderRadius: BorderRadius.only(
                    topLeft: Radius.circular(20),
                    bottomLeft: Radius.circular(20),
                    bottomRight: Radius.circular(20),
                  ),
                  border: Border.all(color: Color(0x60D4AF37), width: 0.8),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withValues(alpha: 0.05),
                      blurRadius: 8,
                      spreadRadius: 1,
                      offset: Offset(2, 2),
                    ),
                  ],
                ),
                child: Text(
                  message.message,
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    color: Color(0xFFD4AF37),
                    fontSize: 16,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ),
            );
          }

          if (customData["gift_type"] == "lucky_bag") {
            // Forward lucky_bag events to the bag handler (LuckBag logic)
            // The LuckBag manager/cubit will deduplicate and handle timing
            // and queueing.
            try {
              dlog(
                '[ChatSection] 🔄 Forwarding lucky_bag event to handler: ${customData["bag_id"]?.toString() ?? customData[r"$id"]?.toString() ?? 'unknown'}',
              );
              handleMoneyBag(customData);
            } catch (e, st) {
              dlog(
                '[ChatSection] Error forwarding lucky_bag to handler: $e',
                error: e,
                stackTrace: st,
              );
            }
            // إعرض أيضاً عنصر رسالة مرئي لضمان تحفيز التمرير لكل الأنواع
            // return _buildLuckyBagEventMessage(customData);
            // لا تعرض رسالة للمستخدمين: هذه رسالة نظام تحمل معرف الماسك للحقيبة
            // إرجع مبكراً لمنع بناء عنصر نصي يعرض معرف المستخدم
            dlog(
                '[ChatSection:721] 🚫 HIDDEN lucky_bag message | msgID=${message.messageID} | content="${message.message}"');
            return null;
          }

          // معالجة الرسائل النصية العادية
          final userImage = customData["UserImage"] ?? "";
          final userName = customData["UserName"] ?? "";
          final userID = customData["UserID"] ?? "";
          final vipLevel = customData["UserVipLevel"] ?? 0;

          dlog(
              '[ChatSection:730] 📨 Displaying _buildTextMessageItem | msgID=${message.messageID} | userName="$userName" | content="${message.message}"');
          return _buildTextMessageItem(
            message: message.message,
            messageId: message.messageID.toString(),
            userImage: userImage,
            userName: userName,
            userId: userID,
            vipLevel: vipLevel,
          );
        } else {
          // إذا كان extendedData فارغاً، حاول parse message كـ JSON
          try {
            final jsonData = jsonDecode(message.message);
            if (jsonData is Map<String, dynamic>) {
              if (jsonData.containsKey('Message')) {
                final operationType = jsonData['Message']['operationType'];
                if (operationType == 20001) {
                  final giftData = jsonData['Message']['data']['gifts'][0];
                  final giftType = giftData['gift_type'];

                  if (giftType == 'lucky') {
                    dlog(
                        '[ChatSection:750] 📨 Displaying _buildLuckyMessageItem | msgID=${message.messageID} | giftType="$giftType" | content="${message.message}"');
                    return _buildLuckyMessageItem(giftData);
                  } else {
                    dlog(
                        '[ChatSection:752] 📨 Displaying _buildGiftMessageItem | msgID=${message.messageID} | giftType="$giftType" | content="${message.message}"');
                    return _buildGiftMessageItem(giftData);
                  }
                }
              }
            }
          } catch (e) {
            // إذا فشل parse message كـ JSON، عالج كرسالة نصية عادية
            dlog('Error parsing extendedData: $e', error: e);
            dlog(
                '[ChatSection:760] 📨 Displaying _buildTextMessageItem (fallback) | msgID=${message.messageID} | content="${message.message}"');
            return _buildTextMessageItem(
              message: message.message,
              messageId: message.messageID.toString(),
              userImage: "",
              userName: "",
              userId: "",
              vipLevel: 0,
            );
          }
        }
      } catch (e) {
        dlog('Error processing ZIMBarrageMessage: $e', error: e);
        dlog(
            '[ChatSection:772] 📨 Displaying _buildTextMessageItem (error fallback) | msgID=${message.messageID} | content="${message.message}"');
        return _buildTextMessageItem(
          message: message.message,
          messageId: message.messageID.toString(),
          userImage: "",
          userName: "",
          userId: "",
          vipLevel: 0,
        );
      }
    }
    return null;
  }

  // باقي الدوال تبقى كما هي بدون تغيير
  Widget _buildLuckyMessageItem(Map<String, dynamic> giftData) {
    return LuckyMessageItemWidget(
      text:
          "هدية الحظ : ${giftData["user_name"]} حصل على ${giftData["gift_points"]} كوينز لإرسال هدية حظ",
    );
  }

  // عنصر مرئي لرسائل lucky_bag حتى تظهر في الدردشة وتحفّز التمرير التلقائي
  // Widget _buildLuckyBagEventMessage(Map<String, dynamic> data) {
  //   final String senderName =
  //       (data['UserName']?.toString() ?? data['SenderName']?.toString() ?? '')
  //           .trim();
  //   // استخرج bagId لاستخدامه كـ fallback إن لم تتوفر قيمة الكوينز
  //   final String bagId =
  //       (data['bag_id']?.toString() ?? data[r'$id']?.toString() ?? '').trim();
  //   final String shortId = bagId.isNotEmpty && bagId.length > 6
  //       ? bagId.substring(bagId.length - 6)
  //       : bagId;

  //   // حاول استخراج قيمة الكوينز من الحقول المحتملة أو من النص إن وُجد
  //   final String? coins = (() {
  //     final candidates = [
  //       'gift_points',
  //       'points',
  //       'coins',
  //       'amount',
  //       'price',
  //       'gift_price',
  //       'bag_value',
  //       'value',
  //       // حقول محتملة ضمن هيكل رسائل lucky_bag في مشروعنا
  //       'how', // غالباً تشير لقيمة الحقيبة
  //       'gift_id', // أحياناً تكون رقم القيمة مباشرة
  //     ];
  //     for (final k in candidates) {
  //       final v = data[k];
  //       if (v == null) continue;
  //       final s = v.toString().trim();
  //       if (s.isEmpty) continue;
  //       final n = int.tryParse(s);
  //       if (n != null && n > 0) return n.toString();
  //     }
  //     final msg = data['message']?.toString();
  //     if (msg != null) {
  //       final match = RegExp(r'/coin:\s*(\d+)').firstMatch(msg);
  //       if (match != null) return match.group(1);
  //     }
  //     return null;
  //   })();

  //   // Debug
  //   try {
  //     dlog(
  //         '[ChatSection] _buildLuckyBagEventMessage → senderName=$senderName, coins=${coins ?? 'null'}, bagId=$bagId, shortId=$shortId');
  //   } catch (_) {}

  //   final String text = senderName.isNotEmpty
  //       ? (coins != null
  //           ? 'هدية الحظ: $senderName أنشأ حقيبة حظ بقيمة $coins'
  //           : (shortId.isNotEmpty
  //               ? 'هدية الحظ: $senderName أنشأ حقيبة حظ #$shortId'
  //               : 'هدية الحظ: $senderName أنشأ حقيبة حظ'))
  //       : (coins != null
  //           ? 'هدية الحظ: تم إنشاء حقيبة حظ بقيمة $coins'
  //           : (shortId.isNotEmpty
  //               ? 'هدية الحظ: تم إنشاء حقيبة حظ #$shortId'
  //               : 'هدية الحظ: تم إنشاء حقيبة حظ'));

  //   return LuckyMessageItemWidget(text: text);
  // }

  Widget _buildGiftMessageItem(Map<String, dynamic> giftData) {
    // Extract recipients list. Backend sends a single string joined by 'ـ'
    // Example: "AـBـC" → ["A", "B", "C"]
    final String rawNames = giftData['gift_recivers_name']?.toString() ?? '';
    final List<String> recipients = rawNames
        .split('ـ')
        .map((s) => s.trim())
        .where((s) => s.isNotEmpty)
        .toList();

    // If only one (or empty), keep existing single-item behavior
    if (recipients.length <= 1) {
      return MessageGiftItemWidget(
        img: giftData['img_user'],
        giftSender: giftData['user_name'],
        giftImg: giftData['img_gift'],
        giftsMany: giftData['gift_count'].toString(),
        giftReceiver: rawNames,
        roomCubit: widget.roomCubit,
        roomID: widget.roomID,
        userId: giftData['user_id'].toString(),
      );
    }

    // Multiple recipients → render a separate message per recipient
    return Column(
      mainAxisSize: MainAxisSize.min,
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: recipients
          .map(
            (name) => MessageGiftItemWidget(
              img: giftData['img_user'],
              giftSender: giftData['user_name'],
              giftImg: giftData['img_gift'],
              giftsMany: giftData['gift_count'].toString(),
              giftReceiver: name,
              roomCubit: widget.roomCubit,
              roomID: widget.roomID,
              userId: giftData['user_id'].toString(),
            ),
          )
          .toList(),
    );
  }

  Widget _buildTextMessageItem({
    required String message,
    required String messageId,
    required String userImage,
    required String userName,
    required String userId,
    required int vipLevel,
  }) {
    final isHost = widget.role == ZegoLiveAudioRoomRole.host;
    final isMenu = isHost;

    Widget messageWidget;

    if (vipLevel > 0) {
      messageWidget = MessageItemVIPWidget(
        text: message,
        vip: vipLevel.toString(),
        img: userImage,
        userName: userName,
        colorContainer: _getVipColor(vipLevel).withValues(alpha: .7),
        colorBorder: AppColors.goldenRoyal,
        paddingValue: 5,
        imagePath: _getVipImagePath(vipLevel),
        userId: userId,
        roomCubit: widget.roomCubit,
        roomID: widget.roomID,
      );
    } else {
      messageWidget = MessageItemWidget(
        text: message,
        id: messageId,
        userId: userId,
        img: userImage,
        userName: userName,
        roomCubit: widget.roomCubit,
        roomID: widget.roomID,
      );
    }

    return isMenu
        ? FocusedMenuHolder(
            menuWidth: 110,
            blurSize: 5,
            menuItemExtent: 38,
            duration: const Duration(milliseconds: 300),
            animateMenuItems: true,
            blurBackgroundColor: Colors.transparent,
            menuOffset: 2,
            bottomOffsetHeight: 20,
            enableMenuScroll: false,
            menuItems: _getMenuItemsList(messageId, message),
            onPressed: () {},
            child: GestureDetector(
              onTap: _isFetchingUserProfile
                  ? null
                  : () => _showUserProfile(userId),
              child: messageWidget,
            ),
          )
        : messageWidget;
  }

  // باقي الدوال المساعدة تبقى كما هي
  List<FocusedMenuItem> _getMenuItemsList(String messageID, String message) {
    return <FocusedMenuItem>[_copyMessage(message), _back()];
  }

  FocusedMenuItem _back() {
    return FocusedMenuItem(
      title: Row(
        mainAxisAlignment: MainAxisAlignment.start,
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          const SizedBox(width: 2),
          const Icon(FontAwesomeIcons.xmark, size: 12),
          const SizedBox(width: 4),
          AutoSizeText(
            S.of(context).back,
            textAlign: TextAlign.center,
            style: const TextStyle(fontSize: 13, fontWeight: FontWeight.w500),
          ),
        ],
      ),
      onPressed: () {},
    );
  }

  FocusedMenuItem _copyMessage(String message) {
    return FocusedMenuItem(
      title: Row(
        mainAxisAlignment: MainAxisAlignment.start,
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          const Icon(FontAwesomeIcons.copy, size: 12),
          const SizedBox(width: 4),
          AutoSizeText(
            S.of(context).copy,
            textAlign: TextAlign.center,
            style: const TextStyle(fontSize: 13, fontWeight: FontWeight.w500),
          ),
        ],
      ),
      onPressed: () => _copyMessageText(message),
    );
  }

  void _copyMessageText(String text) {
    Clipboard.setData(ClipboardData(text: text));
    SnackbarHelper.showMessage(context, S.of(context).doneCopiedToClipboard);
  }

  Color _getVipColor(int level) {
    switch (level) {
      case 1:
        return AppColors.svipFramColorOne;
      case 2:
        return AppColors.svipFramColorTwo;
      case 3:
        return AppColors.svipFramColorThree;
      case 4:
        return AppColors.svipFramColorFour;
      case 5:
        return AppColors.svipFramColorFive;
      default:
        return Colors.blueAccent;
    }
  }

  String _getVipImagePath(int level) {
    switch (level) {
      case 1:
        return AssetsData.vip1SvgaSheild;
      case 2:
        return AssetsData.vip2SvgaSheild;
      case 3:
        return AssetsData.vip3SvgaSheild;
      case 4:
        return AssetsData.vip4SvgaSheild;
      case 5:
        return AssetsData.vip5SvgaSheild;
      default:
        return '';
    }
  }

  Future<void> _showUserProfile(String userId) async {
    if (_isFetchingUserProfile) return;

    setState(() => _isFetchingUserProfile = true);

    try {
      if (mounted && widget.roomCubit.state.usersZego != null) {
        final user = widget.roomCubit.state.usersZego!
            .firstWhereOrNullExtention((element) => element.iduser == userId);

        if (user != null) {
          UserVIPBottomSheetWidget.showBasicModalBottomSheet(
            context,
            user,
            widget.roomCubit,
            widget.roomID,
            widget.onSend,
          );
        }
      }
    } finally {
      if (mounted) {
        setState(() => _isFetchingUserProfile = false);
      }
    }
  }

  Widget enterNameUserMessageSitulations(
    int vip,
    String userName,
    String text,
  ) {
    switch (vip) {
      case 0:
        // عرض رسالة دخول بسيطة للمستخدمين بدون VIP بدلاً من إخفائها
        return SizedBox();
      case 1:
        return AnimationSlideTransitionWidget(
          child: CustomSVGAWidget(
            isNotCenter: true,
            alignment: Alignment.centerRight,
            height: 80,
            width: double.infinity,
            pathOfSvgaFile: AssetsData.vip1SvgaName,
            allowDrawingOverflow: true,
            fit: BoxFit.contain,
            durationSeconds: (_entryUiDurationMs / 1000).round(),
            aboveChild: EnterMessageRoomVIPBody(
              text: "${S.of(context).entered}: $userName",
              colorFontOne: AppColors.white,
              colorFontTwo: AppColors.whiteGrey,
              padding: const EdgeInsets.only(top: 7.5, right: 34),
              vipAssets: AssetsData.vip1Name,
            ),
          ),
        );
      case 2:
        return AnimationSlideTransitionWidget(
          child: CustomSVGAWidget(
            isNotCenter: true,
            alignment: Alignment.centerRight,
            height: 80,
            width: double.infinity,
            pathOfSvgaFile: AssetsData.vip2SvgaName,
            allowDrawingOverflow: true,
            fit: BoxFit.contain,
            durationSeconds: (_entryUiDurationMs / 1000).round(),
            aboveChild: EnterMessageRoomVIPBody(
              text: "${S.of(context).entered}: $userName",
              colorFontOne: AppColors.white,
              colorFontTwo: AppColors.whiteGrey,
              padding: const EdgeInsets.only(top: 7.5, right: 34),
              vipAssets: AssetsData.vip2Name,
            ),
          ),
        );
      case 3:
        return AnimationSlideTransitionWidget(
          child: CustomSVGAWidget(
            isNotCenter: true,
            alignment: Alignment.centerRight,
            height: 80,
            width: double.infinity,
            pathOfSvgaFile: AssetsData.vip3SvgaName,
            allowDrawingOverflow: true,
            fit: BoxFit.contain,
            durationSeconds: (_entryUiDurationMs / 1000).round(),
            aboveChild: EnterMessageRoomVIPBody(
              text: "${S.of(context).entered}: $userName",
              colorFontOne: AppColors.white,
              colorFontTwo: AppColors.whiteGrey,
              padding: const EdgeInsets.only(top: 7.5, right: 34),
              vipAssets: AssetsData.vip3Name,
              alignment: Alignment.centerRight,
            ),
          ),
        );
      case 4:
        return AnimationSlideTransitionWidget(
          child: CustomSVGAWidget(
            isNotCenter: true,
            alignment: Alignment.centerRight,
            height: 80,
            width: 250,
            pathOfSvgaFile: AssetsData.vip4SvgaName,
            allowDrawingOverflow: true,
            fit: BoxFit.contain,
            durationSeconds: (_entryUiDurationMs / 1000).round(),
            aboveChild: EnterMessageRoomVIPBody(
              text: "${S.of(context).entered}: $userName",
              colorFontOne: AppColors.white,
              colorFontTwo: AppColors.whiteGrey,
              padding: const EdgeInsets.only(top: 7.5, right: 34),
              vipAssets: AssetsData.vip4Name,
              alignment: Alignment.centerRight,
            ),
          ),
        );
      case 5:
        return AnimationSlideTransitionWidget(
          child: CustomSVGAWidget(
            isNotCenter: true,
            alignment: Alignment.centerRight,
            height: 80,
            width: double.infinity,
            pathOfSvgaFile: AssetsData.vip5SvgaName,
            allowDrawingOverflow: true,
            fit: BoxFit.contain,
            durationSeconds: (_entryUiDurationMs / 1000).round(),
            aboveChild: EnterMessageRoomVIPBody(
              text: "${S.of(context).entered}: $userName",
              colorFontOne: AppColors.white,
              colorFontTwo: AppColors.whiteGrey,
              padding: const EdgeInsets.only(top: 7.5, right: 34),
              vipAssets: AssetsData.vip5Name,
            ),
          ),
        );
      default:
        return SizedBox();
    }
  }

  void handleMoneyBag(dynamic rawData) async {
    dlog('-------------------------------------------------');
    dlog('[handleMoneyBag] 👜 Start handling new bag event');
    dlog('[handleMoneyBag] 📦 Raw data: $rawData');

    // ✅ تأكد إن الـ rawData Map
    if (rawData is! Map<String, dynamic>) {
      dlog(
        '❌ handleMoneyBag: Expected Map<String,dynamic> but got ${rawData.runtimeType}',
      );
      return;
    }
    final Map<String, dynamic> data = rawData;

    // Parse القيم
    final roomId = data['room_id']?.toString();
    final userId = data['UserID']?.toString();
    final bagId = data['bag_id']?.toString() ?? data[r'$id']?.toString();
    final senderID = data['SenderID']?.toString();

    dlog(
      '[handleMoneyBag] 🔎 Parsed values → roomId=${roomId ?? 'null'}, userId=${userId ?? 'null'}, bagId=${bagId ?? 'null'}, senderID=${senderID ?? 'null'}',
    );

    // المستخدم الحالي (لأغراض السجل فقط)
    final UserEntity? userAuth =
        await AuthService.getUserFromSharedPreferences();
    dlog(
      '[handleMoneyBag] 👤 Current user from prefs: id=${userAuth?.id?.toString() ?? 'null'}, iduser=${userAuth?.iduser ?? 'null'}',
    );

    // لا تتجاهل الحدث بناءً على المرسل؛ يجب أن تعمل للجميع في نفس الغرفة
    // بدلاً من ذلك، تأكد أن room_id يطابق الغرفة الحالية
    if (roomId != widget.roomID) {
      dlog(
        '⚠️ Ignored: event for room ${roomId ?? 'null'} does not match current room ${widget.roomID}',
      );
      return;
    }

    // تحقق من القيم الأساسية
    if (roomId == null || userId == null || bagId == null) {
      dlog(
        '❌ Missing critical values → roomId=${roomId ?? 'null'}, userId=${userId ?? 'null'}, bagId=${bagId ?? 'null'}',
      );
      return;
    }

    // استخدام مفتاح مركب لمنع التكرار (bagId + userId)
    final String compositeKey = '$bagId|$userId';

    // منع التكرار
    if (_recentlyHandledBags.contains(compositeKey)) {
      dlog(
        '⚠️ Skipping duplicate: User $userId already handled bag $bagId recently.',
      );
      return;
    }
    _recentlyHandledBags.add(compositeKey);
    dlog(
      '[handleMoneyBag] 🆕 Added composite key $compositeKey to _recentlyHandledBags',
    );

    // ابحث عن الجلسة
    final session = widget.luckBagCubit.manager.findSession(roomId, bagId);
    if (session != null) {
      dlog(
        '[handleMoneyBag] 📂 Found existing session for bag $bagId in room $roomId',
      );
      if (!session.collectedUsers.contains(userId)) {
        session.collectedUsers.add(userId);
        dlog(
          '✅ Added user $userId to bag $bagId → total collected: ${session.collectedUsers.length}',
        );
      } else {
        dlog(
          '⚠️ User $userId already exists in collectedUsers for bag $bagId',
        );
      }
    } else {
      dlog(
        '[handleMoneyBag] 🆕 No session found → delegating to luckBagCubit.handleMoneyBag()',
      );
      widget.luckBagCubit.handleMoneyBag(data);
    }

    widget.luckBagCubit.debugPrintSessions();

    // إزالة المفتاح لاحقًا
    Future.delayed(const Duration(seconds: 17), () {
      _recentlyHandledBags.remove(compositeKey);
      dlog(
        '[handleMoneyBag] 🧹 Removed compositeKey=$compositeKey from _recentlyHandledBags after 17s',
      );
    });

    dlog('-------------------------------------------------');
  }
}

// import 'dart:convert';
// import 'package:lklk/core/utils/logger.dart';
// import 'package:flutter/material.dart';
// import 'package:flutter/services.dart';
// import 'package:lklk/features/home/presentation/manger/room_cubit/room_cubit_cubit.dart';
// import 'package:lklk/features/profile_users/presentaion/manger/user_cubit/user_cubit_cubit.dart';
// import 'package:lklk/features/room/domain/entities/room_entity.dart';
// import 'package:lklk/zego_sdk_manager.dart';
// import 'package:flutter_screenutil/flutter_screenutil.dart';
// import 'package:lklk/core/services/auth_service.dart';
// import 'package:lklk/core/utils/functions/snackbar_helper.dart';
// import 'package:lklk/features/auth/domain/entities/user_entity.dart';
// import 'package:lklk/core/constants/app_colors.dart';
// import 'package:lklk/core/constants/assets.dart';
// import 'package:lklk/core/player/svga_custom_player.dart';
// import 'package:lklk/features/room/presentation/views/widgets/player_room.dart';
// import 'package:lklk/features/room/presentation/views/widgets/trash_icon_deletechat.dart';
// import 'package:lklk/features/room/presentation/views/widgets/user_v_i_p_bottom_sheet_widget.dart';
// import 'package:lklk/generated/l10n.dart';
// import 'package:lklk/features/room/presentation/views/widgets/enter_message_room_v_i_p_body.dart';
// import 'package:lklk/features/room/presentation/views/widgets/lucky_message_item.dart';
// import 'package:lklk/features/room/presentation/views/widgets/message_item_gifts_widget.dart';
// import 'package:lklk/features/room/presentation/views/widgets/message_item_v_i_p_widget.dart';
// import 'package:lklk/features/room/presentation/views/widgets/message_item_widget.dart';
// import 'package:lklk/features/room/presentation/views/widgets/enter_user_message.dart';
// import 'package:lklk/core/animations/animation_slide_transition_widget.dart';

// class ChatSection extends StatefulWidget {
//   final List<ZIMMessage> messages;
//   final RoomEntity room;
//   final ZegoLiveAudioRoomRole role;
//   final bool? fromOverlay;
//   final RoomCubit roomCubit;
//   final UserCubit userCubit;
//   final String roomID;
//   const ChatSection({
//     super.key,
//     required this.messages,
//     required this.room,
//     required this.role,
//     this.fromOverlay,
//     required this.roomCubit,
//     required this.userCubit,
//     required this.roomID,
//   });

//   @override
//   State<ChatSection> createState() => _ChatSectionState();
// }

// class _ChatSectionState extends State<ChatSection> {
//   late ScrollController _scrollController;
//   UserEntity? currentUser;
//   bool _shouldScrollToBottom = true;
//   final Set<String> _displayedEntryIds = {};

//   @override
//   void initState() {
//     super.initState();
//     _scrollController = ScrollController();
//     _loadCurrentUser();

//     _scrollController.addListener(_handleScroll);
//   }

//   Future<void> _loadCurrentUser() async {
//     final user = await AuthService.getUserFromSharedPreferences();
//     setState(() => currentUser = user);
//   }

//   void _handleScroll() {
//     if (_scrollController.position.atEdge) {
//       setState(() {
//         _shouldScrollToBottom = _scrollController.position.pixels ==
//             _scrollController.position.minScrollExtent;
//       });
//     }
//   }

//   void _scrollToBottom() {
//     if (_scrollController.hasClients) {
//       _scrollController.animateTo(
//         _scrollController.position.minScrollExtent,
//         duration: const Duration(milliseconds: 300),
//         curve: Curves.easeOut,
//       );
//     }
//   }

//   @override
//   void dispose() {
//     _scrollController.dispose();
//     super.dispose();
//   }

//   @override
//   Widget build(BuildContext context) {
//     WidgetsBinding.instance.addPostFrameCallback((_) {
//       if (_shouldScrollToBottom) _scrollToBottom();
//     });

//     return Column(
//       crossAxisAlignment: CrossAxisAlignment.end,
//       children: [
//         // زر حذف الرسائل (للمضيف فقط)
//         if (widget.role == ZegoLiveAudioRoomRole.host &&
//             widget.messages.length > 1)
//           SizedBox(
//             height: 40,
//             child: TrashIconDeletechat(
//               // onDelete: _handleDeleteAllMessages,
//               widget: widget,
//             ),
//           ),

//         Expanded(
//           child: Stack(
//             children: [
//               // منطقة الرسائل (70% من الشاشة)
//               Align(
//                 alignment: Alignment.centerRight,
//                 child: SizedBox(
//                   width: MediaQuery.of(context).size.width * 0.7,
//                   child: _buildMessageList(),
//                 ),
//               ),

//               // منطقة المشغل (30% من الشاشة)
//               Positioned(
//                 left: 0,
//                 top: 0,
//                 child: SizedBox(
//                   height: 240.h,
//                   width: 220.w,
//                   child: PlayerRoom(fromOverlay: widget.fromOverlay ?? false),
//                 ),
//               ),
//             ],
//           ),
//         ),
//       ],
//     );
//   }

//   Widget _buildMessageList() {
//     return ListView.builder(
//       controller: _scrollController,
//       reverse: true,
//       itemCount: widget.messages.length,
//       itemBuilder: (context, index) {
//         final message = widget.messages[index];
//         return _buildMessageItem(message);
//       },
//     );
//   }

//   Widget _buildMessageItem(ZIMMessage message) {
//     // معالجة رسائل الهدايا بأنواعها
//     if (message is ZIMCustomMessage) {
//       try {
//         final jsonData = jsonDecode(message.message);
//         final operationType = jsonData['Message']['operationType'];

//         if (operationType == 20001) {
//           final giftData = jsonData['Message']['data']['gifts'][0];
//           final giftType = giftData['gift_type'];

//           if (giftType == 'entry') {
//             // رسالة دخول المستخدم
//             return _buildEntryMessage(giftData);
//           } else if (giftType == 'lucky') {
//             // رسالة هدية الحظ
//             return _buildLuckyMessage(giftData);
//           } else if (giftType == 'popular') {
//             return _buildGiftMessage(giftData);
//           } else {
//             // رسالة هدية عادية
//             return _buildGiftMessage(giftData);
//           }
//         }
//       } catch (e) {
//         return Text("catch 1 ${e.toString()} :: ${message.message}");
//       }
//     }
//     // رسالة نصية عادية
//     else if (message is ZIMBarrageMessage) {
//       Map<String, dynamic> customData = jsonDecode(message.extendedData);

//       // استخراج البيانات
//       String userImage = customData["UserImage"] ?? "";
//       String userName = customData["UserName"] ?? "";
//       String userID = customData["UserID"] ?? "";
//       int vipLevel = customData["UserVipLevel"] ?? 0;
//       // log("""message is ZIMBarrageMessage ::
//       //  message ::: ${message}
//       //  message ::: ${message.message}
//       //  customData ::: ${customData}
//       // vipLevel ::: ${vipLevel}
//       //  userImage ::: ${userImage}""");
//       return _buildTextMessage(message.message, userImage, userName,
//           message.messageID.toString(), userID, vipLevel);
//     }
//     Map<String, dynamic> customData = jsonDecode(message.extendedData);

//     // استخراج البيانات
//     String userImage = customData["UserImage"];
//     return Text(
//         "catch 2 ${message} :: ${message.extendedData} :: ${userImage}.}");
//   }

//   Widget _buildEntryMessage(Map<String, dynamic> giftData) {
//     final userName = giftData['user_name'];
//     final vipLevel = giftData['vip'] ?? '0';
//     final messageId =
//         'entry_${userName}_${DateTime.now().millisecondsSinceEpoch}';

//     // تجنب عرض رسائل الدخول المكررة
//     if (_displayedEntryIds.contains(messageId)) {
//       return const SizedBox.shrink();
//     }
//     _displayedEntryIds.add(messageId);

//     return _buildEnterUserMessage(userName, vipLevel);
//   }

//   Widget _buildLuckyMessage(Map<String, dynamic> giftData) {
//     // final userName = giftData['user_name'];
//     // final giftType = giftData['gift_type'];
//     // final giftCount = giftData['gift_count'];

//     return LuckyMessageItemWidget(
//       text: giftData['text'] ?? giftData['message'],
//       // userName: userName,
//       // giftType: giftType,
//       // giftCount: giftCount,
//     );
//   }

//   Widget _buildGiftMessage(Map<String, dynamic> giftData) {
//     // final userName = giftData['user_name'];
//     // final giftType = giftData['gift_type'];
//     // final giftCount = giftData['gift_count'];
//     // final vipLevel = giftData['vip'] ?? '0';

//     return MessageGiftItemWidget(
//       img: giftData['img_user'],
//       giftSender: giftData['user_name'],
//       giftImg: giftData['img_gift'],
//       giftsMany: giftData['gift_count'].toString(),
//     );
//   }

//   Widget _buildTextMessage(String text, String img, String userName, String id,
//       String userID, int vipLevel) {
//     // في التصميم الجديد ليس لدينا معلومات المستخدم المرسل
//     // سنستخدم المستخدم الحالي كمثال (يمكنك تعديل هذا لاحقًا)
//     final isCurrentUser = true;
//     // يمكنك تعديل هذا إذا كانت الرسالة تحتوي على مستوى VIP

//     return _buildTextMessageItem(
//       text: text,
//       isCurrentUser: isCurrentUser,
//       vipLevel: vipLevel,
//       img: img,
//       userName: userName,
//       id: id,
//       userId: userID,
//     );
//   }

//   Widget _buildEnterUserMessage(String text, String vipLevel) {
//     switch (vipLevel) {
//       case '1':
//         return AnimationSlideTransitionWidget(
//           child: CustomSVGAWidget(
//             height: 80,
//             width: double.infinity,
//             pathOfSvgaFile: AssetsData.vip1SvgaName,
//             allowDrawingOverflow: true,
//             fit: BoxFit.contain,
//             isRepeat: true,
//             aboveChild: EnterMessageRoomVIPBody(
//               // userName: userName,
//               colorFontOne: AppColors.white,
//               colorFontTwo: AppColors.whiteGrey,
//               padding: const EdgeInsets.only(top: 7.5, right: 34),
//               vipAssets: AssetsData.vip1Name,
//               text: text,
//             ),
//           ),
//         );
//       case '2':
//         return AnimationSlideTransitionWidget(
//           child: CustomSVGAWidget(
//             height: 80,
//             width: double.infinity,
//             pathOfSvgaFile: AssetsData.vip2SvgaName,
//             allowDrawingOverflow: true,
//             fit: BoxFit.contain,
//             isRepeat: true,
//             aboveChild: EnterMessageRoomVIPBody(
//               // userName: userName,
//               colorFontOne: AppColors.white,
//               colorFontTwo: AppColors.whiteGrey,
//               padding: const EdgeInsets.only(top: 7.5, right: 34),
//               vipAssets: AssetsData.vip2Name, text: text,
//             ),
//           ),
//         );
//       case '3':
//         return AnimationSlideTransitionWidget(
//           child: CustomSVGAWidget(
//             height: 80,
//             width: double.infinity,
//             pathOfSvgaFile: AssetsData.vip3SvgaName,
//             allowDrawingOverflow: true,
//             fit: BoxFit.contain,
//             isRepeat: true,
//             aboveChild: EnterMessageRoomVIPBody(
//               // userName: userName,
//               text: text,
//               colorFontOne: AppColors.white,
//               colorFontTwo: AppColors.whiteGrey,
//               padding: const EdgeInsets.only(top: 7.5, right: 34),
//               vipAssets: AssetsData.vip3Name,
//             ),
//           ),
//         );
//       case '4':
//         return AnimationSlideTransitionWidget(
//           child: CustomSVGAWidget(
//             height: 80,
//             width: double.infinity,
//             pathOfSvgaFile: AssetsData.vip4SvgaName,
//             allowDrawingOverflow: true,
//             fit: BoxFit.contain,
//             isRepeat: true,
//             aboveChild: EnterMessageRoomVIPBody(
//               // userName: userName,
//               text: text,
//               colorFontOne: AppColors.white,
//               colorFontTwo: AppColors.whiteGrey,
//               padding: const EdgeInsets.only(top: 7.5, right: 34),
//               vipAssets: AssetsData.vip4Name,
//             ),
//           ),
//         );
//       case '5':
//         return AnimationSlideTransitionWidget(
//           child: CustomSVGAWidget(
//             height: 80,
//             width: double.infinity,
//             pathOfSvgaFile: AssetsData.vip5SvgaName,
//             allowDrawingOverflow: true,
//             fit: BoxFit.contain,
//             isRepeat: true,
//             aboveChild: EnterMessageRoomVIPBody(
//               // userName: userName,
//               text: text,
//               colorFontOne: AppColors.white,
//               colorFontTwo: AppColors.whiteGrey,
//               padding: const EdgeInsets.only(top: 7.5, right: 34),
//               vipAssets: AssetsData.vip5Name,
//             ),
//           ),
//         );
//       default:
//         return EnterUserMessage(
//           // userName: userName
//           text: text,
//         );
//     }
//   }

//   Widget _buildTextMessageItem({
//     required String text,
//     required bool isCurrentUser,
//     required int vipLevel,
//     required String img,
//     required String userName,
//     required String id,
//     required String userId,
//     // required String userImg,
//   }) {
//     final isHost = widget.role == ZegoLiveAudioRoomRole.host;
//     final isMenu = isHost || isCurrentUser;

//     if (vipLevel > 0) {
//       return MessageItemVIPWidget(
//         // message: text,
//         text: text,
//         vip: vipLevel.toString(),
//         img: img,
//         userName: isCurrentUser ? 'أنت' : 'مستخدم',
//         // vipLevel: vipLevel,
//         colorContainer: _getVipColor(vipLevel).withValues(alpha: .7),
//         colorBorder: _getVipBorderColor(vipLevel),
//         paddingValue: 5,
//         imagePath: _getVipImagePath(vipLevel),
//         // onTap: isMenu ? _showUserProfile : null,
//         // onDelete: isMenu ? () => _deleteMessage(text) : null,
//         // onCopy: isMenu ? () => _copyMessage(text) : null,
//       );
//     } else {
//       return MessageItemWidget(
//         text: text, id: id, userId: userId, img: img, userName: userName,
//         // message: text,
//         // userName: isCurrentUser ? 'أنت' : 'مستخدم',
//         // isCurrentUser: isCurrentUser,
//         // onTap: isMenu ? _showUserProfile : null,
//         // onDelete: isMenu ? () => _deleteMessage(text) : null,
//         // onCopy: isMenu ? () => _copyMessage(text) : null,
//       );
//     }
//   }

//   Color _getVipColor(int level) {
//     switch (level) {
//       case 1:
//         return AppColors.svipFramColorOne;
//       case 2:
//         return AppColors.svipFramColorTwo;
//       case 3:
//         return AppColors.svipFramColorThree;
//       case 4:
//         return AppColors.svipFramColorFour;
//       case 5:
//         return AppColors.svipFramColorFive;
//       default:
//         return Colors.blueAccent;
//     }
//   }

//   Color _getVipBorderColor(int level) {
//     switch (level) {
//       case 1:
//         return AppColors.svipFramColorOne3;
//       case 2:
//         return AppColors.svipFramColorTwo3;
//       case 3:
//         return AppColors.svipFramColorThree3;
//       case 4:
//         return AppColors.svipFramColorFour3;
//       case 5:
//         return AppColors.svipFramColorFive3;
//       default:
//         return Colors.grey;
//     }
//   }

//   String _getVipImagePath(int level) {
//     switch (level) {
//       case 1:
//         return AssetsData.vip1SvgaSheild;
//       case 2:
//         return AssetsData.vip2SvgaSheild;
//       case 3:
//         return AssetsData.vip3SvgaSheild;
//       case 4:
//         return AssetsData.vip4SvgaSheild;
//       case 5:
//         return AssetsData.vip5SvgaSheild;
//       default:
//         return '';
//     }
//   }

//   void _handleDeleteAllMessages() {
//     // TODO: تنفيذ حذف جميع الرسائل
//   }

//   void _deleteMessage(String messageId) {
//     // TODO: تنفيذ حذف الرسالة
//   }

//   void _copyMessage(String text) {
//     Clipboard.setData(ClipboardData(text: text));
//     SnackbarHelper.showMessage(
//       context,
//       S.of(context).doneCopiedToClipboard,
//     );
//   }

//   void _showUserProfile() {
//     if (currentUser == null) return;
//     UserVIPBottomSheetWidget.showBasicModalBottomSheet(
//       context,
//       currentUser!,
//       // TODO: تمرير الـ Cubits اللازمة
//       widget.userCubit,
//       widget.roomCubit,
//       widget.room.id.toString(),
//     );
//   }
// }
//////////////////
//////////////////
//////////////////
//////////////////
//////////////////
//////////////////
//////////////////
// import 'dart:convert';
// import 'package:flutter/material.dart';
// import 'package:lklk/features/room/domain/entities/room_entity.dart';
// import 'package:lklk/zego_sdk_manager.dart';

// class ChatSection extends StatelessWidget {
//   final List<ZIMMessage> messages;
//   final RoomEntity room;

//   const ChatSection({super.key, required this.messages, required this.room});

//   @override
//   Widget build(BuildContext context) {

//     return ListView.separated(
//       reverse: true,
//       itemCount: messages.length,
//       separatorBuilder: (_, __) => const SizedBox(height: 6),
//       itemBuilder: (context, index) {
//         final message = messages[index];
//         // final isMine = message.senderUserID == ZEGOSDKManager().currentUser?.iduser;

//         // التعامل مع الرسائل العادية (Barrage)
//         if (message is ZIMBarrageMessage) {
//           return _buildTextMessage(message.message);
//         }
//         // التعامل مع رسائل الهدايا (Custom)
//         else if (message is ZIMCustomMessage) {
//           return _buildGiftMessage(message);
//         }
//         // التعامل مع الأنواع الأخرى
//         else {
//           return _buildTextMessage('رسالة غير معروفة');
//         }
//       },
//     );
//   }

//   Widget _buildTextMessage(String text) {
//     return Align(
//       alignment:  Alignment.centerRight ,
//       child: Container(
//         margin: const EdgeInsets.symmetric(vertical: 4, horizontal: 8),
//         padding: const EdgeInsets.all(10),
//         decoration: BoxDecoration(
//           color:  Colors.blueAccent.withValues(alpha: 0.8),
//           borderRadius: BorderRadius.circular(12),
//         ),
//         child: Text(
//           text,
//           style: TextStyle(color:Colors.white ),
//         ),
//       ),
//     );
//   }

//   Widget _buildGiftMessage(ZIMCustomMessage message) {
//     try {
//       final jsonData = jsonDecode(message.message);
//       final operationType = jsonData['Message']['operationType'];

//       if (operationType == 20001) {
//         final giftData = jsonData['Message']['data']['gifts'][0];
//         final giftType = giftData['gift_type'];
//         final giftCount = giftData['gift_count'];
//         final userName = giftData['user_name'];

//         return Align(
//           alignment:Alignment.centerRight ,
//           child: Container(
//             margin: const EdgeInsets.symmetric(vertical: 4, horizontal: 8),
//             padding: const EdgeInsets.all(10),
//             decoration: BoxDecoration(
//               color: Colors.purpleAccent.withValues(alpha: 0.8),
//               borderRadius: BorderRadius.circular(12),
//             ),
//             child: Row(
//               mainAxisSize: MainAxisSize.min,
//               children: [
//                 const Icon(Icons.card_giftcard, color: Colors.white),
//                 const SizedBox(width: 8),
//                 Text(
//                   '$userName أرسل هدية: $giftType ($giftCount)',
//                   style: const TextStyle(color: Colors.white),
//                 ),
//               ],
//             ),
//           ),
//         );
//       }
//     } catch (e) {
//       return _buildTextMessage('هدية غير معروفة');
//     }
//     return _buildTextMessage('رسالة هدية');
//   }
// }

////////////////////////////////////////////////////////////
// class ChatSection extends StatefulWidget {
//   const ChatSection({
//     super.key,
//     required this.room,
//     required this.roomCubit,
//     required this.role,
//     this.users,
//     required this.userCubit,
//     required this.roomId,
//     this.fromOverlay,
//   });

//   final RoomEntity room;
//   final RoomCubit roomCubit;
//   final UserCubit userCubit;

//   final ZegoLiveAudioRoomRole role;
//   final List<UserEntity>? users;
//   final String roomId;
//   final bool? fromOverlay;

//   @override
//   State<ChatSection> createState() => _ChatSectionState();
// }

// class _ChatSectionState extends State<ChatSection> {
//   UserEntity? currentUser;
//   late ScrollController scrollController;
//   bool _shouldScrollToBottom = true;
//   List<Message> messages = [];
//   bool isGiftVisible = false;
//   bool isTopBarVisible = false;
//   late GiftsShowCubit giftsCubit;
//   // late RoomUpdatedCubit roomUpdatedCubit;
//   bool _isFetchingUserProfile = false;
//   // Track displayed message IDs to prevent re-displaying them.
//   final Set<String> displayedMessageIds = {};
//   final Set<String> displayedEntryMessageIds = {};
//   void _scrollToBottom() {
//     if (scrollController.hasClients) {
//       scrollController.animateTo(
//         scrollController.position.minScrollExtent,
//         duration: const Duration(milliseconds: 300),
//         curve: Curves.easeOut,
//       );
//     }
//   }

//   @override
//   void dispose() {
//     scrollController.dispose();

//     super.dispose();
//   }

//   Future<void> _getUser() async {
//     final userAuth = await AuthService.getUserFromSharedPreferences();
//     if (mounted) {
//       setState(() {
//         currentUser = userAuth;
//       });
//     }
//   }

//   @override
//   void initState() {
//     super.initState();
//     _getUser();
//

//     scrollController = ScrollController();

//     scrollController.addListener(() {
//       if (scrollController.position.atEdge &&
//           scrollController.position.pixels ==
//               scrollController.position.minScrollExtent) {
//         WidgetsBinding.instance.addPostFrameCallback((_) {
//           if (mounted) {
//             setState(() {
//               _shouldScrollToBottom = true;
//             });
//           }
//         });
//       } else {
//         WidgetsBinding.instance.addPostFrameCallback((_) {
//           if (mounted) {
//             setState(() {
//               _shouldScrollToBottom = false;
//             });
//           }
//         });
//       }
//     });
//   }

//   @override
//   Widget build(BuildContext context) {
//
//
//       return Column(
//   crossAxisAlignment: CrossAxisAlignment.end,
//   children: [
//     // الجزء العلوي (زر الحذف الشرطي)
//     SizedBox(
//       height: 40,
//       child: (widget.role == ZegoLiveAudioRoomRole.host) &&
//               (newMessages.length > 1)
//           ? TrashIconDeletechat(widget: widget)
//           : const SizedBox(),
//     ),
//     Expanded(
//       child: Stack(
//         children: [
//           // جزء الرسائل (3/5 من العرض، لكنه يبقى على اليمين)
//           Align(
//             alignment: Alignment.centerRight,
//             child: SizedBox(
//               width: MediaQuery.of(context).size.width * 0.7,
//               child: Stack(
//                 children: [
//                   messageListView(newMessages),
//                   entryNameListView(entryNameMessages),
//                 ],
//               ),
//             ),
//           ),
//           // PlayerRoom ملتصق بالحافة اليسرى تمامًا
//           Positioned(
//             left: 0,
//             top: 0,
//             child: SizedBox(
//               height: 240.h,
//               width: 220.w,
//               child: Column(
//                 children: [
//                   PlayerRoom(
//                     fromOverlay: widget.fromOverlay,
//                     // progressStream: widget.progressStream,
//                   ),
//                 ],
//               ),
//             ),
//           ),
//         ],
//       ),
//     ),
//   ],
// );
//  });
//   }

// //////////////////////////////////////////////////////////////////
//   ListView messageListView(List<Message>? newMessages) {
//     return ListView.builder(
//       shrinkWrap: true,
//       padding: EdgeInsets.zero,
//       itemCount: newMessages?.length,
//       reverse: true,
//       controller: scrollController,
//       itemBuilder: (context, index) {
//         final newMessage = newMessages![index];

//         bool isMenu = (widget.role == ZegoLiveAudioRoomRole.host) ||
//             (currentUser?.iduser == newMessage.userId);
//         return Column(
//           children: [
//             if (newMessage.userId == "0001")
//               MessageGiftItemWidget(
//                 message: newMessage,
//               ),
//             if (newMessage.userId == "0002")
//               LuckyMessageItemWidget(message: newMessage),
//             // if(newMessage.userId =="01011")
//             // DiceMessageShow(message: newMessage),

//             if (newMessage.userId != "0001" &&
//                 newMessage.userId != "0002" &&
//                 newMessage.userId != '0' &&
//                 newMessage.userId != '0101' &&
//                 newMessage.userId != '00055')
//               isMenu
//                   ? FocusedMenuHolder(
//                       menuWidth: 110,
//                       blurSize: 5,
//                       menuItemExtent: 38,
//                       duration: const Duration(milliseconds: 300),
//                       animateMenuItems: true,
//                       blurBackgroundColor: Colors.transparent,
//                       menuOffset: 2,
//                       bottomOffsetHeight: 20,
//                       enableMenuScroll: false,
//                       menuItems: getMenuItemsList(
//                           newMessage.id.toString(), newMessage.text),
//                       onPressed: () {},
//                       child: GestureDetector(
//                           onTap: _isFetchingUserProfile
//                               ? null
//                               : () async {
//                                   if (mounted) {
//                                     setState(() {
//                                       _isFetchingUserProfile = true;
//                                     });
//                                   }
//                                   // final UserEntity? user = await AuthService
//                                   //     .getUserFromSharedPreferences();
//                                   if (currentUser != null) {
//                                     UserVIPBottomSheetWidget
//                                         .showBasicModalBottomSheet(
//                                       context,
//                                       currentUser!,
//                                       widget.userCubit,
//                                       widget.roomCubit,
//                                       widget.roomId,
//                                     );
//                                   }
//                                   if (mounted) {
//                                     setState(() {
//                                       _isFetchingUserProfile = false;
//                                     });
//                                   }
//                                 },
//                           child: messageItemSoulation(newMessage)),
//                     )
//                   : messageItemSoulation(newMessage)
//           ],
//         );
//       },
//     );
//   }

//   List<FocusedMenuItem> getMenuItemsList(String messageID, String message) {
//     return <FocusedMenuItem>[
//       copyMessage(message),
//       deleteMessage(messageID),
//       back(),
//     ];
//   }

//   FocusedMenuItem back() {
//     return FocusedMenuItem(
//       title: Row(
//         mainAxisAlignment: MainAxisAlignment.start,
//         crossAxisAlignment: CrossAxisAlignment.center,
//         children: [
//           const SizedBox(width: 2),
//           const Icon(
//             FontAwesomeIcons.xmark,
//             size: 12,
//           ),
//           const SizedBox(width: 4),
//           AutoSizeText(
//             S.of(context).back,
//             textAlign: TextAlign.center,
//             style: const TextStyle(
//               fontSize: 13,
//               fontWeight: FontWeight.w500,
//             ),
//           ),
//         ],
//       ),
//       onPressed: () {},
//     );
//   }

//   FocusedMenuItem deleteMessage(String messageID) {
//     return FocusedMenuItem(
//       title: Row(
//         mainAxisAlignment: MainAxisAlignment.start,
//         crossAxisAlignment: CrossAxisAlignment.center,
//         children: [
//           const Icon(
//             FontAwesomeIcons.trash,
//             size: 12,
//           ),
//           const SizedBox(width: 4),
//           AutoSizeText(
//             S.of(context).delete,
//             textAlign: TextAlign.center,
//             style: const TextStyle(
//               fontSize: 13,
//               fontWeight: FontWeight.w500,
//             ),
//           ),
//         ],
//       ),
//       onPressed: () {
//         BlocProvider.of<RoomMessagesCubit>(context)
//             .deleteMessage(messageID); //back00000000000000000
//       },
//     );
//   }

//   FocusedMenuItem copyMessage(String message) {
//     return FocusedMenuItem(
//       title: Row(
//         mainAxisAlignment: MainAxisAlignment.start,
//         crossAxisAlignment: CrossAxisAlignment.center,
//         children: [
//           const Icon(
//             FontAwesomeIcons.copy,
//             size: 12,
//           ),
//           const SizedBox(width: 4),
//           AutoSizeText(
//             S.of(context).copy,
//             textAlign: TextAlign.center,
//             style: const TextStyle(
//               fontSize: 13,
//               fontWeight: FontWeight.w500,
//             ),
//           ),
//         ],
//       ),
//       onPressed: () {
//         Clipboard.setData(ClipboardData(text: message));
//         SnackbarHelper.showMessage(
//           context,
//           S.of(context).doneCopiedToClipboard,
//         );
//       },
//     );
//   }

//   Widget messageItemSoulation(Message newMessage) {
//     switch (int.parse(newMessage.vip ?? '0')) {
//       case 1:
//         return MessageItemVIPWidget(
//           message: newMessage,
//           colorContainer: AppColors.svipFramColorOne.withValues(alpha: .7),
//           colorBorder: AppColors.svipFramColorOne3,
//           paddingValue: 5,
//           imagePath: AssetsData.vip1SvgaSheild,
//         );
//       case 2:
//         return MessageItemVIPWidget(
//           message: newMessage,
//           colorContainer: AppColors.svipFramColorTwo.withValues(alpha: .7),
//           colorBorder: AppColors.svipFramColorTwo3,
//           paddingValue: 5,
//           imagePath: AssetsData.vip2SvgaSheild,
//         );
//       case 3:
//         return MessageItemVIPWidget(
//           message: newMessage,
//           colorContainer: AppColors.svipFramColorThree.withValues(alpha: .7),
//           colorBorder: AppColors.svipFramColorThree3,
//           paddingValue: 5,
//           imagePath: AssetsData.vip3SvgaSheild,
//         );
//       case 4:
//         return MessageItemVIPWidget(
//           message: newMessage,
//           colorContainer: AppColors.svipFramColorFour.withValues(alpha: .7),
//           colorBorder: AppColors.svipFramColorFour3,
//           paddingValue: 5,
//           imagePath: AssetsData.vip4SvgaSheild,
//         );
//       case 5:
//         return MessageItemVIPWidget(
//           message: newMessage,
//           colorContainer: AppColors.svipFramColorFive.withValues(alpha: .7),
//           colorBorder: AppColors.svipFramColorFive3,
//           paddingValue: 5,
//           imagePath: AssetsData.vip5SvgaSheild,
//         );
//       default:
//         return MessageItemWidget(
//           message: newMessage,
//         );
//     }
//   }

//   ListView entryNameListView(List<Message>? entryNameMessages) {
//     return ListView.builder(
//       shrinkWrap: true,
//       padding: EdgeInsets.zero,
//       itemCount: entryNameMessages?.length,
//       reverse: false,
//       controller: scrollController,
//       itemBuilder: (context, index) {
//         final newMessage = entryNameMessages?[index];
//         return Column(
//           children: [
//             if (newMessage != null &&
//                 DateTime.now().difference(newMessage.createdAt).inSeconds <= 30)
//               Align(
//                   alignment: Alignment.centerRight,
//                   child: enterNameUserMessageSitulations(newMessage))
//           ],
//         );
//       },
//     );
//   }

//   Widget enterNameUserMessageSitulations(Message newMessage) {
//     switch (newMessage.vip) {
//       case null:
//         return EnterUserMessage(message: newMessage);
//       case "1":
//         return AnimationSlideTransitionWidget(
//           child: CustomSVGAWidget(
//             height: 80,
//             width: double.infinity,
//             pathOfSvgaFile: AssetsData.vip1SvgaName,
//             allowDrawingOverflow: true,
//             fit: BoxFit.contain,
//             isRepeat: true,
//             aboveChild: EnterMessageRoomVIPBody(
//               message: newMessage,
//               colorFontOne: AppColors.white,
//               colorFontTwo: AppColors.whiteGrey,
//               padding: const EdgeInsets.only(top: 7.5, right: 34),
//               vipAssets: AssetsData.vip1Name,
//             ),
//           ),
//         );
//       case "2":
//         return AnimationSlideTransitionWidget(
//           child: CustomSVGAWidget(
//             height: 80,
//             width: double.infinity,
//             pathOfSvgaFile: AssetsData.vip2SvgaName,
//             allowDrawingOverflow: true,
//             fit: BoxFit.contain,
//             isRepeat: true,
//             aboveChild: EnterMessageRoomVIPBody(
//               message: newMessage,
//               colorFontOne: AppColors.white,
//               colorFontTwo: AppColors.whiteGrey,
//               padding: const EdgeInsets.only(top: 7.5, right: 34),
//               vipAssets: AssetsData.vip2Name,
//             ),
//           ),
//         );
//       case "3":
//         return AnimationSlideTransitionWidget(
//           child: CustomSVGAWidget(
//             height: 80,
//             width: double.infinity,
//             pathOfSvgaFile: AssetsData.vip3SvgaName,
//             allowDrawingOverflow: true,
//             fit: BoxFit.contain,
//             isRepeat: true,
//             aboveChild: EnterMessageRoomVIPBody(
//               message: newMessage,
//               colorFontOne: AppColors.white,
//               colorFontTwo: AppColors.whiteGrey,
//               padding: const EdgeInsets.only(top: 7.5, right: 34),
//               vipAssets: AssetsData.vip3Name,
//             ),
//           ),
//         );
//       case "4":
//         return AnimationSlideTransitionWidget(
//           child: CustomSVGAWidget(
//             height: 80,
//             width: double.infinity,
//             pathOfSvgaFile: AssetsData.vip4SvgaName,
//             allowDrawingOverflow: true,
//             fit: BoxFit.contain,
//             isRepeat: true,
//             aboveChild: EnterMessageRoomVIPBody(
//               message: newMessage,
//               colorFontOne: AppColors.white,
//               colorFontTwo: AppColors.whiteGrey,
//               padding: const EdgeInsets.only(top: 7.5, right: 34),
//               vipAssets: AssetsData.vip4Name,
//             ),
//           ),
//         );
//       case "5":
//         return AnimationSlideTransitionWidget(
//           child: CustomSVGAWidget(
//             height: 80,
//             width: double.infinity,
//             pathOfSvgaFile: AssetsData.vip5SvgaName,
//             allowDrawingOverflow: true,
//             fit: BoxFit.contain,
//             isRepeat: true,
//             aboveChild: EnterMessageRoomVIPBody(
//               message: newMessage,
//               colorFontOne: AppColors.white,
//               colorFontTwo: AppColors.whiteGrey,
//               padding: const EdgeInsets.only(top: 7.5, right: 34),
//               vipAssets: AssetsData.vip5Name,
//             ),
//           ),
//         );
//       default:
//         return EnterUserMessage(message: newMessage);
//     }
//   }
// }
