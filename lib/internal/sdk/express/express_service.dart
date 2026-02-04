import 'dart:async';
import 'dart:convert' as convert;
import 'dart:convert';
// import 'package:lklk/core/utils/logger.dart';
import 'dart:io';

import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:lklk/core/utils/logger.dart';
import 'package:lklk/features/auth/domain/entities/user_entity.dart';
import 'package:dio/dio.dart';
import 'package:lklk/core/config/app_config.dart';
import 'package:lklk/core/services/auth_service.dart';

import '../../internal_defines.dart';
import 'express_service.dart';
import '../livekit/livekit_audio_service.dart';

export 'package:zego_express_engine/zego_express_engine.dart';

export '../../internal_defines.dart';

part 'express_service_media.dart';
part 'express_service_mixer.dart';
part 'express_service_room_extra_info.dart';
part 'express_service_sei.dart';
part 'express_service_stream.dart';

class ExpressService {
  ExpressService._internal();

  factory ExpressService() => instance;
  static final ExpressService instance = ExpressService._internal();

  String currentRoomID = '';
  ZegoRoomStateChangedReason currentRoomState =
      ZegoRoomStateChangedReason.Logout;
  UserEntity? currentUser;
  List<UserEntity> userInfoList = [];
  var remoteStreamUserInfoListNotifier = ValueNotifier<List<UserEntity>>([]);
  Map<String, String> streamMap = {};
  ZegoMixerTask? currentMixerTask;
  ValueNotifier<Widget?> mixerStreamNotifier = ValueNotifier(null);
  ZegoScenario currentScenario = ZegoScenario.Default;
  ValueNotifier<ZegoPublisherState> publisherState =
      ValueNotifier<ZegoPublisherState>(ZegoPublisherState.NoPublish);
  // When true, ignore incoming room callbacks to prevent stale updates during switch/logout
  bool suppressRoomCallbacks = false;
  // When true, delegate audio to LiveKit instead of Zego while preserving the same app logic
  bool useLiveKitAudio = false;
  LiveKitAudioService get _lk => LiveKitAudioService.instance;

  void enableLiveKitAudio(bool enable) {
    useLiveKitAudio = enable;
    AppLogger.info(
        'LiveKit audio delegation set to: ${enable ? 'ENABLED' : 'DISABLED'}',
        tag: 'ExpressService');
  }

  Future<String?> _fetchLiveKitToken(String roomID) async {
    final identity = currentUser?.iduser;
    if (identity == null || identity.isEmpty) return null;
    final url = AppConfig.getApiEndpoint('/livekit/token');
    try {
      final dio = Dio(BaseOptions(
        connectTimeout: const Duration(seconds: 10),
        receiveTimeout: const Duration(seconds: 10),
      ));
      String? bearer;
      try {
        bearer = await AuthService.getTokenFromSharedPreferences();
      } catch (_) {}
      final resp = await dio.get(url,
          queryParameters: {'identity': identity, 'room': roomID},
          options: (bearer != null && bearer.isNotEmpty)
              ? Options(headers: {'Authorization': 'Bearer $bearer'})
              : null);
      final data = resp.data;
      if (data is Map && data['token'] is String) return data['token'] as String;
      if (data is String && data.contains('.')) return data;
    } catch (e) {
      AppLogger.error('LiveKit token fetch failed', tag: 'ExpressService', error: e as Object?);
    }
    return null;
  }

  void clearRoomData() {
    currentScenario = ZegoScenario.Default;
    currentRoomID = '';
    currentRoomState = ZegoRoomStateChangedReason.Logout;
    userInfoList.clear();
    // remoteStreamUserInfoListNotifier.value = <ZegoSDKUser>[];
    clearLocalUserData();
    streamMap.clear();
    currentMixerTask = null;
    mixerStreamNotifier.value = null;
  }

  Future<void> uploadLog() {
    return ZegoExpressEngine.instance.uploadLog();
  }

