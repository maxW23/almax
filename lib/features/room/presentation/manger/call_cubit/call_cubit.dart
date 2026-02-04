// import 'package:flutter_bloc/flutter_bloc.dart';
// import 'dart:async';
// import 'package:lklk/core/utils/logger.dart';

// import 'package:flutter/material.dart';
// import 'package:lklk/core/services/auth_service.dart';
// import 'package:lklk/features/home/presentation/manger/room_cubit/room_cubit_cubit.dart';
// import 'package:lklk/features/home/presentation/views/home_view.dart';
// import 'package:lklk/features/profile_users/presentaion/manger/user_cubit/user_cubit_cubit.dart';
// import 'package:lklk/live_audio_room_manager.dart';
// import 'package:lklk/main.dart';
// import 'dart:convert';
// import 'package:flutter/foundation.dart';
// import 'package:permission_handler/permission_handler.dart';

// class CallState {
//   final bool isInCall;
//   final bool isMuted;
//   final bool isMinimized;
//   final String? roomImg;
//   CallState(
//       {required this.isInCall,
//       required this.isMuted,
//       required this.isMinimized,
//       this.roomImg});
// }

// class CallCubit extends Cubit<CallState> {
//   List<StreamSubscription> subscriptions = [];
//   String? currentRequestID;
//   ValueNotifier<bool> isApplyStateNoti = ValueNotifier(false);
//   final zimService = ZEGOSDKManager().zimService;
//   final expressService = ZEGOSDKManager().expressService;
//   String? img;

//   CallCubit()
//       : super(CallState(
//             isInCall: false,
//             isMuted: false,
//             isMinimized: false,
//             roomImg: null));

//   // void startCall(
//   //     UserCubit userCubit, RoomCubit roomCubit, String? roomImg) async {
//   //       //log('Call start call --------------');
//   //   requestMicrophonePermission(userCubit, roomCubit);
//   //   _initializeSubscriptions(userCubit, roomCubit);
//   //   img = roomImg;
//   //   emit(CallState(
//   //       isInCall: true, isMuted: false, isMinimized: false, roomImg: roomImg));
//   // }
//   void startCall(
//       UserCubit userCubit, RoomCubit roomCubit, String? roomImg) async {
//     //log('Call start call --------------');

//     // Ensure room scenario is set before login
//     await expressService.setRoomScenario(ZegoScenario.General);

//     // Check if already in a room and log out if necessary
//     if (state.isInCall) {
//       logoutRoom();
//     }

//     requestMicrophonePermission(userCubit, roomCubit);
//     _initializeSubscriptions(userCubit, roomCubit);
//     img = roomImg;
//     emit(CallState(
//         isInCall: true, isMuted: false, isMinimized: false, roomImg: roomImg));
//   }

//   void endCall() {
//     //log('Call end call --------------');

//     // cancelSubscriptions();
//     // logoutRoom();
//     emit(CallState(
//         isInCall: false, isMuted: false, isMinimized: false, roomImg: null));
//     Future.delayed(const Duration(milliseconds: 500), () {
//       cancelSubscriptions();

//       logoutRoom();
//     });
//   }

//   void endCallFull() {
//     //log('Call end call --------------');

//     cancelSubscriptions();
//     logoutRoom();
//     emit(CallState(
//         isInCall: false, isMuted: false, isMinimized: false, roomImg: null));
//   }

//   void toggleMute() {
//     //log('Call toggleMute call --------------');

//     muteAllSpeaker(state.isMuted);
//     emit(CallState(
//         isInCall: state.isInCall,
//         isMuted: !state.isMuted,
//         isMinimized: state.isMinimized,
//         roomImg: img));
//   }

//   void toggleMinimize() {
//     //log('Call toggleMinimize call --------------');

//     emit(CallState(
//         isInCall: state.isInCall,
//         isMuted: state.isMuted,
//         isMinimized: !state.isMinimized,
//         roomImg: img));
//   }

