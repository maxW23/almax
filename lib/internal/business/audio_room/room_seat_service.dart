import 'dart:async';

import 'package:lklk/core/services/seat_user.dart';
import 'package:lklk/internal/sdk/livekit/livekit_audio_service.dart';

import '../../../live_audio_room_manager.dart';

class RoomSeatService {
  final seatCount = 20;
  int hostSeatIndex = 0;
  late List<ZegoLiveAudioRoomSeat> seatList =
      List.generate(seatCount, (index) => ZegoLiveAudioRoomSeat(index));
  bool isBatchOperation = false;
  bool _processingAttributeBatch = false;

  List<StreamSubscription<dynamic>> subscriptions = [];

  void initWithConfig(ZegoLiveAudioRoomRole role) {
    final expressService = ZEGOSDKManager().expressService;
    final zimService = ZEGOSDKManager().zimService;
    subscriptions.addAll([
      expressService.roomUserListUpdateStreamCtrl.stream
          .listen(onRoomUserListUpdate),
      zimService.roomAttributeUpdateStreamCtrl.stream
          .listen(onRoomAttributeUpdate),
      zimService.roomAttributeBatchUpdatedStreamCtrl.stream
          .listen(onRoomAttributeBatchUpdate)
    ]);
    // مزامنة فورية لحالة المقاعد من الخصائص الحالية للغرفة
    try {
      _syncFromExistingAttributes();
    } catch (_) {}
  }

// Future<ZIMRoomAttributesBatchOperatedResult?> switchSeat(int fromSeatIndex, int toSeatIndex) async {
//   if (!isBatchOperation) {
//     ZEGOSDKManager.instance.zimService.beginRoomAttributesBatchOperation();
//     isBatchOperation = true;
//     takeSeat(toSeatIndex);
//     leaveSeat(fromSeatIndex);
//     ZIMRoomAttributesBatchOperatedResult? result =
//         await ZEGOSDKManager.instance.zimService.endRoomPropertiesBatchOperation();
//     isBatchOperation = false;
//     return result;
//   }
//   return null;
// }
  Future<ZIMRoomAttributesOperatedCallResult?> takeSeat(int seatIndex,
      {bool? isForce}) async {
    //log('zego takeSeat ::: seatIndex = $seatIndex --- isForce = $isForce');
    final currentUserID = ZEGOSDKManager().currentUser!.iduser;
    final attributes = {seatIndex.toString(): currentUserID};
    final result = await ZEGOSDKManager().zimService.setRoomAttributes(
          attributes,
          isForce: isForce ?? false,
          isUpdateOwner: true,
          isDeleteAfterOwnerLeft: true,
        );

    if (result != null) {
      // During batch switch, don't flip seatTaken here; final state handled by updates
      if (!isBatchOperation) {
        await SeatPreferences.setSeatTaken(true);
      }
      if (!result.errorKeys.contains(seatIndex.toString())) {
        for (final element in seatList) {
          if (element.seatIndex == seatIndex) {
            ZEGOSDKManager().zimService.roomRequestMapNoti.removeWhere(
                (String k, RoomRequest v) => v.senderID == currentUserID);
            element.currentUser.value = ZEGOSDKManager().currentUser;
            break;
          }
        }
      }
    }
    return result;
  }

  Future<ZIMRoomAttributesBatchOperatedResult?> switchSeat(
      int fromSeatIndex, int toSeatIndex) async {
    if (!isBatchOperation) {
      ZEGOSDKManager().zimService.beginRoomAttributesBatchOperation(
            isForce: true,
            isUpdateOwner: true,
            isDeleteAfterOwnerLeft: true,
          );
      isBatchOperation = true;
      takeSeat(toSeatIndex);
      leaveSeat(fromSeatIndex);
      final result =
          await ZEGOSDKManager().zimService.endRoomPropertiesBatchOperation();
      isBatchOperation = false;
      return result;
    }
    return null;
  }

