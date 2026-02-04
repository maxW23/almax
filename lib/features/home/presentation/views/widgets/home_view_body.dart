import 'package:flutter/material.dart';
import 'package:lklk/core/constants/app_colors.dart';
import 'package:lklk/features/home/presentation/manger/room_cubit/room_cubit_cubit.dart';
import 'package:lklk/features/home/presentation/views/widgets/rooms_view.dart';
import 'package:lklk/features/profile_users/presentaion/manger/user_cubit/user_cubit_cubit.dart';

class RoomsHome extends StatelessWidget {
  const RoomsHome({
    super.key,
    required this.roomCubit,
    required this.userCubit,
  });

  final RoomCubit roomCubit;
  final UserCubit userCubit;

  @override
  Widget build(BuildContext context) {
    return Container(
        // color: AppColors.primary,
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.centerLeft,
            end: Alignment.centerRight,
            colors: [
              AppColors.primary, // بنفسجي فاتح
              AppColors.secondColor, // بنفسجي غامق
            ],
          ),
        ),
        child: SafeArea(
          child: RoomsView(roomCubit: roomCubit, userCubit: userCubit),
        ));
  }
}
