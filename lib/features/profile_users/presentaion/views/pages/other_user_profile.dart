// ignore_for_file: public_member_api_docs, sort_constructors_first

import 'package:flutter/material.dart';
import 'package:lklk/features/home/presentation/manger/room_cubit/room_cubit_cubit.dart';
import 'package:lklk/features/profile_users/domain/entities/elements_entity.dart';
import 'package:lklk/features/profile_users/presentaion/manger/post_charger/post_charger_cubit.dart';
import 'package:lklk/features/profile_users/presentaion/manger/relation_cubit/relation_cubit.dart';
import 'package:lklk/features/profile_users/presentaion/views/pages/other_user_profile_body.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import 'package:lklk/features/auth/domain/entities/user_entity.dart';
import 'package:lklk/features/profile_users/presentaion/manger/user_cubit/user_cubit_cubit.dart';

class OtherUserProfile extends StatefulWidget {
  const OtherUserProfile({
    super.key,
    required this.user,
    required this.userCubit,
    this.friendNumber,
    this.visitorNumber,
    this.friendStatus,
    this.giftList,
    this.frameList,
    this.entryList,
    required this.roomCubit,
  });

  final UserEntity user;
  final UserCubit userCubit;
  final RoomCubit roomCubit;

  final int? friendNumber;
  final int? visitorNumber;
  final String? friendStatus;
  final List<ElementEntity>? giftList;
  final List<ElementEntity>? frameList;
  final List<ElementEntity>? entryList;
  @override
  State<OtherUserProfile> createState() => _OtherUserProfileState();
}

class _OtherUserProfileState extends State<OtherUserProfile> {
  @override
  Widget build(BuildContext context) {
    //log('useruseruser ${widget.user} :: ${widget.use-r.img} :: ${widget.user.name!}');
    // ModalRoute.of(context)!.addScopedWillPopCallback(() async {
    //   // widget.userCubit.getUserProfileById(widget.user.iduser!!); /// 1234 1234
    //   return true;
    // });
    return BlocProvider<RelationCubit>(
      create: (context) => RelationCubit(),
      child: BlocProvider(
        create: (context) => PostChargerCubit(),
        lazy: true,
        child: SafeArea(
          top: false,
          child: Scaffold(
            body: OtherUserProfileBody(widget: widget),
          
          ),
        ),
      ),
    );
  }
}
