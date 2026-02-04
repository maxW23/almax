// import 'package:lklk/core/utils/logger.dart';

// import 'package:flutter/material.dart';
// import 'package:font_awesome_flutter/font_awesome_flutter.dart';
// import 'package:lklk/core/utils/gifts_bottom_sheet.dart';
// import 'package:lklk/features/auth/domain/entities/user_entity.dart';
// import 'package:lklk/features/home/presentation/manger/room_messages_cubit/room_messages_cubit.dart';
// import 'package:lklk/features/profile_users/presentaion/manger/user_cubit/user_cubit_cubit.dart';
// import 'package:lklk/live_audio_room_manager.dart';

// class CustomPopupMenuButton extends StatelessWidget {
//   const CustomPopupMenuButton(
//       {super.key,
//       this.child,
//       required this.seatIndex,
//       required this.user,
//       required this.roomId,
//       required this.roomMessagesCubit,
//       required this.userCubit,
//       required this.role});
//   final Widget? child;
//   final UserEntity user;
//   final int seatIndex;
//   final String roomId;
//   final RoomMessagesCubit roomMessagesCubit;
//   final UserCubit userCubit;
//   final ZegoLiveAudioRoomRole role;

//   void showCustomMenu(
//     BuildContext context,
//     Offset offset,
//     UserEntity targetUser,
//     ZegoLiveAudioRoomRole role,
//   ) {
//     log('role == ZegoLiveAudioRoomRole.host ::${role == ZegoLiveAudioRoomRole.host}');

//     log("""role == ZegoLiveAudioRoomRole.host &&
//         (ZegoLiveAudioRoomManager()
//                 .seatList[seatIndex]
//                 .currentUser
//                 .value
//                 ?.userID !=
//             ZEGOSDKManager().currentUser!.userID ::${role == ZegoLiveAudioRoomRole.host && (ZegoLiveAudioRoomManager().seatList[seatIndex].currentUser.value?.iduser != ZEGOSDKManager().currentUser!.iduser)}""");

//     final RenderBox overlay =
//         Overlay.of(context).context.findRenderObject() as RenderBox;

//     showMenu(
//       context: context,
//       position: RelativeRect.fromRect(
//         Rect.fromPoints(
//           overlay.localToGlobal(offset, ancestor: null),
//           overlay.localToGlobal(offset, ancestor: null),
//         ),
//         Offset.zero & overlay.size,
//       ),
//       items: getPopupMenuItems(role),
//     ).then((value) {
//       if (value == "leave microphone") {
//         leaveMicrophoneMethod();
//       } else if (value == "remove speaker") {
//         removeSpeakerFromSeatMethod(targetUser);
//       } else if (value == "mute") {
//         if (targetUser.iduser! != userCubit.user?.iduser) {
//           ZegoLiveAudioRoomManager().muteSpeaker(
//               targetUser.iduser!, targetUser.isMicOnNotifier.value);
//         } else {
//           log('mute mute mute ${userCubit.user!.isMicOnNotifier.value}');
//           if (userCubit.user!.isMicOnNotifier.value == true) {
//             muteMicrophoneForYourself(false);
//             userCubit.user!.isMicOnNotifier.value = false;
//             log('mute mute mute a ${userCubit.user!.isMicOnNotifier.value}');
//           } else if (userCubit.user!.isMicOnNotifier.value == false) {
//             muteMicrophoneForYourself(true);
//             userCubit.user!.isMicOnNotifier.value = true;
//             log('mute mute mute b ${userCubit.user!.isMicOnNotifier.value}');
//           }
//         }
//       } else if (value == 'kick Out Room') {
//         kickOutRoomMethod(targetUser);
//       } else if (value == 'lock') {
//         // ZegoLiveAudioRoomManager().lockSeat();
//       } //

//       else if (value == 'switch seat') {
//         log('switchSeat ${getLocalUserSeatIndex()} --- $seatIndex ');

//         if (role == ZegoLiveAudioRoomRole.host) {
//           ZegoLiveAudioRoomManager()
//               .switchSeat(getLocalUserSeatIndex(), seatIndex);
//         }
//       } //
//       else if (value == "send Gift") {
//         GiftsBottomSheetWidget.showBasicModalBottomSheet(
//             // ignore: use_build_context_synchronously
//             context,
//             user,
//             roomId,
//             [targetUser],
//             roomMessagesCubit,
//             userCubit);
//       }
//     });
//   }

//   List<PopupMenuEntry> getPopupMenuItems(ZegoLiveAudioRoomRole role) {
//     if (role == ZegoLiveAudioRoomRole.host &&
//         (ZegoLiveAudioRoomManager()
//                 .seatList[seatIndex]
//                 .currentUser
//                 .value
//                 ?.iduser ==
//             ZEGOSDKManager().currentUser!.iduser)) {
//       return <PopupMenuEntry>[
//         customPopupMenuItem(
//             'leave microphone', FontAwesomeIcons.microphoneLinesSlash),

