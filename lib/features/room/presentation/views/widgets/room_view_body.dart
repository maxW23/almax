import 'dart:async';
import 'dart:convert';
import 'package:focused_menu_custom/focused_menu.dart';
import 'package:lklk/components/audio_room/seat_item_view.dart';
import 'package:lklk/core/utils/logger.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:auto_size_text/auto_size_text.dart';
import 'package:flutter_background/flutter_background.dart';
import 'package:lklk/core/service_locator.dart';
import 'package:lklk/core/services/auth_service.dart';
import 'package:lklk/core/utils/functions/snackbar_helper.dart';
import 'package:lklk/core/zego_delegate.dart';
import 'package:lklk/features/home/domain/entities/avatar_data_zego.dart';
import 'package:lklk/features/home/presentation/manger/gifts_show_cubit/gifts_show_cubit.dart';
import 'package:lklk/features/profile_users/domain/entities/elements_entity.dart';
import 'package:lklk/features/room/domain/entities/gift_entity.dart';
import 'package:lklk/core/services/api_service.dart';
import 'package:lklk/features/room/presentation/manger/lucky_bag/luck_bag_cubit.dart';
import 'package:lklk/features/room/presentation/manger/room_exit_service.dart';
import 'package:lklk/features/room/presentation/views/widgets/gift_animation_widget.dart';
import 'package:lklk/features/room/presentation/views/widgets/gift_animation_data.dart';
import 'package:lklk/features/home/presentation/manger/gifts_show_cubit/unified_gift_queue_manager.dart';
import 'package:lklk/features/room/presentation/views/widgets/room_messages_store.dart';
import 'package:lklk/features/room/presentation/views/widgets/optimized_message_manager.dart';
import 'package:lklk/features/room/presentation/views/widgets/user_v_i_p_bottom_sheet_widget.dart';
import 'package:lklk/generated/l10n.dart';
import 'package:lklk/core/utils/functions/file_utils.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:focused_menu_custom/modals.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:lklk/core/utils/gifts_bottom_sheet.dart';
import 'package:lklk/core/widgets/overlay/defines.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:lklk/features/room/presentation/views/widgets/chat_section.dart';
import 'package:lklk/features/profile_users/presentaion/manger/user_cubit/user_cubit_cubit.dart';
import 'package:lklk/features/room/presentation/views/widgets/room_info_row.dart';
import 'package:lklk/core/room_switch_guard.dart';
import 'package:lklk/core/performance/performance_manager.dart';
import 'package:lklk/utils/zegocloud_token.dart';
import 'package:lklk/zego_sdk_key_center.dart';
import 'package:x_overlay/x_overlay.dart';
import 'package:lklk/live_audio_room_manager.dart';
import 'package:lklk/features/livekit_audio/presentation/cubit/livekit_audio_cubit.dart';
import 'package:lklk/internal/sdk/express/express_service.dart';
import 'package:lklk/internal/sdk/livekit/livekit_audio_service.dart';
import '../../../../auth/domain/entities/user_entity.dart';
import '../../../../home/presentation/manger/room_cubit/room_cubit_cubit.dart';
import '../../../domain/entities/room_entity.dart';
import 'room_appbar.dart';
import 'room_buttons_row.dart';
// INVITE_FREEZE: imports below were used for invite-to-mic feature
// import 'users_bottomsheet.dart';
// import '../../services/mic_invite_service.dart';
// import 'mic_invite_dialog.dart';

/// كائن بسيط يحمل أبعاد الشبكة والدردشة
class _SeatChatLayout {
  final double gridHeight;
  final double chatHeight;
  const _SeatChatLayout(this.gridHeight, this.chatHeight);
}

class RoomViewBody extends StatefulWidget {
  const RoomViewBody({
    super.key,
    required this.room,
    required this.roomCubit,
    this.users,
    this.bannedUsers,
    required this.userCubit,
    required this.role,
    this.fromOverlay,
    required this.onSend,
    this.adminUsers,
  });
  final bool? fromOverlay;
  final RoomCubit roomCubit;
  final RoomEntity room;
  final List<UserEntity>? users;
  final List<UserEntity>? bannedUsers;
  final List<UserEntity>? adminUsers;
  final UserCubit userCubit;
  final ZegoLiveAudioRoomRole role;
  final void Function(ZIMMessage) onSend;

  @override
  State<RoomViewBody> createState() => _RoomViewBodyState();
}

