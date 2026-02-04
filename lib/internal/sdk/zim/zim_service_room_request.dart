part of 'zim_service.dart';

extension ZIMServiceRoomMessage on ZIMService {
  Future<RoomRequestResult> sendRoomRequest(
      String receiverID, String extendedData) async {
    final request = RoomRequest(
        RoomRequestAction.request, currentZimUserInfo!.userID, receiverID)
      ..extendedData = extendedData;

    await ZIM
        .getInstance()!
        .sendMessage(
          ZIMCommandMessage(
              message: Uint8List.fromList(utf8.encode(request.toJsonString()))),
          currentRoomID!,
          ZIMConversationType.room,
          ZIMMessageSendConfig(),
        )
        .then((value) {
      roomRequestMapNoti.addValue(request.requestID ?? '', request);
    }).catchError((error) {
      debugAppLogger.debug('sendRoomRequest error');
    });

    sendRoomRequestStreamCtrl.add(SendRoomRequestEvent(
        requestID: request.requestID ?? '', extendedData: extendedData));
    final result = RoomRequestResult(request.requestID ?? '');
    return result;
  }

  Future<RoomRequestResult> acceptRoomRequest(String requestID,
      {String? extendedData}) async {
    final newRoomRequest = roomRequestMapNoti.value[requestID];
    if (newRoomRequest is RoomRequest) {
      newRoomRequest
        ..actionType = RoomRequestAction.accept
        ..receiverID = newRoomRequest.senderID
        ..senderID = currentZimUserInfo!.userID
        ..extendedData = extendedData ?? newRoomRequest.extendedData;

      await ZIM.getInstance()!.sendMessage(
            ZIMCommandMessage(
                message: Uint8List.fromList(
                    utf8.encode(newRoomRequest.toJsonString()))),
            currentRoomID!,
            ZIMConversationType.room,
            ZIMMessageSendConfig(),
          );
    }

    roomRequestMapNoti.removeValue(requestID);

    acceptIncomingRoomRequestStreamCtrl.add(AcceptIncomingRoomRequestEvent(
        requestID: requestID, extendedData: extendedData));

    final result = RoomRequestResult(requestID);
    return result;
  }

  Future<RoomRequestResult> rejectRoomRequest(String requestID,
      {String? extendedData}) async {
    final newRoomRequest = roomRequestMapNoti.value[requestID];
    if (newRoomRequest is RoomRequest) {
      newRoomRequest
        ..actionType = RoomRequestAction.reject
        ..receiverID = newRoomRequest.senderID
        ..senderID = currentZimUserInfo!.userID
        ..extendedData = extendedData ?? newRoomRequest.extendedData;

      await ZIM.getInstance()!.sendMessage(
            ZIMCommandMessage(
                message: Uint8List.fromList(
                    utf8.encode(newRoomRequest.toJsonString()))),
            currentRoomID!,
            ZIMConversationType.room,
            ZIMMessageSendConfig(),
          );
    }

    roomRequestMapNoti.removeValue(requestID);

    rejectIncomingRoomRequestStreamCtrl.add(RejectIncomingRoomRequestEvent(
        requestID: requestID, extendedData: extendedData));

    final result = RoomRequestResult(requestID);
    return result;
  }

  Future<RoomRequestResult> cancelRoomRequest(String requestID,
      {String? extendedData}) async {
    final newRoomRequest = roomRequestMapNoti.value[requestID];
    if (newRoomRequest is RoomRequest) {
      newRoomRequest
        ..actionType = RoomRequestAction.cancel
        ..extendedData = extendedData ?? newRoomRequest.extendedData;

      await ZIM.getInstance()!.sendMessage(
            ZIMCommandMessage(
                message: Uint8List.fromList(
                    utf8.encode(newRoomRequest.toJsonString()))),
            currentRoomID!,
            ZIMConversationType.room,
            ZIMMessageSendConfig(),
          );
    }

    roomRequestMapNoti.removeValue(requestID);

    cancelRoomRequestStreamCtrl.add(CancelRoomRequestEvent(
        requestID: requestID, extendedData: extendedData));

    final result = RoomRequestResult(requestID);
    return result;
  }

  Future<ZIMMessageSentResult> sendRoomCommand(String command) async {
    final result = await ZIM.getInstance()!.sendMessage(
        ZIMCommandMessage(message: Uint8List.fromList(utf8.encode(command))),
        currentRoomID!,
        ZIMConversationType.room,
        ZIMMessageSendConfig());
    //log('~~~~~~~~~~~~~~~~ sendRoomCommand $result');
    return result;
  }

