// ignore_for_file: public_member_api_docs, sort_constructors_first

import 'package:flutter/material.dart';
import 'package:lklk/core/constants/app_colors.dart';
import 'package:lklk/features/auth/domain/entities/user_entity.dart';
import 'package:lklk/features/home/presentation/manger/room_cubit/room_cubit_cubit.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:lklk/features/profile_users/presentaion/manger/user_cubit/user_cubit_cubit.dart';
import 'package:lklk/features/profile_users/presentaion/views/widgets/user_profile_appbar.dart';
import '../widgets/user_profile_view_body_success.dart';

class UserProfileView extends StatefulWidget {
  const UserProfileView(
      {super.key, required this.userCubit, required this.roomCubit});
  final UserCubit userCubit;
  final RoomCubit roomCubit;
  @override
  State<UserProfileView> createState() => _UserProfileViewState();
}

class _UserProfileViewState extends State<UserProfileView> {
  @override
  Widget build(BuildContext context) {
    // widget.userCubit.getProfileUser("UserProfileView context");
    return SingleChildScrollView(
      child: Container(
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
        child: Column(
          children: [
            // const UserProfileAppbar(),
            BlocConsumer<UserCubit, UserCubitState>(
              bloc: widget.userCubit
                ..getProfileUser("widget.userCubit..getProfileUser"),
              listener: (context, state) {},
              builder: (context, state) {
                final UserEntity? user = state.user;

                if (user != null) {
                  return UserProfileViewBodySuccess(
                    user: user,
                    userCubit: widget.userCubit,
                    roomCubit: widget.roomCubit,
                    friendNumber: state.friendNumber ?? 0,
                    friendRequest: state.friendRequest ?? 0,
                    relationRequest: state.relationRequest ?? 0,
                    visitorNumber: state.visitorNumber ?? 0,
                    giftList: state.giftList ?? [],
                    entryList: state.entryList ?? [],
                    frameList: state.frameList ?? [],
                  );
                } else {
                  return const SizedBox();
                }
              },
            ),
          ],
        ),
      ),
    );
  }

  @override
  void dispose() {
    // Clean up any active work here if necessary
    super.dispose();
  }
}
