import 'package:equatable/equatable.dart';
import 'package:lklk/features/livekit_audio/domain/entities/audio_participant.dart';
import 'package:lklk/features/livekit_audio/domain/entities/audio_room_status.dart';

class LiveKitAudioState extends Equatable {
  final AudioRoomStatus roomStatus;
  final bool micOn;
  final bool speakerOn;
  final List<AudioParticipant> participants;
  final String? error;

  const LiveKitAudioState({
    required this.roomStatus,
    required this.micOn,
    required this.speakerOn,
    required this.participants,
    this.error,
  });

  factory LiveKitAudioState.initial() => const LiveKitAudioState(
        roomStatus: AudioRoomStatus.idle(),
        micOn: false,
        speakerOn: true,
        participants: <AudioParticipant>[],
      );

  LiveKitAudioState copyWith({
    AudioRoomStatus? roomStatus,
    bool? micOn,
    bool? speakerOn,
    List<AudioParticipant>? participants,
    String? error,
  }) {
    return LiveKitAudioState(
      roomStatus: roomStatus ?? this.roomStatus,
      micOn: micOn ?? this.micOn,
      speakerOn: speakerOn ?? this.speakerOn,
      participants: participants ?? this.participants,
      error: error,
    );
  }

  @override
  List<Object?> get props => [roomStatus, micOn, speakerOn, participants, error];
}
