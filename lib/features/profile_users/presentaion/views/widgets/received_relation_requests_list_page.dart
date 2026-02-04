// ignore_for_file: public_member_api_docs, sort_constructors_first

import 'package:flutter/material.dart';
import 'package:auto_size_text/auto_size_text.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:lklk/core/constants/app_colors.dart';
import 'package:lklk/features/home/presentation/manger/room_cubit/room_cubit_cubit.dart';
import 'package:lklk/features/profile_users/presentaion/manger/relation_cubit/relation_cubit.dart';
import 'package:lklk/features/profile_users/presentaion/manger/relation_progress_cubit/relation_progress_cubit.dart';
import 'package:lklk/features/profile_users/presentaion/manger/user_cubit/user_cubit_cubit.dart';
import 'package:lklk/features/profile_users/presentaion/views/widgets/empty_screen.dart';
import 'package:lklk/features/profile_users/presentaion/views/widgets/user_profile_view_body_success_bloc.dart';
import 'package:lklk/features/room/presentation/views/widgets/user_widget_title.dart';

class ReceivedRelationRequestsListPage extends StatelessWidget {
  const ReceivedRelationRequestsListPage(
      {super.key, required this.userCubit, required this.roomCubit});
  final UserCubit userCubit;
  final RoomCubit roomCubit;

  @override
  Widget build(BuildContext context) {
    return BlocProvider<RelationCubit>(
      create: (context) => RelationCubit(),
      child: ReceivedRelationRequestsListPageBody(
        userCubit: userCubit,
        roomCubit: roomCubit,
      ),
    );
  }
}

class ReceivedRelationRequestsListPageBody extends StatelessWidget {
  const ReceivedRelationRequestsListPageBody({
    super.key,
    required this.userCubit,
    required this.roomCubit,
  });

  final UserCubit userCubit;
  final RoomCubit roomCubit;

  @override
  Widget build(BuildContext context) {
    double w = MediaQuery.of(context).size.width;

    return MultiBlocProvider(
      providers: [
        BlocProvider<RelationProgressCubit>(
          create: (context) => RelationProgressCubit(),
        ),
        BlocProvider(
          create: (context) => RelationCubit()..getReceivedRelationRequests(),
        ),
      ],
      child: SafeArea(
        top: false,
        child: Scaffold(
          body: SafeArea(
            child: BlocConsumer<RelationCubit, RelationState>(
              listener: (context, state) async {
                if (state is RelationProgressRelationRequestAccepted ||
                    state is RelationProgressError) {
                  await BlocProvider.of<RelationCubit>(context)
                      .getReceivedRelationRequests();
                }
              },
              builder: (context, state) {
                //log('getReceivedRelationRequests state is : //');
                if (state is RelationError) {
                  return Center(
                      child: AutoSizeText('RelationError ${state.message}'));
                } else if (state is RelationReceivedRelationRequestsLoaded) {
                  if (state.relationRequests.isEmpty) {
                    return const EmptyScreen();
                  } else {
                    return ListView.builder(
                      padding: EdgeInsets.all(w / 30),
                      physics: const BouncingScrollPhysics(
                        parent: AlwaysScrollableScrollPhysics(),
                      ),
                      itemCount: state.relationRequests.length,
                      itemBuilder: (context, index) =>
                          relationItem(w, context, state, index),
                    );
                  }
                } else {
                  return const Center(
                    // child: AutoSizeText('state ')
                    child: SizedBox(),
                  );
                }
              },
            ),
          ),
        ),
      ),
    );
  }

  Container relationItem(double w, BuildContext context,
      RelationReceivedRelationRequestsLoaded state, int index) {
    return Container(
      margin: EdgeInsets.only(bottom: w / 10),
      child: UserWidgetTitle(
        isRoomTypeUser: false,
        isWakel: true,
        isAnimatedIcon: true,
        isID: true,
        isLevel: false,
        iconColor: AppColors.danger,
        isPressIcon: () async {
          //log('addFriend');
          await BlocProvider.of<RelationProgressCubit>(context)
              .acceptRelationRequest(
                  state.relationRequests[index].user!.iduser);
          await BlocProvider.of<RelationCubit>(context)
              .getReceivedRelationRequests();
        },
        isPressIcon2: () async {
          //log('deleteFriendOrFriendRequest ${state.relationRequest!s[index].user!.iduser}');
          await BlocProvider.of<RelationProgressCubit>(context)
              .acceptRelationRequest(
            state.relationRequests[index].user!.iduser,
          );
          await BlocProvider.of<RelationCubit>(context)
              .getReceivedRelationRequests();
        },
        icon: FontAwesomeIcons.heartCircleCheck,
        iconSecond: FontAwesomeIcons.heartCirclePlus,
        isIcon: true,
        user: state.relationRequests[index].user!,
        userCubit: userCubit,
        onTap: () => Navigator.push(
          context,
          MaterialPageRoute(
            builder: (context) => UserProfileViewBodySuccessBloc(
              iduser: state.relationRequests[index].user!.iduser,
              userCubit: userCubit,
              roomCubit: roomCubit,
            ),
          ),
        ),
      ),
    );
  }
}
