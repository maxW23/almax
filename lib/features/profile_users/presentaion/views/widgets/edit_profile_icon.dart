import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:lklk/core/constants/app_colors.dart';
import 'package:lklk/features/auth/domain/entities/user_entity.dart';
import 'package:lklk/features/profile_users/presentaion/manger/user_cubit/user_cubit_cubit.dart';
import 'package:lklk/features/profile_users/presentaion/views/pages/user_profile_edit_page.dart';

class EditProfileIcon extends StatelessWidget {
  const EditProfileIcon({
    super.key,
    required this.userCubit,
    required this.user,
  });

  final UserCubit userCubit;
  final UserEntity user;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16),
      child: IconButton(
        icon: ShaderMask(
          shaderCallback: (bounds) => const LinearGradient(
            colors: [AppColors.white, AppColors.secondColor],
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
          ).createShader(bounds),
          child: const Icon(
            FontAwesomeIcons.edit,
            color: Colors.white,
          ),
        ),
        onPressed: () => Navigator.push(
          context,
          MaterialPageRoute(
            builder: (context) => UserProfileEditPage(
              userCubit: userCubit,
              user: user,
            ),
          ),
        ),
      ),
    );
  }
}
