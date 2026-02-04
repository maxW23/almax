import 'dart:async';
import 'package:lklk/core/utils/logger.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:lklk/live_audio_room_manager.dart';
import 'package:lklk/internal/sdk/livekit/livekit_audio_service.dart';
import 'package:lklk/internal/sdk/express/express_service.dart';

typedef RoomStateUpdateCallback = void Function(
    String, ZegoRoomState, int, Map<String, dynamic>);
typedef PublisherStateUpdateCallback = void Function(
    String, ZegoPublisherState, int, Map<String, dynamic>);
typedef PlayerStateUpdateCallback = void Function(
    String, ZegoPlayerState, int, Map<String, dynamic>);
typedef MediaPlayerPlayingProgressCallback = void Function(double);

typedef CapturedSoundLevelUpdateCallback = void Function(double soundLevel);
typedef RemoteSoundLevelUpdateCallback = void Function(
    Map<String, double> soundLevels);
typedef CapturedAudioSpectrumUpdateCallback = void Function(
    List<double> audioSpectrum);
typedef RemoteAudioSpectrumUpdateCallback = void Function(
    Map<String, List<double>> audioSpectrums);
//////////////////////////////////////

///
class ZegoDelegate {
  /////////////////////////////////////////////////////////////
  ///
  ///
  ///
  ///
  /////////////////////////////////////////////////////////////
// ignore: unused_field

  void _initCallback() {
    // Non-audio callbacks (room state etc.) always wired
    ZegoExpressEngine.onRoomStateUpdate = (String roomID, ZegoRoomState state,
        int errorCode, Map<String, dynamic> extendedData) {
      _onRoomStateUpdate?.call(roomID, state, errorCode, extendedData);
    };

    ZegoExpressEngine.onPublisherStateUpdate = (String streamID,
        ZegoPublisherState state,
        int errorCode,
        Map<String, dynamic> extendedData) {
      if (state == ZegoPublisherState.Publishing && errorCode == 0) {}
      if (errorCode != 0) {}
      _onPublisherStateUpdate?.call(streamID, state, errorCode, extendedData);
    };

    ZegoExpressEngine.onPlayerStateUpdate = (String streamID,
        ZegoPlayerState state,
        int errorCode,
        Map<String, dynamic> extendedData) {
      if (state == ZegoPlayerState.Playing && errorCode == 0) {}
      if (errorCode != 0) {}
      _onPlayerStateUpdate?.call(streamID, state, errorCode, extendedData);
    };

    // Audio-related callbacks should be disabled when LiveKit audio is active
    if (!ExpressService.instance.useLiveKitAudio) {
      ZegoExpressEngine.onCapturedSoundLevelUpdate = (double soundLevel) {
        _onCapturedSoundLevelUpdate?.call(soundLevel);
      };

      ZegoExpressEngine.onRemoteSoundLevelUpdate =
          (Map<String, double> soundLevels) {
        _onRemoteSoundLevelUpdate?.call(soundLevels);
      };

      ZegoExpressEngine.onCapturedAudioSpectrumUpdate =
          (List<double> audioSpectrum) {
        _onCapturedAudioSpectrumUpdate?.call(audioSpectrum);
      };

      ZegoExpressEngine.onRemoteAudioSpectrumUpdate =
          (Map<String, List<double>> audioSpectrums) {
        log('ZegoExpressEngine.onRemoteAudioSpectrumUpdate: $audioSpectrums');
        _onRemoteAudioSpectrumUpdate?.call(audioSpectrums);
      };

      ZegoExpressEngine.onMediaPlayerPlayingProgress =
          (ZegoMediaPlayer player, int progress) async {
        _onMediaPlayerPlayingProgress?.call(progress / _totalDurationMediaplayer);
      };

      ZegoExpressEngine.onMediaPlayerRenderingProgress =
          (ZegoMediaPlayer mediaPlayer, int millisecond) async {};

      ZegoExpressEngine.onMediaPlayerFirstFrameEvent =
          (ZegoMediaPlayer player, ZegoMediaPlayerFirstFrameEvent event) async {};
    } else {
      ZegoExpressEngine.onCapturedSoundLevelUpdate = null;
      ZegoExpressEngine.onRemoteSoundLevelUpdate = null;
      ZegoExpressEngine.onCapturedAudioSpectrumUpdate = null;
      ZegoExpressEngine.onRemoteAudioSpectrumUpdate = null;
      ZegoExpressEngine.onMediaPlayerPlayingProgress = null;
      ZegoExpressEngine.onMediaPlayerRenderingProgress = null;
      ZegoExpressEngine.onMediaPlayerFirstFrameEvent = null;
    }
  }

