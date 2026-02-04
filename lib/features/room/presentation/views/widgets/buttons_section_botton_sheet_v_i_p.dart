import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:lklk/core/constants/app_colors.dart';
import 'package:lklk/core/constants/assets.dart';
import 'package:lklk/core/utils/gifts_bottom_sheet.dart';
import 'package:lklk/features/auth/domain/entities/user_entity.dart';
import 'package:lklk/features/chat/presentation/views/chat_private_page.dart';
import 'package:lklk/features/home/presentation/manger/gifts_show_cubit/gifts_show_cubit.dart';
import 'package:lklk/features/home/presentation/manger/room_cubit/room_cubit_cubit.dart';
import 'package:lklk/features/profile_users/presentaion/manger/user_cubit/user_cubit_cubit.dart';
import 'package:lklk/features/profile_users/presentaion/views/widgets/user_profile_view_body_success_bloc.dart';
import 'package:lklk/features/room/presentation/views/widgets/button_icon_with_text_widget.dart';
import 'package:lklk/features/room/presentation/views/widgets/custom_duration_dialog.dart';
import 'package:lklk/generated/l10n.dart';
import 'package:lklk/zego_sdk_manager.dart';

class ButtonsSectionBottonSheetVIP extends StatelessWidget {
  const ButtonsSectionBottonSheetVIP({
    super.key,
    required this.user,
    required this.isME,
    required this.roomId,
    required this.roomCubit,
    required this.onSend,
  });

  final UserEntity user;
  final bool isME;
  final String roomId;
  final RoomCubit roomCubit;
  final void Function(ZIMMessage) onSend;

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<UserCubit, UserCubitState>(
      builder: (context, userState) {
        final currentUser = userState.user;
        final currentUserImg = currentUser?.img ?? AssetsData.userTestNetwork;

        return Row(
          mainAxisAlignment: MainAxisAlignment.center,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            SizedBox(
              width: 75,
              child: TextButton(
                onPressed: () => Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => UserProfileViewBodySuccessBloc(
                      iduser: user.iduser,
                      roomCubit: roomCubit,
                      userCubit: context.read<UserCubit>(),
                    ),
                  ),
                ),
                child: ButtonIconWithTextWidget(
                  text: S.of(context).profile,
                  colorText: AppColors.grey,
                  svgAsset:
                      'assets/icons/user_vip_sheet_icons/profile_icon_gray.svg',
                ),
              ),
            ),
            if (!isME)
              SizedBox(
                width: 75,
                child: TextButton(
                  onPressed: () => Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) => ChatPrivatePageBloc(
                        roomCubit: roomCubit,
                        userId: user.iduser,
                        userImg: user.img,
                        userName: user.name!,
                        userImgcurrent: currentUserImg,
                        userCubit: context.read<UserCubit>(),
                      ),
                    ),
                  ),
                  child: ButtonIconWithTextWidget(
                    text: S.of(context).chat,
                    colorText: AppColors.grey,
                    svgAsset:
                        'assets/icons/user_vip_sheet_icons/chat_icon_gray.svg',
                  ),
                ),
              ),
            SizedBox(
              width: 75,
              child: TextButton(
                onPressed: () {
                  GiftsBottomSheetWidget.showBasicModalBottomSheet(
                    context,
                    user,
                    roomId,
                    context.read<UserCubit>(),
                    context.read<GiftsShowCubit>(),
                    onSend,
                    [user],
                  );
                },
                child: ButtonIconWithTextWidget(
                  text: S.of(context).sendGift,
                  colorText: AppColors.grey,
                  svgAsset:
                      'assets/icons/user_vip_sheet_icons/gift_icon_gray.svg',
                ),
              ),
            ),
            BlocConsumer<RoomCubit, RoomCubitState>(
              listener: (context, state) {},
              builder: (context, state) {
                UserEntity? typeUserState;
                final users = state.usersZego;
                if (users != null) {
                  for (final u in users) {
                    if (u.iduser == user.iduser) {
                      typeUserState = u;
                      break;
                    }
                  }
                }

                final String roomKey = roomId.toString();
                final bool iAmOwnerOrAdmin =
                    (currentUser?.ownerIds?.contains(roomKey) ?? false) ||
                        (currentUser?.adminRoomIds?.contains(roomKey) ?? false);
                final bool targetIsOwner =
                    user.ownerIds?.contains(roomKey) ?? false;

                final List<Widget> extra = [];

                if (iAmOwnerOrAdmin && !isME) {
                  if (state.status.isAdminLoading) {
                    extra.add(const SizedBox(
                      width: 70,
                      height: 70,
                      child: Center(
                          child: SizedBox(
                              width: 18,
                              height: 18,
                              child:
                                  CircularProgressIndicator(strokeWidth: 2))),
                    ));
                  } else {
                    final bool isTargetAdmin =
                        typeUserState?.adminRoomIds?.contains(roomKey) ?? false;
                    final bool isTargetOwner =
                        typeUserState?.ownerIds?.contains(roomKey) ?? false;
                    if (!isTargetOwner) {
                      extra.add(SizedBox(
                        width: 75,
                        child: TextButton(
                          onPressed: () async {
                            try {
                              if (!isTargetAdmin) {
                                await roomCubit.addAdminToRoom(
                                    int.parse(roomId), user.iduser);
                              } else {
                                await roomCubit.removeAdminFromRoom(
                                    int.parse(roomId), user.iduser);
                              }
                              roomCubit.refreshUserData(user.iduser);
                            } catch (_) {}
                          },
                          child: ButtonIconWithTextWidget(
                            text: !isTargetAdmin
                                ? S.of(context).addAdmin
                                : S.of(context).removeAdmin,
                            colorText: AppColors.grey,
                            svgAsset: !isTargetAdmin
                                ? 'assets/icons/user_vip_sheet_icons/admin_icon_gray.svg'
                                : 'assets/icons/user_vip_sheet_icons/admin_to_user_gray_icon.svg',
                          ),
                        ),
                      ));
                    }
                  }
                }

                if (iAmOwnerOrAdmin && !targetIsOwner && !isME) {
                  final bool isBanned = state.bannedUsers
                          ?.any((bu) => bu.iduser == user.iduser) ??
                      false;
                  extra.add(SizedBox(
                    width: 75,
                    child: TextButton(
                      onPressed: () async {
                        try {
                          if (isBanned) {
                            await roomCubit.removeBanFromUser(
                                int.parse(roomId), user.iduser);
                          } else {
                            final String? how = await showDialog<String>(
                              context: context,
                              builder: (ctx) => const CustomDurationDialog(),
                            );
                            await roomCubit.banUserFromRoom(
                                int.parse(roomId), user.iduser, how ?? "");
                          }
                          if (context.mounted) {
                            roomCubit.refreshRoomData(int.parse(roomId));
                          }
                        } catch (_) {}
                      },
                      child: ButtonIconWithTextWidget(
                        text: isBanned
                            ? S.of(context).kickOutdone
                            : S.of(context).kickOut,
                        colorText: AppColors.grey,
                        svgAsset:
                            'assets/icons/user_vip_sheet_icons/kick_icon_gray.svg',
                      ),
                    ),
                  ));
                }

                return Row(children: extra);
              },
            ),
          ],
        );
      },
    );
  }
}