//   void toggleMinimizeTrue() {
//     //log('Call toggleMinimizeTrue call --------------');

//     emit(CallState(
//         isInCall: state.isInCall,
//         isMuted: state.isMuted,
//         isMinimized: true,
//         roomImg: img));
//   }

// ////////////////////////////////////////////////////////////////////////////////////////
// ////////////////////////////////////////////////////////////////////////////////////////
// ////////////////////////////////////////////////////////////////////////////////////////
// ////////////////////////////////////////////////////////////////////////////////////////
//   Future<List<ZIMMessageSentResult>> muteAllSpeaker(bool isMute) async {
//     final messageType =
//         isMute ? RoomCommandType.muteSpeaker : RoomCommandType.unMuteSpeaker;

//     List<ZIMMessageSentResult> results = [];

//     for (final element in ZegoLiveAudioRoomManager().seatList) {
//       final commandMap = {
//         'room_command_type': messageType,
//         'receiver_id': element.currentUser.value?.iduser
//       };

//       // Send the room command for each user
//       final result = await ZEGOSDKManager()
//           .zimService
//           .sendRoomCommand(jsonEncode(commandMap));

//       // Store the result in the list
//       results.add(result);
//     }

//     // Return the list of results for all commands sent
//     return results;
//   }

//   Future<void> requestMicrophonePermission(
//       UserCubit userCubit, RoomCubit roomCubit) async {
//     final status = await Permission.microphone.request();
//     if (status != PermissionStatus.granted) {
//       //log('Microphone permission is required');
//       Navigator.pushReplacement(
//         navigatorKey.currentContext!,
//         MaterialPageRoute(
//           builder: (context) => HomeView(
//             userCubit: userCubit,
//             roomCubit: roomCubit,
//           ),
//         ),
//       );
//     }
//   }

//   void _initializeSubscriptions(UserCubit userCubit, RoomCubit roomCubit) {
//     subscriptions.addAll([
//       expressService.roomStateChangedStreamCtrl.stream.listen(
//           (event) => onExpressRoomStateChanged(event, userCubit, roomCubit)),
//       zimService.roomStateChangedStreamCtrl.stream.listen(
//           (event) => onZIMRoomStateChanged(event, userCubit, roomCubit)),
//       zimService.connectionStateStreamCtrl.stream.listen(
//           (event) => onZIMConnectionStateChanged(event, userCubit, roomCubit)),
//       zimService.onInComingRoomRequestStreamCtrl.stream
//           .listen(onInComingRoomRequest),
//       zimService.onOutgoingRoomRequestAcceptedStreamCtrl.stream
//           .listen(onOutgoingRoomRequestAccepted),
//       zimService.onOutgoingRoomRequestRejectedStreamCtrl.stream
//           .listen(onOutgoingRoomRequestRejected),
//       zimService.onRoomCommandReceivedEventStreamCtrl.stream.listen(
//           (event) => onRoomCommandReceived(event, userCubit, roomCubit)),
//     ]);
//   }

//   void cancelSubscriptions() {
//     //log('Call cancelSubscriptions call --------------');

//     for (final subscription in subscriptions) {
//       subscription.cancel();
//     }
//   }

//   Future<void> loginRoom(UserCubit userCubit, RoomCubit roomCubit,
//       String roomID, ZegoLiveAudioRoomRole role) async {
//     // Ensure we are not logged into another room
//     if (state.isInCall) {
//       //log('Already in a room, logging out first...');
//       logoutRoom();
//     }

//     final token =
//         kIsWeb ? await AuthService.getTokenFromSharedPreferences() : null;
//     ZegoLiveAudioRoomManager()
//         .loginRoom(roomID, role, token: token)
//         .then((result) {
//       if (result.errorCode == 0) {
//         hostTakeSeat(role);
//       } else {
//         WidgetsBinding.instance.addPostFrameCallback((_) {
//           Future.delayed(const Duration(seconds: 2), () {
//             Navigator.pushAndRemoveUntil(
//               navigatorKey.currentContext!,
//               MaterialPageRoute(
//                 builder: (context) => HomeView(
//                   userCubit: userCubit,
//                   roomCubit: roomCubit,
//                 ),
//               ),
//               (Route<dynamic> route) => false,
//             );
//           });
//         });
//         //log('Login room failed: ${result.errorCode}');
//       }
//     });
//   }

