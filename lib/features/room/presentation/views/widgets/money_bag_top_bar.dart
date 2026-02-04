import 'package:lklk/core/utils/logger.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:lklk/core/delay.dart';
import 'package:lklk/core/room_switch_guard.dart';
import 'package:lklk/features/home/presentation/manger/top_bar_room_cubit/has_message.dart';
import 'package:lklk/features/home/presentation/manger/top_bar_room_cubit/money_bag_top_bar_cubit.dart';
import 'package:lklk/features/room/domain/entities/topbar_meesage_entity.dart';
import 'package:lklk/features/room/presentation/views/room_move_dialog.dart';
import 'package:lklk/features/room/presentation/views/widgets/lucky_bag_body.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:lklk/core/player/svga_custom_player.dart';
import 'package:lklk/features/home/presentation/manger/room_cubit/room_cubit_cubit.dart';
import 'package:lklk/features/profile_users/presentaion/manger/user_cubit/user_cubit_cubit.dart';
import 'package:lklk/features/room/presentation/views/widgets/room_view_bloc.dart';
import 'package:lklk/zego_sdk_manager.dart';

class MoneyBagTopBar extends StatefulWidget {
  const MoneyBagTopBar({
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
  State<MoneyBagTopBar> createState() => _MoneyBagTopBarState();
}

class _MoneyBagTopBarState extends State<MoneyBagTopBar> {
  final double topBarHeight = 60.0;
  final double giftBottomPadding = 59.0;

  Future<void> _handleMoneyBagTap(
      BuildContext context, MoneyBagTopBarShow state, int roomId) async {
    // إذا كان المستخدم في نفس الغرفة، عرض ديالوغ money_bag مباشرة
    if (widget.roomID != roomId.toString()) {
      RoomMoveDialog.show(
        context: context,
        originalContext: context,
        state: state, // قد تحتاج إلى تعديل Dialog ليقبل MoneyBagTopBarShow
        roomId: roomId,
        onConfirm: _processRoomMoveForMoneyBag,
        isMoneyBag: true,
      );
    }
  }

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

  Future<void> _navigateToRoomWithMoneyBag(
      BuildContext context,
      int roomId,
      String? pass,
      String? backgroundImage,
      TopBarMessageEntity message) async {
    final navigator = Navigator.of(context);
    final messenger = ScaffoldMessenger.of(context);

    // ابدأ حماية التنقل قبل أي قطع اتصال لتجنب الرجوع للرئيسية
    RoomSwitchGuard.start();

    // تهيئة حالة RoomCubit فقط (بدون إيقاف الخدمة/تسجيل الخروج هنا)
    BlocProvider.of<RoomCubit>(context).backInitial();
    widget.roomCubit.backInitial();

    try {
      if (mounted) {
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

    return BlocConsumer<MoneyBagTopBarCubit, MoneyBagTopBarState>(
      listener: (BuildContext context, MoneyBagTopBarState state) {
        log('[MoneyBagTopBarUI] Listener → new state: $state');
      },
      builder: (context, state) {
        if (state is MoneyBagTopBarShow) {
          final TopBarMessageEntity msg = state.message;
          return InkWell(
            onTap: () => _handleMoneyBagTap(
                context, state, int.tryParse(msg.roomId.toString()) ?? 0),
            child: Container(
              alignment: Alignment.center,
              // إزالة الـ margin لأننا نتحكم في الموضع من خلال الـ Stack الأب
              padding: const EdgeInsets.only(left: 15),
              child: Stack(
                children: [
                  if (msg.type == "money_bag")
                    SizedBox(
                      width: screenWidth,
                      height: topBarHeight.h,
                      child: Stack(
                        alignment: Alignment.center,
                        children: [
                          Padding(
                            padding:
                                EdgeInsets.only(bottom: giftBottomPadding.r),
                            child: Center(
                              child: CustomSVGAWidget(
                                key: Key(state.message.id.toString()),
                                height: topBarHeight.h,
                                width: screenWidth,
                                pathOfSvgaFile:
                                    'assets/top_bar_room/lucky_bag_topbar.svga',
                                allowDrawingOverflow: true,
                                clearsAfterStop: false,
                                isRepeat: false,
                                fit: BoxFit.cover,
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
                    ),
                ],
              ),
            ),
          );
        }
        log('[MoneyBagTopBarUI] Hiding top bar');
        return const SizedBox.shrink();
      },
    );
  }
}
