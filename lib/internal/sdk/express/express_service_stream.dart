part of 'express_service.dart';

extension ExpressServiceStream on ExpressService {
  ZegoViewMode get streamPlayViewMode => ZegoViewMode.AspectFill;

  Future<void> stopPlayingStream(String streamID) async {
    // Skip Zego stop when LiveKit audio is active; LiveKit manages subscriptions separately
    AppLogger.debug('stopPlayingStream($streamID) useLiveKitAudio=$useLiveKitAudio',
        tag: 'ExpressService');
    if (useLiveKitAudio) {
      AppLogger.debug('stopPlayingStream skipped for $streamID (LiveKit manages audio)',
          tag: 'ExpressService');
      return;
    }
    final userID = streamMap[streamID];
    var userInfo = getUser(userID ?? '');
    userInfo ??= getRemoteUser(userID ?? '');
    if (userInfo != null) {
      userInfo.streamID = '';
      userInfo.videoViewNotifier.value = null;
      userInfo.viewID = -1;
    }
    AppLogger.info('Stopping Zego playback for $streamID', tag: 'ExpressService');
    await ZegoExpressEngine.instance.stopPlayingStream(streamID);
  }

  Future<void> startPreview({viewMode = ZegoViewMode.AspectFill}) async {
    if (useLiveKitAudio) {
      // No preview needed for audio-only LiveKit migration
      AppLogger.debug('startPreview skipped (LiveKit audio mode)', tag: 'ExpressService');
      return;
    }
    if (currentUser != null) {
      AppLogger.info('Creating preview canvas (viewMode=$viewMode)', tag: 'ExpressService');
      await ZegoExpressEngine.instance.createCanvasView((viewID) async {
        currentUser!.viewID = viewID;
        final previewCanvas = ZegoCanvas(
          currentUser!.viewID,
          viewMode: viewMode,
        );
        await ZegoExpressEngine.instance.startPreview(canvas: previewCanvas);
      }).then((videoViewWidget) {
        currentUser!.videoViewNotifier.value = videoViewWidget;
      });
    }
  }

  Future<void> stopPreview() async {
    if (useLiveKitAudio) {
      AppLogger.debug('stopPreview skipped (LiveKit audio mode)', tag: 'ExpressService');
      return;
    }
    currentUser!.videoViewNotifier.value = null;
    currentUser!.viewID = -1;
    AppLogger.info('Stopping Zego preview', tag: 'ExpressService');
    await ZegoExpressEngine.instance.stopPreview();
  }

  Future<void> updateStreamExtraInfo() async {
    if (kIsWeb && (publisherState.value != ZegoPublisherState.Publishing)) {
      return;
    }
    final extraInfo = jsonEncode({
      'mic': currentUser!.isMicOnNotifier.value ? 'on' : 'off',
      'cam': currentUser!.isCameraOnNotifier.value ? 'on' : 'off',
    });
    await ZegoExpressEngine.instance.setStreamExtraInfo(extraInfo);
  }

  Future<void> startPublishingStream(String streamID,
      {ZegoPublishChannel channel = ZegoPublishChannel.Main}) async {
    currentUser!.streamID = streamID;
    debugAppLogger.debug('startPublishingStream:$streamID');
    await updateStreamExtraInfo();
    if (useLiveKitAudio) {
      AppLogger.info('startPublishingStream($streamID) via LiveKit -> enable mic',
          tag: 'ExpressService');
      await _lk.setMicrophoneEnabled(true, reason: 'startPublishingStream');
      return;
    }
    AppLogger.info('Starting Zego publishing streamID=$streamID channel=$channel',
        tag: 'ExpressService');
    await ZegoExpressEngine.instance
        .startPublishingStream(streamID, channel: channel);
  }

  Future<void> stopPublishingStream({ZegoPublishChannel? channel}) async {
    currentUser!.streamID = null;
    currentUser!.isCameraOnNotifier.value = false;
    currentUser!.isMicOnNotifier.value = false;
    if (useLiveKitAudio) {
      AppLogger.info('stopPublishingStream via LiveKit -> disable mic',
          tag: 'ExpressService');
      await _lk.setMicrophoneEnabled(false, reason: 'stopPublishingStream');
      return;
    }
    AppLogger.info('Stopping Zego publishing', tag: 'ExpressService');
    await ZegoExpressEngine.instance.stopPublishingStream();
  }

  Future<void> mutePlayStreamAudio(String streamID, bool mute) async {
    // Skip per-stream mute toggles entirely in LiveKit mode
    AppLogger.debug('mutePlayStreamAudio(streamID=$streamID, mute=$mute) useLiveKitAudio=$useLiveKitAudio',
        tag: 'ExpressService');
    if (useLiveKitAudio) {
      AppLogger.debug('mutePlayStreamAudio skipped (LiveKit audio mode)', tag: 'ExpressService');
      return;
    }
    ZegoExpressEngine.instance.mutePlayStreamAudio(streamID, mute);
  }

