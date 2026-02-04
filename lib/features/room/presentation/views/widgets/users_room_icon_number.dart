import 'package:flutter/material.dart';
import 'package:auto_size_text/auto_size_text.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:lklk/core/constants/app_colors.dart';
import 'package:lklk/features/home/presentation/manger/room_cubit/room_cubit_cubit.dart';

class UsersRoomIconNumber extends StatelessWidget {
  const UsersRoomIconNumber(
      {super.key, required this.icon, required this.value, this.onTap});
  final IconData icon;
  final int value;
  final void Function()? onTap;
  @override
  Widget build(BuildContext context) {
    return BlocBuilder<RoomCubit, RoomCubitState>(builder: (context, state) {
      int numberUsers = value;
      if (state.status.isRoomLoaded) {
        numberUsers = state.usersZego!.length;
      } else if (state.status.isInitial) {
        numberUsers = value;
      }
      return GestureDetector(
        onTap: onTap,
        child: Container(
          decoration: BoxDecoration(
            color: AppColors.whiteWithOpacity25,
            borderRadius: BorderRadius.circular(20),
          ),
          padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 7),
          child: Row(
            children: [
              Icon(
                icon,
                size: 20,
                color: AppColors.whiteIcon.withValues(alpha: .8),
              ),
              const SizedBox(width: 10),
              AutoSizeText(numberUsers.toString(),
                  style: const TextStyle(
                    color: AppColors.whiteIcon,
                  )),
            ],
          ),
        ),
      );
    });
  }
}
