import 'package:flutter/material.dart';
import 'package:auto_size_text/auto_size_text.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:lklk/core/constants/app_colors.dart';
import 'package:lklk/core/constants/styles.dart';
import 'package:lklk/features/auth/domain/entities/user_entity.dart';
import 'package:lklk/features/home/presentation/manger/room_cubit/room_cubit_cubit.dart';
import 'package:lklk/features/profile_users/presentaion/manger/user_cubit/user_cubit_cubit.dart';
import 'package:lklk/features/profile_users/presentaion/views/widgets/user_profile_view_body_success_bloc.dart';
import 'package:lklk/features/room/presentation/views/widgets/circular_user_image.dart';

class UserListItem extends StatelessWidget {
  const UserListItem({
    super.key,
    required this.user,
    this.isAdd = false,
    this.roomId,
    this.icon,
    this.onUserAction,
    required this.userCubit,
    required this.roomCubit,
  });

  final UserEntity user;
  final bool isAdd;
  final int? roomId;
  final IconData? icon;
  final Function(int, String)? onUserAction;
  final UserCubit userCubit;
  final RoomCubit roomCubit;

  @override
  Widget build(BuildContext context) {
    return ListTile(
      leading: UserImage(
        user: user,
        userCubit: userCubit,
        roomCubit: roomCubit,
      ),
      title: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          UserNameRow(user: user),
          if (isAdd) ...[
            Row(
              children: [
                const Padding(
                  padding: EdgeInsets.all(4),
                  child: CircleAvatar(
                    backgroundColor: AppColors.whiteIcon,
                    radius: 14,
                    child: Icon(
                      FontAwesomeIcons.idBadge,
                      size: 14,
                    ),
                  ),
                ),
                AutoSizeText(
                  ' user ID : ${user.iduser}',
                  style: Styles.textStyle12bold.copyWith(
                    color: AppColors.grey,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 8),
          ],
        ],
      ),
      trailing: isAdd
          ? AnimatedContainer(
              duration: const Duration(milliseconds: 300),
              child: IconButton(
                icon: Icon(
                  icon ?? FontAwesomeIcons.circlePlus,
                  color: AppColors.danger,
                ),
                onPressed: () async {
                  if (onUserAction != null) {
                    final roomCubitRef = BlocProvider.of<RoomCubit>(context);
                    await onUserAction!(roomId!, user.iduser);
                    roomCubitRef.refreshRoomData(roomId!);
                  }
                },
              ),
            )
          : null,
    );
  }
}

class UserNameRow extends StatelessWidget {
  const UserNameRow({
    super.key,
    required this.user,
  });

  final UserEntity user;

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        const Padding(
          padding: EdgeInsets.all(4),
          child: UserIcon(),
        ),
        AutoSizeText(user.name!),
      ],
    );
  }
}

class UserImage extends StatelessWidget {
  const UserImage({
    super.key,
    required this.user,
    required this.userCubit,
    required this.roomCubit,
  });

  final UserEntity user;
  final UserCubit userCubit;
  final RoomCubit roomCubit;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () {
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (context) => UserProfileViewBodySuccessBloc(
              iduser: user.iduser,
              userCubit: userCubit,
              roomCubit: roomCubit,
            ),
          ),
        );
      },
      child: Hero(
        tag: 'userImage_${user.iduser}',
        child: CircularUserImage(
          imagePath: user.img,
          isEmpty: false,
          radius: 30,
        ),
      ),
    );
  }
}

class UserIcon extends StatelessWidget {
  const UserIcon({
    super.key,
  });

  @override
  Widget build(BuildContext context) {
    return const CircleAvatar(
      backgroundColor: AppColors.whiteIcon,
      radius: 14,
      child: Icon(
        FontAwesomeIcons.user,
        size: 14,
      ),
    );
  }
}
// subtitle: Row(
//   children: [
//     const CustomLevelWidgetIcon(
//       image: AssetsData.levelShieldOneG,
//       text: '1',
//     ),
//     const SizedBox(width: 10),
//     const CustomLevelWidgetIcon(
//       // colorBackground: AppColors.gray,
//       // colorIcon: AppColors.danger,
//       // colorIconBackgound: AppColors.whiteIcon,
//       // icon: FontAwesomeIcons.heartCircleBolt,
//       image: AssetsData.levelShieldOneG,

//       text: '0',
//     ),
//     const SizedBox(width: 10),
//     CustomLevelWidgetIcon(
//       // colorBackground: user.type == 'owner'
//       // ? AppColors.golden
//       // : user.type == 'admin'
//       //     ? AppColors.fourthColor
//       //     : AppColors.gray,
//       // colorIcon: user.type == 'owner'
//       //     ? AppColors.golden
//       //     : user.type == 'admin'
//       //         ? AppColors.fourthColor
//       //         : AppColors.gray,
//       // colorIconBackgound: AppColors.whiteIcon,
//       // icon: Icons.person,
//       text: '${user.type}',
//     ),
//   ],
// ),
