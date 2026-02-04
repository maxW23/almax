// ignore_for_file: public_member_api_docs, sort_constructors_first

import 'package:lklk/core/utils/logger.dart';

import 'package:flutter/material.dart';
import 'package:auto_size_text/auto_size_text.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:lklk/core/constants/app_colors.dart';
import 'package:lklk/features/home/presentation/manger/room_cubit/room_cubit_cubit.dart';
import 'package:lklk/features/profile_users/presentaion/manger/freind_progress/freind_progress_cubit.dart';
import 'package:lklk/features/profile_users/presentaion/manger/friend_cubit/freind_cubit.dart';
import 'package:lklk/features/profile_users/presentaion/manger/user_cubit/user_cubit_cubit.dart';
import 'package:lklk/features/profile_users/presentaion/views/widgets/empty_screen.dart';
import 'package:lklk/features/profile_users/presentaion/views/widgets/user_profile_view_body_success_bloc.dart';
import 'package:lklk/features/room/presentation/views/widgets/user_widget_title.dart';

class FriendWaitingListPage extends StatelessWidget {
  const FriendWaitingListPage(
      {super.key, required this.userCubit, required this.roomCubit});
  final UserCubit userCubit;
  final RoomCubit roomCubit;

  @override
  Widget build(BuildContext context) {
    double w = MediaQuery.of(context).size.width;

    return MultiBlocProvider(
      providers: [
        BlocProvider<FreindCubit>(
          create: (context) => FreindCubit()..getWaitingFriendRequestsList(),
        ),
        BlocProvider<FreindProgressCubit>(
            lazy: true, create: (context) => FreindProgressCubit()),
      ],
      child: SafeArea(
        top: false,
        child: Scaffold(
          body: SafeArea(
              child: BlocConsumer<FreindCubit, FreindState>(
            listener: (context, state) {
              if (state is FreindProgressFriendRequestAccepted ||
                  state is FreindProgressError) {
                BlocProvider.of<FreindCubit>(context)
                    .getWaitingFriendRequestsList();
              }
            },
            builder: (context, state) {
              //log('state is : //');
              if (state is FreindError) {
                return Center(child: AutoSizeText(state.message));
              }
              if (state is FreindLoadingList) {
                return const Center(
                  child: CircularProgressIndicator(
                    color: AppColors.black,
                  ),
                );
              }
              if (state is FreindWaitingFriendRequestsLoaded) {
                if (state.friendshipEntity.isEmpty) {
                  return const EmptyScreen();
                } else {
                  return ListView.builder(
                      padding: EdgeInsets.all(w / 30),
                      physics: const BouncingScrollPhysics(
                        parent: AlwaysScrollableScrollPhysics(),
                      ),
                      cacheExtent: 300,
                      addAutomaticKeepAlives: true,
                      addRepaintBoundaries: true,
                      addSemanticIndexes: false,
                      itemCount: state.friendshipEntity.length,
                      itemBuilder: (context, index) =>
                          ///////////////////////////////////////////////////////////
                          RepaintBoundary(
                            child: freindWaitingItem(w, context, state, index),
                          ));
                }
              }

              if (state is FreindError) {
                return Center(
                    child: AutoSizeText('UserCubitError ${state.message}'));
              } else {
                return const Center(
                  // child: AutoSizeText('state ')
                  child: SizedBox(),
                );
              }
            },
          )),
        ),
      ),
    );
  }

  Container freindWaitingItem(double w, BuildContext context,
      FreindWaitingFriendRequestsLoaded state, int index) {
    return Container(
      margin: EdgeInsets.only(bottom: w / 10),
      child: UserWidgetTitle(
        isRoomTypeUser: false,
        isWakel: true,
        isAnimatedIcon: true,
        isID: true,
        isLevel: false,
        iconColor: AppColors.black,
        isPressIcon: () async {
          //log('addFriend');

          // await userCubit.addFriend(users[index].iduser!);
          log("state.friendshipEntity[index].stringId ${state.friendshipEntity[index].stringId}");
          await BlocProvider.of<FreindProgressCubit>(context)
              .acceptFriendRequest(state.friendshipEntity[index].stringId);
          await BlocProvider.of<FreindCubit>(context)
              .getWaitingFriendRequestsList();
        },
        isPressIcon2: () async {
          // Use the friendship record stringId for deletion
          final friendShipStringId = state.friendshipEntity[index].stringId;
          await BlocProvider.of<FreindProgressCubit>(context)
              .deleteFriendOrFriendRequest(friendShipStringId);
          await BlocProvider.of<FreindCubit>(context)
              .getWaitingFriendRequestsList();
        },
        icon: FontAwesomeIcons.userCheck,
        iconSecond: FontAwesomeIcons.userMinus,
        isIcon: true,
        user: state.friendshipEntity[index].userSent,
        userCubit: userCubit,
        onTap: () => Navigator.push(
          context,
          MaterialPageRoute(
            builder: (context) => UserProfileViewBodySuccessBloc(
              iduser: state.friendshipEntity[index].userSent.iduser,
              userCubit: userCubit,
              roomCubit: roomCubit,
            ),
          ),
        ),
      ),
    );
  }
}