  Future<void> init({
    required int appID,
    String? appSign,
    ZegoScenario scenario = ZegoScenario.Default,
  }) async {
    initEventHandle();
    ZegoExpressEngine.setEngineConfig(
        ZegoEngineConfig(advancedConfig: {'vcap_external_mem_class': '1'}));
    final profile = ZegoEngineProfile(appID, scenario, appSign: appSign);
    if (Platform.isIOS) {
      profile.enablePlatformView = true;
    }

    currentScenario = scenario;
    await ZegoExpressEngine.createEngineWithProfile(profile);
    ZegoExpressEngine.instance.enableHardwareEncoder(true);
    ZegoExpressEngine.instance.enableHardwareDecoder(true);
    ZegoExpressEngine.setEngineConfig(ZegoEngineConfig(advancedConfig: {
      'notify_remote_device_unknown_status': 'true',
      'notify_remote_device_init_status': 'true',
      'keep_audio_session_active': 'true',
    }));
  }

  Future<void> uninit() async {
    uninitEventHandle();
    await ZegoExpressEngine.destroyEngine();
  }

  Future<void> connectUser(UserEntity user, {String? token}) async {
    currentUser = user;
  }

  Future<void> disconnectUser() async {
    currentUser = null;
  }

  UserEntity? getUser(String userID) {
    for (final user in userInfoList) {
      if (user.iduser == userID) {
        return user;
      }
    }

    return null;
  }

  UserEntity? getRemoteUser(String userID) {
    for (final user in remoteStreamUserInfoListNotifier.value) {
      if (user.iduser == userID) {
        return user;
      }
    }

    return null;
  }

  Future<void> setRoomScenario(ZegoScenario scenario) async {
    // Skip if scenario unchanged
    if (scenario == currentScenario) {
      AppLogger.debug('setRoomScenario skipped: unchanged ($scenario)',
          tag: 'ExpressService');
      return;
    }
    // Avoid changing scenario while already logged in or connecting to a room
    final inRoom = currentRoomID.isNotEmpty &&
        currentRoomState != ZegoRoomStateChangedReason.Logout;
    if (inRoom) {
      AppLogger.debug(
          'setRoomScenario skipped while in-room. Current: $currentScenario, Requested: $scenario',
          tag: 'ExpressService');
      return;
    }

    currentScenario = scenario;
    await ZegoExpressEngine.instance.setRoomScenario(scenario);
  }

  Future<ZegoRoomLoginResult> loginRoom(String roomID, {String? token}) async {
    assert(!kIsWeb || token != null, 'token is required for web platform!');

    AppLogger.debug(
        'ready loginRoom, current room id:$currentRoomID, target room id:$roomID',
        tag: 'ExpressService');

    // Extra safety: ensure remote audio is muted before starting a new login
    try {
      await ZegoExpressEngine.instance.muteAllPlayAudioStreams(true);
    } catch (_) {}

    currentRoomID = roomID;

    final joinRoomResult = await ZegoExpressEngine.instance.loginRoom(
      roomID,
      ZegoUser(currentUser!.iduser, currentUser!.name!),
      config: ZegoRoomConfig(0, true, token ?? ''),
    );
    AppLogger.debug('loginRoom, id:$roomID, result:${joinRoomResult.errorCode}',
        tag: 'ExpressService');
    if (joinRoomResult.errorCode != 0) {
      currentRoomID = '';
    } else {
      // If LiveKit is being used for audio, keep Zego audio globally muted
      if (!useLiveKitAudio) {
        AppLogger.debug(
            'Using Zego for audio in this session: unmuting global play streams',
            tag: 'ExpressService');
        try {
          await ZegoExpressEngine.instance.muteAllPlayAudioStreams(false);
        } catch (_) {}
      }
      // Re-enable callbacks for the active room
      suppressRoomCallbacks = false;
      // Optionally connect LiveKit audio if explicitly configured; auto-fetch token if needed
      try {
        final hasServer = _lk.serverUrl != null && _lk.serverUrl!.isNotEmpty;
        if (useLiveKitAudio && hasServer) {
          String? lkToken =
              (token != null && token.contains('.')) ? token : await _fetchLiveKitToken(roomID);
          if (lkToken != null && lkToken.contains('.')) {
            AppLogger.info(
                'LiveKit: connecting to room=$roomID server=${_lk.serverUrl}',
                tag: 'ExpressService');
            await _lk.loginRoom(roomID, token: lkToken);
            AppLogger.info('LiveKit: connected to room=$roomID',
                tag: 'ExpressService');
          }
        }
      } catch (e) {
        AppLogger.error('LiveKit login failed', tag: 'ExpressService', error: e as Object?);
        // Fallback: re-enable Zego audio this session to avoid silent room
        try {
          useLiveKitAudio = false;
          await ZegoExpressEngine.instance.muteAllPlayAudioStreams(false);
          // Rewire Zego audio callbacks now that LiveKit is disabled
          initEventHandle();
          AppLogger.info('LiveKit fallback engaged: using Zego audio for room=$roomID',
              tag: 'ExpressService');
          // Stop LiveKit sound-level monitor if running
          try { await _lk.stopSoundLevelMonitor(); } catch (_) {}
          // Resume playing any known remote streams via Zego
          try {
            final toPlay = List<String>.from(streamMap.keys);
            for (final sid in toPlay) {
              try { await startPlayingStream(sid); } catch (_) {}
            }
          } catch (_) {}
          // If a publish was intended, start Zego publishing with the same streamID
          try {
            final sid = currentUser?.streamID;
            if (sid != null && sid.isNotEmpty) {
              AppLogger.info('Fallback: starting Zego publishing for streamID=$sid', tag: 'ExpressService');
              await ZegoExpressEngine.instance.startPublishingStream(sid);
            }
          } catch (_) {}
        } catch (_) {}
      }
    }

    return joinRoomResult;
  }

