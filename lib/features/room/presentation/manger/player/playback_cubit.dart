import 'dart:async';
import 'dart:convert';
import 'dart:io';
import 'package:bloc/bloc.dart';
import 'package:equatable/equatable.dart';
import 'package:lklk/core/zego_delegate.dart';
import 'package:zego_express_engine/zego_express_engine.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:lklk/core/config/app_config.dart';
import 'package:lklk/internal/sdk/music/music_pipe_service.dart';
import 'package:lklk/internal/sdk/livekit/livekit_audio_service.dart';
import 'package:lklk/core/services/api_service.dart';
import 'package:lklk/features/livekit_audio/data/livekit_token_api.dart';
import 'package:lklk/zego_sdk_manager.dart';

part 'playback_state.dart';

/// Cubit لإدارة حالة المشغل الصوتي (تشغيل/إيقاف/تقديم/صوت...)
/// يحافظ على الحالة باستخدام SharedPreferences بدون إيقاف الصوت عند إغلاق الواجهات.
class PlaybackCubit extends Cubit<PlaybackState> {
  PlaybackCubit(this._zego) : super(const PlaybackState()) {
    _bindZegoCallbacks();
    _restoreState();
  }

  final ZegoDelegate _zego;
  MusicPipeService? _musicPipe;
  StreamSubscription<MusicPipeState>? _pipeSub;
  // لا حاجة لاشتراك مباشر هنا، نعتمد على callback الخاصّ بـ Zego

  Future<void> _restoreState() async {
    final prefs = await SharedPreferences.getInstance();
    final raw = prefs.getString('player_playback_state');
    if (raw != null) {
      try {
        final map = jsonDecode(raw) as Map<String, dynamic>;
        final restoredVol = ((map['volume'] as num?)?.toDouble() ?? 0.30)
            .clamp(0.10, 0.70)
            .toDouble();
        emit(state.copyWith(
          volume: restoredVol,
          isAux: map['isAux'] as bool? ?? true,
          isMuteLocal: map['isMuteLocal'] as bool? ?? false,
          currentIndex: map['currentIndex'] as int? ?? -1,
          currentSong: map['currentSong'] as String? ?? '',
          progress: (map['progress'] as num?)?.toDouble() ?? 0.0,
          durationMs: map['durationMs'] as int? ?? 0,
          isPlaying: map['isPlaying'] as bool? ?? false,
        ));
      } catch (_) {}
    }
    // إعدادات Zego بناءً على الحالة المستعادة
    _zego.setVolumeMediaPlayer(state.volume);
    _zego.enableAuxMediaPlayer(state.isAux);
    _zego.muteLocalMediaPlayer(state.isMuteLocal);
  }

