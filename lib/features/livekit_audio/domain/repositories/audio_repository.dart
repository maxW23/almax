import 'package:lklk/features/livekit_audio/domain/entities/audio_participant.dart';
import 'package:lklk/features/livekit_audio/domain/entities/audio_room_status.dart';

abstract class AudioRepository {
  Future<void> connect({required String roomId, required String identity});
  Future<void> disconnect();
  Future<void> setMic(bool on);
  Future<void> setSpeaker(bool on);
  Stream<List<AudioParticipant>> observeParticipants();
  Stream<AudioRoomStatus> observeStatus();
}
