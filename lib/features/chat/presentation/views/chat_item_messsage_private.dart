import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:auto_size_text/auto_size_text.dart';
import 'package:lklk/features/chat/presentation/views/message_counter_alert.dart';
import 'package:lklk/generated/l10n.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:intl/intl.dart';
import 'package:lklk/core/constants/app_colors.dart';
import 'package:lklk/core/constants/assets.dart';
import 'package:lklk/core/constants/styles.dart';
import 'package:lklk/features/chat/domain/enitity/home_message_entity.dart';
import 'package:lklk/features/chat/presentation/views/chat_private_page.dart';
import 'package:lklk/features/room/presentation/views/widgets/circular_user_image.dart';
import 'package:lklk/features/home/presentation/manger/room_cubit/room_cubit_cubit.dart';
import 'package:lklk/features/profile_users/presentaion/manger/user_cubit/user_cubit_cubit.dart';

class ChatPageItemLastMesssage extends StatelessWidget {
  const ChatPageItemLastMesssage({
    super.key,
    // this.color = AppColors.primary,
    this.isOffical = false,
    required this.lastMessageEntity,
    required this.userCubit,
    required this.roomCubit,
  });

  // final Color color;
  final bool isOffical;
  final HomeMessageEntity lastMessageEntity;
  final UserCubit userCubit;
  final RoomCubit roomCubit;
  @override
  Widget build(BuildContext context) {
    bool isUnRead = lastMessageEntity.howManyTime != null &&
        lastMessageEntity.howManyTime != "null" &&
        int.tryParse(lastMessageEntity.howManyTime!)! > 0;
    return GestureDetector(
      onTap: () {
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (context) => ChatPrivatePageBloc(
              userId: lastMessageEntity.idString,
              userImg: lastMessageEntity.userImg,
              userName: lastMessageEntity.user,
              isOfficial: lastMessageEntity.senderId == '1' ? true : false,
              userImgcurrent: userCubit.user?.img ?? AssetsData.userTestNetwork,
              roomCubit: roomCubit,
              userCubit: userCubit,
            ),
          ),
        );
      },
      child: SizedBox(
        width: double.infinity,
        child: Column(
          children: [
            const Divider(
                height: 0.0, thickness: 0.3, indent: 20, endIndent: 30),
            ListTile(
              leading: UserImageSection(
                  // color: color,
                  lastMessageEntity: lastMessageEntity),
              title: Row(
                children: [
                  UserNameLastMessage(
                      lastMessageEntity: lastMessageEntity,
                      isOffical: isOffical),
                  const SizedBox(
                    width: 10,
                  ),
                  if (isUnRead)
                    MessageCounterAlert(
                        howManyTime: lastMessageEntity.howManyTime!),
                ],
              ),
              subtitle: LastMessageText(
                lastMessageEntity: lastMessageEntity,
                isUnRead: isUnRead,
              ),
              trailing: SizedBox(
                width: 50.w,
                child: DateText(
                  lastMessageEntityCreatedAt: lastMessageEntity.createdAt,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class UserNameLastMessage extends StatelessWidget {
  const UserNameLastMessage({
    super.key,
    required this.lastMessageEntity,
    required this.isOffical,
  });

  final HomeMessageEntity lastMessageEntity;
  final bool isOffical;

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        AutoSizeText(
          lastMessageEntity.user,
          style: Styles.textStyle16,
        ),
        const SizedBox(
          width: 4,
        ),
        // isOffical ? const OfficialWidget() : const SizedBox(),
      ],
    );
  }
}

class LastMessageText extends StatelessWidget {
  const LastMessageText({
    super.key,
    required this.lastMessageEntity,
    required this.isUnRead,
  });
  final bool isUnRead;
  final HomeMessageEntity lastMessageEntity;

  @override
  Widget build(BuildContext context) {
    return AutoSizeText(
      lastMessageEntity.sender == 'you'
          ? 'you: ${lastMessageEntity.message}'
          : '${lastMessageEntity.user.split(" ").first}:${lastMessageEntity.message}',
      style: Styles.textStyle12gray
          .copyWith(fontWeight: isUnRead ? FontWeight.w900 : FontWeight.w400),
      overflow: TextOverflow.ellipsis,
      maxLines: 1,
    );
  }
}

class DateText extends StatelessWidget {
  const DateText({
    super.key,
    required this.lastMessageEntityCreatedAt,
  });
  final String lastMessageEntityCreatedAt;

  @override
  Widget build(BuildContext context) {
    String formattedDate = _formatDate(lastMessageEntityCreatedAt);

    return AutoSizeText(
      formattedDate,
      maxLines: 1,
      textAlign: TextAlign.center,
      overflow: TextOverflow.ellipsis,
      style: Styles.textStyle12gray.copyWith(
        fontSize: 7,
      ),
    );
  }

  String _formatDate(String date) {
    final DateTime parsedDate = DateTime.parse(date);
    final DateTime now = DateTime.now();

    if (parsedDate.year == now.year &&
        parsedDate.month == now.month &&
        parsedDate.day == now.day) {
      return DateFormat.Hm().format(parsedDate);
    } else {
      return DateFormat.yMd().format(parsedDate);
    }
  }
}

class UserImageSection extends StatelessWidget {
  const UserImageSection({
    super.key,
    // required this.color,
    required this.lastMessageEntity,
  });

  // final Color color;
  final HomeMessageEntity lastMessageEntity;

  @override
  Widget build(BuildContext context) {
    return Stack(
      alignment: Alignment.center,
      children: [
        // CircleAvatar(
        //   radius: 24.7,
        //   // backgroundColor: color,
        // ),
        CircularUserImage(
          imagePath: lastMessageEntity.userImg,
          radius: 24,
        ),
        // Container(
        //   width: 55,
        //   height: 55,
        //   decoration: BoxDecoration(
        //     shape: BoxShape.circle,
        //     border: Border.all(
        //       // color: color.withValues(alpha: .4),
        //       width: 1,
        //     ),
        //   ),
        // ),
      ],
    );
  }
}

class OfficialWidget extends StatelessWidget {
  const OfficialWidget({
    super.key,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.only(left: 4),
      padding: const EdgeInsets.all(4),
      decoration: BoxDecoration(
        border: Border.all(
          color: AppColors.amber.withValues(alpha: .4),
          width: 1,
        ),
        gradient: const LinearGradient(
          begin: Alignment.topCenter,
          end: Alignment.bottomCenter,
          colors: [
            AppColors.whiteIcon,
            AppColors.whiteIcon,
            AppColors.amber,
            AppColors.amber,
          ],
        ),
      ),
      child: Row(
        children: [
          const Icon(
            FontAwesomeIcons.check,
            color: AppColors.brown,
            size: 10,
          ),
          AutoSizeText(
            S.of(context).official,
            style: const TextStyle(
              color: AppColors.brown,
              fontSize: 8,
            ),
          ),
        ],
      ),
    );
  }
}
