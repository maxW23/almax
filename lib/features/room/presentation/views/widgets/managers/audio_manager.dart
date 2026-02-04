import 'dart:async';
import 'package:flutter/material.dart';
import 'package:lklk/core/utils/logger.dart';
import 'package:lklk/core/zego_delegate.dart';
import 'package:lklk/internal/sdk/livekit/livekit_audio_service.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:lklk/features/livekit_audio/presentation/cubit/livekit_audio_cubit.dart';

/// مدير الصوت والميكروفون للغرفة الصوتية
class AudioManager {
  final BuildContext context;
  final ZegoDelegate zegoDelegate;

  double _localSoundLevel = 0;
  Map<String, double> _remoteSoundLevels = {};
  final Map<String, DateTime> _lastAudioFrameAt = {};
  Timer? _playbackWatchdog;

  // Getters للوصول للبيانات
  double get localSoundLevel => _localSoundLevel;
  Map<String, double> get remoteSoundLevels =>
      Map.unmodifiable(_remoteSoundLevels);

  AudioManager({
    required this.context,
    required this.zegoDelegate,
  });

  /// تهيئة مدير الصوت
  void initialize() {
    _initializeAudioEvents();
    _startPlaybackWatchdog(const Duration(seconds: 15));
  }

  /// تنظيف الموارد
  void dispose() {
    _playbackWatchdog?.cancel();
    _playbackWatchdog = null;
  }

  /// تهيئة أحداث الصوت
  void _initializeAudioEvents() {
    // Hook LiveKit events instead of Zego
    final svc = LiveKitAudioService.instance;
    svc.onCapturedSoundLevelUpdate = (double level) {
      onCapturedSoundLevelUpdate(level);
      // Timestamp update for watchdog
      _lastAudioFrameAt['local'] = DateTime.now();
    };
    svc.onRemoteSoundLevelUpdate = (Map<String, double> levels) {
      onRemoteSoundLevelUpdate(levels);
      final now = DateTime.now();
      for (final entry in levels.entries) {
        _lastAudioFrameAt[entry.key] = now;
      }
    };
  }

  /// معالجة تحديث مستوى الصوت المحلي
  void onCapturedSoundLevelUpdate(double soundLevel) {
    _localSoundLevel = soundLevel;
    // يمكن إضافة منطق إضافي هنا مثل تحديث UI
  }

  /// معالجة تحديث مستوى الصوت البعيد
  void onRemoteSoundLevelUpdate(Map<String, double> soundLevels) {
    _remoteSoundLevels = soundLevels;
    // يمكن إضافة منطق إضافي هنا مثل تحديث UI
  }

  /// بدء مراقب تشغيل الصوت
  void _startPlaybackWatchdog(Duration interval) {
    _playbackWatchdog?.cancel();
    _playbackWatchdog = Timer.periodic(interval, (_) async {
      if (!context.mounted) return;

      try {
        final now = DateTime.now();
        // Consider any participant with no recent audio level as stale
        for (final entry in List<MapEntry<String, DateTime>>.from(
            _lastAudioFrameAt.entries)) {
          final id = entry.key;
          if (id == 'local') continue;
          final last = entry.value;
          final stale = now.difference(last) > const Duration(seconds: 30);
          if (stale) {
            await LiveKitAudioService.instance.restartRemoteAudio(id);
            _lastAudioFrameAt[id] = DateTime.now();
          }
        }
      } catch (e) {
        log('Error in playback watchdog: $e', name: 'AudioManager');
      }
    });
  }

  // إعادة التشغيل تتم مباشرة عبر LiveKitAudioService في المراقب

  /// تسجيل استلام إطار صوتي
  void onAudioFrameReceived(String streamID) {
    _lastAudioFrameAt[streamID] = DateTime.now();
  }

  /// تشغيل/إيقاف الميكروفون
  void toggleMicrophone(bool enable) {
    try {
      // LiveKit-only
      // ignore: discarded_futures
      LiveKitAudioService.instance.setMicrophoneEnabled(enable);
      log('Microphone ${enable ? 'enabled' : 'disabled'}',
          name: 'AudioManager');
    } catch (e) {
      log('Error toggling microphone: $e', name: 'AudioManager');
    }
  }

  /// تشغيل/إيقاف السماعة
  void toggleSpeaker(bool enable) {
    try {
      // LiveKit-only
      // ignore: discarded_futures
      LiveKitAudioService.instance.setSpeakerEnabled(enable);
      log('Speaker ${enable ? 'enabled' : 'disabled'}', name: 'AudioManager');
    } catch (e) {
      log('Error toggling speaker: $e', name: 'AudioManager');
    }
  }

  /// الحصول على حالة الميكروفون
  bool get isMicrophoneOn {
    try {
      return context.read<LiveKitAudioCubit>().state.micOn;
    } catch (_) {
      return false;
    }
  }

  /// الحصول على حالة السماعة
  bool get isSpeakerOn {
    try {
      return context.read<LiveKitAudioCubit>().state.speakerOn;
    } catch (_) {
      return false;
    }
  }

  /// الحصول على مستوى الصوت لمستخدم معين
  double getSoundLevelForUser(String userID) {
    return _remoteSoundLevels[userID] ?? 0.0;
  }

  /// فحص ما إذا كان المستخدم يتحدث
  bool isUserSpeaking(String userID, {double threshold = 5.0}) {
    return getSoundLevelForUser(userID) > threshold;
  }

  /// الحصول على قائمة المستخدمين الذين يتحدثون
  List<String> getSpeakingUsers({double threshold = 5.0}) {
    return _remoteSoundLevels.entries
        .where((entry) => entry.value > threshold)
        .map((entry) => entry.key)
        .toList();
  }

  /// إعادة تعيين بيانات الصوت
  void reset() {
    _localSoundLevel = 0;
    _remoteSoundLevels.clear();
    _lastAudioFrameAt.clear();
  }
}
