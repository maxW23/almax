import 'dart:async';
import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:auto_size_text/auto_size_text.dart';
import 'package:lklk/features/auth/domain/entities/user_entity.dart';

import 'main.dart';
import 'package:lklk/core/utils/logger.dart';
import 'zego_sdk_manager.dart';
import 'package:lklk/internal/sdk/livekit/livekit_audio_service.dart';

export 'zego_sdk_manager.dart';

class ZegoLiveAudioRoomManager {
  factory ZegoLiveAudioRoomManager() => instance;
  ZegoLiveAudioRoomManager._internal();
  static final ZegoLiveAudioRoomManager instance =
      ZegoLiveAudioRoomManager._internal();

  static const String roomKey = 'audioRoom';

  Map<String, dynamic> roomExtraInfoDict = {};
  List<StreamSubscription<dynamic>> subscriptions = [];

  ValueNotifier<bool> isLockSeat = ValueNotifier(false);
  ValueNotifier<UserEntity?> hostUserNoti = ValueNotifier(null);
  ValueNotifier<ZegoLiveAudioRoomRole> roleNoti =
      ValueNotifier(ZegoLiveAudioRoomRole.audience);

  RoomSeatService? roomSeatService;

  int get hostSeatIndex {
    return roomSeatService?.hostSeatIndex ?? 0;
  }

  List<ZegoLiveAudioRoomSeat> get seatList {
    return roomSeatService?.seatList ?? [];
  }

// Use a Map to store locked seats for each room
  ValueNotifier<Map<String, Map<String, bool>>> lockedSeatsPerRoomNotifier =
      ValueNotifier({});

  Future<ZegoRoomSetRoomExtraInfoResult> lockSpecificSeat(
      int seatIndex, String roomId) async {
    log('LockLogs: Initiating seat lock/unlock process for seat $seatIndex in room $roomId');

    Map<String, bool> lockedSeats =
        lockedSeatsPerRoomNotifier.value[roomId] ?? {};
    log('LockLogs: Current locked seats for room $roomId before update: $lockedSeats');

    // Toggle the lock state of the seat
    lockedSeats[seatIndex.toString()] =
        !(lockedSeats[seatIndex.toString()] ?? false);
    log('LockLogs: Seat $seatIndex lock state toggled to ${lockedSeats[seatIndex.toString()]} in room $roomId');

    // Update the lockedSeatsPerRoomNotifier
    lockedSeatsPerRoomNotifier.value = {
      ...lockedSeatsPerRoomNotifier.value,
      roomId: lockedSeats
    };
    log('LockLogs: lockedSeatsPerRoomNotifier updated for room $roomId: ${lockedSeatsPerRoomNotifier.value[roomId]}');

    // Prepare data to send as room extra info
    roomExtraInfoDict['lockedSeats'] = lockedSeats;
    final dataJson = jsonEncode(roomExtraInfoDict);
    log('LockLogs: roomExtraInfoDict prepared with locked seats: $roomExtraInfoDict');

    // Call to set room extra info
    ZegoRoomSetRoomExtraInfoResult result = await ZEGOSDKManager
        .instance.expressService
        .setRoomExtraInfo(roomId, dataJson);
    log('LockLogs: setRoomExtraInfo called with data: $dataJson');

    // Check and log the result
    if (result.errorCode == 0) {
      log('LockLogs: Seat $seatIndex lock state changed successfully in room $roomId.');
    } else {
      log('LockLogs: Error locking seat $seatIndex in room $roomId: ${result.errorCode}');
    }

    return result;
  }

  bool isSeatLocked(int seatIndex, String roomId) {
    log('LockLogs: Checking if seat $seatIndex is locked in room $roomId');

    Map<String, bool> lockedSeats =
        lockedSeatsPerRoomNotifier.value[roomId] ?? {};
    bool isLocked = lockedSeats[seatIndex.toString()] ?? false;
    log('LockLogs: Seat $seatIndex lock state in room $roomId is $isLocked');

    return isLocked;
  }

  void onRoomExtraInfoUpdate(ZegoRoomExtraInfoEvent event, String roomID) {
    log('LockLogs: Received room extra info update for room $roomID');

    for (final extraInfo in event.extraInfoList) {
      if (extraInfo.key == roomID) {
        log('LockLogs: Processing extra info for room $roomID');
        roomExtraInfoDict = jsonDecode(extraInfo.value);
        log('LockLogs: roomExtraInfoDict decoded: $roomExtraInfoDict');

        if (roomExtraInfoDict.containsKey('lockedSeats')) {
          final lockedSeatsMap =
              Map<String, bool>.from(roomExtraInfoDict['lockedSeats']);
          lockedSeatsPerRoomNotifier.value = {
            ...lockedSeatsPerRoomNotifier.value,
            roomID: lockedSeatsMap
          };
          log('LockLogs: Locked seats updated for room $roomID: $lockedSeatsMap');
        }

        if (roomExtraInfoDict.containsKey('host')) {
          final String tempUserID = roomExtraInfoDict['host'];
          hostUserNoti.value = getHostUser(tempUserID);
          log('LockLogs: Host user updated for room $roomID: $tempUserID');
        }
      }
    }
  }

