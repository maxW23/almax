import 'package:flutter/material.dart';
import 'package:lklk/core/constants/app_colors.dart';
import 'package:lklk/features/auth/domain/entities/user_entity.dart';
import 'package:lklk/features/profile_users/presentaion/manger/user_cubit/user_cubit_cubit.dart';

import 'edit_profile_icon.dart';

class UserProfileTitlesAppbar extends StatelessWidget
    implements PreferredSizeWidget {
  const UserProfileTitlesAppbar(
      {super.key, required this.user, required this.userCubit});
  final UserEntity user;
  final UserCubit userCubit;

  @override
  Size get preferredSize => const Size.fromHeight(kToolbarHeight);

  @override
  Widget build(BuildContext context) {
    return Container(
      color: AppColors.transparent,
      child: EditProfileIcon(userCubit: userCubit, user: user),
    );
  }
}