  Future<ZIMRoomAttributesOperatedCallResult?> leaveSeat(int seatIndex) async {
    final result = await ZEGOSDKManager()
        .zimService
        .deleteRoomAttributes([seatIndex.toString()]);
    if (result != null) {
      // During batch switch, don't flip seatTaken here; final state handled by updates
      if (!isBatchOperation) {
        await SeatPreferences.setSeatTaken(false);
      }

      if (result.errorKeys.contains(seatIndex.toString())) {
        for (final element in seatList) {
          if (element.seatIndex == seatIndex) {
            element.currentUser.value = null;
          }
        }
      }
    }
    return result;
  }

  Future<ZIMRoomAttributesOperatedCallResult?> removeSpeakerFromSeat(
      String userID) async {
    for (final seat in seatList) {
      if (seat.currentUser.value?.iduser == userID) {
        final result = await leaveSeat(seat.seatIndex);
        return result;
      }
    }
    return null;
  }

  void unInit() {
    for (final subscription in subscriptions) {
      subscription.cancel();
    }
    subscriptions.clear();
  }

  void clear() {
    // لا تفرغ القائمة للحفاظ على ValueNotifiers ثابتة في عناصر الواجهة
    for (final seat in seatList) {
      seat.currentUser.value = null;
    }
    isBatchOperation = false;
    unInit();
  }

  void onRoomUserListUpdate(ZegoRoomUserListUpdateEvent event) {
    if (event.updateType == ZegoUpdateType.Add) {
      final userIDList = <String>[];
      for (final element in event.userList) {
        userIDList.add(element.userID);
        ZEGOSDKManager().zimService.roomAttributesMap.forEach((key, value) {
          if (element.userID == value) {
            for (final seat in seatList) {
              if (seat.seatIndex.toString() == key) {
                seat.currentUser.value = ZEGOSDKManager().getUser(value);
                break;
              }
            }
          }
        });
      }
    } else {
      // empty seat
    }
  }

  void onRoomAttributeBatchUpdate(
      ZIMServiceRoomAttributeBatchUpdatedEvent event) {
    // Process as an atomic batch to avoid audience/mic flips between delete/set
    _processingAttributeBatch = true;
    try {
      for (final updateInfo in event.updateInfos) {
        if (updateInfo.action == ZIMRoomAttributesUpdateAction.set) {
          updateInfo.roomAttributes.forEach((key, value) {
            for (final element in seatList) {
              if (element.seatIndex.toString() == key) {
                if (value == ZEGOSDKManager().currentUser!.iduser) {
                  element.currentUser.value = ZEGOSDKManager().currentUser;
                } else {
                  element.currentUser.value = ZEGOSDKManager().getUser(value);
                }
                break;
              }
            }
          });
        } else {
          updateInfo.roomAttributes.forEach((key, value) {
            for (final element in seatList) {
              if (element.seatIndex.toString() == key) {
                element.currentUser.value = null;
                break;
              }
            }
          });
        }
      }
      // After applying all seat changes, update role snapshot once and policy
      updatecurrentUserRole();
      _applyLiveKitRemoteAudioPolicy();
    } finally {
      _processingAttributeBatch = false;
    }
  }

  void onRoomAttributeUpdate(ZIMServiceRoomAttributeUpdateEvent event) {
    _onRoomAttributeUpdate(event.updateInfo);
  }