//   Future<void> hostTakeSeat(ZegoLiveAudioRoomRole role) async {
//     if (role == ZegoLiveAudioRoomRole.host) {
//       // await ZegoLiveAudioRoomManager().setSelfHost();
//       //   await ZegoLiveAudioRoomManager()
//       //       .takeSeat(0, isForce: false)
//       //       .then((result) {
//       //     if (((result == null) ||
//       //         result.errorKeys.contains(ZEGOSDKManager().currentUser!.iduser))) {
//       //       //log('Take seat failed: $result');
//       //     }
//       //   }).catchError((error) {
//       //     //log('Take seat failed: $error');
//       //   });
//       // }
//     }
//   }
//   // void loginRoom(UserCubit userCubit, RoomCubit roomCubit, String roomID,
//   //     ZegoLiveAudioRoomRole role) async {
//   //   final token =
//   //       kIsWeb ? await AuthService.getTokenFromSharedPreferences() : null;
//   //   ZegoLiveAudioRoomManager()
//   //       .loginRoom(roomID, role, token: token)
//   //       .then((result) {
//   //     if (result.errorCode == 0) {
//   //       // hostTakeSeat();
//   //     } else {
//   //       Navigator.pushReplacement(
//   //         navigatorKey.currentContext!,
//   //         MaterialPageRoute(
//   //           builder: (context) => HomeView(
//   //             userCubit: userCubit,
//   //             roomCubit: roomCubit,
//   //           ),
//   //         ),
//   //       );
//   //       //log('Login room failed: ${result.errorCode}');
//   //     }
//   //   });
//   // }

//   void onRoomCommandReceived(OnRoomCommandReceivedEvent event,
//       UserCubit userCubit, RoomCubit roomCubit) {
//     // //log('onRoomCommandReceived $event');
//     // final Map<String, dynamic> messageMap = jsonDecode(event.command);
//     // if (messageMap.keys.contains('room_command_type')) {
//     //   final type = messageMap['room_command_type'];
//     //   final receiverID = messageMap['receiver_id'];
//     //   if (receiverID == ZEGOSDKManager().currentUser!.iduser) {
//     //     if (type == RoomCommandType.muteSpeaker) {
//     //       //log('You have been muted by the host');
//     //       ZEGOSDKManager().expressService.turnMicrophoneOn(false);
//     //     } else if (type == RoomCommandType.unMuteSpeaker) {
//     //       //log('You have been unmuted by the host');
//     //       ZEGOSDKManager().expressService.turnMicrophoneOn(true);
//     //     } else if (type == RoomCommandType.kickOutRoom) {
//     //       //log('You have been kicked out of the room');

//     //       logoutRoom();
//     //       WidgetsBinding.instance.addPostFrameCallback((_) {
//     //         Future.delayed(const Duration(seconds: 2), () {
//     //           Navigator.pushAndRemoveUntil(
//     //             navigatorKey.currentContext!,
//     //             MaterialPageRoute(
//     //               builder: (context) => HomeView(
//     //                 userCubit: userCubit,
//     //                 roomCubit: roomCubit,
//     //               ),
//     //             ),
//     //             (Route<dynamic> route) => false,
//     //           );
//     //         });
//     //       });
//     //     }
//     //   }
//     // }
//   }

//   void logoutRoom() {
//     //log('Call logoutRoom call --------------');

//     ZEGOSDKManager().logoutRoom();
//   }

//   void onInComingRoomRequestCancelled(
//       OnInComingRoomRequestCancelledEvent event) {}

//   void onInComingRoomRequestTimeOut() {}

