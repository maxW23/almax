// ignore_for_file: public_member_api_docs, sort_constructors_first

import 'package:flutter/material.dart';
import 'package:lklk/features/home/presentation/manger/room_cubit/room_cubit_cubit.dart';
import 'package:lklk/features/profile_users/presentaion/views/pages/other_user_profile.dart';
import 'package:lklk/features/profile_users/presentaion/views/widgets/profile_bottom_naigation_bar.dart';

class ProfileBottomNaigationBarSection extends StatelessWidget {
  const ProfileBottomNaigationBarSection({
    super.key,
    required this.widget,
    required this.roomCubit,
  });

  final OtherUserProfile widget;
  final RoomCubit roomCubit;

  @override
  Widget build(BuildContext context) {
    return Positioned(
      bottom: 0,
      right: 0,
      left: 0,
      child: widget.userCubit.user?.iduser == widget.user.iduser
          ? const SizedBox()
          : ProfileBottomNaigationBar(
              userCubit: widget.userCubit,
              user: widget.user,
              friendStatus: widget.friendStatus,
              roomCubit: roomCubit,
            ),
    );
  }
}
