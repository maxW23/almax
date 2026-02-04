import 'dart:async';
import 'dart:convert';
import 'dart:math';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:lklk/core/utils/logger.dart';
import 'package:lklk/core/services/auth_service.dart';
import 'package:lklk/features/room/presentation/views/widgets/optimized_message_manager.dart';

import 'package:lklk/internal/sdk/zim/zim_service.dart';

import '../../../../room/domain/entities/message_room_entity.dart';
import 'package:lklk/core/services/api_service.dart';
import 'package:meta/meta.dart';
import 'package:zego_zim/zego_zim.dart';

part 'room_messages_state.dart';

class RoomMessagesCubit extends Cubit<RoomMessageState> {
  final ApiService apiService;
  StreamSubscription<List<ZIMMessage>>? _zimMessagesSub;
  RoomMessagesCubit(this.apiService)
      : super(const RoomMessageState(
            status: RoomMessageStatus.initial, messages: [])) {
    _zimMessagesSub = ZIMService.instance.onRoomMessageReceivedStreamCtrl.stream
        .listen((messageList) {
      log('Zego: Received message list from ZIMService: ${messageList.length} messages');
      final newMessages = messageList
          .map((zimMessage) => _convertZIMMessageToMessage(zimMessage))
          .toList();
      if (isClosed) return;
      try {
        emit(state
            .copyWith(messages: [...(state.messages ?? []), ...newMessages]));
      } catch (e, st) {
        log('RoomMessagesCubit emit error after close? $e',
            error: e, stackTrace: st);
      }
    });
  }

  bool isActive = true;
  Future<void> fetchMessages(String roomId, String where) async {
    emit(state.copyWith(status: RoomMessageStatus.loaded, messages: []));
  }

  Future<void> sendMessage(String roomId, String message) async {
    emit(state.copyWith(status: RoomMessageStatus.loading));

    try {
      // Check if the message is a special command (e.g., for gifts, entries, topBar)
      // This assumes special messages are sent as JSON strings.
      if (message.startsWith('{') && message.endsWith('}')) {
        try {
          final Map<String, dynamic> messageMap = jsonDecode(message);

          final customMessage = ZIMBarrageMessage(
            message: jsonEncode(messageMap),
          );
          await ZIM.getInstance()!.sendMessage(
                customMessage,
                roomId,
                ZIMConversationType.room,
                ZIMMessageSendConfig(),
              );
          log('Zego: Custom message sent: $message to room $roomId');
          emit(state.copyWith(status: RoomMessageStatus.sent));
          return;
        } catch (e) {
          log('Zego: Failed to parse message as JSON, sending as text: $e');
          // Fallback to text message if JSON parsing fails
        }
      }

      // If not a special command or JSON parsing failed, send as a regular text message
      final textMessage = ZIMTextMessage(message: message);
      await ZIM.getInstance()!.sendMessage(
            textMessage,
            roomId,
            ZIMConversationType.room,
            ZIMMessageSendConfig(),
          );
      log('Zego: Text message sent: $message to room $roomId');
      emit(state.copyWith(status: RoomMessageStatus.sent));
    } catch (e) {
      log('Zego: Failed to send message: $e');
      emit(state.copyWith(
        status: RoomMessageStatus.error,
        errorMessage: 'Failed to send message: $e',
      ));
    }
  }

  Future<void> deleteMessage(String messageID) async {
    emit(state.copyWith(status: RoomMessageStatus.loading));

    try {
      final response = await apiService.post(
        '/delete/onemassage/room/$messageID',
      );
      log("RoomMessagesCubit rooooom deleteMessage ${response.data}");

      if (response.statusCode == 200) {
        emit(state.copyWith(status: RoomMessageStatus.sent));
      } else {
        emit(state.copyWith(
          status: RoomMessageStatus.error,
          errorMessage: 'Failed to delete message: ${response.data}',
        ));
      }
    } catch (e) {
      emit(state.copyWith(
        status: RoomMessageStatus.error,
        errorMessage: 'Failed to delete message: $e',
      ));
    }
  }

  Future<void> deleteAllMessages(String roomID) async {
    emit(state.copyWith(status: RoomMessageStatus.loading));

    try {
      final response = await apiService.post(
        '/delete/massage/room/$roomID',
      );
      log("RoomMessagesCubit rooooom deleteAllMessages ${response.data}");

      if (response.statusCode == 200) {
        emit(state.copyWith(status: RoomMessageStatus.sent));
      } else {
        emit(state.copyWith(
          status: RoomMessageStatus.error,
          errorMessage: 'Failed to delete messages: ${response.data}',
        ));
      }
    } catch (e) {
      emit(state.copyWith(
        status: RoomMessageStatus.error,
        errorMessage: 'Failed to delete messages: $e',
      ));
    }
  }