  Future<ZegoRoomLogoutResult> logoutRoom([String roomID = '']) async {
    AppLogger.debug('ready logoutRoom, room id:$currentRoomID',
        tag: 'ExpressService');

    final targetRoomID = roomID.isNotEmpty ? roomID : currentRoomID;
    // Suppress callbacks immediately to avoid late events re-starting playback
    suppressRoomCallbacks = true;

    // Immediately mute all remote audio to avoid hearing previous room
    try {
      await ZegoExpressEngine.instance.muteAllPlayAudioStreams(true);
    } catch (_) {}

    // Proactively stop local preview/publishing and monitoring
    try {
      await stopPreview();
    } catch (_) {}
    try {
      await stopPublishingStream();
    } catch (_) {}
    try {
      await stopSoundLevelMonitor();
    } catch (_) {}
    try {
      stopAudioSpectrumMonitor();
    } catch (_) {}

    // Stop any currently playing remote streams proactively
    try {
      final playing = List<String>.from(streamMap.keys);
      for (final sid in playing) {
        await stopPlayingStream(sid);
      }
    } catch (_) {}

    // Clear local room data BEFORE engine logout so callbacks see empty roomID
    clearRoomData();

    // Disconnect LiveKit audio if enabled
    try {
      if (useLiveKitAudio) {
        AppLogger.info('LiveKit: disconnecting from room=$targetRoomID',
            tag: 'ExpressService');
        await _lk.logoutRoom();
        AppLogger.info('LiveKit: disconnected from room=$targetRoomID',
            tag: 'ExpressService');
      }
    } catch (_) {}

    final leaveResult = await ZegoExpressEngine.instance.logoutRoom();
    AppLogger.debug(
        'logoutRoom, id:$targetRoomID, result:${leaveResult.errorCode}',
        tag: 'ExpressService');

    return leaveResult;
  }

  void clearLocalUserData() {
    currentUser!.streamID = null;
    currentUser!.isCameraOnNotifier.value = false;
    currentUser!.isMicOnNotifier.value = false;
    currentUser!.isUsingFrontCameraNotifier.value = true;
    currentUser!.isUsingSpeaker.value = true;
    currentUser!.videoViewNotifier.value = null;
    currentUser!.viewID = -1;
  }

  void useFrontCamera(bool isFrontFacing) {
    currentUser!.isUsingFrontCameraNotifier.value = isFrontFacing;
    ZegoExpressEngine.instance.useFrontCamera(isFrontFacing);
  }

  void enableVideoMirroring(bool isVideoMirror) {
    ZegoExpressEngine.instance.setVideoMirrorMode(
      isVideoMirror
          ? ZegoVideoMirrorMode.BothMirror
          : ZegoVideoMirrorMode.NoMirror,
    );
  }

  @Deprecated(
      'Use muteAllPlayAudioStreams instead to leverage engine-level global mute.')
  void muteAllPlayStreamAudio(bool mute) {
    // Backward compatibility alias: delegate to guarded method
    // This ensures LiveKit mode cannot be bypassed by calling the alias
    // and attempting to unmute Zego audio.
    // ignore: deprecated_member_use_from_same_package
    muteAllPlayAudioStreams(mute);
  }