class _RoomViewBodyState extends State<RoomViewBody>
    with WidgetsBindingObserver, TickerProviderStateMixin {
  late ZegoLiveAudioRoomRole role;
  late BuildContext pageContext;
  List<StreamSubscription> subscriptions = [];
  String? currentRequestID;
  final TextEditingController _controller = TextEditingController();
  final luckBagCubit = sl<LuckBagCubit>();
  final RoomMessagesStore _messagesStore = RoomMessagesStore.instance;

  // استبدال النظام القديم بالرتل الموحد
  // منع التداخل والتكرار: مجموعة معرفات الهدايا المعروضة حالياً
  final List<GiftAnimationData> _activeAnimations = [];
  static const int _maxConcurrentGiftAnimations = 6;

  // نظام منع التكرار القوي
  final Set<String> _processedGiftIds = <String>{};
  final Map<String, Timer> _giftIdTimers = <String, Timer>{};

  // نظام الانتظار بين الهدايا لمنع التداخل
  Timer? _giftDelayTimer;
  final List<GiftAnimationData> _pendingGifts = [];
  bool _isProcessingGift = false;
  static const Duration _giftProcessingDelay = Duration(milliseconds: 500);

  // متغيرات مطلوبة للنظام
  late UnifiedGiftQueueManager _unifiedGiftQueue;
  late ZegoDelegate _zegoDelegate;

  // منع تكرار رسائل الدخول والاشعارات
  final Set<String> _presentUserIds = <String>{};
  final Map<String, DateTime> _lastJoinShownAt = <String, DateTime>{};
  // نافذة عرض إشعار الدخول (ms) ومنع التكرار لكل مستخدم (ms)
  static const int _joinWindowMs = 2000; // اعرض فقط الرسائل الأحدث من 2 ثانية
  static const int _joinDedupMs = 8000; // لا تكرر إشعار نفس المستخدم خلال 8 ثوانٍ

  // ValueNotifier لحالة طلب المايك
  late final ValueNotifier<bool> isApplyStateNotifier;
  late List<ValueNotifier<double>> seatSoundNotifiers;
  late int microphoneNumber;
  double? _pendingLocalLevel;
  Timer? _soundLevelTicker;
  // Watchdog to ensure publishing continues (some OEMs/Doze may interrupt)
  Timer? _publishWatchdog;
  // Playback watchdog to ensure remote audio stays alive
  Timer? _playbackWatchdog;
  final Map<String, DateTime> _lastAudioFrameAt = {};
  final Map<String, double> _pendingRemoteSoundLevels = {};
  // LiveKit event-driven audio levels (no timers)
  void _onLkRemoteLevels(Map<String, double> levels) {
    if (!mounted) return;
    // levels keys are LiveKit identities == UserEntity.iduser
    levels.forEach((identity, level) {
      final seatIndex = _findSeatIndexByUserId(identity);
      if (seatIndex == null) {
        AppLogger.debug('LK UI: no seat for id=$identity level=${level.toStringAsFixed(3)}');
        return;
      }
      if (seatIndex < 0 || seatIndex >= seatSoundNotifiers.length) {
        AppLogger.debug('LK UI: seat idx OOR id=$identity idx=$seatIndex len=${seatSoundNotifiers.length} level=${level.toStringAsFixed(3)}');
        return;
      }
      // Max responsiveness: always propagate updates; UI handles threshold (0.25)
      seatSoundNotifiers[seatIndex].value = level.clamp(0.0, 1.0);
      if (level > 0.18) {
        AppLogger.debug('LK UI: set seat=$seatIndex id=$identity level=${level.toStringAsFixed(3)}');
      }
    });
  }
  // Debug-only logger: runs only in debug via assert
  void _dlog(String message, {Object? error, StackTrace? stackTrace}) {
    assert(() {
      // ignore: avoid_print
      AppLogger.debug(message);
      if (error != null) {
        // ignore: avoid_print
        AppLogger.debug('Error: $error');
      }
      if (stackTrace != null) {
        // ignore: avoid_print
        AppLogger.debug(stackTrace.toString());
      }
      return true;
    }());
  }

  void _logGiftInfo(String message, {dynamic extra}) {
    final text = 'GIFT_ANIMATION: $message${extra != null ? ' $extra' : ''}';
    log(text);
    assert(() {
      // Also print to console in debug to ensure visibility in logcat
      // ignore: avoid_print
      AppLogger.debug(text);
      return true;
    }());
  }

  // بناء معرف فريد للهدية لتفادي التكرار: بدون timestamp لضمان نفس المعرف للهدية الواحدة
  String _buildUniqueGiftId({
    required GiftEntity gift,
    required String senderId,
    required String receiverId,
  }) {
    // استخدام بيانات ثابتة بدون timestamp لضمان نفس المعرف للهدية الواحدة
    final gid = gift.giftId;
    final count = gift.giftCount;
    final type = gift.giftType;
    return '${gid}_${type}_${senderId}_${receiverId}_$count';
  }

  // يحدد إن كان المستخدم الحالي (على هذا الجهاز) يملك صلاحيات المالك/الأدمن لهذه الغرفة
  bool _isAdminOrOwner(RoomCubitState state, UserEntity? current) {
    final String roomIdStr = widget.room.id.toString();
    // من ملف المستخدم
    final bool isOwner = current?.ownerIds?.contains(roomIdStr) ?? false;
    bool isAdmin = current?.adminRoomIds?.contains(roomIdStr) ?? false;

    // من قائمة أدمن الغرفة القادمة من RoomCubit (في حال لم تُحدث user profile بعد)
    if (!isAdmin) {
      final List<UserEntity> admins =
          state.adminsListUsers ?? widget.adminUsers ?? const <UserEntity>[];
      final String? me = current?.iduser ?? current?.id;
      if (me != null) {
        isAdmin = admins.any((u) => (u.iduser == me) || (u.id == me));
      }
    }

    return isOwner || isAdmin;
  }

  // إعادة احتساب الدور المحلي وتطبيق إعدادات الصوت/المقعد عند التغيير
  void _recomputeRoleFromState() {
    try {
      final RoomCubitState roomState = widget.roomCubit.state;
      final UserEntity? currentUser =
          widget.userCubit.user ?? widget.userCubit.state.user;
      final bool hasModeratorPower = _isAdminOrOwner(roomState, currentUser);
      final ZegoLiveAudioRoomRole newRole = hasModeratorPower
          ? ZegoLiveAudioRoomRole.host
          : ZegoLiveAudioRoomRole.audience;

      if (newRole != role) {
        _dlog('Role changed -> $newRole (admin/owner recompute)');
        if (mounted) {
          setState(() {
            role = newRole;
          });
        }
        _configureAudioForRole();
        if (newRole == ZegoLiveAudioRoomRole.host) {
          // ضمان امتلاك المقعد فوراً عند اكتساب صلاحيات المضيف/الأدمن
          // ignore: discarded_futures
          hostTakeSeat();
        }
      }
    } catch (e, st) {
      _dlog('Failed to recompute role: $e', error: e, stackTrace: st);
    }
  }

  @override
  void initState() {
    super.initState();

    // تهيئة الرتل الموحد
    _unifiedGiftQueue = UnifiedGiftQueueManager();

    // تهيئة ValueNotifier لحالة طلب المايك
    isApplyStateNotifier = ValueNotifier<bool>(false);
    pageContext = context;

    // إدارة دورة الحياة
    WidgetsBinding.instance.addObserver(this);

    // العمليات الأساسية الفورية
    pageContext = context;
    role = widget.role;
    // حماية من أي قيمة غير رقمية قادمة من الـ API
    microphoneNumber = int.tryParse(widget.room.microphoneNumber) ?? 10;

    // تأكد فوراً أن الدور يعكس أحدث صلاحيات المالك/الأدمن
    _recomputeRoleFromState();

    // أنشئ النوتيفايزرات مرة واحدة
    seatSoundNotifiers =
        List.generate(microphoneNumber, (_) => ValueNotifier<double>(0.0));

    // تهيئة مدير الرسائل المحسن للغرفة الحالية فوراً
    OptimizedMessageManager.instance
        .initializeForRoom(widget.room.id.toString());

    // تفعيل وضع الأداء العالي للغرف ذات الكثافة العالية
    PerformanceManager().enableHighPerformanceMode();

    // تهيئة قائمة المستخدمين الموجودين حالياً لمنع رسائل دخول مكررة
    try {
      final initialUsers =
          widget.users ?? widget.roomCubit.state.usersZego ?? [];
      for (final u in initialUsers) {
        final String id = u.iduser;
        if (id.isNotEmpty) {
          _presentUserIds.add(id);
        }
      }
    } catch (_) {}

    // العمليات الثقيلة - تأجيل للإطار التالي
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (!mounted) return;

      // تهيئة الاتصال والصوت
      _zegoDelegate = ZegoDelegate();
      _createEngineAndLoginRoom();
      _initSoundMonitoring();
      _eventsSoundsLevelRoom();

      // تهيئة المستمعين
      _initChatListeners();
      _initSubscriptions();
      _listenUserChanges();

      // LiveKit: subscribe to event-driven audio levels and avoid legacy ticker
      if (ExpressService.instance.useLiveKitAudio) {
        LiveKitAudioService.instance.addRemoteSoundLevelListener(_onLkRemoteLevels);
      }

      // عند أي تغيير في RoomCubit (مثل تحديث adminsListUsers) أعد احتساب الدور
      subscriptions.add(widget.roomCubit.stream.listen((_) {
        if (!mounted) return;
        _recomputeRoleFromState();
      }));

      // العمليات الأقل أولوية - تأجيل أكثر
      Future.delayed(const Duration(milliseconds: 300), () {
        if (mounted) {
          backgroundMethod();
          // Legacy ticker only for Zego path; LiveKit uses event-driven updates
          if (!ExpressService.instance.useLiveKitAudio) {
            _startSoundTicker(const Duration(milliseconds: 250));
          }
        }
      });

      // العمليات الثقيلة - تأجيل كبير
      Future.delayed(const Duration(seconds: 1), () {
        if (mounted) _startPublishWatchdog(const Duration(seconds: 60));
      });

      Future.delayed(const Duration(seconds: 2), () {
        if (mounted) _startPlaybackWatchdog(const Duration(seconds: 20));
      });
    });

    // تسجيل معالج الأحداث
    ZIMEventHandler.onRoomMemberJoined = (zim, memberList, roomID) {
      if (roomID != widget.room.id.toString()) return;
      _onRoomMemberJoined(zim, memberList, roomID);
    };
  }

  // يضمن أن عدد النوتيفايرز يساوي على الأقل عدد المقاعد المطلوب
  void _ensureSeatNotifiersCount(int count) {
    final current = seatSoundNotifiers.length;
    if (current < count) {
      seatSoundNotifiers.addAll(
          List.generate(count - current, (_) => ValueNotifier<double>(0.0)));
    }
  }

  // متغير لتتبع آخر عدد مقاعد تم حسابه
  int _lastCalculatedSeats = 20; // القيمة الافتراضية

  /// فحص وتحديث حجم المقاعد عند تغيير العدد الفعلي
  void _checkAndUpdateSeatLayout() {
    final int roomMicNumber =
        int.tryParse(widget.room.microphoneNumber) ?? microphoneNumber;

    // لا تستخدم طول seatList لأنه ثابت (20). اعتمد دائماً على عدد ميكروفونات الغرفة
    final int actualSeats = roomMicNumber > 0 ? roomMicNumber : 15;

    // إذا تغير العدد، أعد بناء التخطيط فوراً
    if (actualSeats != _lastCalculatedSeats && mounted) {
      _dlog(
          'Seat layout updated: $_lastCalculatedSeats -> $actualSeats (room: $roomMicNumber)');
      _lastCalculatedSeats = actualSeats;

      // إعادة بناء فورية للتخطيط لتحديث حجم الشات
      setState(() {
        // إعادة حساب أبعاد الشات والمقاعد بناءً على العدد الجديد
      });

      // أعِد ضبط فاصل مؤقت الصوت ديناميكياً حسب عدد المقاعد
      final intervalMs = actualSeats >= 15 ? 400 : 250;
      _startSoundTicker(Duration(milliseconds: intervalMs));
    }
  }

  /// فرض إعادة حساب تخطيط الشات عند توفر البيانات الجديدة
  void _forceLayoutRecalculation() {
    if (mounted) {
      _dlog('Forcing layout recalculation due to new data availability');
      setState(() {
        // إعادة حساب أبعاد الشات بناءً على البيانات المحدثة
      });
    }
  }

  /// يحسب ارتفاع شبكة المقاعد وارتفاع الدردشة ديناميكياً
  /// يعتمد على:
  /// - حجم عنصر المقعد من `ZegoSeatItemView` (عرض 72.w وارتفاع 90.h)
  /// - عدد المقاعد `microphoneNumber`
  /// - عرض الحاوية المتاحة (من Constraints) لحساب الأعمدة
  /// - حجز حد أدنى لارتفاع الدردشة لضمان سهولة الاستخدام
  _SeatChatLayout _computeSeatAndChatHeights(
    BuildContext context, {
    double? availableHeightOverride,
    bool isKeyboardOpen = false,
    bool hasInfoRow = true,
  }) {
    final media = MediaQuery.of(context);
    final screenWidth = media.size.width;

    // استخدم ارتفاع الحاوية الفعلي إن توفر، وإلا استخدم ارتفاع الشاشة
    final double containerHeight =
        (availableHeightOverride ?? media.size.height)
            .clamp(0.0, double.infinity);

    // مساحات رأسية ثابتة تقريبية لعناصر أعلى/أسفل الشبكة داخل هذه الصفحة
    // AppBar (~kToolbarHeight) + RoomInfoRow (~60 عند الظهور) + RoomButtonsRow (~72 محجوزة كمساحة للأسفل) + هوامش
    final double fixedOverhead =
        kToolbarHeight + (hasInfoRow ? 60 : 0) + 72 + 16;

    // المساحة المتاحة للشبكة + الدردشة ضمن العمود الحالي
    double available = containerHeight - fixedOverhead;
    if (available < 0) available = 0;

    // أبعاد عنصر المقعد وفق ما هو مستخدم داخل ZegoSeatItemView (مع حماية)
    final double seatWidth = _safeScale(72.w, 72.0);
    final double seatHeight = _safeScale(90.h, 90.0);
    final double rowExtraPadding = _safeScale(8.h, 8.0); // هامش رأسي إضافي بسيط

    // لا تعتمد على seatList.length (ثابت 20). استخدم عدد ميكروفونات الغرفة فقط
    final int roomMicNumber =
        int.tryParse(widget.room.microphoneNumber) ?? microphoneNumber;
    final int effectiveSeats =
        roomMicNumber > 0 ? roomMicNumber : 15; // متوسط أفضل من 20
    _dlog('Using room microphone count only: $effectiveSeats');

    // في حال المساحة المتاحة صفر، لا نخصص أي مساحة للشبكة
    if (available <= 0) {
      return const _SeatChatLayout(0, 0);
    }

    // في حال لم تتوفر مقاعد فعّالة، خصص المساحة للدردشة فقط ضمن المتاح
    if (effectiveSeats <= 0) {
      final double minChatHeight = _safeScale(
          isKeyboardOpen ? 120.h : 180.h, isKeyboardOpen ? 120.0 : 180.0);
      final double chat =
          available >= minChatHeight ? minChatHeight : available;
      return _SeatChatLayout(0, chat);
    }

    // حساب عدد الأعمدة المتاحة بناء على عرض الحاوية (مع حماية من القسمة على صفر)
    int columns = seatWidth > 0
        ? (screenWidth / seatWidth).floor()
        : (screenWidth / 72.0).floor();
    if (columns < 1) columns = 1;
    if (columns > effectiveSeats) columns = effectiveSeats;

    // حساب عدد الصفوف
    final int rows = (effectiveSeats / columns).ceil();

    // الارتفاع النظري للشبكة
    double gridHeight = rows * seatHeight + (rows - 1) * 0 + rowExtraPadding;

    // احجز حد أدنى لارتفاع الدردشة (مع حماية)
    final double minChatHeight = _safeScale(
        isKeyboardOpen ? 120.h : 180.h, isKeyboardOpen ? 120.0 : 180.0);
    if (available - gridHeight < minChatHeight) {
      gridHeight = available - minChatHeight;
      if (gridHeight < seatHeight) {
        // لا تقل عن ارتفاع صف واحد على الأقل، وإن لم تسمح المساحة فاجعله صفاً جزئياً أو صفراً
        gridHeight = gridHeight <= 0 ? 0 : seatHeight;
      }
    }

    // الآن احسب ارتفاع الدردشة كالمتبقي
    double chatHeight = available - gridHeight;
    if (chatHeight < 0) chatHeight = 0;
    if (chatHeight < minChatHeight && available >= minChatHeight) {
      chatHeight = minChatHeight;
      gridHeight = available - chatHeight;
      if (gridHeight < 0) gridHeight = 0;
    }

    // حماية إضافية: لا تتجاوز القيم المساحة المتاحة
    if (gridHeight + chatHeight > available) {
      chatHeight = available - gridHeight;
      if (chatHeight < 0) chatHeight = 0;
    }

    return _SeatChatLayout(gridHeight, chatHeight);
  }

  /// دالة مساعدة لتفادي قيم NaN/Infinity أو الصفر عند استخدام ScreenUtil
  double _safeScale(double scaled, double fallback) {
    if (scaled.isNaN || scaled.isInfinite || scaled <= 0) return fallback;
    return scaled;
  }

  void _startPlaybackWatchdog(Duration interval) {
    _playbackWatchdog?.cancel();
    _playbackWatchdog = Timer.periodic(interval, (_) async {
      if (!mounted) return;
      // LiveKit-only migration: Zego playback watchdog disabled.
      // Playback restarts handled by LiveKitAudioService/AudioManager.
    });
  }

  void _startPublishWatchdog(Duration interval) {
    _publishWatchdog?.cancel();
    _publishWatchdog = Timer.periodic(interval, (_) async {
      if (!mounted) return;
      // LiveKit-only migration: publishing watchdog disabled (audio-only).
      // Mic publishing is managed by LiveKitAudioCubit based on seat/role.
    });
  }

  @override
  Widget build(BuildContext context) {
    pageContext = context;
    // فحص وتحديث تخطيط المقاعد عند الحاجة
    _checkAndUpdateSeatLayout();

    // احسب أبعاد الشبكة والدردشة ديناميكياً بناءً على عدد المقاعد وحجم كل عنصر
    // سيتم إعادة حساب التخطيط داخل BlocBuilder للمقاعد

    return Stack(
      children: [
        // Fixed layout using constraints-aware sizing
        Positioned.fill(
          child: LayoutBuilder(
            builder: (context, constraints) {
              final media = MediaQuery.of(context);
              final double keyboardInset = media.viewInsets.bottom;
              final bool keyboardOpen = keyboardInset > 0;
              final bool showInfoRow =
                  !keyboardOpen && constraints.maxHeight > 300;
              return Column(
                children: [
                  // Room Appbar
                  RepaintBoundary(
                    child: BlocBuilder<RoomCubit, RoomCubitState>(
                      buildWhen: (prev, curr) =>
                          !identical(prev.usersZego, curr.usersZego) ||
                          !identical(prev.bannedUsers, curr.bannedUsers) ||
                          !identical(
                              prev.adminsListUsers, curr.adminsListUsers),
                      builder: (context, state) {
                        return RoomAppbar(
                          room: widget.room,
                          roomCubit: widget.roomCubit,
                          users: state.usersZego ?? widget.users ?? [],
                          bannedUsers: state.bannedUsers ?? widget.bannedUsers,
                          adminUsers:
                              state.adminsListUsers ?? widget.adminUsers,
                          userCubit: widget.userCubit,
                          onSend: widget.onSend,
                        );
                      },
                    ),
                  ),

                  // Room Info Row (hidden when keyboard is open or height too tight)
                  if (showInfoRow)
                    RepaintBoundary(
                      child: Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 6),
                        child: RoomInfoRow(
                          roomCubit: widget.roomCubit,
                          room: widget.room,
                          userCubit: widget.userCubit,
                          onSend: widget.onSend,
                        ),
                      ),
                    ),

                  // Seat Grid (fixed height)
                  BlocBuilder<RoomCubit, RoomCubitState>(
                    buildWhen: (prev, curr) =>
                        !identical(prev.usersZego, curr.usersZego) ||
                        !identical(prev.room, curr.room) ||
                        prev.status != curr.status,
                    builder: (context, state) {
                      final String micStr = state.room?.microphoneNumber ??
                          widget.room.microphoneNumber;
                      microphoneNumber = int.tryParse(micStr) ?? 10;

                      // إعادة حساب التخطيط مع البيانات المحدثة
                      final layout = _computeSeatAndChatHeights(
                        context,
                        availableHeightOverride: constraints.maxHeight,
                        isKeyboardOpen: keyboardOpen,
                        hasInfoRow: showInfoRow,
                      );
                      double updatedGridHeight = layout.gridHeight;
                      // إذا كانت قائمة المقاعد غير متاحة بعد، لا تجعل ارتفاع الشبكة صفراً
                      // حتى يظهر الـ placeholder داخل grid بدلاً من أن يختفي تحت الخلفية
                      if (ZegoLiveAudioRoomManager().seatList.isEmpty &&
                          updatedGridHeight <= 0) {
                        updatedGridHeight = _safeScale(220.h, 220.0);
                      }

                      return SizedBox(
                        height: updatedGridHeight,
                        child: RepaintBoundary(child: seatListView(state)),
                      );
                    },
                  ),

                  const SizedBox(height: 8),

                  // ChatSection expands and scrolls internally (with bottom padding to avoid overlayed buttons)
                  Expanded(
                    child: Padding(
                      padding: EdgeInsets.only(
                        bottom: keyboardOpen ? 8 : 64,
                      ),
                      child: RepaintBoundary(
                        child: ChatSection(
                          room: widget.room,
                          role: role,
                          roomCubit: widget.roomCubit,
                          userCubit: widget.userCubit,
                          roomID: widget.room.id.toString(),
                          fromOverlay: widget.fromOverlay,
                          onSend: widget.onSend,
                          luckBagCubit: luckBagCubit,
                        ),
                      ),
                    ),
                  ),

                  // Buttons moved out as overlay below
                ],
              );
            },
          ),
        ),

        // Bottom buttons overlay
        Positioned(
          left: 0,
          right: 0,
          // ضع الأزرار مباشرة فوق الكيبورد عند ظهوره
          bottom: MediaQuery.of(context).viewInsets.bottom,
          child: SafeArea(
            bottom: true,
            minimum: const EdgeInsets.only(bottom: 8),
            child: RepaintBoundary(
              child: BlocBuilder<RoomCubit, RoomCubitState>(
                buildWhen: (prev, curr) =>
                    !identical(prev.usersZego, curr.usersZego) ||
                    !identical(prev.room, curr.room) ||
                    prev.status != curr.status,
                builder: (context, state) {
                  final currentUser = widget.userCubit.user;
                  if (currentUser == null) {
                    return const SizedBox.shrink();
                  }
                  return RoomButtonsRow(
                    role: role,
                    userCubit: widget.userCubit,
                    roomCubit: widget.roomCubit,
                    room: widget.room,
                    user: currentUser,
                    usersRoom: state.usersZego ?? widget.users ?? [],
                    onSend: widget.onSend,
                    fromOverlay: widget.fromOverlay,
                    deleteAllMessages: _deleteAllMessages,
                    addDeleteAllMessagesMessage: _addDeleteAllMessagesMessage,
                  );
                },
              ),
            ),
          ),
        ),

        // Gift animations (overlay on top of everything else) - REMOVED DUPLICATE LISTENER
        // RepaintBoundary(child: giftImageBloc()), // تم إزالة المستمع المكرر
        // عرض الأنيميشن النشطة من الرتل الموحد
        ..._activeAnimations.map((giftData) {
          return RepaintBoundary(
            child: GiftAnimationWidget(
              key: ValueKey<String>(
                  giftData.giftId ?? giftData.hashCode.toString()),
              giftData: giftData,
              giftId: (giftData.giftId ??
                  giftData.hashCode.toString()), // معرف فريد للStack
              onAnimationComplete: () => _onGiftAnimationComplete(giftData),
            ),
          );
        }),
      ],
    );
  }
  ///////////////////////////////////////////////////////////
  ///////////////////////////////////////////////////////////
  ///////////////////////////////////////////////////////////
  ///////////////////////////////////////////////////////////
  ///////////////////////////////////////////////////////////
  ///////////////////////////////////////////////////////////
  ///////////////////////////////////////////////////////////
  ///////////////////////////////////////////////////////////
  ///////////////////////////////////////////////////////////
  ///////////////////////////////////////////////////////////
  ///////////////////////////////////////////////////////////
  ///////////////////////////////////////////////////////////
  ///////////////////////////////////////////////////////////
  ///////////////////////////////////////////////////////////
  ///////////////////////////////////////////////////////////
  ///////////////////////////////////////////////////////////
  ///////////////////////////////////////////////////////////
  ///////////////////////////////////////////////////////////
  ///////////////////////////////////////////////////////////

  void _listenUserChanges() {
    final sub = widget.userCubit.stream.listen((_) {
      // تحديث ملف المستخدم (ownerIds/adminRoomIds) ينبغي أن ينعكس فوراً على الدور
      _recomputeRoleFromState();
    });
    subscriptions.add(sub);
  }

  void _initChatListeners() {
    ZEGOSDKManager()
        .zimService
        .onRoomMessageReceivedStreamCtrl
        .stream
        .listen((messageList) {
      if (!mounted || messageList.isEmpty) return;
      // Add messages in bounded store and sync local cache
      _messagesStore.addMessages(widget.room.id.toString(), messageList);
      // أيضاً ادفع كل رسالة إلى OptimizedMessageManager مع فلترة رسائل الدخول القديمة
      final now = DateTime.now();
      for (final msg in messageList) {
        bool skip = false;
        if (msg is ZIMBarrageMessage) {
          try {
            if (msg.extendedData.isNotEmpty) {
              final Map<String, dynamic> data = jsonDecode(msg.extendedData);
              final type = data['gift_type'];
              if (type == 'entry') {
                // تجاهل أي رسالة دخول قديمة أكثر من النافذة المحددة من الآن
                final String? dt = data['dateTime'];
                if (dt != null) {
                  final DateTime ts = DateTime.tryParse(dt)?.toLocal() ?? now;
                  if (now.difference(ts).inMilliseconds > _joinWindowMs) {
                    skip = true;
                  }
                }
                // منع التكرار إن ظهر المستخدم مسبقاً
                final String? uid = data['UserID'];
                if (!skip && uid is String && uid.isNotEmpty) {
                  final last = _lastJoinShownAt[uid];
                  if (last != null &&
                      now.difference(last).inMilliseconds <= _joinDedupMs) {
                    skip = true;
                  }
                }
              }
            }
          } catch (_) {}
        }

        if (!skip) {
          OptimizedMessageManager.instance
              .addMessage(widget.room.id.toString(), msg);
        }
      }
    });
  }

  void _eventsSoundsLevelRoom() {
    _zegoDelegate.setZegoEventCallback(
      onRemoteSoundLevelUpdate: onRemoteSoundLevelUpdate,
      onCapturedSoundLevelUpdate: onCapturedSoundLevelUpdate,
    );
  }

  void _createEngineAndLoginRoom() async {
    try {
      _dlog(
          'Creating engine and logging into room, fromOverlay: ${widget.fromOverlay}');
      await _zegoDelegate.createEngine();
      // Ensure speaker route is enabled before any playback starts (LiveKit)
      try {
        context.read<LiveKitAudioCubit>().setSpeaker(true);
      } catch (_) {}

      if (!(widget.fromOverlay ?? false)) {
        // دخول عادي للغرفة
        _dlog('Normal room entry - loginRoom() immediately; refresh profile in background');
        // سجل دخول الغرفة فوراً لبدء الصوت/المايك بدون انتظار الشبكة
        loginRoom();
        // حدّث ملف المستخدم في الخلفية (لا تمنع الدخول)
        try {
          // تشغيل دون انتظار حتى لا نحجب تدفق الدخول
          unawaited(widget.userCubit.getProfileUser('room_entry'));
        } catch (_) {}
      } else {
        // العودة من التصغير - استعادة حالة الغرفة
        _dlog('Overlay restore - calling restoreRoomStateFromOverlay()');
        await _restoreRoomStateFromOverlay();
      }
    } catch (e) {
      _dlog('Error in _createEngineAndLoginRoom: $e', error: e);
    }
  }

  /// استعادة حالة الغرفة عند العودة من التصغير
  /// تقوم بالعمليات الأساسية لاستعادة الحالة بدون تسجيل دخول جديد
  Future<void> _restoreRoomStateFromOverlay() async {
    try {
      _dlog('Restoring room state from overlay...');

      // جلب بيانات الغرفة الكاملة من الخادم (users/admin/banned/top) مع تمرير كلمة المرور إن وجدت
      try {
        await widget.roomCubit.updatedfetchRoomById(
          widget.room.id.toString(),
          'overlay_restore',
          pass: widget.room.pass,
        );
        _recomputeRoleFromState();
      } catch (e) {
        _dlog('Failed to refresh room data on overlay restore: $e', error: e);
      }

      // جلب المستخدمين المتصلين من الخادم
      await widget.roomCubit.fetchOnlineUsersFromRoom(
        widget.room.id.toString(),
      );

      // تحديث قائمة الموجودين حالياً بعد الاسترجاع لمنع رسائل دخول مكررة
      try {
        final currentUsers = widget.roomCubit.state.usersZego ?? [];
        for (final u in currentUsers) {
          final String id = u.iduser;
          if (id.isNotEmpty) {
            _presentUserIds.add(id);
          }
        }
      } catch (_) {}

      // فرض إعادة حساب تخطيط الشات بعد استعادة البيانات
      _forceLayoutRecalculation();

      // ضبط الإعدادات الصوتية (LiveKit)
      try {
        context.read<LiveKitAudioCubit>().setSpeaker(true);
      } catch (_) {}

      // ضبط جودة الصوت حسب الدور
      _configureAudioForRole();
      // LiveKit: لا حاجة لإلغاء كتم عالمي للتدفقات؛ الاشتراكات تُدار تلقائياً

      // حجز المقعد إذا كان مضيف
      if (role == ZegoLiveAudioRoomRole.host) {
        await hostTakeSeat();
      }

      // التأكد من أن قائمة المقاعد متاحة
      final seatList = ZegoLiveAudioRoomManager().seatList;
      if (seatList.isEmpty) {
        _dlog('Seat list is empty after overlay restore - may need full login');
        // إذا كانت قائمة المقاعد فارغة، قد نحتاج لتسجيل دخول كامل
        await Future.delayed(const Duration(milliseconds: 500));
        loginRoom();
      } else {
        _dlog('Seat list restored successfully: ${seatList.length} seats');
      }

      _dlog('Room state restored successfully from overlay');
    } catch (e, stackTrace) {
      _dlog('Error restoring room state from overlay: $e',
          error: e, stackTrace: stackTrace);
      // في حالة فشل الاستعادة، نفذ تسجيل دخول كامل
      _dlog('Fallback to full room login due to restore error');
      loginRoom();
    }
  }

  void _initSubscriptions() {
    final zimService = ZEGOSDKManager().zimService;
    final expressService = ZEGOSDKManager().expressService;
    subscriptions.addAll([
      expressService.roomStateChangedStreamCtrl.stream.listen(
        onExpressRoomStateChanged,
      ),
      // أول إطار صوت مستلم من أي ستريم -> حدّث آخر نشاط صوتي
      expressService.recvAudioFirstFrameCtrl.stream.listen((event) async {
        _lastAudioFrameAt[event.streamID] = DateTime.now();
        // Safety: ensure stream is unmuted once we confirm frames are arriving
        try {
          await ZegoExpressEngine.instance
              .mutePlayStreamAudio(event.streamID, false);
        } catch (_) {}
      }),
      zimService.roomStateChangedStreamCtrl.stream.listen(
        onZIMRoomStateChanged,
      ),
      zimService.connectionStateStreamCtrl.stream.listen(
        onZIMConnectionStateChanged,
      ),
      zimService.onInComingRoomRequestStreamCtrl.stream.listen(
        onInComingRoomRequest,
      ),
      zimService.onOutgoingRoomRequestAcceptedStreamCtrl.stream.listen(
        onOutgoingRoomRequestAccepted,
      ),
      zimService.onOutgoingRoomRequestRejectedStreamCtrl.stream.listen(
        onOutgoingRoomRequestRejected,
      ),
      // expressService.roomUserListUpdateStreamCtrl.stream
      //     .listen(onRoomUserListUpdate,widget.roomCubit),
      zimService.onRoomCommandReceivedEventStreamCtrl.stream.listen(
        (event) {
          onRoomCommandReceived(
            event,
            widget.userCubit,
            widget.roomCubit,
          );
        },
        onError: (error) {},
        onDone: () => log('Room command stream is closed'),
      )
    ]);
  }

  void _onRoomMemberJoined(
      ZIM zim, List<ZIMUserInfo> memberList, String roomID) {
    if (roomID != widget.room.id.toString()) return;

    for (final member in memberList) {
      try {
        // 1. Log the join
        _logMemberJoin(member);

        // منع التكرار: إذا كان المستخدم موجوداً مسبقاً لا تُظهر رسالة دخول
        final String uid = member.userID;
        final DateTime now = DateTime.now();
        bool shouldShow = true;

        if (_presentUserIds.contains(uid)) {
          // الموجودون مسبقاً (قد يظهر الحدث بسبب إعادة الاتصال/الاسترجاع)
          shouldShow = false;
        }
        final DateTime? lastShown = _lastJoinShownAt[uid];
        try {
          final int agoMs = lastShown != null ? now.difference(lastShown).inMilliseconds : -1;
          log('[JoinFlow] check uid=$uid present=${_presentUserIds.contains(uid)} lastShownAgoMs=$agoMs shouldShowPre=$shouldShow');
        } catch (_) {}
        if (shouldShow &&
            lastShown != null &&
            now.difference(lastShown).inMilliseconds <= _joinDedupMs) {
          // نفس المستخدم خلال <= 1 ثانية
          shouldShow = false;
        }

        if (shouldShow) {
          // 2. Show system message in chat (مرة واحدة فقط)
          log('[JoinFlow] adding system message for uid=$uid');
          _addSystemMessage(member);
          // 3. Show entry gift animation
          log('[JoinFlow] triggering _showJoinNotification for uid=$uid');
          _showJoinNotification(member);
          _lastJoinShownAt[uid] = now;
          log('[JoinFlow] lastJoinShownAt updated uid=$uid at=$now');
        } else {
          _dlog('Skip duplicate join message for $uid');
        }

        // 4. Add member to RoomCubit (for online user list)
        final avatarData = AvatarData.fromEncodedString(member.userAvatarUrl);

        // use newlevel3 carried in AvatarData directly
        final String? _newLevel3 = avatarData.newlevel3;

        final newUser = UserEntity(
          iduser: member.userID,
          id: member.userID,
          name: member.userName,
          img: avatarData.imageUrl ?? '',
          elementFrame: ElementEntity(elamentId: avatarData.frameId ?? ''),
          vip: avatarData.vipLevel,
          adminRoomIds: avatarData.adminRoomIds,
          ownerIds: avatarData.ownerIds,
          totalSocre: avatarData.totalSocre,
          entryID: avatarData.entryID,
          entryTimer: avatarData.entryTimer,
          level1: avatarData.level1,
          level2: avatarData.level2,
          level3: avatarData.newlevel3,
          newlevel3: _newLevel3,
          // Map SVGA badges from AvatarData lists if provided
          ws1: (avatarData.svgaSquareUrls != null && avatarData.svgaSquareUrls!.isNotEmpty)
              ? avatarData.svgaSquareUrls![0]
              : null,
          ws2: (avatarData.svgaSquareUrls != null && avatarData.svgaSquareUrls!.length > 1)
              ? avatarData.svgaSquareUrls![1]
              : null,
          ws3: (avatarData.svgaSquareUrls != null && avatarData.svgaSquareUrls!.length > 2)
              ? avatarData.svgaSquareUrls![2]
              : null,
          ws4: (avatarData.svgaSquareUrls != null && avatarData.svgaSquareUrls!.length > 3)
              ? avatarData.svgaSquareUrls![3]
              : null,
          ws5: (avatarData.svgaSquareUrls != null && avatarData.svgaSquareUrls!.length > 4)
              ? avatarData.svgaSquareUrls![4]
              : null,
          ic1: (avatarData.svgaRectUrls != null && avatarData.svgaRectUrls!.isNotEmpty)
              ? avatarData.svgaRectUrls![0]
              : null,
          ic2: (avatarData.svgaRectUrls != null && avatarData.svgaRectUrls!.length > 1)
              ? avatarData.svgaRectUrls![1]
              : null,
          ic3: (avatarData.svgaRectUrls != null && avatarData.svgaRectUrls!.length > 2)
              ? avatarData.svgaRectUrls![2]
              : null,
          ic4: (avatarData.svgaRectUrls != null && avatarData.svgaRectUrls!.length > 3)
              ? avatarData.svgaRectUrls![3]
              : null,
          ic5: (avatarData.svgaRectUrls != null && avatarData.svgaRectUrls!.length > 4)
              ? avatarData.svgaRectUrls![4]
              : null,
          ic6: (avatarData.svgaRectUrls != null && avatarData.svgaRectUrls!.length > 5)
              ? avatarData.svgaRectUrls![5]
              : null,
          ic7: (avatarData.svgaRectUrls != null && avatarData.svgaRectUrls!.length > 6)
              ? avatarData.svgaRectUrls![6]
              : null,
          ic8: (avatarData.svgaRectUrls != null && avatarData.svgaRectUrls!.length > 7)
              ? avatarData.svgaRectUrls![7]
              : null,
          ic9: (avatarData.svgaRectUrls != null && avatarData.svgaRectUrls!.length > 8)
              ? avatarData.svgaRectUrls![8]
              : null,
          ic10: (avatarData.svgaRectUrls != null && avatarData.svgaRectUrls!.length > 9)
              ? avatarData.svgaRectUrls![9]
              : null,
          ic11: (avatarData.svgaRectUrls != null && avatarData.svgaRectUrls!.length > 10)
              ? avatarData.svgaRectUrls![10]
              : null,
          ic12: (avatarData.svgaRectUrls != null && avatarData.svgaRectUrls!.length > 11)
              ? avatarData.svgaRectUrls![11]
              : null,
          ic13: (avatarData.svgaRectUrls != null && avatarData.svgaRectUrls!.length > 12)
              ? avatarData.svgaRectUrls![12]
              : null,
          ic14: (avatarData.svgaRectUrls != null && avatarData.svgaRectUrls!.length > 13)
              ? avatarData.svgaRectUrls![13]
              : null,
          ic15: (avatarData.svgaRectUrls != null && avatarData.svgaRectUrls!.length > 14)
              ? avatarData.svgaRectUrls![14]
              : null,
        );

        widget.roomCubit.addUser(newUser);
        _presentUserIds.add(uid);
        // Enrich this user with latest badges/frame via ZIM extendedData
        try {
          widget.roomCubit.refreshUserData(uid);
        } catch (_) {}
      } catch (e) {
        log('Error processing member join: $e', error: e);
      }
    }
  }

  void _logMemberJoin(ZIMUserInfo member) {
    log("Member joined - ID: ${member.userID}, Name: ${member.userName}, Avatar: ${member.userAvatarUrl}");
  }

  void _addSystemMessage(ZIMUserInfo member) async {
    if (!mounted) return;

    final systemMessage = ZIMBarrageMessage(
      message: '${member.userName} انضم إلى الغرفة',
    );
    final DateTime now = DateTime.now();

    // استخراج بيانات العضو الجديد بدلاً من المستخدم الحالي
    final avatarData = AvatarData.fromEncodedString(member.userAvatarUrl);

    // التأكد من استخدام بيانات العضو الجديد وليس المستخدم الحالي
    Map<String, dynamic> customData = {
      "UserImage": "${avatarData.imageUrl}",
      "UserVipLevel": int.tryParse(avatarData.vipLevel.toString()),
      "UserName": member.userName,
      "UserID": member.userID,
      "gift_type": 'entry',
      "dateTime": now.toIso8601String(),
    };

    // تحويل الكائن إلى JSON string
    systemMessage.extendedData = jsonEncode(customData);

    // إضافة الرسالة إلى المدير المحسن
    OptimizedMessageManager.instance
        .addMessage(widget.room.id.toString(), systemMessage);
    try {
      log('[JoinFlow] system entry message added for user=${member.userID} name=${member.userName}');
    } catch (_) {}
  }

  void _showJoinNotification(ZIMUserInfo member) {
    try {
      final avatarData = AvatarData.fromEncodedString(member.userAvatarUrl);
      try {
        log('[JoinNotify] parsed avatarData for uid=${member.userID}: entryID=${avatarData.entryID}, entryTimer=${avatarData.entryTimer}');
      } catch (_) {}

      // Safely parse timer (fallback to 6 seconds on invalid/missing values)
      final int timerSeconds =
          int.tryParse(avatarData.entryTimer?.trim() ?? '') ?? 6;

      // Normalize entryId (avoid using literal 'null' or empty strings)
      final String entryId = (avatarData.entryID != null &&
              avatarData.entryID!.trim().isNotEmpty &&
              avatarData.entryID!.trim().toLowerCase() != 'null')
          ? avatarData.entryID!.trim()
          : '';
      log('[JoinNotify] computed timerSeconds=$timerSeconds entryId="$entryId" for uid=${member.userID}');

      // Try to resolve a direct SVGA link for this entry from RoomCubit (server users list)
      String? entryLink = avatarData.entryLink?.trim();
      String? entryImgUrl;
      try {
        final usersServer = widget.roomCubit.state.usersServer;
        if (usersServer != null && usersServer.isNotEmpty) {
          log('[JoinNotify] scanning usersServer(size=${usersServer.length}) for uid=${member.userID}');
          for (final u in usersServer) {
            if (u.iduser == member.userID || (u.id != null && u.id == member.userID)) {
              final link = u.entrylink?.trim();
              if (link != null && link.isNotEmpty && link.toLowerCase() != 'null') {
                entryLink = link;
              }
              final img = u.entryimg?.trim();
              if (img != null && img.isNotEmpty && img.toLowerCase() != 'null') {
                entryImgUrl = img;
              }
              log('[JoinNotify] usersServer match uid=${member.userID} link=${entryLink ?? 'N/A'} img=${entryImgUrl ?? 'N/A'}');
              break;
            }
          }
        }
      } catch (_) {}

      final notificationEntity = GiftEntity(
        userId: member.userID,
        userName: member.userName,
        giftId: (entryId.isNotEmpty ? entryId : 'entry_${member.userID}'),
        giftType: 'entry',
        giftCount: 1,
        giftPoints: 1,
        timestamp: DateTime.now().millisecondsSinceEpoch,
        timer: timerSeconds,
        // Fallback: if no SVGA link, pass an image URL for GiftOverlay to animate
        imgGift: (entryLink == null || entryLink.isEmpty) ? entryImgUrl : null,
        imgUser: null,
        // Pass direct download URL when available so GiftsShowSection can fetch it if not cached
        link: entryLink,
      );

      void _dispatch(GiftEntity e, {String reason = 'direct'}) {
        log("[JoinNotify] dispatch reason=$reason user=${member.userName}(${member.userID}) entryId=${e.giftId} timer=$timerSeconds link=${e.link ?? 'N/A'} img=${e.imgGift ?? 'N/A'}");
        WidgetsBinding.instance.addPostFrameCallback((_) {
          if (!mounted) return;
          try {
            context.read<GiftsShowCubit>().showGiftAnimation(e, []);
          } catch (e, st) {
            log('Failed to dispatch join notification to GiftsShowCubit: $e', stackTrace: st);
          }
        });
      }

      // If we already have assets or a local SVGA file exists, dispatch immediately
      final localPath = entryId.isNotEmpty ? SvgaUtils.getValidFilePath(entryId) : null;
      final hasLocalFile = localPath != null && localPath.isNotEmpty;
      log('[JoinNotify] assets pre-check: localPath=${localPath ?? 'N/A'} link=${notificationEntity.link ?? 'N/A'} img=${notificationEntity.imgGift ?? 'N/A'}');
      final hasAssets = (notificationEntity.link != null && notificationEntity.link!.isNotEmpty) ||
          hasLocalFile ||
          (notificationEntity.imgGift != null && notificationEntity.imgGift!.isNotEmpty);

      if (hasAssets) {
        _dispatch(notificationEntity, reason: hasLocalFile ? 'local' : 'preresolved');
      } else {
        // Try to resolve quickly via server profile
        () async {
          try {
            String? fetchedLink;
            String? fetchedImg;
            UserEntity? fetchedUser; // hold a parsed user for fallback usage
            int? fetchedTimerSeconds; // optional timer from entry list

            // If this is the current user (self-join), prefer myprofile
            try {
              final me = await AuthService.getUserFromSharedPreferences();
              if (me?.iduser == member.userID) {
                log('[JoinNotify] fetching /user/myprofile for self uid=${member.userID}');
                final resp = await ApiService().get('/user/myprofile');
                final raw = resp.data;
                final Map<String, dynamic> parsed = raw is String ? jsonDecode(raw) : Map<String, dynamic>.from(raw as Map);
                final u = UserEntity.fromJson(parsed['user'] as Map<String, dynamic>);
                fetchedLink = u.entrylink?.trim();
                fetchedImg = u.entryimg?.trim();
                fetchedUser = u;

                // Try to resolve from 'entry' array ONLY if there is an active == 'yes' item
                try {
                  if ((fetchedLink == null || fetchedLink.isEmpty)) {
                    final entriesRaw = parsed['entry'];
                    if (entriesRaw is List && entriesRaw.isNotEmpty) {
                      Map<String, dynamic>? selected;
                      for (final e in entriesRaw) {
                        if (e is Map) {
                          final m = Map<String, dynamic>.from(e);
                          final isActive = m['active']?.toString().toLowerCase() == 'yes';
                          if (isActive) {
                            selected = m;
                            break;
                          }
                        }
                      }
                      if (selected != null) {
                        final ln = selected['link']?.toString().trim();
                        if (ln != null && ln.isNotEmpty && ln.toLowerCase() != 'null') {
                          fetchedLink = ln;
                        }
                        final t = selected['timer'] ?? selected['date1'];
                        final ts = t == null ? null : int.tryParse(t.toString());
                        if (ts != null && ts > 0) fetchedTimerSeconds = ts;
                      }
                    }
                  }
                } catch (_) {}
                log('[JoinNotify] fetched self profile entryLink=${fetchedLink ?? 'N/A'} entryImg=${fetchedImg ?? 'N/A'}');
              }
            } catch (_) {}

            // If still not found or not self, try search by id
            if (fetchedLink == null || fetchedLink.isEmpty) {
              try {
                log('[JoinNotify] fetching /user/search?id=${member.userID}');
                final resp = await ApiService().get('/user/search?id=${member.userID}');
                final raw = resp.data;
                final Map<String, dynamic> parsed = raw is String ? jsonDecode(raw) : Map<String, dynamic>.from(raw as Map);
                final list = parsed['user'];
                if (list is List && list.isNotEmpty) {
                  final u = UserEntity.fromJson(Map<String, dynamic>.from(list.first as Map));
                  fetchedLink = u.entrylink?.trim() ?? fetchedLink;
                  fetchedImg = u.entryimg?.trim() ?? fetchedImg;
                  fetchedUser ??= u;
                  log('[JoinNotify] fetched search entryLink=${fetchedLink ?? 'N/A'} entryImg=${fetchedImg ?? 'N/A'}');
                }
              } catch (_) {}
            }

            if ((fetchedLink != null && fetchedLink.isNotEmpty) || (fetchedImg != null && fetchedImg.isNotEmpty)) {
              final updated = GiftEntity(
                userId: notificationEntity.userId,
                userName: notificationEntity.userName,
                giftId: notificationEntity.giftId,
                giftType: notificationEntity.giftType,
                giftCount: notificationEntity.giftCount,
                giftPoints: notificationEntity.giftPoints,
                timestamp: notificationEntity.timestamp,
                timer: fetchedTimerSeconds ?? notificationEntity.timer,
                imgGift: (fetchedLink == null || fetchedLink.isEmpty)
                    ? (fetchedImg ?? notificationEntity.imgGift)
                    : notificationEntity.imgGift,
                imgUser: notificationEntity.imgUser,
                link: (fetchedLink != null && fetchedLink.isNotEmpty) ? fetchedLink : null,
              );
              _dispatch(updated, reason: 'fetched');
            } else {
              // Requirement: never fall back to frame if entry is absent
              log('[JoinNotify] no entry assets resolved for ${member.userName} (id=${member.userID}); skipping frame fallback');
            }
          } catch (e, st) {
            log('Error resolving entry assets: $e', stackTrace: st);
          }
        }();
      }
    } catch (e, st) {
      log('Error in _showJoinNotification: $e', stackTrace: st);
    }
  }

  void loginRoom() async {
    final token = kIsWeb
        ? ZegoTokenUtils.generateToken(
            SDKKeyCenter.appID,
            SDKKeyCenter.serverSecret,
            ZEGOSDKManager().currentUser!.iduser,
          )
        : null;
    _dlog('Current RoomID: ${widget.room.id}');
    await ZegoLiveAudioRoomManager()
        .loginRoom(widget.room.id.toString(), role, token: token)
        .then((result) async {
      if (result.errorCode == 0) {
        hostTakeSeat();

        // اضبط توجيه الصوت فوراً (LiveKit)
        try {
          pageContext.read<LiveKitAudioCubit>().setSpeaker(true);
        } catch (_) {}
        _configureAudioForRole();
        // LiveKit: لا حاجة لإلغاء كتم عالمي للتدفقات

        // جلب المستخدمين المتصلين في الخلفية ثم فرض إعادة حساب التخطيط
        try {
          unawaited(() async {
            await widget.roomCubit
                .fetchOnlineUsersFromRoom(widget.room.id.toString());
            if (mounted) _forceLayoutRecalculation();
          }());
        } catch (_) {}
        //
        // Pull latest profile and push encoded AvatarData to ZIM extendedData (non-blocking)
        try {
          unawaited(widget.userCubit.getProfileUser('room_login'));
        } catch (_) {}
        
        // Prefer up-to-date UserCubit state; fallback to cached SharedPreferences
        final UserEntity? currentUser =
            widget.userCubit.user ?? widget.userCubit.state.user ??
            await AuthService.getUserFromSharedPreferences();
        if (currentUser != null) {
          final avatarData = AvatarData(
            imageUrl: currentUser.img,
            frameId: currentUser.elementFrame?.elamentId,
            frameLink: currentUser.elementFrame?.linkPath,
            vipLevel: currentUser.vip,
            entryID: currentUser.entryID,
            entryTimer: currentUser.entryTimer,
            entryLink: currentUser.entrylink,
            totalSocre: currentUser.totalSocre,
            newlevel3: currentUser.newlevel3,
            ownerIds: currentUser.ownerIds,
            adminRoomIds: currentUser.adminRoomIds,
            svgaSquareUrls: [
              currentUser.ws1,
              currentUser.ws2,
              currentUser.ws3,
              currentUser.ws4,
              currentUser.ws5,
            ]
                .where((s) => s != null && s!.trim().isNotEmpty && s!.trim() != 'null')
                .map((e) => e!.trim())
                .toList(),
            svgaRectUrls: [
              currentUser.ic1,
              currentUser.ic2,
              currentUser.ic3,
              currentUser.ic4,
              currentUser.ic5,
              currentUser.ic6,
              currentUser.ic7,
              currentUser.ic8,
              currentUser.ic9,
              currentUser.ic10,
              currentUser.ic11,
              currentUser.ic12,
              currentUser.ic13,
              currentUser.ic14,
              currentUser.ic15,
            ]
                .where((s) => s != null && s!.trim().isNotEmpty && s!.trim() != 'null')
                .map((e) => e!.trim())
                .toList(),
          );
          final ZIMUserInfo user = ZIMUserInfo(
            userID: currentUser.iduser,
            userName: currentUser.name ?? "",
            userAvatarUrl: avatarData.toEncodedString(),
          );

          _logMemberJoin(user);
          _addSystemMessage(user);
          _showJoinNotification(user);
          // دمج شارات/إطار ملف المستخدم المحدثة داخل usersZego لضمان اتساق العرض
          try {
            final profile = widget.userCubit.user ?? widget.userCubit.state.user;
            if (profile != null) {
              widget.roomCubit.mergeUserProfileIntoZego(profile);
            }
          } catch (_) {}
        } else {
          _dlog('loginRoom: currentUser is null; skipping join notifications');
        }
        //
      } else {
        WidgetsBinding.instance.addPostFrameCallback((_) {
          _dlog('HomeView RoomViewBody if (result.errorCode != 0)');
          if (!RoomExitService.isExiting) {
            RoomExitService.exitRoom(
              context: pageContext,
              userCubit: widget.userCubit,
              roomCubit: widget.roomCubit,
              delayDuration: Duration.zero,
            );
          }
        });
      }
    });
  }

  void _configureAudioForRole() {
    try {
      // اختيار السيناريو المناسب: جودة عالية للمتحدث/المضيف، قياسي للمستمع
      final isSpeakerRole = role == ZegoLiveAudioRoomRole.host ||
          role == ZegoLiveAudioRoomRole.speaker;
      final scenario = isSpeakerRole
          ? ZegoScenario.HighQualityChatroom
          : ZegoScenario.StandardChatroom;
      ZEGOSDKManager().expressService.setRoomScenario(scenario);
    } catch (e) {
      _dlog('Failed to apply audio scenario: $e', error: e);
    }
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    super.didChangeAppLifecycleState(state);
    _dlog('App lifecycle state changed: $state');

    switch (state) {
      case AppLifecycleState.resumed:
        _dlog('App resumed - checking room connection');
        // التحقق من حالة الاتصال عند العودة للمقدمة
        _checkAndRestoreConnection();
        break;
      case AppLifecycleState.paused:
      case AppLifecycleState.inactive:
        _dlog('App paused/inactive');
        break;
      case AppLifecycleState.detached:
        _dlog('App detached');
        break;
      case AppLifecycleState.hidden:
        _dlog('App hidden');
        break;
    }

    if (mounted) setState(() {});
  }

  /// فحص واستعادة الاتصال عند العودة من الخلفية
  void _checkAndRestoreConnection() async {
    try {
      // التحقق من حالة الاتصال - استخدام الطرق المتاحة
      _dlog('Checking room connection status...');

      // التحقق من حالة المقاعد كمؤشر على الاتصال
      final seatList = ZegoLiveAudioRoomManager().seatList;
      final isConnected = seatList.isNotEmpty;

      _dlog('Seat list status: ${seatList.length} seats available');

      // إذا كانت قائمة المقاعد فارغة، قد نحتاج لإعادة الاتصال
      if (!isConnected) {
        _dlog('Connection appears lost - attempting to restore');
        await _restoreRoomConnection();
      } else {
        _dlog('Connection appears stable');
      }
    } catch (e) {
      _dlog('Error checking connection: $e', error: e);
    }
  }

  /// استعادة اتصال الغرفة
  Future<void> _restoreRoomConnection() async {
    try {
      _dlog('Restoring room connection...');

      // إعادة تحميل بيانات الغرفة
      await widget.roomCubit.fetchOnlineUsersFromRoom(
        widget.room.id.toString(),
      );

      // فرض إعادة حساب تخطيط الشات بعد استعادة الاتصال
      _forceLayoutRecalculation();

      // التأكد من حالة المقاعد
      final seatList = ZegoLiveAudioRoomManager().seatList;
      if (seatList.isNotEmpty) {
        _dlog('Seat list available: ${seatList.length} seats');
      } else {
        _dlog('Seat list empty - may need room re-login');
      }

      _dlog('Room connection restored successfully');
    } catch (e) {
      _dlog('Error restoring room connection: $e', error: e);
    }
  }

  /// معالجة فشل إعادة الاتصال
  void _handleReconnectionFailure() async {
    try {
      _dlog('Handling reconnection failure - attempting manual login');

      // محاولة إعادة تسجيل الدخول يدوياً
      await Future.delayed(const Duration(seconds: 2));

      if (mounted) {
        loginRoom();
      }
    } catch (e) {
      _dlog('Error in manual reconnection: $e', error: e);
    }
  }

  /// الحصول على رسالة خطأ واضحة للمستخدم
  String _getConnectionErrorMessage(
      int errorCode, ZegoRoomStateChangedReason reason) {
    switch (errorCode) {
      case 1002001:
        return 'الغرفة متصلة بالفعل';
      case 1002002:
        return 'فشل في الاتصال بالغرفة';
      case 1002003:
        return 'انقطع الاتصال بالغرفة';
      case 1002004:
        return 'تم طردك من الغرفة';
      case 1002005:
        return 'الغرفة غير موجودة';
      case 1002006:
        return 'الغرفة ممتلئة';
      default:
        switch (reason) {
          case ZegoRoomStateChangedReason.LoginFailed:
            return 'فشل في دخول الغرفة';
          case ZegoRoomStateChangedReason.ReconnectFailed:
            return 'فشل في إعادة الاتصال';
          case ZegoRoomStateChangedReason.KickOut:
            return 'تم طردك من الغرفة';
          default:
            return 'خطأ في الاتصال: $errorCode';
        }
    }
  }

  @override
  void dispose() {
    // تنظيف الرتل الموحد
    _unifiedGiftQueue.close();

    // تنظيف نظام منع التكرار
    _giftDelayTimer?.cancel();
    for (final timer in _giftIdTimers.values) {
      timer.cancel();
    }
    _giftIdTimers.clear();
    _processedGiftIds.clear();
    _pendingGifts.clear();

    // تنظيف ValueNotifier
    isApplyStateNotifier.dispose();
    WidgetsBinding.instance.removeObserver(this);
    super.dispose();
    _controller.dispose();
    _zegoDelegate.stopSoundLevelMonitor();
    _zegoDelegate.stopAudioSpectrumMonitor();
    _soundLevelTicker?.cancel();
    _publishWatchdog?.cancel();
    _playbackWatchdog?.cancel();
    for (final notifier in seatSoundNotifiers) {
      notifier.dispose();
    }
    // LiveKit: remove level listener
    if (ExpressService.instance.useLiveKitAudio) {
      try {
        LiveKitAudioService.instance.removeRemoteSoundLevelListener(_onLkRemoteLevels);
      } catch (_) {}
    }
    for (final subscription in subscriptions) {
      subscription.cancel();
    }
    luckBagCubit.close();
    _zegoDelegate.dispose();
    // إلغاء تفعيل وضع الأداء العالي
    PerformanceManager().disableHighPerformanceMode();
    // تجنب تنظيف الذاكرة الثقيل أثناء التصغير إلى الـ Overlay لتفادي الوميض الرمادي والتأخير
    if (audioRoomOverlayController.pageStateNotifier.value !=
        XOverlayPageState.overlaying) {
      PerformanceManager().cleanupMemory();
    }
    if (XOverlayPageState.overlaying !=
        audioRoomOverlayController.pageStateNotifier.value) {
      _messagesStore.clearMessages();
      ZegoLiveAudioRoomManager().logoutRoom();
      final userId = ZEGOSDKManager().currentUser?.iduser;
      if (userId != null) {
        widget.roomCubit.removeUserById(userId);
      }
    }

    for (final subscription in subscriptions) {
      subscription.cancel();
    }
  }

  void _addDeleteAllMessagesMessage() async {
    final UserEntity? userAuth =
        await AuthService.getUserFromSharedPreferences();

    final systemMessage = ZIMBarrageMessage(
      message: "${userAuth?.name} قام بحذف رسائل الغرفة",
    );
    final DateTime now = DateTime.now();

    Map<String, dynamic> customData = {
      "UserName": "${userAuth?.name}",
      "UserID": "${userAuth?.iduser}",
      "gift_type": "deleteAllMessages",
      "UserImage": "${userAuth?.img}",
      "UserVipLevel": int.tryParse("${userAuth?.vip}"),
      "dateTime": now.toIso8601String(),
    };
    // تحويل الكائن إلى JSON string
    systemMessage.extendedData = jsonEncode(customData);
    // أضف الرسالة عبر OptimizedMessageManager لعرضها مباشرة
    OptimizedMessageManager.instance
        .addMessage(widget.room.id.toString(), systemMessage);
    if (!mounted) return;
  }

  /// حذف جميع رسائل الدردشة محلياً عبر OptimizedMessageManager (مصدر العرض الحالي)
  void _deleteAllMessages() {
    OptimizedMessageManager.instance.clearMessages();
  }

  ///////////////////////////////////////////////////////////
  ///////////////////////////////////////////////////////////
  ///////////////////////////////////////////////////////////
  ///////////////////////////////////////////////////////////
  ///////////////////////////////////////////////////////////
  ///////////////////////////////////////////////////////////
  ///////////////////////////////////////////////////////////
  ///////////////////////////////////////////////////////////
  ///////////////////////////////////////////////////////////
  ///////////////////////////////////////////////////////////
  void _initSoundMonitoring() async {
    try {
      // Slight delay to avoid competing with first frame work
      await Future.delayed(const Duration(milliseconds: 300));
      await _zegoDelegate.startSoundLevelMonitor();
      // لا تبدأ AudioSpectrum إلا عند الحاجة لتقليل استهلاك المعالجة
      // await _zegoDelegate.startAudioSpectrumMonitor();
      _dlog('Sound level monitoring started');
    } catch (e) {
      _dlog('Failed to start sound monitoring: $e', error: e);
    }
  }

  void onCapturedSoundLevelUpdate(double soundLevel) {
    if (!mounted) return;
    // Cache latest local level; applied by ticker
    _pendingLocalLevel = soundLevel;
  }

  int? _findSeatIndexByUserId(String userId) {
    // البحث في جميع المقاعد عن المستخدم المطابق
    for (int i = 0; i < ZegoLiveAudioRoomManager().seatList.length; i++) {
      final seat = ZegoLiveAudioRoomManager().seatList[i];
      final user = seat.currentUser.value;
      if (user != null && user.iduser == userId) {
        return i;
      }
    }
    return null;
  }

  void _startSoundTicker(Duration interval) {
    _soundLevelTicker?.cancel();
    _soundLevelTicker = Timer.periodic(interval, (_) {
      if (!mounted) return;

      // Apply local level to corresponding seat
      final localLevel = _pendingLocalLevel;
      if (localLevel != null) {
        final localUserId = ZEGOSDKManager().currentUser?.iduser;
        if (localUserId != null) {
          final localSeat = _findSeatIndexByUserId(localUserId);
          if (localSeat != null &&
              localSeat >= 0 &&
              localSeat < seatSoundNotifiers.length) {
            final prev = seatSoundNotifiers[localSeat].value;
            if ((localLevel - prev).abs() > 0.02) {
              seatSoundNotifiers[localSeat].value = localLevel;
            }
          }
        }
      }

      // Apply remote levels to respective seats
      if (_pendingRemoteSoundLevels.isNotEmpty) {
        final entries = Map<String, double>.from(_pendingRemoteSoundLevels);
        _pendingRemoteSoundLevels.clear();
        entries.forEach((streamId, level) {
          final seatIndex = _findSeatIndexByStreamId(streamId);
          if (seatIndex != null &&
              seatIndex >= 0 &&
              seatIndex < seatSoundNotifiers.length) {
            final prev = seatSoundNotifiers[seatIndex].value;
            if ((level - prev).abs() > 0.02) {
              seatSoundNotifiers[seatIndex].value = level;
            }
          }
        });
      }
    });
  }

  void onRemoteSoundLevelUpdate(Map<String, double> soundLevels) {
    if (!mounted) return;
    // Merge latest remote levels; applied by ticker
    for (final e in soundLevels.entries) {
      _pendingRemoteSoundLevels[e.key] = e.value;
    }
  }

  int? _findSeatIndexByStreamId(String streamId) {
    try {
      // تحليل streamId لاستخراج userId
      final parts = streamId.split('_');
      if (parts.length >= 2) {
        final userId = parts[1];

        // البحث في جميع المقاعد عن المستخدم المطابق
        for (int i = 0; i < ZegoLiveAudioRoomManager().seatList.length; i++) {
          final seat = ZegoLiveAudioRoomManager().seatList[i];
          final user = seat.currentUser.value;
          if (user != null && user.iduser == userId) {
            return i;
          }
        }
      }
    } catch (e) {
      log('Error finding seat by streamId: $e');
    }
    return null;
  }

  Future<void> hostTakeSeat() async {
    if (role == ZegoLiveAudioRoomRole.host) {
      //take seat
      await ZegoLiveAudioRoomManager().setSelfHost(widget.room.id.toString());
      // await ZegoLiveAudioRoomManager()
      //     .takeSeat(0, widget.room.id.toString(), isForce: false)
      //     .then((result) {
      //   if (mounted &&
      //       ((result == null) ||
      //           result.errorKeys
      //               .contains(ZEGOSDKManager().currentUser!.iduser!))) {}
      // }).catchError((error) {});
    }
  }

  //////////////////////////////////////////////////////////

  Widget seatListView(RoomCubitState state) {
    // اعتمد دائماً على القيمة الأحدث من حالة الغرفة إن توفرت
    final String micStr =
        state.room?.microphoneNumber ?? widget.room.microphoneNumber;
    final int newMicrophoneNumber = int.tryParse(micStr) ?? 10;

    // تسجيل تغيير عدد الميكروفونات
    if (newMicrophoneNumber != microphoneNumber) {
      _dlog(
          'Microphone number changed: $microphoneNumber -> $newMicrophoneNumber');
    }

    microphoneNumber = newMicrophoneNumber;
    _ensureSeatNotifiersCount(microphoneNumber);

    if (state.status.isRoomLoaded) {
      final currentUser = widget.userCubit.user;
      if (currentUser != null) {
        final isOwner =
            (currentUser.ownerIds?.contains(widget.room.id.toString())) ??
                false;
        final isAdmin =
            (currentUser.adminRoomIds?.contains(widget.room.id.toString())) ??
                false;

        final seatList = ZegoLiveAudioRoomManager().seatList;
        if (seatList.isEmpty) {
          return SizedBox(height: 300);
        }
        // تم تعيين microphoneNumber مسبقاً من الحالة، لا تعيد التعيين هنا
        _ensureSeatNotifiersCount(microphoneNumber);
        if (isOwner || isAdmin) {
          role = ZegoLiveAudioRoomRole.host;
        }
      }
    }

    // احسب عدد العناصر الآمن توليده بحسب حالة تحميل قائمة المقاعد
    final allSeats = ZegoLiveAudioRoomManager().seatList.length;
    // لتفادي الرجوع المؤقت، اعرض دائماً حتى الحد الأدنى المتاح بين قائمة المقاعد الحالية والعدد المطلوب
    final int totalSeats =
        (allSeats < microphoneNumber ? allSeats : microphoneNumber);
    _ensureSeatNotifiersCount(totalSeats);

    // إذا لم تتوفر أي مقاعد بعد، لا تنشئ GridView (تجنب crossAxisCount = 0)
    if (totalSeats <= 0) {
      return const SizedBox(height: 300);
    }

    // GridView.builder لتحسين الأداء بدلاً من Wrap
    final screenWidth = MediaQuery.of(context).size.width;
    int columns = _safeScale(72.w, 72.0) > 0
        ? (screenWidth / _safeScale(72.w, 72.0)).floor()
        : (screenWidth / 72.0).floor();
    if (columns > totalSeats) columns = totalSeats;
    if (columns < 1) columns = 1;

    return SizedBox(
      width: MediaQuery.of(context).size.width,
      child: GridView.builder(
        key: const ValueKey('seat_grid'),
        shrinkWrap: true,
        physics: const NeverScrollableScrollPhysics(),
        padding: EdgeInsets.zero,
        gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
          crossAxisCount: columns,
          mainAxisSpacing: 0,
          crossAxisSpacing: 0,
          childAspectRatio: _safeScale(72.w, 72.0) / _safeScale(90.h, 90.0),
        ),
        itemCount: totalSeats,
        itemBuilder: (context, seatIndex) {
          final seatNotifier = seatSoundNotifiers[seatIndex];
          return ValueListenableBuilder<Map<String, Map<String, bool>>>(
            valueListenable:
                ZegoLiveAudioRoomManager().lockedSeatsPerRoomNotifier,
            builder: (context, lockedSeatsPerRoom, _) {
              final lockedSeats =
                  lockedSeatsPerRoom[widget.room.id.toString()] ?? {};
              final isLocked = lockedSeats[seatIndex.toString()] ?? false;
              return ValueListenableBuilder<UserEntity?>(
                valueListenable:
                    ZegoLiveAudioRoomManager().seatList[seatIndex].currentUser,
                builder: (context, user, _) {
                  final isMenuShow = !(user == null &&
                      isLocked == true &&
                      role != ZegoLiveAudioRoomRole.host);
                  final seatWidget = KeyedSubtree(
                    key: ValueKey('seat_$seatIndex'),
                    child: RepaintBoundary(
                      child: ZegoSeatItemView(
                        roomCubit: widget.roomCubit,
                        userCubit: widget.userCubit,
                        micNum: totalSeats,
                        indexmic: seatIndex,
                        seatIndex: seatIndex,
                        roomId: widget.room.id.toString(),
                        soundLevel: seatNotifier,
                      ),
                    ),
                  );
                  return isMenuShow
                      ? FocusedMenuHolder(
                          menuWidth: 120,
                          menuItemExtent: 38,
                          animateMenuItems: true,
                          blurBackgroundColor: Colors.transparent,
                          blurSize: 0,
                          openWithTap: true,
                          menuOffset: 2,
                          bottomOffsetHeight: 20,
                          enableMenuScroll: false,
                          menuItems: getMenuItemsList(
                              seatIndex, role, isLocked, user, state),
                          onPressed: () {},
                          child: seatWidget,
                        )
                      : seatWidget;
                },
              );
            },
          );
        },
      ),
    );
  }

  //////////////////////////////////////////////////////////
  //////////////////////////////////////////////////////////
  //////////////////////////////////////////////////////////
  //////////////////////////////////////////////////////////
  //////////////////////////////////////////////////////////
  //////////////////////////////////////////////////////////
  //////////////////////////////////////////////////////////
  //////////////////////////////////////////////////////////
  //////////////////////////////////////////////////////////
  //////////////////////////////////////////////////////////
  //////////////////////////////////////////////////////////
  //////////////////////////////////////////////////////////
  //////////////////////////////////////////////////////////
  //////////////////////////////////////////////////////////
  //////////////////////////////////////////////////////////
  //////////////////////////////////////////////////////////
  //////////////////////////////////////////////////////////
  //////////////////////////////////////////////////////////
  //////////////////////////////////////////////////////////
  //////////////////////////////////////////////////////////
  //////////////////////////////////////////////////////////
  //////////////////////////////////////////////////////////
  //////////////////////////////////////////////////////////
  //////////////////////////////////////////////////////////
  //////////////////////////////////////////////////////////
  //////////////////////////////////////////////////////////
  //////////////////////////////////////////////////////////
  //////////////////////////////////////////////////////////
  //////////////////////////////////////////////////////////
  //////////////////////////////////////////////////////////
  //////////////////////////////////////////////////////////
  //////////////////////////////////////////////////////////
  //////////////////////////////////////////////////////////
  //////////////////////////////////////////////////////////
  //////////////////////////////////////////////////////////
  //////////////////////////////////////////////////////////
  //////////////////////////////////////////////////////////

  List<FocusedMenuItem> getMenuItemsList(
      int seatIndex,
      ZegoLiveAudioRoomRole role,
      bool isLocked,
      UserEntity? user,
      RoomCubitState state) {
    // If there's a user in the mic seat
    if (user != null) {
      return _getMenuItemsForOccupiedSeat(seatIndex, role, state);
    }
    // If the mic seat is empty
    else {
      return _getMenuItemsForEmptySeat(seatIndex, role, isLocked);
    }
  }

  /// Returns menu items for cases when the seat is occupied by a user
  List<FocusedMenuItem> _getMenuItemsForOccupiedSeat(
      int seatIndex, ZegoLiveAudioRoomRole role, RoomCubitState state) {
    // log("ZegoLiveAudioRoomManager().seatList[seatIndex].currentUser.value = ${ZegoLiveAudioRoomManager().seatList[seatIndex].currentUser.value}");
    final userEntity =
        ZegoLiveAudioRoomManager().seatList[seatIndex].currentUser.value;
    final currentSeatUser = userEntity?.fromOwnAvatarData();
    final meUserId = ZEGOSDKManager().currentUser?.iduser;
    final roomOwnerId = widget.room.owner;
    // log("User Role ${currentSeatUser?.iduser}: $role -- is admin : ${currentSeatUser?.ownerIds} -- is owner : ${currentSeatUser?.adminRoomIds} }");
    // Case 1: Current user is host and selected themselves
    if (role == ZegoLiveAudioRoomRole.host &&
        currentSeatUser?.iduser == meUserId) {
      return [
        leaveMicMenuItem(),
        profileMenuItem(currentSeatUser!),
        sendGiftMenuItem(seatIndex),
      ];
    }

    // Case 2: Current user is host and selected the room owner (not themselves)
    if (role == ZegoLiveAudioRoomRole.host &&
        currentSeatUser?.iduser != meUserId &&
        currentSeatUser?.iduser == roomOwnerId) {
      return [
        sendGiftMenuItem(seatIndex),
        profileMenuItem(currentSeatUser!),
      ];
    }

    // Case 3: Current user is host and selected another regular user
    if (role == ZegoLiveAudioRoomRole.host &&
        currentSeatUser?.iduser != meUserId &&
        currentSeatUser?.iduser != roomOwnerId) {
      final items = [
        switchSeatMenuItem(seatIndex),
        muteMenuItem(seatIndex),
        removeSpeakerMenuItem(seatIndex),
        kickOutMenuItem(seatIndex),
        sendGiftMenuItem(seatIndex),
        profileMenuItem(currentSeatUser!),
      ];

      if (meUserId == roomOwnerId) {
        final isUserAdmin =
            currentSeatUser.adminRoomIds?.contains(widget.room.id.toString()) ??
                false;
        if (isUserAdmin) {
          items.add(removeAdminMenuItem(seatIndex));
        } else {
          items.add(addAdminMenuItem(seatIndex));
        }
      }

      return items;
    }
    // Case 4: Non-host user selected themselves
    if (role != ZegoLiveAudioRoomRole.host &&
        currentSeatUser?.iduser == meUserId) {
      return [
        leaveMicMenuItem(),
        profileMenuItem(currentSeatUser!),
        sendGiftMenuItem(seatIndex),
      ];
    }

    // Default case for non-host selecting another user
    return [
      sendGiftMenuItem(seatIndex),
      profileMenuItem(currentSeatUser!),
    ];
  }

  /// Returns menu items for cases when the seat is empty
  List<FocusedMenuItem> _getMenuItemsForEmptySeat(
    int seatIndex,
    ZegoLiveAudioRoomRole role,
    bool isLocked,
  ) {
    // Original behavior (before invite feature):
    // - If seat is locked: only host sees unlock item
    // - If seat is not locked: host sees take mic + lock; audience sees take mic
    if (isLocked) {
      return role == ZegoLiveAudioRoomRole.host
          ? [lockSpecificSeat(seatIndex)]
          : [];
    }
    if (role == ZegoLiveAudioRoomRole.host) {
      return [
        takeMicMenuItem(seatIndex),
        lockSpecificSeat(seatIndex),
      ];
    } else {
      return [takeMicMenuItem(seatIndex)];
    }
  }
  // INVITE_FREEZE: inviteToMicMenuItem() is disabled. Re-enable by uncommenting below.
  // FocusedMenuItem inviteToMicMenuItem(int seatIndex) {
  //   return FocusedMenuItem(
  //     title: Row(
  //       mainAxisAlignment: MainAxisAlignment.start,
  //       crossAxisAlignment: CrossAxisAlignment.center,
  //       children: const [
  //         Icon(FontAwesomeIcons.microphone, size: 12),
  //         SizedBox(width: 4),
  //         Text('دعوة', style: TextStyle(fontSize: 13, fontWeight: FontWeight.w500)),
  //       ],
  //     ),
  //     onPressed: () {
  //       UsersBottomSheet.showBasicModalBottomSheet(
  //         context,
  //         widget.onSend,
  //         userCubit: widget.userCubit,
  //         roomCubit: widget.roomCubit,
  //         roomId: widget.room.id,
  //         users: widget.roomCubit.state.usersZego ?? [],
  //         isAdd: true,
  //         icon: FontAwesomeIcons.microphone,
  //         onUserAction: (roomId, userId, how) async {
  //           final inviterRole = role == ZegoLiveAudioRoomRole.host ? 'host' : 'admin';
  //           await MicInviteService.sendInvite(
  //             roomId: widget.room.id.toString(),
  //             receiverId: userId,
  //             seatIndex: seatIndex,
  //             inviterRole: inviterRole,
  //           );
  //         },
  //       );
  //     },
  //   );
  // }

  FocusedMenuItem addAdminMenuItem(int seatIndex) {
    return FocusedMenuItem(
      title: Row(
        mainAxisAlignment: MainAxisAlignment.start,
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          const Icon(
            FontAwesomeIcons.circleUser,
            size: 12,
          ),
          const SizedBox(width: 4),
          SizedBox(
            width: 70,
            child: AutoSizeText(
              S.of(context).admin,
              textAlign: TextAlign.center,
              style: const TextStyle(
                fontSize: 13,
                fontWeight: FontWeight.w500,
              ),
            ),
          ),
        ],
      ),
      onPressed: () async {
        await widget.roomCubit.addAdminToRoom(
            widget.room.id,
            ZegoLiveAudioRoomManager()
                .seatList[seatIndex]
                .currentUser
                .value!
                .iduser);
        widget.roomCubit.refreshUserData(ZegoLiveAudioRoomManager()
            .seatList[seatIndex]
            .currentUser
            .value!
            .iduser);

        // kickOutRoomMethod(
        //     ZegoLiveAudioRoomManager().seatList[seatIndex].currentUser.value!);
      },
    );
  }

  FocusedMenuItem removeAdminMenuItem(int seatIndex) {
    return FocusedMenuItem(
      title: Row(
        mainAxisAlignment: MainAxisAlignment.start,
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          const Icon(
            FontAwesomeIcons.userSlash,
            size: 12,
          ),
          const SizedBox(width: 4),
          SizedBox(
            width: 70,
            child: AutoSizeText(
              S.of(context).admin,
              textAlign: TextAlign.center,
              style: const TextStyle(
                fontSize: 13,
                fontWeight: FontWeight.w500,
              ),
            ),
          ),
        ],
      ),
      onPressed: () async {
        await widget.roomCubit.removeAdminFromRoom(
            widget.room.id,
            ZegoLiveAudioRoomManager()
                    .seatList[seatIndex]
                    .currentUser
                    .value!
                    .id ??
                ZegoLiveAudioRoomManager()
                    .seatList[seatIndex]
                    .currentUser
                    .value!
                    .iduser);
      },
    );
  }

  FocusedMenuItem takeMicMenuItem(int seatIndex) {
    return FocusedMenuItem(
      title: Row(
        mainAxisAlignment: MainAxisAlignment.start,
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          const Icon(
            FontAwesomeIcons.microphone,
            size: 12,
          ),
          const SizedBox(
            width: 4,
          ),
          AutoSizeText(
            S.of(context).take,
            textAlign: TextAlign.center,
            style: const TextStyle(
              fontSize: 13,
              fontWeight: FontWeight.w500,
            ),
          ),
        ],
      ),
      onPressed: () {
        getLocalUserSeatIndex() != -1
            ? ZegoLiveAudioRoomManager()
                .switchSeat(getLocalUserSeatIndex(), seatIndex)
            : takeSeatMethod(seatIndex);
      },
    );
  }

  FocusedMenuItem sendGiftMenuItem(int seatIndex) {
    return FocusedMenuItem(
      title: Row(
        mainAxisAlignment: MainAxisAlignment.start,
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          const Icon(
            FontAwesomeIcons.gift,
            size: 12,
          ),
          const SizedBox(width: 4),
          SizedBox(
            width: 70,
            child: AutoSizeText(
              S.of(context).sendGift,
              textAlign: TextAlign.center,
              style: const TextStyle(
                fontSize: 13,
                fontWeight: FontWeight.w500,
              ),
            ),
          ),
        ],
      ),
      onPressed: () {
        GiftsBottomSheetWidget.showBasicModalBottomSheet(
            context,
            widget.userCubit.user!,
            widget.room.id.toString(),
            widget.userCubit,
            context.read<GiftsShowCubit>(),
            widget.onSend, []); // 123412341234
      },
    );
  }

  FocusedMenuItem kickOutMenuItem(int seatIndex) {
    return FocusedMenuItem(
      title: Row(
        mainAxisAlignment: MainAxisAlignment.start,
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          const Icon(
            FontAwesomeIcons.ban,
            size: 12,
          ),
          const SizedBox(width: 4),
          SizedBox(
            width: 70,
            child: AutoSizeText(
              S.of(context).kickOut,
              textAlign: TextAlign.center,
              style: const TextStyle(
                fontSize: 13,
                fontWeight: FontWeight.w500,
              ),
            ),
          ),
        ],
      ),
      onPressed: () {
        removeSpeakerFromSeatMethod(ZegoLiveAudioRoomManager()
            .seatList[seatIndex]
            .currentUser
            .value!
            .iduser);
        log("kick out --  seatIndex $seatIndex --${ZegoLiveAudioRoomManager().seatList[seatIndex].currentUser.value!.iduser}");
        kickOutRoomMethod(ZegoLiveAudioRoomManager()
            .seatList[seatIndex]
            .currentUser
            .value!
            .iduser);
        widget.roomCubit.banUserFromRoom(
            widget.room.id,
            ZegoLiveAudioRoomManager()
                .seatList[seatIndex]
                .currentUser
                .value!
                .iduser,
            "1h");
      },
    );
  }

  FocusedMenuItem switchSeatMenuItem(int seatIndex) {
    return FocusedMenuItem(
      title: Row(
        mainAxisAlignment: MainAxisAlignment.start,
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          const Icon(
            FontAwesomeIcons.chair,
            size: 12,
          ),
          const SizedBox(width: 4),
          SizedBox(
            width: 70,
            child: AutoSizeText(
              S.of(context).switchh,
              textAlign: TextAlign.center,
              style: const TextStyle(
                fontSize: 13,
                fontWeight: FontWeight.w500,
              ),
            ),
          ),
        ],
      ),
      onPressed: () {
        final currentSeat = getLocalUserSeatIndex();
        if (currentSeat == -1) return;

        // Stop current publishing
        _zegoDelegate.stopPublishing();

        ZegoLiveAudioRoomManager()
            .switchSeat(currentSeat, seatIndex)
            .then((result) {
          // Start publishing with new stream ID
          final newStreamID =
              '${widget.room.id}_${ZEGOSDKManager().currentUser!.iduser}_$seatIndex';
          _zegoDelegate.startPublishing(newStreamID);
        });
      },
    );
  }

  FocusedMenuItem removeSpeakerMenuItem(int seatIndex) {
    return FocusedMenuItem(
      title: Row(
        mainAxisAlignment: MainAxisAlignment.start,
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          const Icon(
            // FontAwesomeIcons.volumeMute,
            FontAwesomeIcons.arrowDown,
            size: 12,
          ),
          const SizedBox(width: 4),
          SizedBox(
            width: 70,
            child: AutoSizeText(
              S.of(context).down,
              textAlign: TextAlign.center,
              style: const TextStyle(
                fontSize: 13,
                fontWeight: FontWeight.w500,
              ),
            ),
          ),
        ],
      ),
      onPressed: () {
        removeSpeakerFromSeatMethod(ZegoLiveAudioRoomManager()
            .seatList[seatIndex]
            .currentUser
            .value!
            .iduser);
      },
    );
  }

  FocusedMenuItem lockSpecificSeat(int seatIndex) {
    return FocusedMenuItem(
      title: Row(
        mainAxisAlignment: MainAxisAlignment.start,
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          const Icon(
            FontAwesomeIcons.lock,
            size: 12,
          ),
          const SizedBox(width: 4),
          SizedBox(
            width: 70,
            child: AutoSizeText(
              S.of(context).lock,
              textAlign: TextAlign.center,
              style: const TextStyle(
                fontSize: 13,
                fontWeight: FontWeight.w500,
              ),
            ),
          ),
        ],
      ),
      onPressed: () {
        ZegoLiveAudioRoomManager()
            .lockSpecificSeat(seatIndex, widget.room.id.toString());
      },
    );
  }

  FocusedMenuItem leaveMicMenuItem() {
    return FocusedMenuItem(
      title: Row(
        mainAxisAlignment: MainAxisAlignment.start,
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          const Icon(
            FontAwesomeIcons.microphoneSlash,
            size: 12,
          ),
          const SizedBox(width: 4),
          SizedBox(
            width: 70,
            child: AutoSizeText(
              S.of(context).leaveMic,
              textAlign: TextAlign.center,
              style: const TextStyle(
                fontSize: 13,
                fontWeight: FontWeight.w500,
              ),
            ),
          ),
        ],
      ),
      onPressed: () {
        leaveMicrophoneMethod();
      },
    );
  }

  FocusedMenuItem profileMenuItem(UserEntity user) {
    return FocusedMenuItem(
      title: Row(
        mainAxisAlignment: MainAxisAlignment.start,
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          const Icon(
            FontAwesomeIcons.solidCircleUser,
            size: 12,
          ),
          const SizedBox(width: 4),
          SizedBox(
            width: 70,
            child: AutoSizeText(
              S.of(context).userProfile,
              textAlign: TextAlign.center,
              style: const TextStyle(
                fontSize: 13,
                fontWeight: FontWeight.w500,
              ),
            ),
          ),
        ],
      ),
      onPressed: () {
        if (user.iduser != kNoDefaultValue) {
          UserVIPBottomSheetWidget.showBasicModalBottomSheet(
            context,
            user,
            widget.roomCubit,
            widget.room.id.toString(),
            widget.onSend,
          );
        }
      },
    );
  }

  FocusedMenuItem muteMenuItem(int seatIndex) {
    return FocusedMenuItem(
      title: Row(
        mainAxisAlignment: MainAxisAlignment.start,
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          const Icon(
            FontAwesomeIcons.microphone,
            size: 12,
          ),
          const SizedBox(width: 4),
          SizedBox(
            width: 70,
            child: AutoSizeText(
              S.of(context).mute,
              textAlign: TextAlign.center,
              style: const TextStyle(
                fontSize: 13,
                fontWeight: FontWeight.w500,
              ),
            ),
          ),
        ],
      ),
      onPressed: () async {
        final target = ZegoLiveAudioRoomManager()
            .seatList[seatIndex]
            .currentUser
            .value;
        if (target == null) return;
        // If target is not self: send a MUTE command to that user
        if (target.iduser != widget.userCubit.user?.iduser) {
          ZegoLiveAudioRoomManager().muteSpeaker(target.iduser, true);
          return;
        }
        // If target is self: force mic OFF (mute)
        try {
          if (ExpressService.instance.useLiveKitAudio) {
            await LiveKitAudioService.instance
                .setMicrophoneEnabled(false, reason: 'menu:mute_self');
          } else {
            await muteMicrophoneForYourself(true);
          }
          widget.userCubit.user!.isMicOnNotifier.value = false;
        } catch (_) {}
      },
    );
  }

  ///////////////////////////////////////////////////////////

  void takeSeatMethod(int seatIndex) {
    final seat = ZegoLiveAudioRoomManager().seatList[seatIndex];

    // حالة المضيف (Host)
    if (ZegoLiveAudioRoomManager().roleNoti.value ==
        ZegoLiveAudioRoomRole.host) {
      ZegoLiveAudioRoomManager()
          .takeSeat(seat.seatIndex, widget.room.id.toString(), isForce: true)
          .then((result) {
        if (mounted) {
          if (result != null &&
              result.errorKeys.contains(ZEGOSDKManager().currentUser!.iduser)) {
            SnackbarHelper.showMessage(context, S.of(context).takeSeatFailed);
          } else {
            // بدء البث هنا بعد نجاح أخذ المقعد
            final streamID =
                '${widget.room.id}_${ZEGOSDKManager().currentUser!.iduser}_$seatIndex';
            _zegoDelegate.startPublishing(streamID);
            log('Host started publishing: $streamID');
          }
        }
      }).catchError((error) {
        SnackbarHelper.showMessage(
            context, '${S.of(context).takeSeatFailed} $error');
      });
    }

    // حالة الجمهور (Audience)
    if (seat.currentUser.value == null &&
        ZegoLiveAudioRoomManager().roleNoti.value ==
            ZegoLiveAudioRoomRole.audience) {
      ZegoLiveAudioRoomManager()
          .takeSeat(seat.seatIndex, widget.room.id.toString())
          .then((result) {
        if (mounted && result != null) {
          if (result.errorKeys.any(
              (element) => element == ZEGOSDKManager().currentUser!.iduser)) {
            SnackbarHelper.showMessage(context, S.of(context).takeSeatFailed);
          } else {
            // بدء البث هنا بعد نجاح أخذ المقعد
            final streamID =
                '${widget.room.id}_${ZEGOSDKManager().currentUser!.iduser}';
            _zegoDelegate.startPublishing(streamID);
            log('Audience started publishing: $streamID');
          }
        }
      }).catchError((error) {
        SnackbarHelper.showMessage(
            context, '${S.of(context).takeSeatFailed} $error');
      });
    }

    if (ZegoLiveAudioRoomManager().roleNoti.value ==
            ZegoLiveAudioRoomRole.speaker &&
        getLocalUserSeatIndex() != -1) {
      ZegoLiveAudioRoomManager()
          .switchSeat(getLocalUserSeatIndex(), seat.seatIndex)
          .then((result) {
        if (result != null) {
          // إعادة البث عند تبديل المقعد
          final newStreamID =
              '${widget.room.id}_${ZEGOSDKManager().currentUser!.iduser}';
          if (ExpressService.instance.useLiveKitAudio) {
            // في وضع LiveKit: لا حاجة لإعادة النشر، أبقِ المايك مفعّلاً
            try {
              LiveKitAudioService.instance
                  .setMicrophoneEnabled(true, reason: 'switchSeat');
            } catch (_) {}
            log('Speaker switched seat (LiveKit): mic kept ON; no re-publish');
          } else {
            _zegoDelegate.stopPublishing();
            _zegoDelegate.startPublishing(newStreamID);
            log('Speaker switched seat and started publishing: $newStreamID');
          }
        }
      });
    }
  }

  ///////////////////////////////////////////////////////////
  int getLocalUserSeatIndex() {
    for (final element in ZegoLiveAudioRoomManager().seatList) {
      if (element.currentUser.value?.iduser ==
          ZEGOSDKManager().currentUser!.iduser) {
        return element.seatIndex;
      }
    }
    return -1;
  }

  ///////////////////////////////////////////////////////////
  Future<void> muteMicrophoneForYourself(bool mute) async {
    if (ExpressService.instance.useLiveKitAudio) {
      // In LiveKit, enable=false means muted
      await LiveKitAudioService.instance
          .setMicrophoneEnabled(!mute, reason: 'self-mute');
      return;
    }
    return ZegoExpressEngine.instance.muteMicrophone(mute);
  }

  PopupMenuItem<dynamic> customPopupMenuItem(String name, IconData icon) {
    return PopupMenuItem<dynamic>(
      value: name,
      child: Row(
        children: [
          Padding(
              padding: const EdgeInsets.only(right: 8.0), child: Icon(icon)),
          AutoSizeText(
            name,
            style: const TextStyle(fontSize: 15),
          ),
        ],
      ),
    );
  }

  void leaveMicrophoneMethod() {
    ValueNotifier<bool> isApplyStateNotifier = ValueNotifier(false);

    // TEMP/FIX: Always cut local audio immediately when leaving mic
    try {
      context.read<LiveKitAudioCubit>().toggleMic(false);
    } catch (_) {}

    for (final element in ZegoLiveAudioRoomManager().seatList) {
      if (element.currentUser.value?.iduser ==
          ZEGOSDKManager().currentUser!.iduser) {
        ZegoLiveAudioRoomManager().leaveSeat(element.seatIndex).then((value) {
          _zegoDelegate.stopPublishing();
          ZegoLiveAudioRoomManager().roleNoti.value =
              ZegoLiveAudioRoomRole.audience;
          isApplyStateNotifier.value = false;
        });
      }
    }
  }

  Future<ZIMRoomAttributesOperatedCallResult?> removeSpeakerFromSeatMethod(
          String targetUserID) =>
      ZegoLiveAudioRoomManager().removeSpeakerFromSeat(targetUserID);

  Future<ZIMMessageSentResult> kickOutRoomMethod(String targetUserIduser) =>
      ZegoLiveAudioRoomManager().kickOutRoom(targetUserIduser);
  //////////////////////////////////////////////////////////
  void takeSeatResult() {}

  // zim listener
  void onInComingRoomRequest(OnInComingRoomRequestReceivedEvent event) {}

  void onInComingRoomRequestCancelled(
    OnInComingRoomRequestCancelledEvent event,
  ) {}

  void onInComingRoomRequestTimeOut() {}

  void onOutgoingRoomRequestAccepted(OnOutgoingRoomRequestAcceptedEvent event) {
    isApplyStateNotifier.value = false;
    for (final seat in ZegoLiveAudioRoomManager().seatList) {
      if (seat.currentUser.value == null) {
        ZegoLiveAudioRoomManager()
            .takeSeat(
          seat.seatIndex,
          widget.room.id.toString(),
        )
            .then((result) {
          if (mounted &&
              ((result == null) ||
                  result.errorKeys
                      .contains(ZEGOSDKManager().currentUser!.iduser))) {}
        }).catchError((error) {});

        break;
      }
    }
  }

  void onOutgoingRoomRequestRejected(OnOutgoingRoomRequestRejectedEvent event) {
    isApplyStateNotifier.value = false;
    currentRequestID = null;
  }

  void onExpressRoomStateChanged(ZegoRoomStateEvent event) {
    debugAppLogger.debug('AudioRoomPage:onExpressRoomStateChanged: $event');
    _dlog(
        'Express room state changed: ${event.reason}, errorCode: ${event.errorCode}');

    if (event.errorCode != 0) {
      debugAppLogger
          .debug('Room state error: ${event.errorCode} - ${event.reason}');
      _dlog('Room connection error: ${event.errorCode} - ${event.reason}');

      // عرض رسالة خطأ واضحة للمستخدم
      String errorMessage =
          _getConnectionErrorMessage(event.errorCode, event.reason);
      SnackbarHelper.showMessage(context, errorMessage);
    }

    // معالجة حالات إعادة الاتصال
    if (event.reason == ZegoRoomStateChangedReason.ReconnectFailed) {
      _dlog('Reconnection failed - attempting manual reconnection');
      _handleReconnectionFailure();
    } else if (event.reason == ZegoRoomStateChangedReason.Reconnecting) {
      _dlog('Attempting to reconnect...');
    } else if (event.reason == ZegoRoomStateChangedReason.Reconnected) {
      _dlog('Successfully reconnected to room');
      // إنهاء حماية التبديل بعد نجاح إعادة الاتصال
      RoomSwitchGuard.end();
      // إعادة تحميل بيانات الغرفة بعد إعادة الاتصال
      _restoreRoomConnection();
    }
    if ((event.reason == ZegoRoomStateChangedReason.KickOut) ||
        (event.reason == ZegoRoomStateChangedReason.ReconnectFailed) ||
        (event.reason == ZegoRoomStateChangedReason.LoginFailed)) {
      // تجاهل العودة إلى الرئيسية إذا كنا في حالة تبديل غرفة
      if (RoomSwitchGuard.isSwitching) {
        _dlog('Guard active: suppress home navigation during room switch');
        return;
      }
      if (!RoomExitService.isExiting) {
        RoomExitService.exitRoom(
          context: pageContext,
          userCubit: widget.userCubit,
          roomCubit: widget.roomCubit,
          delayDuration: Duration.zero,
        );
      }
    }
  }

  void onZIMRoomStateChanged(ZIMServiceRoomStateChangedEvent event) {
    debugAppLogger.debug('AudioRoomPage:onZIMRoomStateChanged: $event');
    if ((event.event != ZIMRoomEvent.success) &&
        (event.state != ZIMRoomState.connected)) {}
    if (event.state == ZIMRoomState.disconnected) {
      // أثناء التبديل، قد يحدث قطع اتصال مؤقت - تجاهله
      if (RoomSwitchGuard.isSwitching) {
        _dlog('Guard active: ignore ZIM disconnected during room switch');
        return;
      }
      if (!RoomExitService.isExiting) {
        RoomExitService.exitRoom(
          context: pageContext,
          userCubit: widget.userCubit,
          roomCubit: widget.roomCubit,
          delayDuration: Duration.zero,
        );
      }
    }
  }

  ///
  ///
  void onRoomCommandReceived(OnRoomCommandReceivedEvent event,
      UserCubit userCubit, RoomCubit roomCubit) {
    try {
      final Map<String, dynamic> messageMap = jsonDecode(event.command);
      log('~~~~~~~~~~~~~~~~ Parsed message map: $messageMap',
          name: 'onRoomCommandReceived');

      if (messageMap.containsKey('room_command_type')) {
        final type = messageMap['room_command_type'];
        final receiverID = messageMap['receiver_id'];

        if (receiverID == ZEGOSDKManager().currentUser!.iduser) {
          if (type == RoomCommandType.muteSpeaker) {
            log('You have been muted by the host');
            try {
              pageContext.read<LiveKitAudioCubit>().toggleMic(false);
            } catch (_) {}
          } else if (type == RoomCommandType.unMuteSpeaker) {
            log('You have been unmuted by the host');
            try {
              pageContext.read<LiveKitAudioCubit>().toggleMic(true);
            } catch (_) {}
          } else if (type == RoomCommandType.kickOutRoom) {
            log('You have been kicked out of the room');
            RoomExitService.exitRoom(
              context: pageContext,
              userCubit: widget.userCubit,
              roomCubit: widget.roomCubit,
            );
            log("HomeView ZegoSeatItemView RoomCommandType.kickOutRoom");
          }
        }
      }
      // INVITE_FREEZE: invite handling is disabled. Re-enable by uncommenting below.
      // if (messageMap['type'] == MicInviteService.typeInvite) { ... }
      // if (messageMap['type'] == MicInviteService.typeInviteResponse) { ... }
    } catch (e, st) {
      log('onRoomCommandReceived error: $e', error: e, stackTrace: st);
    }
  }

  ///
  ///
  ///
  void onZIMConnectionStateChanged(
    ZIMServiceConnectionStateChangedEvent event,
  ) {
    debugAppLogger.debug('AudioRoomPage:onZIMConnectionStateChanged: $event');

    if (event.state == ZIMConnectionState.disconnected) {
      if (!RoomExitService.isExiting) {
        RoomExitService.exitRoom(
          context: pageContext,
          userCubit: widget.userCubit,
          roomCubit: widget.roomCubit,
          delayDuration: Duration.zero,
        );
      }
    }
  } //
  ////////////////////////////////////////////////
  ////////////////////////////////////////////////
  ////////////////////////////////////////////////
  ////////////////////////////////////////////////
  ////////////////////////////////////////////////
  ////////////////////////////////////////////////
  ////////////////////////////////////////////////
  ////////////////////////////////////////////////
  ////////////////////////////////////////////////
  ////////////////////////////////////////////////
  ////////////////////////////////////////////////
  ////////////////////////////////////////////////
  ////////////////////////////////////////////////
  ////////////////////////////////////////////////
  ////////////////////////////////////////////////
  ////////////////////////////////////////////////
  ////////////////////////////////////////////////
  ////////////////////////////////////////////////
  ////////////////////////////////////////////////
  ////////////////////////////////////////////////
  ////////////////////////////////////////////////
  ////////////////////////////////////////////////
  ////////////////////////////////////////////////
  ////////////////////////////////////////////////
  ////////////////////////////////////////////////
  ////////////////////////////////////////////////
  ////////////////////////////////////////////////
  ////////////////////////////////////////////////
  ////////////////////////////////////////////////
  ////////////////////////////////////////////////
  ////////////////////////////////////////////////
  ////////////////////////////////////////////////
  ////////////////////////////////////////////////
  ////////////////////////////////////////////////
  ////////////////////////////////////////////////
  ////////////////////////////////////////////////
  ////////////////////////////////////////////////
  ////////////////////////////////////////////////
  ////////////////////////////////////////////////
  ////////////////////////////////////////////////
  ////////////////////////////////////////////////
  ////////////////////////////////////////////////
  ////////////////////////////////////////////////
  ////////////////////////////////////////////////
  ////////////////////////////////////////////////
  ////////////////////////////////////////////////
  ////////////////////////////////////////////////
  ////////////////////////////////////////////////
  ////////////////////////////////////////////////
  ////////////////////////////////////////////////
  ////////////////////////////////////////////////
  ////////////////////////////////////////////////
  ////////////////////////////////////////////////
  ////////////////////////////////////////////////
  ////////////////////////////////////////////////
  ////////////////////////////////////////////////
  ////////////////////////////////////////////////
  ////////////////////////////////////////////////
  ////////////////////////////////////////////////
  ////////////////////////////////////////////////
  ////////////////////////////////////////////////
  ////////////////////////////////////////////////
  ////////////////////////////////////////////////
  ////////////////////////////////////////////////
  ////////////////////////////////////////////////
  ////////////////////////////////////////////////
  ////////////////////////////////////////////////

  BlocListener<GiftsShowCubit, GiftsShowState> giftImageBloc() {
    return BlocListener<GiftsShowCubit, GiftsShowState>(
      listener: (context, state) async {
        _logGiftInfo('Received state: ${state.runtimeType}');

        if (state is GiftShow && mounted) {
          final giftType = state.giftEntity.giftType.toLowerCase();
          _logGiftInfo('🎁 LISTENER: Gift event received', extra: {
            'type': giftType,
            'giftId': state.giftEntity.giftId,
            'count': state.giftEntity.giftCount,
            'sender': state.giftEntity.userId,
            'recipients': state.usersID.length,
          });

          // Only process Lucky gifts
          if (giftType != 'lucky') {
            _logGiftInfo('⏭️ SKIP: Non-lucky gift ignored',
                extra: {'type': giftType});
            return;
          }

          // إنشاء معرف فريد للهدية لمنع التكرار المطلق
          final uniqueGiftId = _buildUniqueGiftId(
            gift: state.giftEntity,
            senderId: state.giftEntity.userId.toString(),
            receiverId: state.usersID.join('_'),
          );

          // فحص منع التكرار المطلق
          if (_processedGiftIds.contains(uniqueGiftId)) {
            _logGiftInfo('🚫 BLOCKED: Duplicate gift detected', extra: {
              'giftId': uniqueGiftId,
              'type': giftType,
              'processedCount': _processedGiftIds.length,
            });
            return;
          }

          // إضافة للمعرفات المعالجة
          _processedGiftIds.add(uniqueGiftId);
          _logGiftInfo('✅ NEW: Gift added to processed list', extra: {
            'giftId': uniqueGiftId,
            'processedCount': _processedGiftIds.length,
          });

          // إزالة المعرف بعد 10 ثوان لتجنب تراكم الذاكرة
          _giftIdTimers[uniqueGiftId]?.cancel();
          _giftIdTimers[uniqueGiftId] = Timer(const Duration(seconds: 10), () {
            _processedGiftIds.remove(uniqueGiftId);
            _giftIdTimers.remove(uniqueGiftId);
            _logGiftInfo('🧹 CLEANUP: Gift removed from processed list',
                extra: {
                  'giftId': uniqueGiftId,
                  'remainingCount': _processedGiftIds.length,
                });
          });

          // Lucky gifts: process once, but display the actual multiplier (giftCount)
          const bool isLucky = true;
          final int displayCount =
              (state.giftEntity.giftCount > 0) ? state.giftEntity.giftCount : 1;
          String giftsMany = displayCount.toString();
          final giftSender = state.giftEntity.userId.toString();
          final link = state.giftEntity.link?.toString();
          String? seatImageUrl = state.giftEntity.imgGift?.toString();

          // If no imgGift, but link looks like an image (png/jpg/webp/gif), use it
          if ((seatImageUrl == null || seatImageUrl.isEmpty) &&
              _looksLikeImageUrl(link)) {
            final normalized = _normalizeGiftUrl(link!);
            if (normalized != null) seatImageUrl = normalized;
          }

          // For lucky, allow animation even if there's no image by using a fallback
          if (isLucky && (seatImageUrl == null || seatImageUrl.isEmpty)) {
            seatImageUrl =
                ""; // Will trigger errorWidget (placeholder) in CachedNetworkImage
          }

          // For lucky, proceed even with empty image (placeholder will show). No count-based skipping.

          // Determine recipients: use provided usersID; if empty, fallback to all occupied seats
          final List<String> recipientGroups = state.usersID.isNotEmpty
              ? state.usersID
              : ZegoLiveAudioRoomManager()
                  .seatList
                  .where((s) => s.currentUser.value != null)
                  .map((s) => s.currentUser.value!.iduser.toString())
                  .toList();

          _logGiftInfo('GiftShow received', extra: {
            'recipientsCount': recipientGroups.length,
            'senderId': giftSender,
          });

          final senderSeat = ZegoLiveAudioRoomManager()
              .seatList
              .firstWhereOrNull2(
                  (s) => s.currentUser.value?.iduser == giftSender);

          if (senderSeat == null) {
            _logGiftInfo('Sender seat not found; skipping animations',
                extra: {'senderId': giftSender});
            return;
          }

          // استخدام context الحالي بدلاً من scaffoldKey
          final senderOffset = _calculateSeatPosition(
            context: context,
            seatIndex: senderSeat.seatIndex,
            gridHeight: _calculateGridHeight(widget.room.microphoneNumber),
          );

          for (final rawUserIds in recipientGroups) {
            final splitUserIds = rawUserIds.split("_");

            for (final userId in splitUserIds) {
              try {
                _logGiftInfo('Processing user: $userId');

                final seat = ZegoLiveAudioRoomManager()
                    .seatList
                    .firstWhereOrNull2(
                        (s) => s.currentUser.value?.iduser == userId);

                if (seat == null) continue;

                final seatIndex = seat.seatIndex;
                final gridHeight =
                    _calculateGridHeight(widget.room.microphoneNumber);

                // استخدام context الحالي بدلاً من scaffoldKey
                final seatPosition = _calculateSeatPosition(
                  context: context,
                  seatIndex: seatIndex,
                  gridHeight: gridHeight,
                );

                // إنشاء بيانات الأنيميشن مع معرف فريد
                final animationData = GiftAnimationData(
                  imageUrl: seatImageUrl,
                  targetOffset: seatPosition,
                  senderOffset: senderOffset,
                  giftsMany: giftsMany,
                  delay: Duration.zero,
                  centerOffset: _calculateCenterOffset(context),
                  microphoneNumber: widget.room.microphoneNumber,
                  senderId: giftSender,
                  receiverId: userId,
                  count: displayCount,
                  giftId: _buildUniqueGiftId(
                    gift: state.giftEntity,
                    senderId: giftSender,
                    receiverId: userId,
                  ),
                  giftType: state.giftEntity.giftType, // إضافة نوع الهدية
                );

                // Lucky: استخدام نظام الانتظار لمنع التداخل
                if (state.giftEntity.giftType.toLowerCase() == 'lucky') {
                  _addGiftWithDelay(animationData);
                } else {
                  // الأنواع الأخرى: إضافة للرتل الموحد
                  _addGiftToUnifiedQueue(
                    giftEntity: state.giftEntity,
                    targetIds: [userId],
                    animationData: animationData,
                  );
                }
              } catch (e) {
                _logGiftInfo('Error processing user $userId',
                    extra: e.toString());
              }
            }
          }
        }
      },
      child: Container(),
    );
  }