  Future<void> mutePlayStreamVideo(String streamID, bool mute) async {
    AppLogger.debug('mutePlayStreamVideo(streamID=$streamID, mute=$mute)',
        tag: 'ExpressService');
    ZegoExpressEngine.instance.mutePlayStreamVideo(streamID, mute);
  }

  Future<void> onRoomStreamUpdate(
    String roomID,
    ZegoUpdateType updateType,
    List<ZegoStream> streamList,
    Map<String, dynamic> extendedData,
  ) async {
    debugAppLogger.debug('onRoomStreamUpdate,'
        'roomID:$roomID, '
        'updateType:$updateType, '
        'streamList:${streamList.map((e) => 'user id:${e.user.userID}, stream id:${e.streamID}, ')}, '
        'extendedData:$extendedData, ');

    // Ignore updates from stale rooms to prevent audio/UI leakage
    if (roomID != currentRoomID || currentRoomID.isEmpty) {
      debugAppLogger.debug(
          'Ignoring stream update for stale room $roomID (current: $currentRoomID)');
      return;
    }

    for (final stream in streamList) {
      if (updateType == ZegoUpdateType.Add) {
        streamMap[stream.streamID] = stream.user.userID;
        var userInfo = getUser(stream.user.userID);
        if (userInfo == null) {
          /// re-use from remote user object
          userInfo = getRemoteUser(stream.user.userID);

          userInfo ??= UserEntity(
              iduser: stream.user.userID, name: stream.user.userName);

          userInfoList.add(userInfo);
        }
        if (userInfo.name!.isEmpty) {
          userInfo.name = stream.user.userName;
        }
        userInfo.streamID = stream.streamID;

        try {
          final Map<String, dynamic> extraInfoMap =
              convert.jsonDecode(stream.extraInfo);
          final isMicOn = extraInfoMap['mic'] == 'on';
          final isCameraOn = extraInfoMap['cam'] == 'on';
          userInfo.isCameraOnNotifier.value = isCameraOn;
          userInfo.isMicOnNotifier.value = isMicOn;
        } catch (e) {
          debugAppLogger.debug('stream.extraInfo: ${stream.extraInfo}.');
        }

        startPlayingStream(stream.streamID);
      } else {
        streamMap[stream.streamID] = '';
        final userInfo = getUser(stream.user.userID);
        userInfo?.streamID = '';
        userInfo?.isCameraOnNotifier.value = false;
        userInfo?.isMicOnNotifier.value = false;
        stopPlayingStream(stream.streamID);
      }
    }
    streamListUpdateStreamCtrl.add(ZegoRoomStreamListUpdateEvent(
        roomID, updateType, streamList, extendedData));
  }

  Future<void> startPlayingAnotherHostStream(
    String streamID,
    UserEntity anotherHost,
  ) async {
    // Do not start any Zego playback when LiveKit audio is active
    if (useLiveKitAudio) {
      AppLogger.debug('startPlayingAnotherHostStream skipped (LiveKit audio mode) streamID=$streamID',
          tag: 'ExpressService');
      return;
    }
    AppLogger.info('Start playing another host stream streamID=$streamID for user=${anotherHost.iduser}',
        tag: 'ExpressService');
    anotherHost.isCameraOnNotifier.value = true;
    anotherHost.isMicOnNotifier.value = true;

    if (null == getRemoteUser(anotherHost.iduser)) {
      remoteStreamUserInfoListNotifier.value.add(anotherHost);
    }
    remoteStreamUserInfoListNotifier.value =
        List.from(remoteStreamUserInfoListNotifier.value);

    if (anotherHost.viewID != -1) {
      final canvas =
          ZegoCanvas(anotherHost.viewID, viewMode: streamPlayViewMode);
      await ZegoExpressEngine.instance
          .startPlayingStream(streamID, canvas: canvas);
    } else {
      await ZegoExpressEngine.instance.createCanvasView((viewID) async {
        anotherHost.viewID = viewID;
        final canvas =
            ZegoCanvas(anotherHost.viewID, viewMode: streamPlayViewMode);
        await ZegoExpressEngine.instance
            .startPlayingStream(streamID, canvas: canvas);
      }).then((videoViewWidget) {
        anotherHost.videoViewNotifier.value = videoViewWidget;
      });
    }
  }

  Future<void> startPlayingMixerStream(String streamID) async {
    // Skip mixer playback in LiveKit mode
    if (useLiveKitAudio) {
      AppLogger.debug('startPlayingMixerStream skipped (LiveKit audio mode) streamID=$streamID',
          tag: 'ExpressService');
      return;
    }
    AppLogger.info('Start playing mixer stream streamID=$streamID', tag: 'ExpressService');
    await ZegoExpressEngine.instance.createCanvasView((viewID) async {
      final canvas = ZegoCanvas(viewID, viewMode: streamPlayViewMode);
      await ZegoExpressEngine.instance.startPlayingStream(
        streamID,
        canvas: canvas,
      );
    }).then((videoViewWidget) {
      mixerStreamNotifier.value = videoViewWidget;
    });
  }

