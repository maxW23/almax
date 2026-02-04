import 'package:flutter/material.dart';
import 'package:auto_size_text/auto_size_text.dart';
import 'package:lklk/features/auth/domain/entities/user_entity.dart';

import '../../zego_sdk_manager.dart';
import '../common/zego_audio_video_view.dart';

class GroupCallView extends StatefulWidget {
  final CallUserInfo callUserInfo;

  const GroupCallView({required this.callUserInfo, super.key});

  @override
  State<GroupCallView> createState() => _GroupCallViewState();
}

class _GroupCallViewState extends State<GroupCallView> {
  @override
  Widget build(BuildContext context) {
    return ValueListenableBuilder(
        valueListenable: widget.callUserInfo.isWaiting,
        builder: (context, bool isWaiting, _) {
          if (isWaiting) {
            return Container(
              alignment: Alignment.center,
              color: Colors.black,
              child: const AutoSizeText(
                'is waiting...',
                textAlign: TextAlign.center,
                style: TextStyle(color: Colors.white),
              ),
            );
          } else {
            return ValueListenableBuilder(
                valueListenable: widget.callUserInfo.sdkUserNoti,
                builder: (context, UserEntity? sdkUser, _) {
                  if (sdkUser != null) {
                    return ValueListenableBuilder(
                        valueListenable: widget.callUserInfo.hasAccepted,
                        builder: (context, bool isAccepted, _) {
                          return ZegoAudioVideoView(userInfo: sdkUser);
                        });
                  } else {
                    return Container(
                      color: Colors.black,
                    );
                  }
                });
          }
        });
  }
}
