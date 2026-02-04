import 'dart:async';
import 'package:lklk/core/utils/logger.dart';
import 'package:flutter/material.dart';
import 'package:auto_size_text/auto_size_text.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:lklk/core/constants/app_colors.dart';
import 'package:lklk/core/constants/assets.dart';
import 'package:lklk/core/foreground_service_manager.dart';
import 'package:lklk/core/service_locator.dart';
import 'package:lklk/core/services/api_service.dart';
import 'package:lklk/core/widgets/overlay/defines.dart';
import 'package:lklk/features/auth/domain/entities/user_entity.dart';
import 'package:lklk/features/home/presentation/manger/room_messages_cubit/room_messages_cubit.dart';
import 'package:lklk/features/home/presentation/manger/top_bar_room_cubit/money_bag_top_bar_cubit.dart';
import 'package:lklk/features/home/presentation/manger/top_bar_room_cubit/top_bar_room_cubit.dart';
import 'package:lklk/features/room/domain/entities/room_entity.dart';
import 'package:lklk/features/room/presentation/manger/emoji_cubit/emoji_cubit.dart';
import 'package:lklk/features/room/presentation/manger/is_active_gifts_cubit/is_active_gifts_cubit.dart';
import 'package:lklk/features/room/presentation/manger/lucky_bag/luck_bag_cubit.dart';
import 'package:lklk/features/room/presentation/manger/room_exit_service.dart';
import 'package:lklk/features/room/presentation/views/widgets/background_image.dart';
import 'package:lklk/features/room/presentation/views/widgets/gift_show_sction_part.dart';
import 'package:lklk/features/room/presentation/views/widgets/gift_overlay.dart';
import 'package:lklk/features/room/presentation/views/widgets/money_bag_top_bar.dart';
import 'package:lklk/features/room/presentation/views/widgets/room_view_body.dart';
import 'package:lklk/features/room/presentation/views/widgets/top_bar_section.dart';
import 'package:lklk/features/room/presentation/views/widgets/smooth_room_transition.dart';
import 'package:lklk/features/room/presentation/views/widgets/high_density_room_manager.dart';
import 'package:lklk/features/room/presentation/views/widgets/optimized_message_manager.dart';
import 'package:lklk/core/room_visibility_manager.dart';
import 'package:lklk/generated/l10n.dart';
import 'package:lklk/live_audio_room_manager.dart';
import 'package:provider/single_child_widget.dart';
import 'package:x_overlay/x_overlay.dart';
import 'package:wakelock_plus/wakelock_plus.dart';
import 'package:lklk/features/profile_users/presentaion/manger/user_cubit/user_cubit_cubit.dart';
import 'package:lklk/features/home/presentation/manger/room_cubit/room_cubit_cubit.dart';
import 'package:lklk/features/home/presentation/views/home_view.dart';
import 'package:lklk/features/livekit_audio/presentation/cubit/livekit_audio_cubit.dart';

class RoomView extends StatefulWidget {
  const RoomView({
    super.key,
    required this.room,
    this.fromOverlay,
    required this.userCubit,
    required this.roomCubit,
    this.users,
    this.bannedUser,
    this.topUsers,
    required this.role,
    required this.adminUsers,
    this.useTransition = true,
    this.showOwnBackground = true,
  });

  final RoomEntity room;
  final bool? fromOverlay;
  final UserCubit userCubit;
  final RoomCubit roomCubit;
  final List<UserEntity>? users;
  final List<UserEntity>? adminUsers;
  final List<UserEntity>? bannedUser;
  final List<UserEntity>? topUsers;
  final ZegoLiveAudioRoomRole role;
  final bool useTransition;
  final bool showOwnBackground;

  @override
  State<RoomView> createState() => _RoomViewState();
}

