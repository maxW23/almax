// ignore_for_file: public_member_api_docs, sort_constructors_first

import 'package:flutter/material.dart';
import 'package:flutter_staggered_animations/flutter_staggered_animations.dart';
import 'package:lklk/features/auth/domain/entities/user_entity.dart';
import 'package:lklk/features/home/presentation/manger/room_cubit/room_cubit_cubit.dart';
import 'package:lklk/features/profile_users/domain/entities/friend_user.dart';
import 'package:lklk/features/profile_users/presentaion/manger/user_cubit/user_cubit_cubit.dart';
import 'package:lklk/features/profile_users/presentaion/views/widgets/user_profile_view_body_success_bloc.dart';
import 'package:lklk/features/room/presentation/views/widgets/user_widget_title.dart';

class BuildAnimatedUsersItem extends StatelessWidget {
  const BuildAnimatedUsersItem({
    super.key,
    required this.context,
    required this.index,
    required this.users,
    required this.userCubit,
    required this.roomCubit,
  });

  final BuildContext context;
  final int index;
  final List<UserEntity> users;
  final UserCubit userCubit;
  final RoomCubit roomCubit;

  @override
  Widget build(BuildContext context) {
    double w = MediaQuery.of(context).size.width;

    return AnimationConfiguration.staggeredList(
      position: index,
      delay: const Duration(milliseconds: 100),
      child: SlideAnimation(
        duration: const Duration(milliseconds: 2500),
        curve: Curves.fastLinearToSlowEaseIn,
        horizontalOffset: 30,
        verticalOffset: 300.0,
        child: FlipAnimation(
          duration: const Duration(milliseconds: 3000),
          curve: Curves.fastLinearToSlowEaseIn,
          flipAxis: FlipAxis.y,
          child: Container(
            margin: EdgeInsets.only(bottom: w / 10),
            child: UserWidgetTitle(
              isID: true,
              isRoomTypeUser: false,
              isWakel: true,
              // isNavigateProfile: true,
              onTap: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => UserProfileViewBodySuccessBloc(
                      iduser: users[index].iduser,
                      userCubit: userCubit,
                      roomCubit: roomCubit,
                    ),
                  ),
                );
              },
              user: users[index],
              userCubit: userCubit,
            ),
          ),
        ),
      ),
    );
  }
}

class BuildAnimatedUsersItemFreind extends StatelessWidget {
  const BuildAnimatedUsersItemFreind({
    super.key,
    required this.context,
    required this.index,
    required this.users,
    required this.userCubit,
    required this.roomCubit,
  });

  final BuildContext context;
  final int index;
  final List<FriendUser> users;
  final UserCubit userCubit;
  final RoomCubit roomCubit;

  @override
  Widget build(BuildContext context) {
    double w = MediaQuery.of(context).size.width;

    return AnimationConfiguration.staggeredList(
      position: index,
      delay: const Duration(milliseconds: 100),
      child: SlideAnimation(
        duration: const Duration(milliseconds: 2500),
        curve: Curves.fastLinearToSlowEaseIn,
        horizontalOffset: 30,
        verticalOffset: 300.0,
        child: FlipAnimation(
          duration: const Duration(milliseconds: 3000),
          curve: Curves.fastLinearToSlowEaseIn,
          flipAxis: FlipAxis.y,
          child: Container(
            margin: EdgeInsets.only(bottom: w / 10),
            child: UserWidgetTitle(
              isID: true,
              isRoomTypeUser: false,
              isWakel: true,
              // isNavigateProfile: true,
              onTap: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => UserProfileViewBodySuccessBloc(
                      iduser: users[index].friendUser.iduser,
                      userCubit: userCubit,
                      roomCubit: roomCubit,
                    ),
                  ),
                );
              },
              user: users[index].friendUser,
              userCubit: userCubit,
            ),
          ),
        ),
      ),
    );
  }
}

/// 000 000