  Future<ZIMRoomAttributesOperatedCallResult?> takeSeat(
      int seatIndex, String roomId,
      {bool? isForce}) async {
    if (isSeatLocked(seatIndex, roomId)) {
      log('Seat $seatIndex is locked. Cannot take the seat.');
      return null;
    }

    final result = await roomSeatService?.takeSeat(seatIndex, isForce: isForce);
    if (result != null) {
      if (!result.errorKeys.contains(seatIndex.toString())) {
        for (final element in seatList) {
          if (element.seatIndex == seatIndex) {
            if (roleNoti.value != ZegoLiveAudioRoomRole.host) {
              roleNoti.value = ZegoLiveAudioRoomRole.speaker;
            }
            break;
          }
        }
      }
    }
    if (result != null &&
        !result.errorKeys.contains(seatIndex.toString())) {
      // Extra safety: ensure we actually occupy this seat before publishing
      final isOnSeat = seatList.any((s) =>
          s.seatIndex == seatIndex &&
          s.currentUser.value?.iduser ==
              ZEGOSDKManager().currentUser!.iduser);
      if (isOnSeat) {
        openMicAndStartPublishStream();
      } else {
        log('⚠️ Skip publishing: not on seat after takeSeat result (seatIndex=$seatIndex)');
      }
    }
    return result;
  }

  Future<ZegoRoomLoginResult> loginRoom(
      String roomID, ZegoLiveAudioRoomRole role,
      {String? token}) async {
    roomSeatService = RoomSeatService();
    roleNoti.value = role;
    final expressService = ZEGOSDKManager().expressService;
    final zimService = ZEGOSDKManager().zimService;
    subscriptions.addAll([
      expressService.roomExtraInfoUpdateCtrl.stream.listen((even) {
        onRoomExtraInfoUpdate(even, roomID);
      }),
      expressService.roomUserListUpdateStreamCtrl.stream
          .listen(onRoomUserListUpdate),
      zimService.onRoomCommandReceivedEventStreamCtrl.stream
          .listen(onRoomCommandReceived)
    ]);
    roomSeatService?.initWithConfig(role);
    return ZEGOSDKManager()
        .loginRoom(roomID, ZegoScenario.StandardChatroom, token: token);
  }

  void unInit() {
    for (final subscription in subscriptions) {
      subscription.cancel();
    }
    subscriptions.clear();
    roomSeatService?.unInit();
  }

  void onRoomUserListUpdate(ZegoRoomUserListUpdateEvent event) {
    if (event.userList.isNotEmpty) {
      log("المستخدمون في الغرفة: ${event.userList.length}");
    }
    if (event.updateType == ZegoUpdateType.Add) {
      final userIDList = <String>[];
      for (final element in event.userList) {
        userIDList.add(element.userID);
      }
      // log("UpdatedUsersInfo $userIDList");
      ZEGOSDKManager().zimService.queryUsersInfo(userIDList);
    } else if (event.updateType == ZegoUpdateType.Delete) {
      final ids = event.userList.map((u) => u.userID);
      for (final id in ids) {
        log("------------------ widget.roomCubit.removeUserById($id); lose ----------");
        // widget.roomCubit.removeUserById(id);
      }
    } else {
      // empty seat
    }
  }

  Future<ZegoRoomSetRoomExtraInfoResult> lockSeat(String roomID) async {
    roomExtraInfoDict['lockseat'] = !isLockSeat.value;
    final dataJson = jsonEncode(roomExtraInfoDict);
    log(' lockSeat roomExtraInfoDict $roomExtraInfoDict');
    ZegoRoomSetRoomExtraInfoResult result = await ZEGOSDKManager
        .instance.expressService
        .setRoomExtraInfo(roomID, dataJson);
    if (result.errorCode == 0) {
      isLockSeat.value = !isLockSeat.value;
    }
    return result;
  }

  void openMicAndStartPublishStream() {
    // Do not publish if user is not host and not on any seat
    final isHost = roleNoti.value == ZegoLiveAudioRoomRole.host;
    final hasSeat = seatList.any((s) =>
        s.currentUser.value?.iduser == ZEGOSDKManager().currentUser!.iduser);
    if (!isHost && !hasSeat) {
      log('🚫 Block publishing: user is not on a seat');
      return;
    }

    // Zego camera is off for audio room; enable LiveKit mic only
    // ZEGOSDKManager().expressService.turnCameraOn(false);
    LiveKitAudioService.instance
        .setMicrophoneEnabled(true, reason: 'openMicAndStartPublishStream');
    // LiveKit handles local audio publishing; no Zego stream publishing
  }

