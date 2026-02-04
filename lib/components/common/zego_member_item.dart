import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:auto_size_text/auto_size_text.dart';
import 'package:lklk/features/auth/domain/entities/user_entity.dart';

import '../../zego_sdk_manager.dart';

class ZegoMemberItem extends StatefulWidget {
  const ZegoMemberItem(
      {required this.userInfo, required this.applyCohostList, super.key});

  final UserEntity userInfo;
  final ValueNotifier<List<String>> applyCohostList;

  @override
  State<ZegoMemberItem> createState() => _ZegoMemberItemState();
}

class _ZegoMemberItemState extends State<ZegoMemberItem> {
  @override
  Widget build(BuildContext context) {
    // return ValueListenableBuilder(valueListenable: widget.userInfo, builder: builder)
    return ValueListenableBuilder<List<String>>(
        valueListenable: widget.applyCohostList,
        builder: (context, applyCohosts, _) {
          if (applyCohosts.contains(widget.userInfo.iduser)) {
            return Row(
              children: [
                AutoSizeText(widget.userInfo.name!),
                const SizedBox(
                  width: 40,
                ),
                OutlinedButton(
                    onPressed: () {
                      final signaling = jsonEncode({
                        'room_request_type':
                            RoomRequestType.hostRefuseAudienceCoHostApply,
                      });
                      ZEGOSDKManager()
                          .zimService
                          .sendRoomRequest(widget.userInfo.iduser, signaling);
                      widget.applyCohostList.value.removeWhere((element) {
                        return element == widget.userInfo.iduser;
                      });
                    },
                    child: const AutoSizeText('Disagree')),
                const SizedBox(
                  width: 10,
                ),
                OutlinedButton(
                    onPressed: () {
                      final signaling = jsonEncode({
                        'room_request_type':
                            RoomRequestType.hostAcceptAudienceCoHostApply,
                      });
                      ZEGOSDKManager()
                          .zimService
                          .sendRoomRequest(widget.userInfo.iduser, signaling);
                      widget.applyCohostList.value.removeWhere((element) {
                        return element == widget.userInfo.iduser;
                      });
                    },
                    child: const AutoSizeText('Agree')),
              ],
            );
          } else {
            return AutoSizeText(widget.userInfo.name!);
          }
        });
  }
}
