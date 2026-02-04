import 'package:flutter/material.dart';
import 'package:lklk/features/home/presentation/manger/room_cubit/room_cubit_cubit.dart';
import 'package:lklk/features/profile_users/presentaion/manger/user_cubit/user_cubit_cubit.dart';
import 'package:lklk/features/room/presentation/views/widgets/gifts_show_section.dart';

class GiftShowSctionPart extends StatelessWidget {
  const GiftShowSctionPart({
    super.key,
    required this.h,
    required this.roomCubit,
    required this.userCubit,
  });

  final double h;
  final RoomCubit roomCubit;
  final UserCubit userCubit;

  @override
  Widget build(BuildContext context) {
    return Stack(
      // mainAxisAlignment: MainAxisAlignment.start,
      children: [
        const GiftsShowSection(),
      ],
    );
  }
}
