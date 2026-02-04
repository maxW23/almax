import 'package:lklk/core/utils/logger.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:lklk/core/delay.dart';
import 'package:lklk/core/room_switch_guard.dart';
import 'package:lklk/core/service_locator.dart';
import 'package:lklk/core/services/auth_service.dart';
import 'package:lklk/features/auth/domain/entities/user_entity.dart';
import 'package:lklk/features/home/presentation/manger/top_bar_room_cubit/has_message.dart';
import 'package:lklk/features/home/presentation/manger/top_bar_room_cubit/money_bag_top_bar_cubit.dart';
import 'package:lklk/features/room/domain/entities/topbar_meesage_entity.dart';
import 'package:lklk/features/room/presentation/manger/lucky_bag/luck_bag_cubit.dart';
import 'package:lklk/features/room/presentation/views/room_move_dialog.dart';
import 'package:lklk/features/room/presentation/views/widgets/hide_after_time_widget.dart';
import 'package:lklk/features/room/presentation/views/widgets/lucky_bag_body.dart';

import 'package:lklk/features/room/presentation/views/widgets/topbar_fading_hide.dart';
import 'package:lklk/features/room/presentation/views/widgets/topbar_game_body.dart';
import 'package:lklk/features/room/presentation/views/widgets/topbar_luck_body.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:lklk/core/player/svga_custom_player.dart';
import 'package:lklk/features/home/presentation/manger/room_cubit/room_cubit_cubit.dart';
import 'package:lklk/features/home/presentation/manger/top_bar_room_cubit/top_bar_room_cubit.dart';
import 'package:lklk/features/profile_users/presentaion/manger/user_cubit/user_cubit_cubit.dart';
import 'package:lklk/features/room/presentation/views/widgets/room_view_bloc.dart';
import 'package:lklk/features/room/presentation/views/widgets/top_bar_body.dart';
import 'package:lklk/zego_sdk_manager.dart';

class TopBarSection extends StatefulWidget {
  const TopBarSection({
    super.key,
    required this.roomCubit,
    required this.userCubit,
    required this.roomID,
    required this.onSend,
  });
  final RoomCubit roomCubit;
  final UserCubit userCubit;
  final String roomID;
  final void Function(ZIMMessage) onSend;

  @override
  State<TopBarSection> createState() => _TopBarSectionState();
}

class _TopBarSectionState extends State<TopBarSection> {
  final double topBarHeight = 60.0;
  final double svgaBottomPadding = 50.0;
  final double giftBottomPadding = 59.0;