//         customPopupMenuItem(
//             'mute',
//             userCubit.user!.isMicOnNotifier.value == true
//                 ? FontAwesomeIcons.volumeXmark
//                 : FontAwesomeIcons.volumeHigh),
//         customPopupMenuItem('send Gift', FontAwesomeIcons.gift), // delete,
//       ];
//     } else if (role == ZegoLiveAudioRoomRole.host &&
//         (ZegoLiveAudioRoomManager()
//                 .seatList[seatIndex]
//                 .currentUser
//                 .value
//                 ?.iduser !=
//             ZEGOSDKManager().currentUser!.iduser)) {
//       return <PopupMenuEntry>[
//         customPopupMenuItem('switch seat', FontAwesomeIcons.chair),
//         customPopupMenuItem('mute', FontAwesomeIcons.volumeXmark),
//         customPopupMenuItem(
//             'remove speaker', FontAwesomeIcons.arrowRightFromBracket),
//         customPopupMenuItem('kick Out Room', FontAwesomeIcons.ban),
//         customPopupMenuItem('lock', FontAwesomeIcons.lock),
//         customPopupMenuItem('send Gift', FontAwesomeIcons.gift),
//         customPopupMenuItem('profile', FontAwesomeIcons.user),
//       ];
//     } else {
//       return <PopupMenuEntry>[
//         customPopupMenuItem(
//             'leave microphone', FontAwesomeIcons.microphoneLinesSlash),
//         customPopupMenuItem('mute', FontAwesomeIcons.volumeXmark),

//         customPopupMenuItem('send Gift', FontAwesomeIcons.gift),
//         customPopupMenuItem('profile', FontAwesomeIcons.user),
//       ];
//     }
//   }

//   Future<void> muteMicrophoneForYourself(bool mute) async {
//     return ZegoExpressEngine.instance.muteMicrophone(mute);
//   }

//   PopupMenuItem<dynamic> customPopupMenuItem(String name, IconData icon) {
//     return PopupMenuItem<dynamic>(
//       value: name,
//       child: Row(
//         children: [
//           Padding(
//               padding: const EdgeInsets.only(right: 8.0), child: Icon(icon)),
//           AutoSizeText(
//             name,
//             style: const TextStyle(fontSize: 15),
//           ),
//         ],
//       ),
//     );
//   }

//   void leaveMicrophoneMethod() {
//     ValueNotifier<bool> isApplyStateNoti = ValueNotifier(false);

//     for (final element in ZegoLiveAudioRoomManager().seatList) {
//       if (element.currentUser.value?.iduser ==
//           ZEGOSDKManager().currentUser!.iduser) {
//         ZegoLiveAudioRoomManager().leaveSeat(element.seatIndex).then((value) {
//           ZegoLiveAudioRoomManager().roleNoti.value =
//               ZegoLiveAudioRoomRole.audience;
//           isApplyStateNoti.value = false;
//         });
//       }
//     }
//   }

//   int getLocalUserSeatIndex() {
//     for (final element in ZegoLiveAudioRoomManager().seatList) {
//       if (element.currentUser.value?.iduser ==
//           ZEGOSDKManager().currentUser!.iduser) {
//         return element.seatIndex;
//       }
//     }
//     return -1;
//   }

//   void lockSeatMethod(int seatIndex) {
//     // ValueNotifier<bool> isApplyStateNoti = ValueNotifier(false);

//     for (final element in ZegoLiveAudioRoomManager().seatList) {
//       if (element.currentUser.value?.iduser ==
//           ZEGOSDKManager().currentUser!.iduser) {
//         ZegoLiveAudioRoomManager().lockSpecificSeat(seatIndex,roomId);
//       }
//     }
//   }

//   Future<ZIMRoomAttributesOperatedCallResult?> removeSpeakerFromSeatMethod(
//           UserEntity targetUser) =>
//       ZegoLiveAudioRoomManager().removeSpeakerFromSeat(targetUser.iduser!);