  Future<void> sendDiceMessage(int roomId) async {
    emit(state.copyWith(status: RoomMessageStatus.loading));
    try {
      // 1..6
      final value = Random().nextInt(6) + 1;
      final user = await AuthService.getUserFromSharedPreferences();
      final ext = {
        "UserImage": user?.img ?? "",
        // اجعلها 0 لتفادي مسار VIP bubble وإظهار ودجت اللعبة
        "UserVipLevel": 0,
        "UserName": user?.name ?? "",
        // خاص بالنرد
        "UserID": "01011",
      };

      final msg = ZIMBarrageMessage(message: value.toString())
        ..extendedData = jsonEncode(ext);

      final result = await ZIM.getInstance()!.sendMessage(
            msg,
            roomId.toString(),
            ZIMConversationType.room,
            ZIMMessageSendConfig(),
          );
      final sent = result.message;
      log('Zego: Dice message sent: ${msg.message} to room $roomId with id=${sent.messageID} ext=${msg.extendedData}');
      // استخدم الرسالة المرجعة لضمان وجود messageID فريد
      OptimizedMessageManager.instance.addMessage(roomId.toString(), sent);
      emit(state.copyWith(status: RoomMessageStatus.sentDice));
    } catch (e) {
      log('Error sending dice via Zego: $e');
      emit(state.copyWith(
        status: RoomMessageStatus.error,
        errorMessage: 'فشل الإرسال: $e',
      ));
      rethrow;
    }
  }

  Future<void> sendSeventyMessage(int roomId) async {
    emit(state.copyWith(status: RoomMessageStatus.loading));
    try {
      // 1..777
      final value = Random().nextInt(777) + 1;
      final user = await AuthService.getUserFromSharedPreferences();
      final ext = {
        "UserImage": user?.img ?? "",
        // اجعلها 0 لتفادي مسار VIP bubble وإظهار ودجت اللعبة
        "UserVipLevel": 0,
        "UserName": user?.name ?? "",
        // خاص بـ 777
        "UserID": "01013",
      };

      final msg = ZIMBarrageMessage(message: value.toString())
        ..extendedData = jsonEncode(ext);

      final result = await ZIM.getInstance()!.sendMessage(
            msg,
            roomId.toString(),
            ZIMConversationType.room,
            ZIMMessageSendConfig(),
          );
      final sent = result.message;
      log('Zego: 777 message sent: ${msg.message} to room $roomId with id=${sent.messageID} ext=${msg.extendedData}');
      OptimizedMessageManager.instance.addMessage(roomId.toString(), sent);
      emit(state.copyWith(status: RoomMessageStatus.sentDice));
    } catch (e) {
      log('Error sending 777 via Zego: $e');
      emit(state.copyWith(
        status: RoomMessageStatus.error,
        errorMessage: 'فشل الإرسال: $e',
      ));
      rethrow;
    }
  }

  Future<void> sendPsrMessage(int roomId) async {
    emit(state.copyWith(status: RoomMessageStatus.loading));
    try {
      // 1..3 (1=ورقة, 2=حجر, 3=مقص)
      final value = Random().nextInt(3) + 1;
      final user = await AuthService.getUserFromSharedPreferences();
      final ext = {
        "UserImage": user?.img ?? "",
        // اجعلها 0 لتفادي مسار VIP bubble وإظهار ودجت اللعبة
        "UserVipLevel": 0,
        "UserName": user?.name ?? "",
        // خاص بـ PSR
        "UserID": "01012",
      };

      final msg = ZIMBarrageMessage(message: value.toString())
        ..extendedData = jsonEncode(ext);

      final result = await ZIM.getInstance()!.sendMessage(
            msg,
            roomId.toString(),
            ZIMConversationType.room,
            ZIMMessageSendConfig(),
          );
      final sent = result.message;
      log('Zego: PSR message sent: ${msg.message} to room $roomId with id=${sent.messageID} ext=${msg.extendedData}');
      OptimizedMessageManager.instance.addMessage(roomId.toString(), sent);
      emit(state.copyWith(status: RoomMessageStatus.sentDice));
    } catch (e) {
      log('Error sending PSR via Zego: $e');
      emit(state.copyWith(
        status: RoomMessageStatus.error,
        errorMessage: 'فشل الإرسال: $e',
      ));
      rethrow;
    }
  }