//   void onExpressRoomStateChanged(
//       ZegoRoomStateEvent event, UserCubit userCubit, RoomCubit roomCubit) {
//     //log('AudioRoomPage:onExpressRoomStateChanged: $event');
//     if (event.errorCode != 0) {
//       //log('onExpressRoomStateChanged: reason:${event.reason.name}, errorCode:${event.errorCode}');
//     }

//     // if (
//     //   (event.reason == ZegoRoomStateChangedReason.KickOut) ||
//     //     (event.reason == ZegoRoomStateChangedReason.ReconnectFailed) ||
//     //     (event.reason == ZegoRoomStateChangedReason.LoginFailed)) {
//     //  WidgetsBinding.instance.addPostFrameCallback((_) {
//     //       Future.delayed(Duration.zero, () {
//     //         Navigator.pushAndRemoveUntil(
//     //           navigatorKey.currentContext!,
//     //           MaterialPageRoute(
//     //             builder: (context) => HomeView(
//     //               userCubit: userCubit,
//     //               roomCubit: roomCubit,
//     //             ),
//     //           ),
//     //           (Route<dynamic> route) => false,
//     //         );
//     //       });
//     //     });
//     // }
//   }

//   void onZIMRoomStateChanged(ZIMServiceRoomStateChangedEvent event,
//       UserCubit userCubit, RoomCubit roomCubit) {
//     //log('AudioRoomPage:onZIMRoomStateChanged: $event');
//     if ((event.event != ZIMRoomEvent.success) &&
//         (event.state != ZIMRoomState.connected)) {
//       //log('onZIMRoomStateChanged: $event');
//     }
//     if (event.state == ZIMRoomState.disconnected) {
//       WidgetsBinding.instance.addPostFrameCallback((_) {
//         Future.delayed(const Duration(seconds: 2), () {
//           Navigator.pushAndRemoveUntil(
//             navigatorKey.currentContext!,
//             MaterialPageRoute(
//               builder: (context) => HomeView(
//                 userCubit: userCubit,
//                 roomCubit: roomCubit,
//               ),
//             ),
//             (Route<dynamic> route) => false,
//           );
//         });
//       });
//     }
//   }

//   void onZIMConnectionStateChanged(ZIMServiceConnectionStateChangedEvent event,
//       UserCubit userCubit, RoomCubit roomCubit) {
//     //log('AudioRoomPage:onZIMConnectionStateChanged: $event');
//     if (event.state == ZIMConnectionState.disconnected) {
//       WidgetsBinding.instance.addPostFrameCallback((_) {
//         Future.delayed(const Duration(seconds: 2), () {
//           Navigator.pushAndRemoveUntil(
//             navigatorKey.currentContext!,
//             MaterialPageRoute(
//               builder: (context) => HomeView(
//                 userCubit: userCubit,
//                 roomCubit: roomCubit,
//               ),
//             ),
//             (Route<dynamic> route) => false,
//           );
//         });
//       });
//     }
//   }

//   void onInComingRoomRequest(OnInComingRoomRequestReceivedEvent event) {}

//   void onOutgoingRoomRequestRejected(OnOutgoingRoomRequestRejectedEvent event) {
//     isApplyStateNoti.value = false;
//     currentRequestID = null;
//   }

//   void onOutgoingRoomRequestAccepted(OnOutgoingRoomRequestAcceptedEvent event) {
//     isApplyStateNoti.value = false;
//     for (final seat in ZegoLiveAudioRoomManager().seatList) {
//       if (seat.currentUser.value == null) {
//         ZegoLiveAudioRoomManager()
//             .takeSeat(
//           seat.seatIndex,
//         )
//             .then((result) {
//           if (navigatorKey.currentContext!.mounted &&
//               ((result == null) ||
//                   result.errorKeys
//                       .contains(ZEGOSDKManager().currentUser!.iduser))) {
//             //log('take seat failed: $result');
//           }
//         }).catchError((error) {
//           //log('take seat failed: $error');
//         });

//         break;
//       }
//     }
//   }
// }