  Future<void> stopPlayingMixerStream(String streamID) async {
    if (useLiveKitAudio) {
      // Nothing to stop in Zego when LiveKit is active
      mixerStreamNotifier.value = null;
      AppLogger.debug('stopPlayingMixerStream skipped (LiveKit audio mode) streamID=$streamID',
          tag: 'ExpressService');
      return;
    }
    AppLogger.info('Stop playing mixer stream streamID=$streamID', tag: 'ExpressService');
    await ZegoExpressEngine.instance.stopPlayingStream(streamID).then((value) {
      mixerStreamNotifier.value = null;
    });
  }

///////////////// 123
  ///
  ///
  void startAudioSpectrumMonitor() {
    if (useLiveKitAudio) {
      AppLogger.debug('startAudioSpectrumMonitor skipped (LiveKit audio mode)',
          tag: 'ExpressService');
      return;
    }
    ZegoExpressEngine.instance.startAudioSpectrumMonitor();
  }

  void stopAudioSpectrumMonitor() {
    if (useLiveKitAudio) {
      AppLogger.debug('stopAudioSpectrumMonitor skipped (LiveKit audio mode)',
          tag: 'ExpressService');
      return;
    }
    ZegoExpressEngine.instance.stopAudioSpectrumMonitor();
  }
//  void startSoundLevelMonitor() {
//     ZegoExpressEngine.instance.startSoundLevelMonitor();
//   }

//   void stopSoundLevelMonitor() {
//     ZegoExpressEngine.instance.stopSoundLevelMonitor();
//   }

  ///123
  Future<void> startSoundLevelMonitor({int millisecond = 1000}) async {
    if (useLiveKitAudio) {
      AppLogger.info('startSoundLevelMonitor via LiveKit intervalMs=$millisecond',
          tag: 'ExpressService');
      await _lk.startSoundLevelMonitor(
          interval: Duration(milliseconds: millisecond));
      return;
    }
    final config = ZegoSoundLevelConfig(millisecond, false);
    AppLogger.info('startSoundLevelMonitor via Zego intervalMs=$millisecond',
        tag: 'ExpressService');
    ZegoExpressEngine.instance.startSoundLevelMonitor(config: config);
  }

  Future<void> stopSoundLevelMonitor() async {
    if (useLiveKitAudio) {
      AppLogger.info('stopSoundLevelMonitor via LiveKit', tag: 'ExpressService');
      await _lk.stopSoundLevelMonitor();
      return;
    }
    AppLogger.info('stopSoundLevelMonitor via Zego', tag: 'ExpressService');
    ZegoExpressEngine.instance.stopSoundLevelMonitor();
  }

  void onCapturedSoundLevelUpdate(double soundLevel) {}

  void onRemoteSoundLevelUpdate(Map<String, double> soundLevels) {}

  void onPlayerRecvAudioFirstFrame(String streamID) {
    AppLogger.debug('onPlayerRecvAudioFirstFrame streamID=$streamID',
        tag: 'ExpressService');
    recvAudioFirstFrameCtrl.add(ZegoRecvAudioFirstFrameEvent(streamID));
  }

  void onPlayerRecvVideoFirstFrame(String streamID) {
    AppLogger.debug('onPlayerRecvVideoFirstFrame streamID=$streamID',
        tag: 'ExpressService');
    recvVideoFirstFrameCtrl.add(ZegoRecvVideoFirstFrameEvent(streamID));
  }

  void onPlayerRecvSEI(String streamID, Uint8List data) {
    AppLogger.debug('onPlayerRecvSEI streamID=$streamID bytes=${data.length}',
        tag: 'ExpressService');
    recvSEICtrl.add(ZegoRecvSEIEvent(streamID, data));
  }

  void onRoomStreamExtraInfoUpdate(String roomID, List<ZegoStream> streamList) {
    // Ignore updates not belonging to the current active room
    if (roomID != currentRoomID || currentRoomID.isEmpty) {
      return;
    }
    AppLogger.debug('onRoomStreamExtraInfoUpdate roomID=$roomID count=${streamList.length}',
        tag: 'ExpressService');
    for (final user in userInfoList) {
      for (final stream in streamList) {
        if (stream.streamID == user.streamID) {
          try {
            final Map<String, dynamic> extraInfoMap =
                convert.jsonDecode(stream.extraInfo);
            final isMicOn = extraInfoMap['mic'] == 'on';
            final isCameraOn = extraInfoMap['cam'] == 'on';
            user.isCameraOnNotifier.value = isCameraOn;
            user.isMicOnNotifier.value = isMicOn;
          } catch (e) {
            debugAppLogger.debug('stream.extraInfo: ${stream.extraInfo}.');
          }
        }
      }
    }
    roomStreamExtraInfoStreamCtrl
        .add(ZegoRoomStreamExtraInfoEvent(roomID, streamList));
  }

  void onPublisherStateUpdate(String streamID, ZegoPublisherState state,
      int errorCode, Map<String, dynamic> extendedData) {
    publisherState.value = state;
    AppLogger.info('onPublisherStateUpdate streamID=$streamID state=$state error=$errorCode',
        tag: 'ExpressService');
    if (kIsWeb && state == ZegoPublisherState.Publishing) {
      updateStreamExtraInfo();
    }
  }
}