class _RoomViewState extends State<RoomView>
    with WidgetsBindingObserver, TickerProviderStateMixin {
  final GlobalKey<ScaffoldState> _scaffoldKey = GlobalKey<ScaffoldState>();
  bool _isExiting = false;
  bool _exitTriggered = false;
  late BuildContext pageContext;
  void sendMessageRoomChat(ZIMMessage message) {
    if (mounted) {
      // استخدام OptimizedMessageManager المحسن
      OptimizedMessageManager.instance
          .addMessage(widget.room.id.toString(), message);
    }
  }

  Widget buildTopBars(double h) {
    return Stack(
      children: [
        Positioned(
          top: -20,
          left: 0,
          right: 0,
          child: SizedBox(
            height: h / 6,
            child: TopBarSection(
              roomCubit: widget.roomCubit,
              userCubit: widget.userCubit,
              roomID: widget.room.id.toString(),
              onSend: sendMessageRoomChat,
              // should listen to TopBarRoomCubit
            ),
          ),
        ),
        Positioned(
          top: 70, // overlap position
          left: 0,
          right: 0,
          child: SizedBox(
            height: h / 6,
            child: MoneyBagTopBar(
              roomCubit: widget.roomCubit,
              userCubit: widget.userCubit,
              roomID: widget.room.id.toString(),
              onSend: sendMessageRoomChat,
              // should listen to MoneyBagTopBarCubit
            ),
          ),
        ),
      ],
    );
  }

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addObserver(this);
    WakelockPlus.enable();
    ForegroundServiceManager.initialize();

    // سجل الغرفة الحالية واعتبرها مستأنفة الآن لضبط مرشح الهدايا بعد العودة من التصغير
    RoomVisibilityManager()
      ..setCurrentRoom(widget.room.id.toString())
      ..markResumed(widget.room.id.toString());

    // تأجيل التهيئات الثقيلة لما بعد أول إطار لتسريع الدخول
    final userCount = widget.users?.length ?? 0;
    WidgetsBinding.instance.addPostFrameCallback((_) {
      try {
        ForegroundServiceManager.startService(widget.room.name);
      } catch (_) {}
      try {
        HighDensityRoomManager.instance.initialize(userCount);
      } catch (_) {}
    });

    _initializeLuckBagCubit();
  }

  void _initializeLuckBagCubit() {
    final luckBagCubit = sl<LuckBagCubit>();
    // إعادة تعيين الـ Cubit إذا كان مغلقاً
    if (luckBagCubit.isClosed) {
      sl.resetLazySingleton<LuckBagCubit>();
    }
    resetLuckBagCubit();
  }

  @override
  void dispose() {
    WidgetsBinding.instance.removeObserver(this);

    super.dispose();
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    if (state == AppLifecycleState.resumed) {
      // عند العودة للتطبيق، حدّث وقت الاستئناف للغرفة الحالية
      RoomVisibilityManager()
        ..setCurrentRoom(widget.room.id.toString())
        ..markResumed(widget.room.id.toString());
    }

    if (
        // state == AppLifecycleState.paused ||
        state == AppLifecycleState.detached) {
      _ensureExitProcedure();
    }
  }

  Future<void> _ensureExitProcedure() async {
    if (!_exitTriggered) {
      log('Triggering exit from lifecycle state');
      await _safeExit();
    }
  }

  @override
  Widget build(BuildContext context) {
    pageContext = context;
    final double h = MediaQuery.of(context).size.height;

    final Widget scaffoldContent = Scaffold(
      key: _scaffoldKey,
      resizeToAvoidBottomInset: false,
      backgroundColor: widget.showOwnBackground ? null : Colors.transparent,
      body: Stack(
        children: [
          if (widget.showOwnBackground)
            BlocBuilder<RoomCubit, RoomCubitState>(
              bloc: widget.roomCubit,
              builder: (context, roomState) {
                final currentRoom = roomState.room ?? widget.room;
                return BackgroundImageWidget(
                  roomCubit: widget.roomCubit,
                  backgroundImage: currentRoom.background,
                );
              },
            ),

          // استخدام BlocListener + BlocBuilder للاستماع لتحديثات بيانات الغرفة
          BlocListener<RoomCubit, RoomCubitState>(
            bloc: widget.roomCubit,
            listener: (context, roomState) {
              // معالجة حالات التحديث
              if (roomState.status == RoomCubitStatus.roomUpdated) {
                log('🔄 Room data updated in UI: ${roomState.room?.name}');

                // إعادة تعيين الحالة بعد التحديث
                Future.delayed(const Duration(milliseconds: 100), () {
                  widget.roomCubit.resetUpdateStatus();
                });
              }
            },
            child: BlocBuilder<RoomCubit, RoomCubitState>(
              bloc: widget.roomCubit,
              builder: (context, roomState) {
                // استخدام البيانات المحدثة من RoomCubit إذا كانت متاحة
                final currentRoom = roomState.room ?? widget.room;
                final currentUsers = roomState.usersServer ?? widget.users;
                final currentBannedUsers =
                    roomState.bannedUsers ?? widget.bannedUser;
                final currentAdminUsers =
                    roomState.adminsListUsers ?? widget.adminUsers;

                return RoomViewBody(
                  onSend: sendMessageRoomChat,
                  fromOverlay: widget.fromOverlay,
                  userCubit: widget.userCubit,
                  room: currentRoom, // استخدام البيانات المحدثة
                  roomCubit: widget.roomCubit,
                  users: currentUsers, // استخدام البيانات المحدثة
                  bannedUsers: currentBannedUsers, // استخدام البيانات المحدثة
                  role: widget.role,
                  adminUsers: currentAdminUsers, // استخدام البيانات المحدثة
                );
              },
            ),
          ),

          // Gift overlay for animations (must be before top bars to show behind them)
          BlocBuilder<RoomCubit, RoomCubitState>(
            bloc: widget.roomCubit,
            builder: (context, roomState) {
              final currentRoom = roomState.room ?? widget.room;
              return GiftOverlay(
                enabled: true,
                room: currentRoom,
                gridHeight: h * 0.4, // تقدير ارتفاع الشبكة
              );
            },
          ),

          // gift svga show and top bars overlays
          giftsSvgaShow(h),
          buildTopBars(h),
        ],
      ),
    );

    final Widget maybeTransitioned = widget.useTransition
        ? SmoothRoomTransition(
            backgroundColor:
                widget.showOwnBackground ? Colors.black : Colors.transparent,
            fadeInDuration: Duration.zero,
            child: scaffoldContent,
          )
        : scaffoldContent;

    return PopScope(
        onPopInvokedWithResult: (didPop, result) async {
          if (didPop) {
            return;
          }
          await exitAndMinimizeDialog(context, pageContext);
        },
        canPop: false,
        child: MultiBlocProvider(
          providers: providersMultiBlocProvider,
          child: SafeArea(
            top: false,
            child: maybeTransitioned,
          ),
        ));
  }

