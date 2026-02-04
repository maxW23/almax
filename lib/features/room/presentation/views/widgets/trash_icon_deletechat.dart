import 'dart:convert';
import 'package:lklk/core/utils/logger.dart';

import 'package:flutter/material.dart';
import 'package:lklk/core/services/auth_service.dart';
import 'package:lklk/features/auth/domain/entities/user_entity.dart';
import 'package:lklk/features/room/presentation/views/widgets/confirm_delete_dialog.dart';
import 'package:lklk/zego_sdk_manager.dart';
import 'package:flutter_svg/flutter_svg.dart';

class TrashIconDeletechat extends StatelessWidget {
  const TrashIconDeletechat({
    super.key,
    required this.deleteAllMessages,
    required this.roomID,
    required this.role,
    required this.addDeleteAllMessagesMessage,
  });

  final void Function() deleteAllMessages;
  final void Function() addDeleteAllMessagesMessage;
  final String roomID;
  final ZegoLiveAudioRoomRole role;

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        Transform.rotate(
          angle: -2.7,
          child: IconButton(
            padding: EdgeInsets.zero,
            constraints: const BoxConstraints(minWidth: 45, minHeight: 45),
            iconSize: 45,
            icon: SvgPicture.asset(
              'assets/icons/room_btn/delete_messages_icon_btn.svg',
              width: 45,
              height: 45,
            ),
            onPressed: () async {
              final confirmed = await showDialog<bool>(
                context: context,
                builder: (context) => DeleteChatConfirmationDialog(
                  role: role,
                  onConfirm: () {
                    AuthService.getUserFromSharedPreferences().then((user) {
                      final roomIdStr = roomID;
                      final isOwner =
                          user?.ownerIds?.contains(roomIdStr) ?? false;
                      final isAdmin =
                          user?.adminRoomIds?.contains(roomIdStr) ?? false;

                      final canBroadcast = role == ZegoLiveAudioRoomRole.host ||
                          isOwner ||
                          isAdmin;

                      if (canBroadcast) {
                        // Broadcast delete-all to everyone (also clears locally).
                        sendDeleteAllMessagesCommand();
                      } else {
                        // Normal users: clear locally only.
                        deleteAllMessages();
                      }
                    });
                  },
                ),
              );

              if (confirmed ?? false) {
                // Actions handled in onConfirm
              }
            },
          ),
        ),
      ],
    );
  }

  void sendDeleteAllMessagesCommand() async {
    final UserEntity? userAuth =
        await AuthService.getUserFromSharedPreferences();
    final systemMessage = ZIMBarrageMessage(
      message: "${userAuth?.name} قام بحذف رسائل الغرفة",
    );
    final DateTime now = DateTime.now();

    final Map<String, dynamic> customData = {
      "UserName": "${userAuth?.name}",
      "UserID": "${userAuth?.iduser}",
      "gift_type": "deleteAllMessages",
      "UserImage": "${userAuth?.img}",
      "UserVipLevel": int.tryParse("${userAuth?.vip}"),
      "dateTime": now.toIso8601String(),
    };
    systemMessage.extendedData = jsonEncode(customData);
    log("deleteAllMessages :systemMessage $systemMessage ");
    log("deleteAllMessages :extendedData $customData ");

    // Clear locally immediately for the broadcaster as well
    WidgetsBinding.instance.addPostFrameCallback((_) {
      deleteAllMessages();
    });

    ZIM
        .getInstance()!
        .sendMessage(
          systemMessage,
          roomID,
          ZIMConversationType.room,
          ZIMMessageSendConfig(),
        )
        .then((result) {
      log("deleteAllMessages :result ${(result.message as ZIMBarrageMessage).message} ");
    }).catchError((e) {
      log("deleteAllMessages :error: $e");
    });
  }
}