  Future<void> _persist() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(
        'player_playback_state',
        jsonEncode({
          'volume': state.volume,
          'isAux': state.isAux,
          'isMuteLocal': state.isMuteLocal,
          'currentIndex': state.currentIndex,
          'currentSong': state.currentSong,
          'progress': state.progress,
          'durationMs': state.durationMs,
          'isPlaying': state.isPlaying,
        }));
  }

  void _bindZegoCallbacks() {
    _zego.setZegoEventCallback(
      onMediaPlayerPlayingProgress: (fraction) {
        // fraction من 0..1
        final newProgress = fraction.clamp(0.0, 1.0);
        emit(state.copyWith(progress: newProgress));
      },
    );
  }

  // =================== MusicPipe helpers ===================
  String _derivePipeRoomName() {
    // Prefer LiveKit room ID if available; fallback to Zego room ID
    try {
      final lkId = LiveKitAudioService.instance.currentRoomID;
      if (lkId.isNotEmpty) return lkId;
    } catch (_) {}
    try {
      final zegoId = ZEGOSDKManager().expressService.currentRoomID;
      if (zegoId.isNotEmpty) return zegoId;
    } catch (_) {}
    return 'room-unknown';
  }

  Future<String> _fetchMusicBotToken(String roomName) async {
    final userId = (() {
      try {
        return ZEGOSDKManager().currentUser?.iduser;
      } catch (_) {
        return null;
      }
    })();
    final identity = (userId != null && userId.isNotEmpty)
        ? 'musicbot_' + userId
        : 'musicbot_' + DateTime.now().millisecondsSinceEpoch.toString();
    try {
      final api = LiveKitTokenApiImpl(ApiService());
      final token = await api.fetchToken(identity: identity, roomId: roomName);
      if (token != null && token.isNotEmpty) {
        return token;
      }
    } catch (e) {
      // Fallback to manual call if LiveKitTokenApiImpl fails
      try {
        final api = ApiService();
        final resp = await api.get('/livekit/token', queryParameters: {
          'identity': identity,
          'room': roomName,
        }, retries: 2);
        final data = resp.data;
        if (data is Map && data['token'] is String) {
          return data['token'] as String;
        }
        if (data is String && data.contains('.')) {
          return data;
        }
      } catch (_) {}
    }
    throw Exception('Failed to fetch MusicBot token');
  }

  Future<void> _ensureMusicPipe() async {
    if (_musicPipe == null) {
      if (AppConfig.musicPipeWsUrl.isEmpty) {
        throw Exception('AppConfig.musicPipeWsUrl is empty. Configure WS URL.');
      }
      _musicPipe = MusicPipeService(wsUrl: AppConfig.musicPipeWsUrl);
      _pipeSub = _musicPipe!.stateStream.listen((s) {
        // NOTE: We only map minimal fields here to avoid breaking UI
        emit(state.copyWith(
          isPlaying: s.isPlaying,
          durationMs: s.durationMs,
          // progress slider in this cubit is 0..1; keep as-is for now
        ));
      });
    }
  }

  /// تهيئة المشغل عند الحاجة فقط
  Future<void> ensureInitialized() async {
    if (!_zego.isInitialized) {
      await _zego.createMediaPlayer();
    }
  }

  Future<void> setVolume(double v) async {
    // enforce 10%..70% effective range regardless of caller
    final value = v.clamp(0.10, 0.70).toDouble();
    if (AppConfig.enableMusicPipe) {
      try { _musicPipe?.setVolume(value); } catch (_) {}
      emit(state.copyWith(volume: value));
      await _persist();
      return;
    }
    _zego.setVolumeMediaPlayer(value);
    emit(state.copyWith(volume: value));
    await _persist();
  }

  Future<void> toggleAux() async {
    final val = !state.isAux;
    _zego.enableAuxMediaPlayer(val);
    emit(state.copyWith(isAux: val));
    await _persist();
  }

  Future<void> toggleMuteLocal() async {
    final val = !state.isMuteLocal;
    _zego.muteLocalMediaPlayer(val);
    emit(state.copyWith(isMuteLocal: val));
    await _persist();
  }

  Future<void> seek(double fraction) async {
    await _zego.seekToMediaPlayer(fraction.clamp(0.0, 1.0));
    emit(state.copyWith(progress: fraction.clamp(0.0, 1.0)));
    await _persist();
  }

  Future<void> playPath(String path, {int index = -1}) async {
    if (AppConfig.enableMusicPipe) {
      final file = File(path);
      if (!await file.exists()) {
        throw Exception('الملف غير موجود: $path');
      }
      await _ensureMusicPipe();
      final roomName = _derivePipeRoomName();
      final token = await _fetchMusicBotToken(roomName);
      try { await _musicPipe!.stop(); } catch (_) {}
      await _musicPipe!.startStreaming(
        roomName: roomName,
        token: token,
        file: file,
        title: file.path.split('/').last,
        mime: null,
      );
      emit(state.copyWith(
        isPlaying: true,
        currentSong: file.path.split('/').last,
        currentIndex: index,
        progress: 0.0,
      ));
      await _persist();
      return;
    }

    await ensureInitialized();

    // إيقاف الأغنية الحالية قبل تشغيل الجديدة
    if (state.isPlaying) {
      await _zego.stopMediaPlayer();
    }

    // تحميل المصدر من المسار الحالي مع الحفاظ على الموضع 0
    await _zego.loadResourceWithPositionMediaPlayer(
      path,
      0,
      ZegoAlphaLayoutType.Right,
    );
    _zego.enableAuxMediaPlayer(state.isAux);
    _zego.startMediaPlayer();

    emit(state.copyWith(
      isPlaying: true,
      currentSong: path.split('/').last,
      currentIndex: index,
      progress: 0.0,
    ));
    await _persist();
  }

  Future<void> pause() async {
    if (AppConfig.enableMusicPipe) {
      try { _musicPipe?.pause(); } catch (_) {}
      emit(state.copyWith(isPlaying: false));
      await _persist();
      return;
    }
    _zego.pauseMediaPlayer();
    emit(state.copyWith(isPlaying: false));
    await _persist();
  }

  Future<void> resume() async {
    if (AppConfig.enableMusicPipe) {
      try { _musicPipe?.resume(); } catch (_) {}
      emit(state.copyWith(isPlaying: true));
      await _persist();
      return;
    }
    _zego.resumeMediaPlayer();
    emit(state.copyWith(isPlaying: true));
    await _persist();
  }

  Future<void> stop() async {
    if (AppConfig.enableMusicPipe) {
      try { await _musicPipe?.stop(); } catch (_) {}
      emit(state.copyWith(isPlaying: false, progress: 0.0));
      await _persist();
      return;
    }
    await _zego.stopMediaPlayer();
    emit(state.copyWith(isPlaying: false, progress: 0.0));
    await _persist();
  }

  /// تحديث الفهرس الحالي عند حذف أغنية من القائمة
  /// إذا تم حذف الأغنية الحالية، يتم إيقاف التشغيل وإعادة التعيين
  Future<void> onSongRemovedFromPlaylist(
      int removedIndex, int newPlaylistLength) async {
    if (state.currentIndex == -1) return;

    if (state.currentIndex == removedIndex) {
      // الأغنية الحالية تم حذفها - إيقاف التشغيل
      await stop();
      emit(state.copyWith(
        currentIndex: -1,
        currentSong: '',
        progress: 0.0,
        isPlaying: false,
      ));
      await _persist();
    } else if (state.currentIndex > removedIndex) {
      // الأغنية المحذوفة قبل الحالية - تحديث الفهرس
      emit(state.copyWith(currentIndex: state.currentIndex - 1));
      await _persist();
    }
    // إذا كان الفهرس المحذوف بعد الحالي، لا حاجة لتحديث
  }

  /// إعادة تعيين الحالة عند مسح القائمة بالكامل
  Future<void> onPlaylistCleared() async {
    await stop();
    emit(state.copyWith(
      currentIndex: -1,
      currentSong: '',
      progress: 0.0,
      isPlaying: false,
    ));
    await _persist();
  }

  @override
  Future<void> close() async {
    try { await _pipeSub?.cancel(); } catch (_) {}
    _pipeSub = null;
    try { await _musicPipe?.dispose(); } catch (_) {}
    return super.close();
  }
}