  void setZegoEventCallback({
    RoomStateUpdateCallback? onRoomStateUpdate,
    CapturedSoundLevelUpdateCallback? onCapturedSoundLevelUpdate,
    RemoteSoundLevelUpdateCallback? onRemoteSoundLevelUpdate,
    CapturedAudioSpectrumUpdateCallback? onCapturedAudioSpectrumUpdate,
    RemoteAudioSpectrumUpdateCallback? onRemoteAudioSpectrumUpdate,
    PublisherStateUpdateCallback? onPublisherStateUpdate,
    PlayerStateUpdateCallback? onPlayerStateUpdate,
    MediaPlayerPlayingProgressCallback? onMediaPlayerPlayingProgress,
  }) {
    if (onCapturedSoundLevelUpdate != null) {
      _onCapturedSoundLevelUpdate = onCapturedSoundLevelUpdate;
    }
    if (onRemoteSoundLevelUpdate != null) {
      _onRemoteSoundLevelUpdate = onRemoteSoundLevelUpdate;
    }
    if (onCapturedAudioSpectrumUpdate != null) {
      _onCapturedAudioSpectrumUpdate = onCapturedAudioSpectrumUpdate;
    }

    if (onPublisherStateUpdate != null) {
      _onPublisherStateUpdate = onPublisherStateUpdate;
    }
    if (onPlayerStateUpdate != null) {
      _onPlayerStateUpdate = onPlayerStateUpdate;
    }
    if (onMediaPlayerPlayingProgress != null) {
      _onMediaPlayerPlayingProgress = onMediaPlayerPlayingProgress;
    }
    if (onRoomStateUpdate != null) {
      _onRoomStateUpdate = onRoomStateUpdate;
    }

    if (onRemoteAudioSpectrumUpdate != null) {
      _onRemoteAudioSpectrumUpdate = onRemoteAudioSpectrumUpdate;
    }

    // Bridge LiveKit callbacks to the same delegates so UI keeps receiving updates
    final lk = LiveKitAudioService.instance;
    lk.onCapturedSoundLevelUpdate = (level) {
      _onCapturedSoundLevelUpdate?.call(level);
    };
    lk.onRemoteSoundLevelUpdate = (levels) {
      // UI expects map keys to be streamIDs, not userIDs. Convert to `${roomId}_${userId}`
      try {
        // ExpressService holds the active room id
        final roomId = ExpressService.instance.currentRoomID;
        if (roomId.isEmpty) {
          _onRemoteSoundLevelUpdate?.call(levels);
          return;
        }
        final mapped = <String, double>{};
        levels.forEach((userId, level) {
          if (userId.isNotEmpty) {
            mapped['${roomId}_$userId'] = level;
          }
        });
        _onRemoteSoundLevelUpdate?.call(mapped);
      } catch (_) {
        // Fallback: pass-through
        _onRemoteSoundLevelUpdate?.call(levels);
      }
    };
  }

  Future<void> logoutRoom(String roomID) async {}

  void startPublishing(String streamID, {String? roomID}) async {
    // Guard: only publish if host or actually on a seat
    try {
      final isHost =
          ZegoLiveAudioRoomManager().roleNoti.value == ZegoLiveAudioRoomRole.host;
      final hasSeat = ZegoLiveAudioRoomManager()
          .seatList
          .any((s) => s.currentUser.value?.iduser ==
              ZEGOSDKManager().currentUser?.iduser);
      if (!isHost && !hasSeat) {
        log('🚫 Block startPublishing: user is audience (no seat)');
        return;
      }
    } catch (_) {
      // If any issue in guard, fall back to original behavior
    }
    // Route through ExpressService to respect LiveKit delegation
    if (roomID != null && roomID.isNotEmpty) {
      await ExpressService.instance
          .startPublishingStream(streamID, channel: ZegoPublishChannel.Main);
    } else {
      await ExpressService.instance
          .startPublishingStream(streamID, channel: ZegoPublishChannel.Main);
    }
  }

  /////////////////////////////////////////////////////////////
  ///
  ///
  ///
  ///
  /////////////////////////////////////////////////////////////
  static final ZegoDelegate _instance = ZegoDelegate._internal();
  factory ZegoDelegate() => _instance;
  ZegoDelegate._internal()
      : _preViewID = -1,
        _playViewID = -1,
        _mediaPlayerViewID = -1;
  Future<bool> get isPlaying async {
    final state = await playerState;
    return state == ZegoMediaPlayerState.Playing;
  }

