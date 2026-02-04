// import 'package:flutter/material.dart';
// import 'package:lklk/features/auth/domain/entities/user_entity.dart';
// import 'package:lklk/features/home/presentation/manger/room_cubit/room_cubit_cubit.dart';
// import 'package:lklk/features/profile_users/presentaion/manger/user_cubit/user_cubit_cubit.dart';
// import 'package:lklk/features/room/domain/entities/room_entity.dart';
// import 'package:lklk/features/room/presentation/views/widgets/room_view_body.dart';
// import 'package:lklk/internal/business/business_define.dart';

// class RoomViewBodyBlocWidget extends StatelessWidget {
//   const RoomViewBodyBlocWidget({
//     super.key,
//     required this.fromOverlay,
//     required this.userCubit,
//     required this.room,
//     required this.roomCubit,
//     required this.users,
//     required this.bannedUser,
//     required this.topUsers,
//     required this.role,
//   });

//   final bool? fromOverlay;
//   final UserCubit userCubit;
//   final RoomEntity room;
//   final RoomCubit roomCubit;
//   final List<UserEntity>? users;
//   final List<UserEntity>? bannedUser;
//   final List<UserEntity>? topUsers;
//   final ZegoLiveAudioRoomRole role;

//   @override
//   Widget build(BuildContext context) {
//     return RoomViewBody(
//         fromOverlay: fromOverlay,
//         userCubit: userCubit,
//         room: room,
//         roomCubit: roomCubit,
//         users: users,
//         bannedUsers: bannedUser,
//         role: role);
//   }
// }
