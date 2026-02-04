// ignore_for_file: use_build_context_synchronously
import 'package:flutter/material.dart';
import 'package:lklk/features/home/presentation/manger/room_cubit/room_cubit_cubit.dart';
import 'package:lklk/features/profile_users/presentaion/manger/user_cubit/user_cubit_cubit.dart';
import 'room_image_widget.dart';
import 'room_titles_widget.dart';
import '../../../../room/domain/entities/room_entity.dart';

class RoomItemWidgetTitles extends StatelessWidget {
  final RoomEntity room;
  final RoomCubit roomCubit;
  final UserCubit userCubit;

  const RoomItemWidgetTitles({
    super.key,
    required this.room,
    required this.roomCubit,
    required this.userCubit,
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        RoomImageWidget(imageUrl: room.img),
        Expanded(child: RoomTitlesWidget(room: room)),
        // const Align(
        //     alignment: Alignment.bottomCenter, child: RoomPointsWidgets()),
      ],
    );
  }
}