  Future<void> _handleRoomMove(BuildContext context, TopBarShow state) async {
    final originalContext = context;
    final messenger = ScaffoldMessenger.of(context);
    final roomIDMessage = int.tryParse(state.message.roomId.toString());

    if (roomIDMessage == null) {
      // SnackbarHelper.showMessage(context, 'Invalid room ID');
      return;
    }

    // إذا كان نوع الرسالة money_bag وتعاملنا معها بشكل مختلف
    if (state.message.type == "money_bag") {
      final UserEntity? currentUser =
          await AuthService.getUserFromSharedPreferences();
      if (!mounted) return;
      final isSender = state.message.reciver == currentUser?.id.toString();
      if (!isSender) {
        await _handleMoneyBagTap(context, state, roomIDMessage);
      }
      return;
    }

    // التحقق من أن roomId المستهدف مختلف عن roomID الحالي
    if (widget.roomID == roomIDMessage.toString()) {
      messenger.showSnackBar(
        const SnackBar(content: Text('You are already in this room')),
      );
      return;
    }

    // جدولة عرض الديالوغ بعد الإطار التالي بدون انتظار async gap
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (!mounted) return;
      RoomMoveDialog.show(
        context: context,
        originalContext: originalContext,
        state: state,
        roomId: roomIDMessage,
        onConfirm: _processRoomMove,
        isMoneyBag: false, // ليست حقيبة حظ
      );
    });
  }

  // دالة للتعامل مع الضغط على money_bag
  Future<void> _handleMoneyBagTap(
      BuildContext context, TopBarShow state, int roomId) async {
    // إذا كان المستخدم في نفس الغرفة، عرض ديالوغ money_bag مباشرة
    if (widget.roomID != roomId.toString()) {
      RoomMoveDialog.show(
        context: context,
        originalContext: context,
        state: state,
        roomId: roomId,
        onConfirm: _processRoomMoveForMoneyBag,
        isMoneyBag: true, // تحديد أن هذه لحقيبة الحظ
      );
    }
  }

  // معالجة الانتقال للغرفة من أجل money_bag
  // معالجة الانتقال للغرفة من أجل money_bag
  Future<void> _processRoomMoveForMoneyBag(
      BuildContext context, HasMessage state, int roomId, String? pass) async {
    if (state is MoneyBagTopBarShow) {
      await _navigateToRoomWithMoneyBag(
        context,
        roomId,
        pass,
        state.message.vip,
        state.message,
      );
    }
  }

  // الانتقال إلى الغرفة وعرض money_bag بعد الدخول
  Future<void> _navigateToRoomWithMoneyBag(
      BuildContext context,
      int roomId,
      String? pass,
      String? backgroundImage,
      TopBarMessageEntity message) async {
    final navigator = Navigator.of(context);
    final messenger = ScaffoldMessenger.of(context);

    BlocProvider.of<RoomCubit>(context).backInitial();
    widget.roomCubit.backInitial();

    try {
      if (mounted) {
        // ابدأ حماية التنقل لمنع شاشة الغرفة القديمة من التفاعل مع قطع الاتصال المؤقت
        RoomSwitchGuard.start();
        navigator.pushReplacement(
          PageRouteBuilder(
            transitionDuration: Duration.zero,
            reverseTransitionDuration: Duration.zero,
            pageBuilder: (_, __, ___) => RoomViewBloc(
              isForce: true,
              roomCubit: widget.roomCubit,
              roomId: roomId,
              pass: pass,
              userCubit: widget.userCubit,
              backgroundImage: backgroundImage,
            ),
          ),
        );
      }
    } catch (e) {
      if (mounted) {
        messenger.showSnackBar(
          SnackBar(content: Text('Error switching rooms: $e')),
        );
      }
    }
  }

  Future<void> _processRoomMove(
      BuildContext context, HasMessage state, int roomId, String? pass) async {
    // التحقق مرة أخرى للتأكد (لأغراض السلامة)
    if (widget.roomID == roomId.toString()) {
      final messenger = ScaffoldMessenger.of(context);
      messenger.showSnackBar(
        const SnackBar(content: Text('You are already in this room')),
      );
      return;
    }

    // يمكنك التحقق من النوع إذا كنت بحاجة إلى معالجة خاصة
    if (state is TopBarShow) {
      await _navigateToRoom(context, roomId, pass, state.message.vip);
    }
  }

  Future<void> _navigateToRoom(BuildContext context, int roomId, String? pass,
      String? backgroundImage) async {
    // حفظ navigator/messenger الحاليين قبل العمليات غير المتزامنة
    final navigator = Navigator.of(context);
    final messenger = ScaffoldMessenger.of(context);

    // // إغلاق أي dialogs مفتوحة أولاً
    // Navigator.of(currentContext, rootNavigator: true)
    //     .popUntil((route) => route.isFirst);

    // استخدام Service Locator للوصول إلى LuckBagCubit

    BlocProvider.of<RoomCubit>(context).backInitial();
    widget.roomCubit.backInitial();
    final luckBagCubit = sl<LuckBagCubit>();
    resetLuckBagCubit();

    await luckBagCubit.close();

    try {
      if (mounted) {
        // ابدأ حماية التنقل لمنع شاشة الغرفة القديمة من التفاعل مع قطع الاتصال المؤقت
        RoomSwitchGuard.start();
        navigator.pushReplacement(
          PageRouteBuilder(
            transitionDuration: Duration.zero,
            reverseTransitionDuration: Duration.zero,
            pageBuilder: (_, __, ___) => RoomViewBloc(
              isForce: true,
              roomCubit: widget.roomCubit,
              roomId: roomId,
              pass: pass,
              userCubit: widget.userCubit,
              backgroundImage: backgroundImage,
            ),
          ),
        );
      }
    } catch (e) {
      if (mounted) {
        messenger.showSnackBar(
          SnackBar(content: Text('Error switching rooms: $e')),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final double screenWidth = MediaQuery.of(context).size.width * .8;

    return BlocSelector<TopBarRoomCubit, TopBarRoomState, TopBarShow?>(
      selector: (state) => state is TopBarShow ? state : null,
      builder: (context, topBar) {
        if (topBar != null) {
          final TopBarMessageEntity msg = topBar.message;
          String? priceGifts;
          String? manyGifts;

          if (msg.type != null &&
              (msg.type!.contains("gift") || msg.type!.contains("luck"))) {
            final rawMsg = (topBar.message.message ?? '').trim();
            final rawLower = rawMsg.toLowerCase();
            if (rawLower.contains('x')) {
              final idx = rawLower.indexOf('x');
              if (idx > 0 && idx < rawMsg.length - 1) {
                priceGifts = rawMsg.substring(0, idx).trim();
                final right = rawMsg.substring(idx + 1).trim();
                if (right.isNotEmpty) {
                  manyGifts = 'X$right';
                }
              }
            }

            // Fallbacks if not found in message: try giftId pattern like x77, then giftsMany digits
            if ((manyGifts ?? '').isEmpty) {
              final gid = (msg.giftId ?? '').trim();
              final match = RegExp(r'[xX](\d+)').firstMatch(gid);
              if (match != null) {
                manyGifts = 'X${match.group(1)}';
              } else if (msg.giftsMany != null) {
                final gm = msg.giftsMany.toString();
                final digits = RegExp(r'\d+').firstMatch(gm)?.group(0);
                if (digits != null && digits.isNotEmpty) {
                  manyGifts = 'X$digits';
                }
              }
            }

            log("priceGifts  $priceGifts manyGifts $manyGifts");
          }
          if ((msg.type ?? '').contains("money_bag")) {
            log("TopBarUI] 🧩 money_bag  msg:${msg.toString()}");
          }
          return GestureDetector(
            behavior: HitTestBehavior.opaque,
            onTap: () => _handleRoomMove(context, topBar),
            child: TopbarFadingHide(
              visibleDuration: msg.timer != null
                  ? Duration(seconds: msg.timer!)
                  : const Duration(milliseconds: 4500),
              hideDuration: const Duration(milliseconds: 600),
              child: Container(
                alignment: Alignment.center,
                margin: EdgeInsets.only(top: 60.r),
                padding: const EdgeInsets.only(left: 15),
                child: Stack(
                  children: [
                    if (msg.type == "huge_gift_recive")
                      giftTopbar(msg, screenWidth, topBar),
                    if (msg.type == "huge_luck_recive")
                      luckyGiftTopbar(
                          msg, screenWidth, topBar, manyGifts, priceGifts),
                    if (msg.type == "huge_game_recive")
                      gameTopbar(screenWidth, topBar, msg),
                    if (msg.type == "money_bag")
                      moneyBagTopbar(screenWidth, topBar, msg),
                  ],
                ),
              ),
            ),
          );
        }
        log('[UI] Hiding top bar');
        return const SizedBox.shrink();
      },
    );
  }

  SizedBox moneyBagTopbar(
      double screenWidth, TopBarShow topBar, TopBarMessageEntity msg) {
    return SizedBox(
      width: screenWidth,
      height: topBarHeight.h,
      child: Stack(
        alignment: Alignment.center,
        children: [
          Padding(
            padding: EdgeInsets.only(bottom: giftBottomPadding.r),
            child: Center(
              child: RepaintBoundary(
                child: CustomSVGAWidget(
                  key: Key(topBar.message.id.toString()),
                  height: topBarHeight.h,
                  width: screenWidth,
                  pathOfSvgaFile: 'assets/top_bar_room/lucky_bag_topbar.svga',
                  allowDrawingOverflow: true,
                  clearsAfterStop: false,
                  isRepeat: false,
                  fit: BoxFit.cover,
                ),
              ),
            ),
          ),
          DelayedDisplay(
            child: SizedBox(
              height: topBarHeight.h,
              width: screenWidth,
              child: Center(
                child: LuckyBagBody(msg: msg),
              ),
            ),
          ),
        ],
      ),
    );
  }

  SizedBox gameTopbar(
      double screenWidth, TopBarShow topBar, TopBarMessageEntity msg) {
    return SizedBox(
      width: screenWidth,
      height: topBarHeight.h,
      child: Stack(
        alignment: Alignment.center,
        children: [
          Padding(
            padding: EdgeInsets.only(bottom: svgaBottomPadding.r),
            child: Center(
              child: RepaintBoundary(
                child: CustomSVGAWidget(
                  key: Key(topBar.message.id.toString()),
                  height: topBarHeight.h,
                  width: screenWidth,
                  pathOfSvgaFile: 'assets/top_bar_room/games_topbar.svga',
                  allowDrawingOverflow: true,
                  clearsAfterStop: false,
                  isRepeat: false,
                  fit: BoxFit.cover,
                ),
              ),
            ),
          ),
          DelayedDisplay(
            child: SizedBox(
              height: topBarHeight.h,
              width: screenWidth,
              child: Center(
                child: TopbarGameBody(msg: msg),
              ),
            ),
          ),
        ],
      ),
    );
  }

  HideAfterTimeWidget luckyGiftTopbar(
      TopBarMessageEntity msg,
      double screenWidth,
      TopBarShow topBar,
      String? manyGifts,
      String? priceGifts) {
    return HideAfterTimeWidget(
      duration: msg.timer != null
          ? Duration(seconds: msg.timer!)
          : const Duration(milliseconds: 4100),
      child: SizedBox(
        width: screenWidth,
        height: topBarHeight.h,
        child: Stack(
          alignment: Alignment.center,
          children: [
            Padding(
              padding: EdgeInsets.only(bottom: giftBottomPadding.r),
              child: Center(
                child: RepaintBoundary(
                  child: CustomSVGAWidget(
                    key: Key(topBar.message.id.toString()),
                    height: topBarHeight.h,
                    width: screenWidth,
                    pathOfSvgaFile:
                        'assets/top_bar_room/lucky_gift_topbar.svga',
                    allowDrawingOverflow: true,
                    clearsAfterStop: false,
                    isRepeat: false,
                    fit: BoxFit.cover,
                    durationSeconds: msg.timer,
                  ),
                ),
              ),
            ),
            DelayedDisplay(
              child: SizedBox(
                height: topBarHeight.h,
                width: screenWidth,
                child: Center(
                  child: TopbarLuckBody(msg: msg),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  HideAfterTimeWidget giftTopbar(
      TopBarMessageEntity msg, double screenWidth, TopBarShow topBar) {
    String? priceGifts;
    String? manyGifts;

    // Safely parse message like "125x70" into price and multiplier as X70
    final rawMsg = (msg.message ?? '').trim();
    final rawLower = rawMsg.toLowerCase();
    if (rawLower.contains('x')) {
      final idx = rawLower.indexOf('x');
      if (idx > 0 && idx < rawMsg.length - 1) {
        priceGifts = rawMsg.substring(0, idx).trim();
        final right = rawMsg.substring(idx + 1).trim();
        if (right.isNotEmpty) {
          manyGifts = 'X$right';
        }
      }
    }

    // Fallbacks: giftId with xNN or digits, then giftsMany
    if ((manyGifts ?? '').isEmpty) {
      final gid = (msg.giftId ?? '').trim();
      final match = RegExp(r'[xX](\d+)').firstMatch(gid);
      if (match != null) {
        manyGifts = 'X${match.group(1)}';
      } else if (gid.isNotEmpty) {
        final digits = RegExp(r'\d+').firstMatch(gid)?.group(0);
        if (digits != null && digits.isNotEmpty) {
          manyGifts = 'X$digits';
        }
      } else if (msg.giftsMany != null) {
        final gm = msg.giftsMany.toString();
        final digits = RegExp(r'\d+').firstMatch(gm)?.group(0);
        if (digits != null && digits.isNotEmpty) {
          manyGifts = 'X$digits';
        }
      }
    }

    return HideAfterTimeWidget(
      duration: msg.timer != null
          ? Duration(seconds: msg.timer!)
          : const Duration(milliseconds: 4100),
      child: SizedBox(
        width: screenWidth,
        height: topBarHeight.h,
        child: Stack(
          alignment: Alignment.center,
          children: [
            Padding(
              padding: EdgeInsets.only(bottom: giftBottomPadding.r),
              child: Center(
                child: RepaintBoundary(
                  child: CustomSVGAWidget(
                    key: Key(topBar.message.id.toString()),
                    height: topBarHeight.h,
                    width: screenWidth,
                    pathOfSvgaFile: 'assets/top_bar_room/gift_topbar.svga',
                    allowDrawingOverflow: true,
                    clearsAfterStop: false,
                    isRepeat: true,
                    fit: BoxFit.cover,
                    durationSeconds: msg.timer,
                  ),
                ),
              ),
            ),
            DelayedDisplay(
              child: SizedBox(
                height: topBarHeight.h,
                width: screenWidth,
                child: Center(
                  child: TopBarGiftBody(
                    manyGifts: manyGifts ?? msg.giftsMany,
                    priceGifts: priceGifts ?? msg.message,
                    img: msg.img,
                    giftImage: msg.giftImg,
                    reciverImage: msg.level,
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
