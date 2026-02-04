import 'package:flutter/material.dart';
import 'package:auto_size_text/auto_size_text.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:lklk/core/constants/app_colors.dart';
import 'package:lklk/core/constants/styles.dart';
import 'package:lklk/features/home/presentation/manger/room_cubit/room_cubit_cubit.dart';
import 'package:lklk/features/room/presentation/views/widgets/dice_message_show.dart';
import 'package:lklk/features/room/presentation/views/widgets/level_row_user_title_widget_section.dart';
import 'package:lklk/features/room/presentation/views/widgets/p_s_r_message_show.dart';
import 'package:lklk/features/room/presentation/views/widgets/seventy_message_show.dart';
import 'package:lklk/features/room/presentation/views/widgets/user_message_info.dart';

class MessageItemWidget extends StatelessWidget {
  static const _diceUserId = '01011';
  static const _psrUserId = '01012';
  static const _seventyUserId = '01013';
  static const _messageWidthFactor = 1.8;
  static const _contentMargin = EdgeInsets.only(right: 20);
  static const _contentPadding =
      EdgeInsets.symmetric(vertical: 10, horizontal: 15);
  static const _bubbleRadius = 14.0;
  static const _infoSpacing = SizedBox(height: 10);

  // final Message message;
  final String text, id, userId, img, userName;
  final RoomCubit roomCubit;
  final String roomID;
  const MessageItemWidget({
    super.key,
    required this.text,
    required this.id,
    required this.userId,
    required this.img,
    required this.userName,
    required this.roomCubit,
    required this.roomID,
    // required this.message,
  });

  Widget _buildMessageContent() {
    switch (userId) {
      case _diceUserId:
        return DiceMessageShow(
          text: text,
          id: id,
          key: ValueKey(id),
        );
      case _psrUserId:
        return PSRMessageShow(
          text: text,
          key: ValueKey(id),
        );
      case _seventyUserId:
        return SevenyMessageShow(
          // message: message,
          text: text,
          key: ValueKey(id),
        );
      default:
        return AutoSizeText(
          text,
          textDirection: TextDirection.rtl,
          style: Styles.textStyle16.copyWith(color: AppColors.white),
        );
    }
  }

  @override
  Widget build(BuildContext context) {
    final screenWidth = MediaQuery.of(context).size.width;

    return Align(
      alignment: Alignment.topRight,
      child: Container(
        constraints:
            BoxConstraints(maxWidth: screenWidth / _messageWidthFactor),
        margin: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
        padding: const EdgeInsets.all(8),
        decoration: const BoxDecoration(
          color: AppColors.transparent,
          borderRadius: BorderRadius.all(Radius.circular(6)),
        ),
        child: Column(
          textDirection: TextDirection.rtl,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            UserMessageInfo(
              img: img,
              userName: userName,
            ),
            if (roomCubit.state.usersZego != null)
              roomCubit.state.usersZego!.firstWhereOrNullExtention(
                          (element) => element.iduser == userId) !=
                      null
                  ? Row(
                      children: [
                        Spacer(),
                        LevelRowUserTitleWidgetSection(
                          size: LevelRowSize.small,
                          isRoomTypeUser: true,
                          isWakel: true,
                          user: roomCubit.state.usersZego!
                              .where((element) => element.iduser == userId)
                              .first,
                          roomID: roomID,
                        ),
                        SizedBox(
                          width: 45.w,
                        )
                      ],
                    )
                  : SizedBox(),
            _infoSpacing,
            Container(
              margin: _contentMargin,
              padding: _contentPadding,
              decoration: BoxDecoration(
                color: AppColors.black.withValues(alpha: .2),
                borderRadius: BorderRadius.circular(_bubbleRadius),
              ),
              child: _buildMessageContent(),
            ),
          ],
        ),
      ),
    );
  }
}
