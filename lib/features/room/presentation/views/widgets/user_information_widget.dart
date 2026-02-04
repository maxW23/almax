import 'package:flutter/material.dart';
import 'package:auto_size_text/auto_size_text.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:lklk/core/constants/app_colors.dart';
import 'package:lklk/core/constants/styles.dart';
import 'package:lklk/features/auth/domain/entities/user_entity.dart';
import 'package:lklk/features/home/presentation/manger/room_cubit/room_cubit_cubit.dart';
import 'package:lklk/features/profile_users/presentaion/manger/user_cubit/user_cubit_cubit.dart';
import 'package:lklk/features/room/domain/entities/room_entity.dart';
import 'package:lklk/features/room/presentation/views/widgets/circular_user_image.dart';
import 'package:lklk/features/room/presentation/views/widgets/faviorate_room_btn.dart';
import 'package:lklk/features/room/presentation/views/widgets/room_my_bottonsheet.dart';
import 'package:flutter/services.dart'; // Required for Clipboard
import 'package:lklk/core/utils/functions/snackbar_helper.dart';
import 'package:lklk/generated/l10n.dart';
import 'package:lklk/zego_sdk_manager.dart';

class UserInformationWidget extends StatelessWidget {
  const UserInformationWidget(
      {super.key,
      required this.room,
      required this.roomCubit,
      this.users,
      this.bannedUsers,
      required this.userCubit,
      required this.onSend,
      required this.adminUsers});
  final RoomEntity room;
  final RoomCubit roomCubit;
  final List<UserEntity>? users;
  final List<UserEntity>? bannedUsers;
  final List<UserEntity>? adminUsers;
  final UserCubit userCubit;
  final void Function(ZIMMessage) onSend;
  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () {
        showModalBottomSheet(
          barrierColor: Colors.transparent,
          context: context,
          builder: (BuildContext context) {
            return RoomInfoBottomSheet(
              room: room,
              roomCubit: roomCubit,
              users: users,
              bannedUsers: bannedUsers,
              userCubit: userCubit,
              onSend: onSend,
              adminUsers: adminUsers,
            );
          },
        );
      },
      child: Container(
        margin: const EdgeInsets.only(left: 8),
        // decoration: BoxDecoration(
            // color: AppColors.whiteWithOpacity2,
            // borderRadius: const BorderRadius.all(Radius.circular(10)),
            // border: Border.all(color: AppColors.blackWithOpacity1, width: .8)),
        // height: kToolbarHeight,
        // width: kToolbarHeight * 3.5,
        child: BlocBuilder<RoomCubit, RoomCubitState>(
          builder: (context, state) {
            String nameRoom = room.name;
            String imageUrlRoom = room.img;
            if (state.status.isRoomLoaded) {
              nameRoom = state.room!.name;
              imageUrlRoom = state.room!.img;
            } else if (state.status.isInitial) {
              nameRoom = room.name;
              imageUrlRoom = room.img;
            }
            return Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                const SizedBox(width: 6),
                SizedBox(
                    height: kToolbarHeight,
                    width: kToolbarHeight,
                    child: CircularUserImage(imagePath: imageUrlRoom)),
                const SizedBox(width: 6),
                Container(
                  height: kToolbarHeight,
                  width: kToolbarHeight * 2.1,
                  color: Colors.transparent,
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                    crossAxisAlignment: CrossAxisAlignment.start,
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Flexible(
                        child: AutoSizeText(nameRoom,
                            overflow: TextOverflow.ellipsis,
                            style: Styles.textStyle12bold
                                .copyWith(color: AppColors.white)),
                      ),
                      GestureDetector(
                        behavior: HitTestBehavior.opaque,
                        onTap: () {
                          Clipboard.setData(
                              ClipboardData(text: room.id.toString()));
                          SnackbarHelper.showMessage(
                            context,
                            S.of(context).doneCopiedToClipboard,
                          );
                        },
                        child: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Flexible(
                              child: AutoSizeText(
                                'ID: ${room.id}',
                                maxLines: 1,
                                overflow: TextOverflow.ellipsis,
                                style: Styles.textStyle12.copyWith(
                                  color: AppColors.white,
                                  fontWeight: FontWeight.w400,
                                ),
                              ),
                            ),
                            const SizedBox(width: 4),
                            const Icon(
                              Icons.content_copy,
                              size: 10,
                              color: AppColors.white,
                            ),
                           
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            );
          },
        ),
      ),
    );
  }
}