/////////////////////////////////////////////////////////////
/////////////////////////////////////////////////////////////
/////////////////////////////////////////////////////////////
/////////////////////////////////////////////////////////////
/////////////////////////////////////////////////////////////
/////////////////////////////////////////////////////////////
/////////////////////////////////////////////////////////////
/////////////////////////////////////////////////////////////
/////////////////////////////////////////////////////////////
/////////////////////////////////////////////////////////////
/////////////////////////////////////////////////////////////
/////////////////////////////////////////////////////////////
/////////////////////////////////////////////////////////////
/////////////////////////////////////////////////////////////
/////////////////////////////////////////////////////////////
/////////////////////////////////////////////////////////////
/////////////////////////////////////////////////////////////
/////////////////////////////////////////////////////////////
  Future<dynamic> exitAndMinimizeDialog(
      BuildContext context, BuildContext pageContext) {
    return showDialog(
      context: context,
      barrierDismissible: true,
      barrierLabel: '',
      barrierColor: Colors.black.withValues(alpha: 0.5),
      builder: (context) {
        return exitAndMinimizeDialogBody(pageContext, context);
      },
    );
  }

  Widget exitAndMinimizeDialogBody(
      BuildContext pageContext, BuildContext context) {
    return StatefulBuilder(builder: (context, setState) {
      return Center(
        child: AlertDialog(
          backgroundColor: AppColors.transparent,
          contentPadding: EdgeInsets.zero,
          content: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.center,
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              SizedBox(
                  height: 130,
                  width: 130,
                  child: overlayButton(
                    context: pageContext,
                    label: S.of(context).minimize,
                    icon: AssetsData.resizeIconBtn,
                  )),
              const SizedBox(
                height: 30,
                width: 30,
              ),
              SizedBox(
                height: 130,
                width: 130,
                child: _buildActionButton(
                  context: pageContext,
                  label: S.of(context).exit,
                  icon: AssetsData.exitIconBtn,
                  onPressed: () async {
                    if (_isExiting) return;
                    setState(() => _isExiting = true);

                    try {
                      log("HomeView exit");
                      // أغلق نافذة الحوار أولاً لتفادي تعارض التنقل
                      try {
                        Navigator.of(context, rootNavigator: true).pop();
                      } catch (_) {}
                      await RoomExitService.exitRoom(
                        context: pageContext,
                        userCubit: widget.userCubit,
                        roomCubit: widget.roomCubit,
                      );
                    } catch (e) {
                      log('Exit error: $e');
                    } finally {
                      if (mounted) setState(() => _isExiting = false);
                    }
                  },
                ),
              ),
            ],
          ),
        ),
      );
    });
  }

  Widget overlayButton({
    required BuildContext context,
    required String label,
    required String icon,
  }) {
    return XOverlayButton(
      buttonSize: const Size(80, 80),
      backgroundColor: AppColors.transparent,
      iconSize: const Size(80, 80),
      onWillPressed: () {
        bool navigated = false;
        void navigate() {
          if (navigated) return;
          navigated = true;
          WidgetsBinding.instance.addPostFrameCallback((_) async {
            if (!mounted) return;
            Navigator.pushAndRemoveUntil(
              context,
              MaterialPageRoute(
                builder: (context) => HomeView(
                  userCubit: widget.userCubit,
                  roomCubit: widget.roomCubit,
                ),
              ),
              (Route<dynamic> route) => false,
            );
          });
        }

        if (audioRoomOverlayController.pageStateNotifier.value ==
            XOverlayPageState.overlaying) {
          navigate();
        } else {
          late VoidCallback listener;
          listener = () {
            if (audioRoomOverlayController.pageStateNotifier.value ==
                XOverlayPageState.overlaying) {
              audioRoomOverlayController.pageStateNotifier.removeListener(listener);
              navigate();
            }
          };
          audioRoomOverlayController.pageStateNotifier.addListener(listener);
          // Fallback timeout to ensure navigation proceeds if event delays
          Future.delayed(const Duration(milliseconds: 700), () {
            try {
              audioRoomOverlayController.pageStateNotifier.removeListener(listener);
            } catch (_) {}
            navigate();
          });
        }
      },
      controller: audioRoomOverlayController,
      icon: Column(
        children: [
          CircleAvatar(
            radius: 40,
            child: Image.asset(icon),
          ),
          const SizedBox(height: 4),
          AutoSizeText(
            label, // نص أثناء التحميل
            style: const TextStyle(
              color: AppColors.white,
              fontSize: 16,
              fontWeight: FontWeight.bold,
            ),
            textAlign: TextAlign.center,
          ),
        ],
      ),
      dataQuery: () {
        return AudioRoomOverlayData(
            roomID: widget.room.id.toString(),
            roomPass: widget.room.pass.toString(),
            role: widget.role,
            roomImg: widget.room.img,
            backgroundImage: widget.room.background);
      },
    );
  }

  Widget _buildActionButton({
    required BuildContext context,
    required String label,
    required VoidCallback onPressed,
    required String icon,
  }) {
    return GestureDetector(
      onTap: _isExiting ? null : onPressed, // تعطيل الضغط أثناء التحميل
      child: Column(
        children: [
          CircleAvatar(
            radius: 40,
            child: _isExiting
                ? const CircularProgressIndicator(
                    color: AppColors.white, // لون المؤشر
                    strokeWidth: 3, // سمك المؤشر
                  )
                : Image.asset(icon),
          ),
          const SizedBox(height: 4),
          AutoSizeText(
            _isExiting ? S.of(context).exiting : label, // نص أثناء التحميل
            style: const TextStyle(
              color: AppColors.white,
              fontSize: 16,
              fontWeight: FontWeight.bold,
            ),
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );
  }

  List<SingleChildWidget> get providersMultiBlocProvider {
    return [
      BlocProvider<RoomMessagesCubit>(
        create: (context) => RoomMessagesCubit(ApiService()),
      ),
      BlocProvider<EmojiPrivateCubit>(
        create: (context) => EmojiPrivateCubit(),
      ),
      BlocProvider<EmojiCubit>(
        create: (context) => EmojiCubit(),
      ),
      BlocProvider<TopBarRoomCubit>(
        create: (context) => TopBarRoomCubit(),
      ),
      BlocProvider<MoneyBagTopBarCubit>(
        create: (context) => MoneyBagTopBarCubit(),
      ),

      // Provide LiveKitAudioCubit in the RoomView scope to avoid ProviderNotFound
      // in widgets like RoomButtonsRow constructed in overlay routes or separate trees.
      BlocProvider<LiveKitAudioCubit>(
        create: (context) => sl<LiveKitAudioCubit>(),
      ),

      // BlocProvider(
      //   create: (context) => RoomUpdatedCubit(),
      // ),
    ];
  }

  Future<void> _safeExit() async {
    if (_exitTriggered) return;
    _exitTriggered = true;

    try {
      await RoomExitService.exitRoom(
        context: pageContext,
        userCubit: widget.userCubit,
        roomCubit: widget.roomCubit,
        delayDuration: Duration(milliseconds: 500),
      );
    } catch (e) {
      log('Exit error: $e');
    }
  }

  ValueListenableBuilder<bool> giftsSvgaShow(double h) {
    final manager = IsActiveGiftsManager();

    return ValueListenableBuilder<bool>(
      valueListenable: manager.isActiveNotifier,
      builder: (context, isActiveGifts, child) {
        if (isActiveGifts) {
          return GiftShowSctionPart(
              h: h, roomCubit: widget.roomCubit, userCubit: widget.userCubit);
        } else {
          return const SizedBox();
        }
      },
    );
  }
}