  void onReceiveRoomMessageCommandsRequest(
      _, List<ZIMMessage> messageList, String fromRoomID) {
    for (final element in messageList) {
      //log('~~~~~~~~~~~~~~~~ onReceiveRoomMessage zsrr');
      if (element is ZIMCommandMessage) {
        final message = utf8.decode(element.message);
        debugAppLogger.debug('onReceiveRoomCustomCommand: $message');
        final Map<String, dynamic> messageMap = jsonDecode(message);
        final sender = messageMap['sender_id'] ?? '';
        final receiver = messageMap['receiver_id'] ?? '';
        final extendedData = messageMap['extended_data'] ?? '';
        final requestID = messageMap['request_id'] ?? '';

        // Check for 'action_type' or handle emoji messages
        if (messageMap.keys.contains('action_type') &&
            currentZimUserInfo != null) {
          final actionType =
              RoomRequestAction.values[messageMap['action_type']];
          if (currentZimUserInfo!.userID == receiver) {
            switch (actionType) {
              case RoomRequestAction.request:
                final request = RoomRequest(actionType, sender, receiver);
                request.extendedData = extendedData;
                request.requestID = requestID;
                roomRequestMapNoti.addValue(requestID, request);
                onInComingRoomRequestStreamCtrl.add(
                    OnInComingRoomRequestReceivedEvent(
                        requestID: requestID, extendedData: extendedData));
                break;
              case RoomRequestAction.accept:
                final roomRequest = roomRequestMapNoti.value[requestID];
                if (roomRequest != null) {
                  roomRequestMapNoti.removeValue(requestID);
                  onOutgoingRoomRequestAcceptedStreamCtrl.add(
                      OnOutgoingRoomRequestAcceptedEvent(
                          requestID: requestID, extendedData: extendedData));
                }
                break;
              case RoomRequestAction.reject:
                final roomRequest = roomRequestMapNoti.value[requestID];
                if (roomRequest != null) {
                  roomRequestMapNoti.removeValue(requestID);
                  onOutgoingRoomRequestRejectedStreamCtrl.add(
                      OnOutgoingRoomRequestRejectedEvent(
                          requestID: requestID, extendedData: extendedData));
                }
                break;
              case RoomRequestAction.cancel:
                final roomRequest = roomRequestMapNoti.value[requestID];
                if (roomRequest != null) {
                  roomRequestMapNoti.removeValue(requestID);
                  onInComingRoomRequestCancelledStreamCtrl.add(
                      OnInComingRoomRequestCancelledEvent(
                          requestID: requestID, extendedData: extendedData));
                }
                break;
            }
          }
        } else if (messageMap['type'] == 'emoji') {
          // Handle emoji message
          final emoji = messageMap['content'];
          debugAppLogger.debug('Received Emoji: $emoji');

          // Pass the emoji to EmojiCubit or any other system to display it
          // context.read<EmojiCubit>().selectEmoji(emoji);

          // Optionally, you can also send this event to another stream
          onRoomCommandReceivedEventStreamCtrl
              .add(OnRoomCommandReceivedEvent(sender, message));
        } else {
          onRoomCommandReceivedEventStreamCtrl
              .add(OnRoomCommandReceivedEvent(sender, message));
        }
      } else if (element is ZIMTextMessage) {
        debugAppLogger.debug('onReceiveRoomTextMessage: ${element.message}');
      }
    }
  }

  // void onReceiveRoomMessage(
  //     _, List<ZIMMessage> messageList, String fromRoomID) {
  //   for (final element in messageList) {
  //     //log('~~~~~~~~~~~~~~~~ onReceiveRoomMessage zsrr');
  //     if (element is ZIMCommandMessage) {
  //       final message = utf8.decode(element.message);
  //       debugAppLogger.debug('onReceiveRoomCustomCommand: $message');
  //       final Map<String, dynamic> messageMap = jsonDecode(message);
  //       final sender = messageMap['sender_id'] ?? '';
  //       final receiver = messageMap['receiver_id'] ?? '';
  //       final extendedData = messageMap['extended_data'] ?? '';
  //       final requestID = messageMap['request_id'] ?? '';
  //       if (messageMap.keys.toList().contains('action_type') &&
  //           currentZimUserInfo != null) {
  //         final actionType =
  //             RoomRequestAction.values[messageMap['action_type']];
  //         if (currentZimUserInfo!.userID == receiver) {
  //           switch (actionType) {
  //             case RoomRequestAction.request:
  //               final request = RoomRequest(actionType, sender, receiver);
  //               request.extendedData = extendedData;
  //               request.requestID = requestID;
  //               roomRequestMapNoti.addValue(requestID, request);
  //               onInComingRoomRequestStreamCtrl.add(
  //                   OnInComingRoomRequestReceivedEvent(
  //                       requestID: requestID, extendedData: extendedData));
  //               break;
  //             case RoomRequestAction.accept:
  //               final roomRequest = roomRequestMapNoti.value[requestID];
  //               if (roomRequest != null) {
  //                 roomRequestMapNoti.removeValue(requestID);
  //                 onOutgoingRoomRequestAcceptedStreamCtrl.add(
  //                     OnOutgoingRoomRequestAcceptedEvent(
  //                         requestID: requestID, extendedData: extendedData));
  //               }
  //               break;
  //             case RoomRequestAction.reject:
  //               final roomRequest = roomRequestMapNoti.value[requestID];
  //               if (roomRequest != null) {
  //                 roomRequestMapNoti.removeValue(requestID);
  //                 onOutgoingRoomRequestRejectedStreamCtrl.add(
  //                     OnOutgoingRoomRequestRejectedEvent(
  //                         requestID: requestID, extendedData: extendedData));
  //               }
  //               break;
  //             case RoomRequestAction.cancel:
  //               final roomRequest = roomRequestMapNoti.value[requestID];
  //               if (roomRequest != null) {
  //                 roomRequestMapNoti.removeValue(requestID);
  //                 onInComingRoomRequestCancelledStreamCtrl.add(
  //                     OnInComingRoomRequestCancelledEvent(
  //                         requestID: requestID, extendedData: extendedData));
  //               }
  //               break;
  //           }
  //         }
  //       } else {
  //         onRoomCommandReceivedEventStreamCtrl
  //             .add(OnRoomCommandReceivedEvent(sender, message));
  //       }
  //     } else if (element is ZIMTextMessage) {
  //       debugAppLogger.debug('onReceiveRoomTextMessage: ${element.message}');
  //     }
  //   }
  // }

  void onRoomMemberLeft(_, List<ZIMUserInfo> memberList, String roomID) {
    for (final member in memberList) {
      roomRequestMapNoti.removeWhere(
          (String k, RoomRequest v) => v.senderID == member.userID);
    }
  }

  RoomRequest? getRoomRequestByRequestID(String requestID) {
    final request = roomRequestMapNoti.value[requestID];
    return request;
  }
}