  Future<void> muteAllPlayAudioStreams(bool mute) async {
    AppLogger.debug(
        'muteAllPlayAudioStreams($mute) called | useLiveKitAudio=$useLiveKitAudio',
        tag: 'ExpressService');
    // In LiveKit mode, enforce Zego global mute regardless of requested state
    if (useLiveKitAudio) {
      if (mute) {
        await ZegoExpressEngine.instance.muteAllPlayAudioStreams(true);
      } else {
        // Ignore unmute requests to prevent dual audio when LiveKit is active
        AppLogger.debug('muteAllPlayAudioStreams(false) ignored in LiveKit mode',
            tag: 'ExpressService');
      }
      return;
    }
    await ZegoExpressEngine.instance.muteAllPlayAudioStreams(mute);
  }

  void setAudioRouteToSpeaker(bool useSpeaker) {
    currentUser!.isUsingSpeaker.value = useSpeaker;
    AppLogger.info(
        'setAudioRouteToSpeaker(useSpeaker=$useSpeaker, useLiveKitAudio=$useLiveKitAudio)',
        tag: 'ExpressService');
    if (useLiveKitAudio) {
      _lk.setSpeakerEnabled(useSpeaker);
      return;
    }
    if (kIsWeb) {
      // On Web, emulate speaker route by globally muting/unmuting remote audio
      muteAllPlayAudioStreams(!useSpeaker);
    } else {
      ZegoExpressEngine.instance.setAudioRouteToSpeaker(useSpeaker);
    }
  }

  void turnCameraOn(bool isOn) {
    currentUser!.isCameraOnNotifier.value = isOn;
    updateStreamExtraInfo();
    AppLogger.info('turnCameraOn(isOn=$isOn)', tag: 'ExpressService');
    ZegoExpressEngine.instance.enableCamera(isOn);
  }

  void turnMicrophoneOn(bool isOn) {
    currentUser!.isMicOnNotifier.value = isOn;
    updateStreamExtraInfo();
    if (useLiveKitAudio) {
      AppLogger.info('turnMicrophoneOn($isOn) via LiveKit', tag: 'ExpressService');
      _lk.setMicrophoneEnabled(isOn, reason: 'turnMicrophoneOn');
    } else {
      AppLogger.info('turnMicrophoneOn($isOn) via Zego', tag: 'ExpressService');
      ZegoExpressEngine.instance.mutePublishStreamAudio(!isOn);
    }
  }

  Future<void> startPlayingStream(String streamID,
      {ZegoViewMode viewMode = ZegoViewMode.AspectFill,
      ZegoPlayerConfig? config}) async {
    AppLogger.debug(
        'startPlayingStream(streamID=$streamID) useLiveKitAudio=$useLiveKitAudio suppressRoomCallbacks=$suppressRoomCallbacks currentRoomID=$currentRoomID',
        tag: 'ExpressService');
    // LiveKit handles remote audio subscription internally; skip Zego playback when enabled
    if (useLiveKitAudio) {
      AppLogger.debug(
          'startPlayingStream skipped for $streamID (LiveKit manages audio)',
          tag: 'ExpressService');
      return;
    }
    // Do not start any playback while switching rooms or without an active room
    if (suppressRoomCallbacks || currentRoomID.isEmpty) {
      AppLogger.debug(
          'startPlayingStream skipped for $streamID (suppressRoomCallbacks=$suppressRoomCallbacks, hasRoom=${currentRoomID.isNotEmpty})',
          tag: 'ExpressService');
      return;
    }
    final userID = streamMap[streamID];
    final userInfo = getUser(userID ?? '');
    if (currentScenario == ZegoScenario.HighQualityChatroom ||
        currentScenario == ZegoScenario.StandardChatroom ||
        currentScenario == ZegoScenario.StandardVideoCall ||
        currentScenario == ZegoScenario.StandardVoiceCall ||
        currentScenario == ZegoScenario.HighQualityVideoCall) {
      if (config == null) {
        config = ZegoPlayerConfig.defaultConfig()
          ..resourceMode = ZegoStreamResourceMode.OnlyRTC;
      } else {
        config.resourceMode = ZegoStreamResourceMode.OnlyRTC;
      }
    }
    if (userInfo != null) {
      if (userInfo.viewID != -1) {
        AppLogger.info('Starting Zego playback for $streamID on viewID=${userInfo.viewID}',
            tag: 'ExpressService');
        final canvas =
            ZegoCanvas(userInfo.viewID, viewMode: streamPlayViewMode);
        await ZegoExpressEngine.instance
            .startPlayingStream(streamID, canvas: canvas, config: config);
        // Ensure the stream audio is unmuted immediately after start
        try {
          await ZegoExpressEngine.instance.mutePlayStreamAudio(streamID, false);
          AppLogger.debug('Ensured per-stream unmute on $streamID after start',
              tag: 'ExpressService');
        } catch (_) {}
      } else {
        AppLogger.info('Creating canvas and starting Zego playback for $streamID',
            tag: 'ExpressService');
        await ZegoExpressEngine.instance.createCanvasView((viewID) async {
          userInfo.viewID = viewID;
          final canvas =
              ZegoCanvas(userInfo.viewID, viewMode: streamPlayViewMode);
          await ZegoExpressEngine.instance
              .startPlayingStream(streamID, canvas: canvas, config: config);
          // Ensure the stream audio is unmuted immediately after start
          try {
            await ZegoExpressEngine.instance.mutePlayStreamAudio(streamID, false);
            AppLogger.debug('Ensured per-stream unmute on $streamID after start',
                tag: 'ExpressService');
          } catch (_) {}
        }).then((videoViewWidget) {
          userInfo.videoViewNotifier.value = videoViewWidget;
        });
      }
    }
  }

