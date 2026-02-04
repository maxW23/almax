import 'dart:async';
import 'package:livekit_client/livekit_client.dart' as lk;
import 'package:lklk/internal/sdk/livekit/livekit_audio_service.dart';
import 'package:lklk/features/livekit_audio/domain/entities/audio_participant.dart';
import 'package:lklk/features/livekit_audio/domain/entities/audio_room_status.dart';

abstract class LiveKitAudioRemote {
  Future<void> connect({required String roomId, required String token});
  Future<void> disconnect();
  Future<void> setMic(bool on);
  Future<void> setSpeaker(bool on);
  Stream<List<AudioParticipant>> observeParticipants();
  Stream<AudioRoomStatus> observeStatus();
}

class LiveKitAudioRemoteImpl implements LiveKitAudioRemote {
  final LiveKitAudioService _svc;
  LiveKitAudioRemoteImpl(this._svc);

  final _participantsCtrl = StreamController<List<AudioParticipant>>.broadcast();
  final _statusCtrl = StreamController<AudioRoomStatus>.broadcast();
  Timer? _timer;

  @override
  Future<void> connect({required String roomId, required String token}) async {
    _statusCtrl.add(const AudioRoomStatus.connecting());
    await _svc.loginRoom(roomId, token: token);
    _statusCtrl.add(const AudioRoomStatus.connected());
    _ensureTimer();

    // bridge disconnect events to status
    _svc.onRoomStateChanged = (rid, state, errorCode, data) {
      switch (state) {
        case 'Connected':
          _statusCtrl.add(const AudioRoomStatus.connected());
          break;
        case 'Disconnected':
          _statusCtrl.add(AudioRoomStatus.disconnected(
              reason: data['reason']?.toString()));
          break;
        default:
          break;
      }
    };
  }

  @override
  Future<void> disconnect() async {
    await _svc.logoutRoom();
    _statusCtrl.add(const AudioRoomStatus.disconnected());
    _timer?.cancel();
    _timer = null;
  }

  @override
  Future<void> setMic(bool on) =>
      _svc.setMicrophoneEnabled(on, reason: 'ui:toggle');

  @override
  Future<void> setSpeaker(bool on) => _svc.setSpeakerEnabled(on);

  void _ensureTimer() {
    _timer?.cancel();
    _timer = Timer.periodic(const Duration(milliseconds: 1000), (_) {
      final parts = _svc.participantsSnapshot();
      if (parts.isEmpty) {
        _participantsCtrl.add(const <AudioParticipant>[]);
        return;
      }
      final mapped = <AudioParticipant>[];
      for (final p in parts) {
        final id = p.sid ?? p.identity; // sid can be null on some platforms
        final identity = p.identity;
        final isLocal = p is lk.LocalParticipant;
        final level = p.audioLevel;
        mapped.add(AudioParticipant(
          id: id,
          identity: identity,
          isLocal: isLocal,
          speaking: level > 0.01,
          level: level,
        ));
      }
      _participantsCtrl.add(mapped);
    });
  }

  @override
  Stream<List<AudioParticipant>> observeParticipants() => _participantsCtrl.stream;

  @override
  Stream<AudioRoomStatus> observeStatus() => _statusCtrl.stream;
}