  Message _convertZIMMessageToMessage(ZIMMessage zimMessage) {
    String textContent = '';
    String? giftSender;
    String? giftReciver;
    String? giftsMany;
    String? vip;
    String? reciverId;
    String? giftLink;
    String? giftImg;
    String? pass;
    int? timer;
    String isOwner = 'false';

    if (zimMessage is ZIMTextMessage) {
      textContent = zimMessage.message;
      log('Zego: Converting ZIMTextMessage: ${zimMessage.message}');
    } else if (zimMessage is ZIMCommandMessage) {
      try {
        // ZIMCommandMessage.message is List<int>, so it needs utf8.decode
        final commandData = utf8.decode(zimMessage.message);
        final Map<String, dynamic> messageMap = jsonDecode(commandData);
        log('Zego: Converting ZIMCommandMessage: $messageMap');

        // Check for specific message types based on content
        if (messageMap['type'] == 'gift') {
          textContent = messageMap['giftId']
              .toString(); // Assuming giftId is the 'text' for gifts
          giftSender = messageMap['senderId'];
          giftReciver = messageMap['receiverName'];
          giftsMany = messageMap['quantity'].toString();
          reciverId = messageMap['receiverId'];
          giftLink = messageMap['giftLink'];
          giftImg = messageMap['giftImg'];
          timer = messageMap['timer'];
          isOwner = messageMap['isOwner']?.toString() ?? 'false';
        } else if (messageMap['type'] == 'entry') {
          textContent = messageMap['message'];
          giftSender = messageMap[
              'userId']; // Assuming userId is the 'giftSender' for entry messages
          isOwner = messageMap['isOwner']?.toString() ?? 'false';
          timer = messageMap['timer'];
        } else if (messageMap['type'] == 'topBar') {
          textContent = messageMap['message'];
          isOwner = messageMap['isOwner']?.toString() ?? 'false';
          // Add other topBar specific fields if any
        } else {
          textContent = commandData; // Fallback for other command messages
        }
      } catch (e) {
        log('Zego: Error decoding ZIMCommandMessage or parsing JSON: $e');
        textContent = 'Error processing command message'; // Fallback text
      }
    } else if (zimMessage is ZIMBarrageMessage) {
      try {
        final customData = zimMessage.message;
        final Map<String, dynamic> messageMap = jsonDecode(customData);
        log('Zego: Converting ZIMBarrageMessage: $messageMap');

        // Handle custom message types if needed, similar to ZIMCommandMessage
        if (messageMap['type'] == 'gift') {
          textContent = messageMap['giftId'].toString();
          giftSender = messageMap['senderId'];
          giftReciver = messageMap['receiverName'];
          giftsMany = messageMap['quantity'].toString();
          reciverId = messageMap['receiverId'];
          giftLink = messageMap['giftLink'];
          giftImg = messageMap['giftImg'];
          timer = messageMap['timer'];
          isOwner = messageMap['isOwner']?.toString() ?? 'false';
        } else if (messageMap['type'] == 'entry') {
          textContent = messageMap['message'];
          giftSender = messageMap['userId'];
          isOwner = messageMap['isOwner']?.toString() ?? 'false';
          timer = messageMap['timer'];
        } else if (messageMap['type'] == 'topBar') {
          textContent = messageMap['message'];
          isOwner = messageMap['isOwner']?.toString() ?? 'false';
        } else {
          textContent = customData; // Fallback for other custom messages
        }
      } catch (e) {
        log('Zego: Error decoding ZIMBarrageMessage or parsing JSON: $e');
        // Fallback: treat as plain text message
        textContent = zimMessage.message;
      }
    } else {
      log('Zego: Converting unknown ZIMMessage type: ${zimMessage.runtimeType}');
      textContent = 'Unsupported message type';
    }

    return Message(
      id: zimMessage.messageID,
      userName: zimMessage
          .senderUserID, // ZIMMessage doesn't have userName directly, assuming senderUserID is used
      roomId: zimMessage.conversationID,
      userId: zimMessage.senderUserID,
      text: textContent,
      createdAt: DateTime.fromMillisecondsSinceEpoch(zimMessage.timestamp),
      updatedAt: DateTime.fromMillisecondsSinceEpoch(zimMessage.timestamp),
      isOwmer: isOwner,
      giftSender: giftSender,
      giftReciver: giftReciver,
      giftsMany: giftsMany,
      vip: vip,
      reciverId: reciverId,
      giftLink: giftLink,
      giftImg: giftImg,
      pass: pass,
      timer: timer,
    );
  }

  @override
  Future<void> close() async {
    try {
      await _zimMessagesSub?.cancel();
    } catch (_) {}
    return super.close();
  }
}