  final roomUserListUpdateStreamCtrl =
      StreamController<ZegoRoomUserListUpdateEvent>.broadcast();
  final streamListUpdateStreamCtrl =
      StreamController<ZegoRoomStreamListUpdateEvent>.broadcast();
  final roomStreamExtraInfoStreamCtrl =
      StreamController<ZegoRoomStreamExtraInfoEvent>.broadcast();
  final roomStateChangedStreamCtrl =
      StreamController<ZegoRoomStateEvent>.broadcast();
  final roomExtraInfoUpdateCtrl =
      StreamController<ZegoRoomExtraInfoEvent>.broadcast();
  final recvAudioFirstFrameCtrl =
      StreamController<ZegoRecvAudioFirstFrameEvent>.broadcast();
  final recvVideoFirstFrameCtrl =
      StreamController<ZegoRecvVideoFirstFrameEvent>.broadcast();
  final recvSEICtrl = StreamController<ZegoRecvSEIEvent>.broadcast();
  final mixerSoundLevelUpdateCtrl =
      StreamController<ZegoMixerSoundLevelUpdateEvent>.broadcast();
  final onMediaPlayerStateUpdateCtrl =
      StreamController<ZegoPlayerStateChangeEvent>.broadcast();
  final onMediaPlayerFirstFrameEventCtrl =
      StreamController<ZegoMediaPlayerFirstFrameEvent>.broadcast();

  void uninitEventHandle() {
    ZegoExpressEngine.onRoomStreamUpdate = null;
    ZegoExpressEngine.onRoomUserUpdate = null;
    ZegoExpressEngine.onRoomStreamExtraInfoUpdate = null;
    ZegoExpressEngine.onRoomStateChanged = null;
    ZegoExpressEngine.onRoomExtraInfoUpdate = null;
    ZegoExpressEngine.onCapturedSoundLevelUpdate = null;
    ZegoExpressEngine.onRemoteSoundLevelUpdate = null;
    ZegoExpressEngine.onMixerSoundLevelUpdate = null;
    ZegoExpressEngine.onPlayerRecvAudioFirstFrame = null;
    ZegoExpressEngine.onPlayerRecvVideoFirstFrame = null;
    ZegoExpressEngine.onPlayerRecvSEI = null;
    ZegoExpressEngine.onPublisherStateUpdate = null;
    ZegoExpressEngine.onMediaPlayerFirstFrameEvent = null;
    ZegoExpressEngine.onMediaPlayerStateUpdate = null;
  }