  void _onRoomAttributeUpdate(ZIMRoomAttributesUpdateInfo updateInfo) {
    if (updateInfo.action == ZIMRoomAttributesUpdateAction.set) {
      updateInfo.roomAttributes.forEach((key, value) {
        for (final element in seatList) {
          if (element.seatIndex.toString() == key) {
            if (value == ZEGOSDKManager().currentUser!.iduser) {
              element.currentUser.value = ZEGOSDKManager().currentUser;
              // Ensure role reflects own seating immediately; avoid audience flip during batch/processing
              updatecurrentUserRole(
                  duringBatch: isBatchOperation || _processingAttributeBatch);
            } else {
              // Others made a request to sit, but he took the initiative to sit down on his own.
              ZIMService().roomRequestMapNoti.removeWhere(
                  (String k, RoomRequest v) => v.senderID == value);
              // update seat user.
              element.currentUser.value = ZEGOSDKManager().getUser(value);
              updatecurrentUserRole(
                  duringBatch: isBatchOperation || _processingAttributeBatch);
            }
          }
        }
      });
      // After applying seat assignments, update LiveKit remote subscription policy
      _applyLiveKitRemoteAudioPolicy();
    } else {
      updateInfo.roomAttributes.forEach((key, value) {
        for (final element in seatList) {
          if (element.seatIndex.toString() == key) {
            element.currentUser.value = null;
            // While switching seats in batch, don't drop to audience/disable mic here
            updatecurrentUserRole(
                duringBatch: isBatchOperation || _processingAttributeBatch);
          }
        }
      });
      // After seat removals, update LiveKit remote subscription policy
      _applyLiveKitRemoteAudioPolicy();
    }
  }

  /// مزامنة فورية لحالة المقاعد من خريطة خصائص الغرفة الحالية بدون انتظار أحداث
  void _syncFromExistingAttributes() {
    try {
      final attrs = ZEGOSDKManager().zimService.roomAttributesMap;
      attrs.forEach((key, value) {
        for (final element in seatList) {
          if (element.seatIndex.toString() == key) {
            element.currentUser.value = ZEGOSDKManager().getUser(value);
            break;
          }
        }
      });
      updatecurrentUserRole();
      // Ensure policy reflects current room snapshot
      _applyLiveKitRemoteAudioPolicy();
    } catch (_) {}
  }

  void updatecurrentUserRole({bool duringBatch = false}) {
    var isFindSelf = false;
    for (final seat in seatList) {
      if (seat.currentUser.value != null &&
          seat.currentUser.value?.iduser ==
              ZEGOSDKManager().currentUser!.iduser) {
        isFindSelf = true;
        break;
      }
    }
    final liveAudioRoomManager = ZegoLiveAudioRoomManager();
    if (isFindSelf) {
      if (liveAudioRoomManager.roleNoti.value != ZegoLiveAudioRoomRole.host) {
        liveAudioRoomManager.roleNoti.value = ZegoLiveAudioRoomRole.speaker;
      }
    } else {
      if (duringBatch) {
        // During seat switch, skip forcing audience/mic-off. Final role will be set after batch completes.
        return;
      }
      liveAudioRoomManager.roleNoti.value = ZegoLiveAudioRoomRole.audience;
      ZEGOSDKManager().expressService.stopPublishingStream();
      // Ensure LiveKit mic is always disabled when leaving the seat (self)
      try {
        LiveKitAudioService.instance
            .setMicrophoneEnabled(false, reason: 'role:audience');
      } catch (_) {}
    }
  }

  /// Compute allowed remote speakers (host + all seated users) and update
  /// LiveKit subscription policy so audience voices are not heard.
  void _applyLiveKitRemoteAudioPolicy() {
    try {
      final allowed = <String>{};
      // Include all seated users
      for (final seat in seatList) {
        final uid = seat.currentUser.value?.iduser;
        if (uid != null && uid.isNotEmpty) allowed.add(uid);
      }
      // Always allow music bot(s): add self bot identity and any connected bot identities
      try {
        final selfId = ZEGOSDKManager().currentUser?.iduser;
        if (selfId != null && selfId.isNotEmpty) {
          allowed.add('musicbot_' + selfId);
        }
      } catch (_) {}
      try {
        final parts = LiveKitAudioService.instance.participantsSnapshot();
        for (final p in parts) {
          final id = p.identity;
          if (id.startsWith('musicbot_')) {
            allowed.add(id);
          }
        }
      } catch (_) {}
      LiveKitAudioService.instance.setAllowedRemoteSpeakers(allowed);
    } catch (_) {}
  }
}
