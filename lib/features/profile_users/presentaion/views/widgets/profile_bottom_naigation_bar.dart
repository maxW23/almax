// ignore_for_file: public_member_api_docs, sort_constructors_first

import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';

import 'package:lklk/core/constants/app_colors.dart';
import 'package:lklk/core/constants/assets.dart';
import 'package:lklk/features/auth/domain/entities/user_entity.dart';
import 'package:lklk/features/chat/presentation/views/chat_private_page.dart';
import 'package:lklk/features/home/presentation/manger/room_cubit/room_cubit_cubit.dart';
import 'package:lklk/features/profile_users/presentaion/manger/freind_progress/freind_progress_cubit.dart';
import 'package:lklk/features/profile_users/presentaion/manger/relation_progress_cubit/relation_progress_cubit.dart';
import 'package:lklk/features/profile_users/presentaion/manger/user_cubit/user_cubit_cubit.dart';
import 'package:lklk/features/profile_users/presentaion/views/widgets/custom_icon_text_button.dart';
import 'package:lklk/generated/l10n.dart';

class ProfileBottomNaigationBar extends StatelessWidget {
  final UserEntity user;
  final UserCubit userCubit;
  final RoomCubit roomCubit;
  final String? friendStatus;
  const ProfileBottomNaigationBar({
    super.key,
    required this.user,
    required this.userCubit,
    this.friendStatus,
    required this.roomCubit,
  });

  @override
  Widget build(BuildContext context) {
    //log('friendStatus :$friendStatus');
    return MultiBlocProvider(
      providers: [
        BlocProvider<FreindProgressCubit>(
          lazy: true,
          create: (context) => FreindProgressCubit(),
        ),
        BlocProvider<RelationProgressCubit>(
            lazy: true, create: (context) => RelationProgressCubit()),
      ],
      child: Container(
        color: AppColors.transparent,
        height: 80,
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceEvenly,
          children: [
            chatBtn(context),
            // BlocBuilder<RoomCubit, RoomCubitState>(
            //   builder: (context, state) {
            //     return CustomIconTextButtonRelation(
            //       title: S.of(context).track,
            //       title2: S.of(context).track,
            //       icon: FontAwesomeIcons.mapMarkerAlt,
            //       activeIconColor: AppColors.secondColor,
            //       onPressedFriend: () async {
            //         await _navigateToRoom(context, user.iduser);
            //       },
            //       onPressedNotFriend: () async {
            //         await _navigateToRoom(context, user.iduser,
            //             showSnackbar: true);
            //       },
            //     );
            //   },
            // ),

            /////////////////
            // relationBtn(),
            friendBtn(context),
          ],
        ),
      ),
    );
  }

  Builder friendBtn(BuildContext _) {
    return Builder(
      builder: (context) {
        return CustomIconTextButton(
          title: '${S.of(context).friends} +',
          title2: '${S.of(context).friends} -',
          icon: FontAwesomeIcons.solidCircleUser,
          activeIconColor: AppColors.successColor,
          enableFriendSnackbars: true,
          friendStatus: friendStatus,
          onPressedNotFriend: () async {
            final messenger = ScaffoldMessenger.of(context)
              ..hideCurrentSnackBar();
            final status =
                await context.read<FreindProgressCubit>().addFriendStatus(
                      user.iduser,
                    );
            switch (status) {
              case 'done':
                messenger.showSnackBar(const SnackBar(
                  content: Text('تم ارسال طلب صداقة بنجاح'),
                  behavior: SnackBarBehavior.floating,
                ));
                break;
              case 'waiting_accepting':
                messenger.showSnackBar(const SnackBar(
                  content: Text('تم الارسال'),
                  behavior: SnackBarBehavior.floating,
                ));
                break;
              case 'already_friend':
                messenger.showSnackBar(const SnackBar(
                  content: Text('أنتما صديقان بالفعل'),
                  behavior: SnackBarBehavior.floating,
                ));
                break;
              default:
                final msg = status.startsWith('error:')
                    ? status.substring(6)
                    : status;
                messenger.showSnackBar(SnackBar(
                  content: Text(msg),
                  behavior: SnackBarBehavior.floating,
                ));
            }
          },
          onPressedFriend: () async {
            // Avoid refetching profile here to prevent rebuilding/disposing the widget tree.
            // Capture cubit before awaiting to avoid using context after possible rebuilds.
            final progressCubit = context.read<FreindProgressCubit>();
            final friendShipId = user.stringid;
            if (friendShipId == null || friendShipId.isEmpty) {
              return;
            }
            await progressCubit.deleteFriendOrFriendRequest(friendShipId);
          },
        );
      },
    );
  }

  Builder relationBtn() {
    return Builder(builder: (context) {
      return CustomIconTextButtonRelation(
        title: '${S.of(context).realtion} +',
        title2: '${S.of(context).realtion} -',
        icon: FontAwesomeIcons.heartCircleBolt,
        activeIconColor: AppColors.danger,
        onPressedNotFriend: () async {
          // await userCubit.sendRelationRequest(user.iduser!);
          await BlocProvider.of<RelationProgressCubit>(context)
              .sendRelationRequest(user.iduser);
        },
        onPressedFriend: () async {
          // await userCubit.deleteRelationRequest(user.iduser!);
          await BlocProvider.of<RelationProgressCubit>(context)
              .deleteRelationRequest(user.iduser);

          // id relation
        },
      );
    });
  }

  CustomIconTextButton chatBtn(BuildContext context) {
    return CustomIconTextButton(
      title: S.of(context).chat,
      title2: S.of(context).chat,
      icon: FontAwesomeIcons.facebookMessenger,
      activeIconColor: AppColors.primary,
      friendStatus: '',
      onPressedFriend: () async {
        Navigator.push(
            context,
            MaterialPageRoute(
              builder: (context) => ChatPrivatePageBloc(
                roomCubit: roomCubit,
                userCubit: userCubit,
                userId: user.iduser,
                userImg: user.img,
                userName: user.name!,
                userImgcurrent:
                    userCubit.user?.img ?? AssetsData.userTestNetwork,
              ),
            ));
        return Future.value();
      },
      onPressedNotFriend: () async {
        Navigator.push(
            context,
            MaterialPageRoute(
              builder: (context) => ChatPrivatePageBloc(
                roomCubit: roomCubit,
                userCubit: userCubit,
                userId: user.iduser,
                userImg: user.img,
                userName: user.name!,
                userImgcurrent:
                    userCubit.user?.img ?? AssetsData.userTestNetwork,
              ),
            ));
        return Future.value();
      },
    );
  }
}