  String generateStreamID() {
    final userID = ZEGOSDKManager().currentUser!.iduser;
    final roomID = ZEGOSDKManager().expressService.currentRoomID;
    final streamID =
        '${roomID}_${userID}_${ZegoLiveAudioRoomManager().roleNoti.value == ZegoLiveAudioRoomRole.host ? 'host' : 'speaker'}';
    log('generateStreamID ::: userID = $userID --- roomID = $roomID -- streamID = $streamID');
    return streamID;
  }

  Future<ZIMRoomAttributesBatchOperatedResult?> switchSeat(
      int fromSeatIndex, int toSeatIndex) async {
    return roomSeatService?.switchSeat(fromSeatIndex, toSeatIndex);
  }

  Future<ZIMRoomAttributesOperatedCallResult?> leaveSeat(int seatIndex) async {
    return roomSeatService?.leaveSeat(seatIndex);
  }

  Future<ZIMRoomAttributesOperatedCallResult?> removeSpeakerFromSeat(
      String userID) async {
    return roomSeatService?.removeSpeakerFromSeat(userID);
  }

  Future<ZIMMessageSentResult> muteSpeaker(String userID, bool isMute) async {
    log('mute mute userID:$userID  isMute:$isMute');

    final messageType =
        isMute ? RoomCommandType.muteSpeaker : RoomCommandType.unMuteSpeaker;
    final commandMap = {
      'room_command_type': messageType,
      'receiver_id': userID
    };
    final result = await ZEGOSDKManager()
        .zimService
        .sendRoomCommand(jsonEncode(commandMap));
    return result;
  }

  Future<ZIMMessageSentResult> kickOutRoom(String userID) async {
    final commandMap = {
      'room_command_type': RoomCommandType.kickOutRoom,
      'receiver_id': userID
    };

    final result = await ZEGOSDKManager()
        .zimService
        .sendRoomCommand(jsonEncode(commandMap));
    return result;
  }

  Future<void> logoutRoom() async {
    // Ensure engine fully leaves the room and stops all streams before clearing
    await ZEGOSDKManager().logoutRoom();
    clear();
  }

  void clear() {
    roomSeatService?.clear();
    roomExtraInfoDict.clear();
    isLockSeat.value = false;
    hostUserNoti.value = null;
    // Reset role to audience to avoid publishing/privileges leaking
    roleNoti.value = ZegoLiveAudioRoomRole.audience;
    // Clear any locked seats cached for previous rooms
    lockedSeatsPerRoomNotifier.value = {};
    for (final subscription in subscriptions) {
      subscription.cancel();
    }
    subscriptions.clear();
  }

  Future<ZegoRoomSetRoomExtraInfoResult?> setSelfHost(String roomID) async {
    if (ZEGOSDKManager().currentUser == null) {
      return null;
    }
    roomExtraInfoDict['host'] = ZEGOSDKManager().currentUser!.iduser;
    final dataJson = jsonEncode(roomExtraInfoDict);
    final result = await ZEGOSDKManager()
        .expressService
        .setRoomExtraInfo(roomID, dataJson);
    if (result.errorCode == 0) {
      roleNoti.value = ZegoLiveAudioRoomRole.host;
      hostUserNoti.value = ZEGOSDKManager().currentUser;
    }
    return result;
  }

  String? getUserAvatar(String userID) {
    return ZEGOSDKManager().zimService.getUserAvatar(userID);
  }
}

void onRoomCommandReceived(OnRoomCommandReceivedEvent event) {
  final Map<String, dynamic> messageMap = jsonDecode(event.command);
  if (messageMap.keys.contains('room_command_type')) {
    final type = messageMap['room_command_type'];
    final receiverID = messageMap['receiver_id'];
    if (receiverID == ZEGOSDKManager().currentUser!.iduser) {
      if (type == RoomCommandType.muteSpeaker) {
        ScaffoldMessenger.of(navigatorKey.currentContext!)
            .showSnackBar(const SnackBar(
                content: AutoSizeText(
          'You have been mute speaker by the host',
          textAlign: TextAlign.center,
        )));
        LiveKitAudioService.instance
            .setMicrophoneEnabled(false, reason: 'command:muteSpeaker');
      } else if (type == RoomCommandType.unMuteSpeaker) {
        ScaffoldMessenger.of(navigatorKey.currentContext!)
            .showSnackBar(const SnackBar(
                content: AutoSizeText(
          'You have been unmuted by the host',
          textAlign: TextAlign.center,
        )));
        LiveKitAudioService.instance
            .setMicrophoneEnabled(true, reason: 'command:unMuteSpeaker');
      } else if (type == RoomCommandType.kickOutRoom) {
        ZEGOSDKManager().logoutRoom();
        // Navigator.pop(navigatorKey.currentContext!);
      }
    }
  }
}

UserEntity? getHostUser(String userID) {
  return ZEGOSDKManager().getUser(userID);
}