  bool _isInitialized = false;
  ZegoMediaPlayer? _mediaPlayer;
  bool get isInitialized => _mediaPlayer != null;

  Future<void> stopMediaPlayer() async {
    if (_mediaPlayer != null) {
      await _mediaPlayer!.stop();
    }
  }

  Future<ZegoMediaPlayerState> get playerState async {
    if (_mediaPlayer != null) {
      return await _mediaPlayer!.getCurrentState();
    }
    return ZegoMediaPlayerState.NoPlay;
  }

  late int _preViewID;
  late int _playViewID;
  int _mediaPlayerViewID;

  Widget? preWidget;
  Widget? playWidget;
  Widget? mediaPlayerWidget;

  dispose() {
    if (_preViewID != -1) {
      ZegoExpressEngine.instance.destroyCanvasView(_preViewID);
      _preViewID = -1;
    }
    if (_playViewID != -1) {
      ZegoExpressEngine.instance.destroyCanvasView(_playViewID);
      _playViewID = -1;
    }
    if (_mediaPlayerViewID != -1) {
      ZegoExpressEngine.instance.destroyCanvasView(_mediaPlayerViewID);
      _mediaPlayerViewID = -1;
    }
  }

  void clearZegoEventCallback() {
    _onRoomStateUpdate = null;
    ZegoExpressEngine.onRoomStateUpdate = null;

    _onPublisherStateUpdate = null;
    ZegoExpressEngine.onPublisherStateUpdate = null;

    _onPlayerStateUpdate = null;
    ZegoExpressEngine.onPlayerStateUpdate = null;

    _onMediaPlayerPlayingProgress = null;
    ZegoExpressEngine.onMediaPlayerPlayingProgress = null;
  }

  Future<void> createEngine({bool? enablePlatformView}) async {
    _initCallback();
  } //123412341234
  // Future<void> createEngine({bool? enablePlatformView}) async {
  //   _initCallback();

  //   await ZegoExpressEngine.destroyEngine();

  //   enablePlatformView =
  //       enablePlatformView ?? ZegoConfig.instance.enablePlatformView;
  //   ZegoEngineProfile profile = ZegoEngineProfile(
  //       SDKKeyCenter.appID, ZegoConfig.instance.scenario,
  //       enablePlatformView: enablePlatformView,
  //       appSign: kIsWeb ? null : SDKKeyCenter.appSign);
  //   await ZegoExpressEngine.createEngineWithProfile(profile);
  // }

  void destroyEngine() {
    ZegoExpressEngine.destroyEngine();
  }

  String roomStateDesc(ZegoRoomState roomState) {
    String result = 'Unknown';
    switch (roomState) {
      case ZegoRoomState.Disconnected:
        result = "Disconnected 🔴";
        break;
      case ZegoRoomState.Connecting:
        result = "Connecting 🟡";
        break;
      case ZegoRoomState.Connected:
        result = "Connected 🟢";
        break;
      default:
        result = "Unknown";
    }
    return result;
  }

  // Future<void> loginRoom(String roomID) async {
  //   if (roomID.isNotEmpty) {}
  // }

  void stopPublishing() {
    // Route through ExpressService to respect LiveKit delegation
    ExpressService.instance.stopPublishingStream();
  }

  Future<Widget?> startPlaying(String streamID,
      {String? cdnURL, bool needShow = true, String? roomID}) async {
    // Ensure all playback goes through ExpressService so LiveKit delegation is respected
    try {
      await ExpressService.instance.startPlayingStream(streamID);
    } catch (_) {}
    // In LiveKit mode, skip creating any Zego playback surfaces or audio
    if (ExpressService.instance.useLiveKitAudio) {
      return null;
    }
    playFunc(int viewID) {
      ZegoCDNConfig? cdnConfig;
      if (cdnURL != null) {
        cdnConfig = ZegoCDNConfig(cdnURL);
      }

      if (needShow) {
        ZegoExpressEngine.instance.startPlayingStream(streamID,
            canvas: ZegoCanvas(viewID, backgroundColor: 0xffffff),
            config: ZegoPlayerConfig(ZegoStreamResourceMode.Default,
                videoCodecID: ZegoVideoCodecID.Default,
                cdnConfig: cdnConfig,
                roomID: roomID));
      } else {
        ZegoExpressEngine.instance.startPlayingStream(
          streamID,
        );
      }
    }

    if (streamID.isNotEmpty) {
      if (_playViewID == -1 && needShow) {
        playWidget =
            await ZegoExpressEngine.instance.createCanvasView((viewID) {
          _playViewID = viewID;
          playFunc(_playViewID);
        });
      } else {
        playFunc(_playViewID);
      }
    }
    return playWidget;
  }

