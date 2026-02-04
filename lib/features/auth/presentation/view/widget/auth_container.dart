import 'package:flutter/material.dart';
import 'package:lklk/core/animations/shimmer_widget.dart';
import 'package:lklk/core/constants/app_colors.dart';
import 'package:lklk/features/auth/presentation/view/widget/login_form.dart';
import 'package:lklk/features/auth/presentation/view/widget/logo_lklk.dart';
import 'package:lklk/features/auth/presentation/view/widget/progress_button.dart';
import 'package:lklk/features/home/presentation/manger/room_cubit/room_cubit_cubit.dart';
import 'package:lklk/features/profile_users/presentaion/manger/user_cubit/user_cubit_cubit.dart';

class AuthContainer extends StatelessWidget {
  final UserCubit userCubit;
  final RoomCubit roomCubit;
  final bool enabled;

  const AuthContainer(
      {super.key,
      required this.userCubit,
      required this.roomCubit,
      required this.enabled});

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      physics: const BouncingScrollPhysics(),
      child: Center(
        child: Container(
          width: double.infinity,
          margin: const EdgeInsets.symmetric(horizontal: 30),
          padding: const EdgeInsets.symmetric(horizontal: 25, vertical: 40),
          decoration: BoxDecoration(
            color: AppColors.black.withValues(alpha: .5),
            borderRadius: BorderRadius.circular(30),
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              ShimmerWidget(
                  period: const Duration(seconds: 4),
                  gradient: LinearGradient(
                      colors: [
                        AppColors.transparent,
                        AppColors.white.withValues(alpha: .15),
                        AppColors.transparent
                      ],
                      begin: Alignment.topLeft,
                      end: Alignment.bottomRight,
                      tileMode: TileMode.repeated),
                  child: const LogoLKLK()),
              const SizedBox(height: 40),
              LoginForm(userCubit: userCubit, roomCubit: roomCubit),
              const SizedBox(height: 40),
              ProgressButtonWidget(
                userCubit: userCubit,
                roomCubit: roomCubit,
                enabled: enabled,
              ),
            ],
          ),
        ),
      ),
    );
  }
}