//   Future<ZIMMessageSentResult> kickOutRoomMethod(UserEntity targetUser) =>
//       ZegoLiveAudioRoomManager().kickOutRoom(targetUser.iduser!);
// ///////////////////////////////////////////////////////////////////////////////////////////
//   @override
//   Widget build(BuildContext context) {
//     return Container();
//   }
// }
// ///////////////////////////////////////////////////////////////////////////////////////////
// ///////////////////////////////////////////////////////////////////////////////////////////
// ///////////////////////////////////////////////////////////////////////////////////////////
// ///////////////////////////////////////////////////////////////////////////////////////////
// ///////////////////////////////////////////////////////////////////////////////////////////
// ///////////////////////////////////////////////////////////////////////////////////////////
// ///////////////////////////////////////////////////////////////////////////////////////////
// ///////////////////////////////////////////////////////////////////////////////////////////
// ///////////////////////////////////////////////////////////////////////////////////////////
// ///////////////////////////////////////////////////////////////////////////////////////////
// ///////////////////////////////////////////////////////////////////////////////////////////
// ///////////////////////////////////////////////////////////////////////////////////////////
// ///////////////////////////////////////////////////////////////////////////////////////////
// ///////////////////////////////////////////////////////////////////////////////////////////
// ///////////////////////////////////////////////////////////////////////////////////////////
// ///////////////////////////////////////////////////////////////////////////////////////////
// ///////////////////////////////////////////////////////////////////////////////////////////
// ///////////////////////////////////////////////////////////////////////////////////////////
// ///////////////////////////////////////////////////////////////////////////////////////////
// ///////////////////////////////////////////////////////////////////////////////////////////
// ///////////////////////////////////////////////////////////////////////////////////////////
// ///////////////////////////////////////////////////////////////////////////////////////////
// ///////////////////////////////////////////////////////////////////////////////////////////
// ///////////////////////////////////////////////////////////////////////////////////////////
// ///////////////////////////////////////////////////////////////////////////////////////////
// ///////////////////////////////////////////////////////////////////////////////////////////

// // GestureDetector(
// //     onTapDown: (TapDownDetails details) {
// //       showCustomMenu(context, details.globalPosition, targetUser);
// //     },
// //     child: child,
// //   );
// /////////////////
// ///
// ///
// // class CustomPopupMenuButton extends StatelessWidget {
// //   const CustomPopupMenuButton(
// //       {super.key, this.child, required this.role, required this.seatIndex});
// //   final Widget? child;
// //   final ZegoLiveAudioRoomRole role;
// //   final int seatIndex;
// //   void showCustomMenu(
// //       BuildContext context, Offset offset, ZegoSDKUser targetUser) {
// //     final RenderBox overlay =
// //         Overlay.of(context).context.findRenderObject() as RenderBox;

// //     showMenu(
// //       context: context,
// //       position: RelativeRect.fromRect(
// //         Rect.fromPoints(
// //           overlay.localToGlobal(offset, ancestor: null),
// //           overlay.localToGlobal(offset, ancestor: null),
// //         ),
// //         Offset.zero & overlay.size,
// //       ),
// //      items: getPopupMenuItems(),
// //     ).then((value) {
// //       if (value == "leave microphone") {
// //         leaveMicrophoneMethod();
// //       } else if (value == "remove speaker") {
// //         removeSpeakerFromSeatMethod(targetUser);
// //       } else if (value == "mute") {
// //         ZegoLiveAudioRoomManager()
// //             .muteSpeaker(targetUser.userID, targetUser.isMicOnNotifier.value);
// //       } else if (value == 'kick Out Room') {
// //         kickOutRoomMethod(targetUser);
// //       } else if (value == 'lock') {
// //         ZegoLiveAudioRoomManager().lockSeat();
// //       }
// //       //  else if (value == 'lock') {
// //       //  ZegoLiveAudioRoomManager().switchSeat();
// //       // }
// //       //  else if (value == 'lock') {
// //       //  ZegoLiveAudioRoomManager().();
// //       // }
// //     });
// //     List<PopupMenuEntry> getPopupMenuItems() {
// //     if (role == ZegoLiveAudioRoomRole.host &&
// //         ZegoLiveAudioRoomManager()
// //                 .seatList[seatIndex]
// //                 .currentUser
// //                 .value
// //                 ?.userID ==
// //             ZEGOSDKManager().currentUser!.userID) {
// //       return <PopupMenuEntry>[
// //         customPopupMenuItem(
// //             'leave microphone', FontAwesomeIcons.microphoneLinesSlash),
// //         customPopupMenuItem('mute', FontAwesomeIcons.volumeXmark),
// //         customPopupMenuItem(
// //             'remove speaker', FontAwesomeIcons.arrowRightFromBracket),
// //         customPopupMenuItem('kick Out Room', FontAwesomeIcons.ban),
// //         customPopupMenuItem('lock', FontAwesomeIcons.lock),
// //         customPopupMenuItem('send Gift', FontAwesomeIcons.gift),
// //         customPopupMenuItem('profile', FontAwesomeIcons.user),
// //       ];
// //     } else {
// //       return <PopupMenuEntry>[
// //         customPopupMenuItem(
// //             'leave microphone', FontAwesomeIcons.microphoneLinesSlash),
// //         customPopupMenuItem('mute', FontAwesomeIcons.volumeXmark),
// //         customPopupMenuItem('send Gift', FontAwesomeIcons.gift),
// //         customPopupMenuItem('profile', FontAwesomeIcons.user),
// //       ];
// //     }
// //   }
// //   }