  void initEventHandle() {
    ZegoExpressEngine.onRoomStreamUpdate =
        (String roomID, ZegoUpdateType updateType, List<ZegoStream> streamList,
            Map<String, dynamic> extendedData) {
      if (suppressRoomCallbacks) return;
      ExpressService()
          .onRoomStreamUpdate(roomID, updateType, streamList, extendedData);
    };
    ZegoExpressEngine.onRoomUserUpdate =
        (String roomID, ZegoUpdateType updateType, List<ZegoUser> userList) {
      if (suppressRoomCallbacks) return;
      ExpressService().onRoomUserUpdate(roomID, updateType, userList);
    };
    ZegoExpressEngine.onRoomStreamExtraInfoUpdate =
        (String roomID, List<ZegoStream> streamList) {
      if (suppressRoomCallbacks) return;
      ExpressService().onRoomStreamExtraInfoUpdate(roomID, streamList);
    };
    ZegoExpressEngine.onRoomStateChanged = ExpressService().onRoomStateChanged;
    // When LiveKit audio is enabled, avoid wiring any Zego audio callbacks
    if (!useLiveKitAudio) {
      ZegoExpressEngine.onCapturedSoundLevelUpdate =
          ExpressService().onCapturedSoundLevelUpdate;
      ZegoExpressEngine.onRemoteSoundLevelUpdate =
          ExpressService().onRemoteSoundLevelUpdate;
      ZegoExpressEngine.onMixerSoundLevelUpdate =
          ExpressService().onMixerSoundLevelUpdate;
      ZegoExpressEngine.onPlayerRecvAudioFirstFrame =
          ExpressService().onPlayerRecvAudioFirstFrame;
    } else {
      ZegoExpressEngine.onCapturedSoundLevelUpdate = null;
      ZegoExpressEngine.onRemoteSoundLevelUpdate = null;
      ZegoExpressEngine.onMixerSoundLevelUpdate = null;
      ZegoExpressEngine.onPlayerRecvAudioFirstFrame = null;
    }
    ZegoExpressEngine.onPlayerRecvVideoFirstFrame =
        ExpressService().onPlayerRecvVideoFirstFrame;
    ZegoExpressEngine.onPlayerRecvSEI = ExpressService().onPlayerRecvSEI;
    ZegoExpressEngine.onRoomExtraInfoUpdate =
        ExpressService().onRoomExtraInfoUpdate;
    ZegoExpressEngine.onPublisherStateUpdate =
        ExpressService().onPublisherStateUpdate;
    // MediaPlayer is Zego-only; keep for non-LiveKit modes
    if (!useLiveKitAudio) {
      ZegoExpressEngine.onMediaPlayerStateUpdate =
          ExpressService().onMediaPlayerStateUpdate;
      ZegoExpressEngine.onMediaPlayerFirstFrameEvent =
          ExpressService().onMediaPlayerFirstFrameEvent;
    } else {
      ZegoExpressEngine.onMediaPlayerStateUpdate = null;
      ZegoExpressEngine.onMediaPlayerFirstFrameEvent = null;
    }
  }

  void onRoomUserUpdate(
    String roomID,
    ZegoUpdateType updateType,
    List<ZegoUser> userList,
  ) {
    // Ignore updates from stale rooms
    if (roomID != currentRoomID || currentRoomID.isEmpty) {
      return;
    }
    if (updateType == ZegoUpdateType.Add) {
      for (final user in userList) {
        var userInfo = getUser(user.userID);
        if (userInfo == null) {
          userInfo = getRemoteUser(user.userID);
          if (userInfo == null) {
            userInfoList
                .add(UserEntity(iduser: user.userID, name: user.userName));
          } else {
            ///  sync from remote user
            userInfo
              ..iduser = user.userID
              ..name = user.userName;
          }
        } else {
          userInfo
            ..iduser = user.userID
            ..name = user.userName;
        }
      }
    } else {
      for (final user in userList) {
        userInfoList.removeWhere((element) {
          return element.iduser == user.userID;
        });
      }
    }
    roomUserListUpdateStreamCtrl
        .add(ZegoRoomUserListUpdateEvent(roomID, updateType, userList));
  }

  void onRoomStateChanged(
    String roomID,
    ZegoRoomStateChangedReason reason,
    int errorCode,
    Map<String, dynamic> extendedData,
  ) {
    currentRoomState = reason;

    AppLogger.info('onRoomStateChanged, room id:$roomID, reason:$reason',
        tag: 'ExpressService');

    roomStateChangedStreamCtrl
        .add(ZegoRoomStateEvent(roomID, reason, errorCode, extendedData));
  }
}
