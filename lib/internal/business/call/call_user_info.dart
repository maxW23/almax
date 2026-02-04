import 'package:flutter/foundation.dart';
import 'package:lklk/features/auth/domain/entities/user_entity.dart';

import '../../../zego_sdk_manager.dart';

class CallUserInfo {
  final String userID;
  ValueNotifier<UserEntity?> sdkUserNoti = ValueNotifier(null);

  String? get userName => ZEGOSDKManager().zimService.getUserName(userID);
  String? get userMap => ZEGOSDKManager().zimService.getUserMap(userID);

  ValueNotifier<ZIMCallUserState> callUserState =
      ValueNotifier(ZIMCallUserState.unknown);

  String extendedData = '';
  String? get headUrl => ZEGOSDKManager().zimService.getUserAvatar(userID);
  String get streamID =>
      '${ZEGOSDKManager().expressService.currentRoomID}_${userID}_main';

  ValueNotifier<bool> hasAccepted = ValueNotifier(false);
  ValueNotifier<bool> isWaiting = ValueNotifier(false);

  CallUserInfo({required this.userID});

  void updateCallUserState(ZIMCallUserState state) {
    callUserState.value = state;
    hasAccepted.value = state == ZIMCallUserState.accepted;
    if (state == ZIMCallUserState.received ||
        state == ZIMCallUserState.inviting) {
      isWaiting.value = true;
    } else {
      isWaiting.value = false;
    }
  }
}
