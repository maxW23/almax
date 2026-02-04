import 'package:flutter/material.dart';
import 'package:lklk/features/auth/domain/entities/user_entity.dart';

import '../../../zego_sdk_manager.dart';

bool isHostStreamID(String streamID) {
  return streamID.endsWith('_host');
}

class CoHostService {
  ValueNotifier<UserEntity?> hostNotifier = ValueNotifier(null);
  ListNotifier<UserEntity> coHostUserListNotifier = ListNotifier([]);

  bool isHost(String userID) {
    return hostNotifier.value?.iduser == userID;
  }

  bool isCoHost(String userID) {
    for (final user in coHostUserListNotifier.value) {
      if (user.iduser == userID) {
        return true;
      }
    }
    return false;
  }

  bool isAudience(String userID) {
    if (isHost(userID) || isCoHost(userID)) {
      return false;
    }
    return true;
  }

  bool iamHost() {
    return isHost(ZEGOSDKManager().currentUser!.iduser);
  }

  void clearData() {
    coHostUserListNotifier.clear();
    hostNotifier.value = null;
  }

  void startCoHost() {
    coHostUserListNotifier.add(ZEGOSDKManager().currentUser!);
  }

  void endCoHost() {
    coHostUserListNotifier.removeWhere((element) {
      return element.iduser == ZEGOSDKManager().currentUser!.iduser;
    });
  }

  void onReceiveStreamUpdate(ZegoRoomStreamListUpdateEvent event) {
    if (event.updateType == ZegoUpdateType.Add) {
      for (final element in event.streamList) {
        if (isHostStreamID(element.streamID)) {
          hostNotifier.value = ZEGOSDKManager().getUser(element.user.userID);
        } else if (element.streamID.endsWith('_cohost')) {
          final cohostUser = ZEGOSDKManager().getUser(element.user.userID);
          if (cohostUser != null) {
            coHostUserListNotifier.add(cohostUser);
          }
        }
      }
    } else {
      for (final element in event.streamList) {
        if (isHostStreamID(element.streamID)) {
          hostNotifier.value = null;
        } else if (element.streamID.endsWith('_cohost')) {
          coHostUserListNotifier.removeWhere((coHostUser) {
            return coHostUser.iduser == element.user.userID;
          });
        }
      }
    }
  }

  void onRoomUserListUpdate(ZegoRoomUserListUpdateEvent event) {
    for (final user in event.userList) {
      if (event.updateType == ZegoUpdateType.Delete) {
        coHostUserListNotifier
            .removeWhere((coHost) => coHost.iduser == user.userID);
        if (hostNotifier.value?.iduser == user.userID) {
          hostNotifier.value = null;
        }
      }
    }
  }
}