// في _RoomViewState
  double _calculateGridHeight(String micNumber) {
    int num = int.parse(micNumber);
    return num == 20
        ? 340.0
        : num == 15
            ? 250.0
            : 170.0;
  }

  bool _looksLikeImageUrl(String? url) {
    if (url == null) return false;
    final u = url.trim().toLowerCase();
    return u.endsWith('.png') ||
        u.endsWith('.jpg') ||
        u.endsWith('.jpeg') ||
        u.endsWith('.webp') ||
        u.endsWith('.gif');
  }

  String? _normalizeGiftUrl(String url) {
    final t = url.trim();
    if (t.isEmpty) return null;
    if (t.startsWith('http://') || t.startsWith('https://')) return t;
    if (t.startsWith('//')) return 'https:$t';
    if (t.startsWith('lklklive.com')) return 'https://$t';
    if (t.startsWith('/')) return 'https://lklklive.com$t';
    return null;
  }

  Offset _calculateSeatPosition({
    required BuildContext context,
    required int seatIndex,
    required double gridHeight,
  }) {
    const columns = 5;
    final row = seatIndex ~/ columns;
    final column = seatIndex % columns;

    final screenWidth = MediaQuery.of(context).size.width;
    final seatWidth = screenWidth / columns;
    final rowsCount =
        (int.parse(widget.room.microphoneNumber) / columns).ceil();
    final seatHeight = gridHeight / rowsCount;

    final appBarHeight = kToolbarHeight;
    final statusBarHeight = MediaQuery.of(context).padding.top;
    const double infoRowHeight = 60.0; // مطابق لحسابات GiftAnimationWidget

    // مركز المقعد بدقة بدون إزاحات عشوائية
    final x = column * seatWidth + (seatWidth / 2);
    final y = appBarHeight +
        statusBarHeight +
        infoRowHeight +
        (row * seatHeight) +
        (seatHeight / 2);

    _logGiftInfo('Seat position debug:', extra: {
      'totalHeight': appBarHeight + statusBarHeight + gridHeight,
      'rowHeight': seatHeight,
      'calculatedY': y
    });
    return Offset(x, y);
  }

  // حساب موضع المركز للأنيميشن
  Offset _calculateCenterOffset(BuildContext context) {
    final media = MediaQuery.of(context);
    final statusBar = media.padding.top;
    const infoRowHeight = 60.0;
    final midX = media.size.width / 2;
    final gridHeight = _calculateGridHeight(widget.room.microphoneNumber);

    final midY =
        statusBar + kToolbarHeight + infoRowHeight + gridHeight + 12 + 60;
    return Offset(midX, midY);
  }

  // إضافة هدية للرتل الموحد
  void _addGiftToUnifiedQueue({
    required GiftEntity giftEntity,
    required List<String> targetIds,
    GiftAnimationData? animationData,
  }) {
    // Lucky: لا تمر عبر الرتل الموحد (بالفعل تمت إضافتها مباشرة أعلاه)
    if (giftEntity.giftType.toLowerCase() == 'lucky') {
      if (animationData != null && mounted) {
        setState(() {
          _activeAnimations.add(animationData);
        });
      }
      return;
    }

    // باقي الأنواع: استخدم الرتل الموحد + الحد الأقصى المحلي
    _unifiedGiftQueue.addGift(
      gift: giftEntity,
      targetIds: targetIds,
      animationData: animationData,
    );

    if (animationData != null &&
        _activeAnimations.length < _maxConcurrentGiftAnimations) {
      if (mounted) {
        setState(() {
          _activeAnimations.add(animationData);
        });
      }
    }
  }

  void _onGiftAnimationComplete(GiftAnimationData completed) {
    if (!mounted) return;

    // إشعار الرتل الموحد بانتهاء الأنيميشن
    _unifiedGiftQueue.onAnimationComplete(completed);

    setState(() {
      _activeAnimations.remove(completed);

      // إضافة الأنيميشن التالي من الرتل الموحد إذا كان متاحاً
      final nextAnimations = _unifiedGiftQueue.queuedAnimations;
      if (nextAnimations.isNotEmpty &&
          _activeAnimations.length < _maxConcurrentGiftAnimations) {
        // هذا سيتم تحسينه لاحقاً للعمل مع النظام الجديد
      }
    });
  }

  // نظام إضافة الهدايا مع انتظار لمنع التداخل
  void _addGiftWithDelay(GiftAnimationData animationData) {
    _logGiftInfo('⏰ DELAY_SYSTEM: Adding gift to queue', extra: {
      'giftId': animationData.giftId,
      'isProcessing': _isProcessingGift,
      'pendingCount': _pendingGifts.length,
      'activeCount': _activeAnimations.length,
    });

    // إضافة للقائمة المعلقة
    _pendingGifts.add(animationData);

    // إذا لم نكن نعالج هدية حالياً، ابدأ المعالجة
    if (!_isProcessingGift) {
      _processNextGift();
    }
  }

  // معالجة الهدية التالية في القائمة
  void _processNextGift() {
    if (_pendingGifts.isEmpty) {
      _isProcessingGift = false;
      _logGiftInfo('🏁 DELAY_SYSTEM: Queue empty, processing stopped');
      return;
    }

    _isProcessingGift = true;
    final nextGift = _pendingGifts.removeAt(0);

    _logGiftInfo('▶️ DELAY_SYSTEM: Processing next gift', extra: {
      'giftId': nextGift.giftId,
      'remainingPending': _pendingGifts.length,
      'activeCount': _activeAnimations.length,
    });

    // إضافة الهدية للعرض فوراً
    if (mounted) {
      setState(() {
        _activeAnimations.add(nextGift);
      });
      _logGiftInfo('✨ DELAY_SYSTEM: Gift added to active animations', extra: {
        'giftId': nextGift.giftId,
        'newActiveCount': _activeAnimations.length,
      });
    }

    // انتظار قبل معالجة الهدية التالية
    _giftDelayTimer?.cancel();
    _giftDelayTimer = Timer(_giftProcessingDelay, () {
      _logGiftInfo('⏰ DELAY_SYSTEM: Delay completed, processing next');
      _processNextGift();
    });
  }

  void backgroundMethod() async {
    const androidConfig = FlutterBackgroundAndroidConfig(
      notificationTitle: "Voice Call Active",
      notificationText: "Your call is ongoing in the background.",
      notificationImportance: AndroidNotificationImportance.high,
      // notificationIcon: AndroidResource(name: 'background_icon', defType: 'drawable'),
    );

    bool initialized =
        await FlutterBackground.initialize(androidConfig: androidConfig);
    if (initialized) {
      await FlutterBackground.enableBackgroundExecution();
    }
  }
}