  void stopPlaying(String streamID) {
    // Route through ExpressService; it will no-op under LiveKit mode
    ExpressService.instance.stopPlayingStream(streamID);
  }

  // ZegoMediaPlayer? _mediaPlayer;
  int _totalDurationMediaplayer = 0;
  Future<void> createMediaPlayer() async {
    if (_isInitialized) return;

    if (_mediaPlayer != null) {
      await destroyMediaPlayer();
    }

    _mediaPlayer = await ZegoExpressEngine.instance.createMediaPlayer();
    _isInitialized = true;
  }

  Future<void> destroyMediaPlayer() async {
    if (_mediaPlayer != null) {
      await ZegoExpressEngine.instance.destroyMediaPlayer(_mediaPlayer!);
      _mediaPlayer = null;
      _isInitialized = false;
    }
  }

  // 0 <= progress <=1
  Future<int> seekToMediaPlayer(double progress) async {
    int ret = -1;

    if (_mediaPlayer != null) {
      int millisecond = (_totalDurationMediaplayer * progress).toInt();
      var result = await _mediaPlayer!.seekTo(millisecond);
      ret = result.errorCode;
    }

    return ret;
  }

  Future<int> loadResourceMediaPlayer(
      String url, ZegoAlphaLayoutType layoutType) async {
    int ret = -1;
    if (_mediaPlayer != null) {
      ZegoMediaPlayerLoadResourceResult result;
      if (kIsWeb) {
        result = await _mediaPlayer!.loadResource(url);
      } else {
        ZegoMediaPlayerResource source =
            ZegoMediaPlayerResource.defaultConfig();
        source.filePath = url;
        source.loadType = ZegoMultimediaLoadType.FilePath;
        source.alphaLayout = layoutType;
        result = await _mediaPlayer!.loadResourceWithConfig(source);
      }
      ret = result.errorCode;
    }
    if (ret == 0) {
      _totalDurationMediaplayer = await _mediaPlayer!.getTotalDuration();
    }

    return ret;
  }

  Future<int> loadResourceWithPositionMediaPlayer(
      String path, int startPosition, ZegoAlphaLayoutType layoutType) async {
    int ret = -1;
    if (_mediaPlayer != null) {
      ZegoMediaPlayerLoadResourceResult result;

      ZegoMediaPlayerResource source = ZegoMediaPlayerResource.defaultConfig();
      source.filePath = path;
      source.loadType = ZegoMultimediaLoadType.FilePath;
      source.alphaLayout = layoutType;

      result =
          await _mediaPlayer!.loadResourceWithPosition(path, startPosition);
      ret = result.errorCode;
    }
    if (ret == 0) {
      _totalDurationMediaplayer = await _mediaPlayer!.getTotalDuration();
    }

    return ret;
  }

  // ignore: unused_field
  RoomStateUpdateCallback? _onRoomStateUpdate;
  PublisherStateUpdateCallback? _onPublisherStateUpdate;
  PlayerStateUpdateCallback? _onPlayerStateUpdate;
  MediaPlayerPlayingProgressCallback? _onMediaPlayerPlayingProgress;
  CapturedSoundLevelUpdateCallback? _onCapturedSoundLevelUpdate;
  RemoteSoundLevelUpdateCallback? _onRemoteSoundLevelUpdate;
  CapturedAudioSpectrumUpdateCallback? _onCapturedAudioSpectrumUpdate;
  RemoteAudioSpectrumUpdateCallback? _onRemoteAudioSpectrumUpdate;

  Future<void> startAudioSpectrumMonitor() async {
    if (ExpressService.instance.useLiveKitAudio) {
      log('startAudioSpectrumMonitor skipped (LiveKit audio mode)');
      return;
    }
    await ZegoExpressEngine.instance.startAudioSpectrumMonitor();
  }

  void stopAudioSpectrumMonitor() {
    if (ExpressService.instance.useLiveKitAudio) {
      log('stopAudioSpectrumMonitor skipped (LiveKit audio mode)');
      return;
    }
    ZegoExpressEngine.instance.stopAudioSpectrumMonitor();
  }

  Future<void> startSoundLevelMonitor() async {
    // Delegate to ExpressService; it will call LiveKit or Zego depending on mode
    await ExpressService.instance.startSoundLevelMonitor();
  }

