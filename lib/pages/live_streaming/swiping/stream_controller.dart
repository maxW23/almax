import 'package:lklk/core/utils/logger.dart';
import 'package:lklk/features/auth/domain/entities/user_entity.dart';

import '../../../zego_live_streaming_manager.dart';

class ZegoSwipingStreamController {
  bool _isInit = false;

  ZegoLiveStreamingManager? liveStreamingManager;

  void init({
    int cacheCount = 3,
    required ZegoLiveStreamingManager liveStreamingManager,
  }) {
    if (_isInit) {
      return;
    }

    debugAppLogger.debug('stream controller, init');

    this.liveStreamingManager = liveStreamingManager;
    _isInit = true;
  }

  void uninit() {
    if (!_isInit) {
      return;
    }

    debugAppLogger.debug('stream controller, uninit');

    _isInit = false;
    liveStreamingManager = null;
  }

  void playRemoteRoomStream(String roomID, String hostID) {
    final streamID = hostStreamIDFormat(roomID, hostID);
    final streamUser = ZEGOSDKManager().expressService.getRemoteUser(hostID) ??
        UserEntity(
          iduser: hostID,
        );

    debugAppLogger.debug(
        'stream controller, playRoomStream, room id:$roomID, stream id:$streamID, user:$streamUser');

    ZEGOSDKManager()
        .expressService
        .startPlayingAnotherHostStream(streamID, streamUser);
  }
}
