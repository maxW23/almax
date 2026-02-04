import 'package:flutter/material.dart';
import 'package:lklk/core/constants/app_colors.dart';
import 'package:lklk/core/constants/styles.dart';
import 'package:lklk/core/utils/gradient_text.dart';
import 'package:lklk/features/home/presentation/manger/room_cubit/room_cubit_cubit.dart';
import 'package:lklk/features/room/presentation/views/widgets/level_row_user_title_widget_section.dart';
import 'package:lklk/features/room/presentation/views/widgets/user_message_info.dart';
import 'gift_image.dart';
import 'gift_text_message.dart';

class MessageGiftItemWidget extends StatelessWidget {
  final String img;
  final String giftSender;
  final String giftImg;
  final String giftsMany;
  final String giftReceiver;
  final RoomCubit roomCubit;
  final String roomID, userId;

  const MessageGiftItemWidget({
    super.key,
    required this.img,
    required this.giftSender,
    required this.giftImg,
    required this.giftsMany,
    required this.giftReceiver,
    required this.roomCubit,
    required this.roomID,
    required this.userId,
  });

  @override
  Widget build(BuildContext context) {
    return Align(
      alignment: Alignment.topRight,
      child: Container(
        width: MediaQuery.of(context).size.width / 1.9,
        constraints: BoxConstraints(
          maxWidth: MediaQuery.of(context).size.width / 1.9,
        ),
        margin: const EdgeInsets.only(right: 8, left: 8, top: 4, bottom: 4),
        padding: const EdgeInsets.all(8),
        decoration: const BoxDecoration(
          color: AppColors.transparent,
          borderRadius: BorderRadius.only(
            bottomLeft: Radius.circular(30),
            bottomRight: Radius.circular(30),
            topLeft: Radius.circular(30),
            topRight: Radius.circular(0),
          ),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.end,
          children: [
            UserMessageInfo(
              img: img,
              userName: giftSender,
            ),
            if (roomCubit.state.usersZego != null)
              roomCubit.state.usersZego!.firstWhereOrNullExtention(
                          (element) => element.iduser == userId) !=
                      null
                  ? Padding(
                      padding: const EdgeInsets.only(right: 8.0),
                      child: LevelRowUserTitleWidgetSection(
                        size: LevelRowSize.small,
                        isRoomTypeUser: true,
                        isWakel: true,
                        user: roomCubit.state.usersZego!
                            .where((element) => element.iduser == userId)
                            .first,
                        roomID: roomID,
                      ),
                    )
                  : const SizedBox(),
            const SizedBox(height: 10),
            Container(
              margin: const EdgeInsets.only(right: 20),
              padding: const EdgeInsets.symmetric(vertical: 10, horizontal: 15),
              decoration: BoxDecoration(
                color: AppColors.black.withValues(alpha: .2),
                borderRadius: BorderRadius.circular(14),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.end,
                children: [
                  Align(
                    alignment: Alignment.center,
                    child: GiftTextMessage(
                      giftReciver: giftReceiver,
                    ),
                  ),
                  const SizedBox(height: 10),
                  // Fixed the overflowing Row here
                  Container(
                    constraints: BoxConstraints(
                      maxWidth: MediaQuery.of(context).size.width / 2.2,
                    ),
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      mainAxisAlignment: MainAxisAlignment.end,
                      children: [
                        Flexible(
                          child: GiftImage(imgElement: giftImg),
                        ),
                        const SizedBox(width: 8),
                        Flexible(
                          child: FittedBox(
                            fit: BoxFit.scaleDown,
                            child: GradientText(
                              'X$giftsMany',
                              gradient: const LinearGradient(colors: [
                                AppColors.brownshad2,
                                AppColors.white,
                              ]),
                              style: Styles.textStyle16
                                  .copyWith(color: AppColors.white),
                            ),
                          ),
                        ),
                      ],
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
}