  void stopSoundLevelMonitor() {
    // Delegate to ExpressService; it will call LiveKit or Zego depending on mode
    ExpressService.instance.stopSoundLevelMonitor();
  }
  /////////////////////////////////////////////////////////////////
  /////////////////////////////////////////////////////////////////
  // 0 <= progress <=1

  void startMediaPlayer() {
    if (_mediaPlayer != null) {
      _mediaPlayer!.start();
    }
  }

  void pauseMediaPlayer() {
    if (_mediaPlayer != null) {
      _mediaPlayer!.pause();
    }
  }

  void resumeMediaPlayer() {
    if (_mediaPlayer != null) {
      _mediaPlayer!.resume();
    }
  }

  void setVolumeMediaPlayer(double volume) {
    if (_mediaPlayer != null) {
      _mediaPlayer!.setVolume((200 * volume).toInt());
    }
  }

  void repeatMediaPlayer(bool enable) {
    if (_mediaPlayer != null) {
      _mediaPlayer!.enableRepeat(enable);
    }
  }

  void enableAuxMediaPlayer(bool enable) {
    if (_mediaPlayer != null) {
      _mediaPlayer!.enableAux(enable);
    }
  }

  void muteLocalMediaPlayer(bool mute) {
    if (_mediaPlayer != null) {
      _mediaPlayer!.muteLocal(mute);
    }
  }

  void setAudioTrackIndexMediaPlayer(int index) {
    if (_mediaPlayer != null) {
      _mediaPlayer!.setAudioTrackIndex(index);
    }
  }

  void setVoiceChangerParamMediaPlayer(double value) {
    if (_mediaPlayer != null) {
      // ignore: deprecated_member_use
      _mediaPlayer!.setVoiceChangerParam(
          ZegoMediaPlayerAudioChannel.All, ZegoVoiceChangerParam(value));
    }
  }

  void setPlaySpeedMediaPlayer(double speed) {
    if (_mediaPlayer != null) {
      _mediaPlayer!.setPlaySpeed(speed);
    }
  }

  void updatePosition(Float32List position) {
    if (_mediaPlayer != null) {
      _mediaPlayer!.updatePosition(position);
    }
  }

  Future<ZegoMediaPlayerMediaInfo?> getMediaInfo() async {
    if (_mediaPlayer != null) {
      ZegoMediaPlayerMediaInfo info = await _mediaPlayer!.getMediaInfo();
      return info;
    }
    return null;
  }
}
// Future<bool> loginRoom(String roomID, String userID, String userName) async {
//   try {
//     if (roomID.isEmpty) return false;
//     ZegoUser user = ZegoUser(userID, userName);
//     ZegoRoomConfig config = ZegoRoomConfig.defaultConfig();

//     if (kIsWeb) {
//       config.token = ZegoTokenUtils.generateToken(
//         SDKKeyCenter.appID,
//         SDKKeyCenter.serverSecret,
//         ZEGOSDKManager().currentUser!.iduser!,
//       );
//     }

//     await ZegoExpressEngine.instance.loginRoom(roomID, user, config: config);
//     return true;
//   } catch (e) {
//     AppLogger.debug("Login room failed: $e");
//     return false;
//   }
// }

// Future<void> logoutRoom(String roomID) async {
//   if (roomID.isNotEmpty) {
//     await ZegoExpressEngine.instance.logoutRoom(roomID);
//   }
// }

// Future<Widget?> startPublishing(String streamID, {String? roomID}) async {
//   ZegoExpressEngine.instance.startPreview();
//   if (roomID != null) {
//     ZegoExpressEngine.instance.startPublishingStream(streamID,
//         config: ZegoPublisherConfig(roomID: roomID));
//   } else {
//     ZegoExpressEngine.instance.startPublishingStream(streamID);
//   }
//   publishFunc(int viewID) {
//     ZegoExpressEngine.instance
//         .startPreview(canvas: ZegoCanvas(viewID, backgroundColor: 0xffffff));
//     if (roomID != null) {
//       ZegoExpressEngine.instance.startPublishingStream(streamID,
//           config: ZegoPublisherConfig(roomID: roomID));
//     } else {
//       ZegoExpressEngine.instance.startPublishingStream(streamID);
//     }
//   }

//   if (streamID.isNotEmpty) {
//     if (_preViewID == -1) {
//       preWidget = await ZegoExpressEngine.instance.createCanvasView((viewID) {
//         _preViewID = viewID;
//         publishFunc(_preViewID);
//       });
//     } else {
//       publishFunc(_preViewID);
//     }
//   }
//   return preWidget;
// }

// void stopMediaPlayer() {
//   if (_mediaPlayer != null) {
//     _mediaPlayer!.stop();
//   }
// }
