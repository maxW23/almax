import 'package:lklk/features/livekit_audio/data/livekit_audio_remote.dart';
import 'package:lklk/features/livekit_audio/data/livekit_token_api.dart';
import 'package:lklk/features/livekit_audio/domain/entities/audio_participant.dart';
import 'package:lklk/features/livekit_audio/domain/entities/audio_room_status.dart';
import 'package:lklk/features/livekit_audio/domain/repositories/audio_repository.dart';

class LiveKitAudioRepositoryImpl implements AudioRepository {
  final LiveKitAudioRemote _remote;
  final LiveKitTokenApi _tokenApi;

  LiveKitAudioRepositoryImpl({required LiveKitAudioRemote remote, required LiveKitTokenApi tokenApi})
      : _remote = remote,
        _tokenApi = tokenApi;

  @override
  Future<void> connect({required String roomId, required String identity}) async {
    final token = await _tokenApi.fetchToken(identity: identity, roomId: roomId);
    if (token == null || token.isEmpty) {
      throw Exception('Failed to get LiveKit token');
    }
    await _remote.connect(roomId: roomId, token: token);
  }

  @override
  Future<void> disconnect() => _remote.disconnect();

  @override
  Future<void> setMic(bool on) => _remote.setMic(on);

  @override
  Future<void> setSpeaker(bool on) => _remote.setSpeaker(on);

  @override
  Stream<List<AudioParticipant>> observeParticipants() => _remote.observeParticipants();

  @override
  Stream<AudioRoomStatus> observeStatus() => _remote.observeStatus();
}
