import 'package:equatable/equatable.dart';

class AudioParticipant extends Equatable {
  final String id;
  final String identity;
  final bool isLocal;
  final bool speaking;
  final double level;

  const AudioParticipant({
    required this.id,
    required this.identity,
    required this.isLocal,
    required this.speaking,
    required this.level,
  });

  AudioParticipant copyWith({
    String? id,
    String? identity,
    bool? isLocal,
    bool? speaking,
    double? level,
  }) {
    return AudioParticipant(
      id: id ?? this.id,
      identity: identity ?? this.identity,
      isLocal: isLocal ?? this.isLocal,
      speaking: speaking ?? this.speaking,
      level: level ?? this.level,
    );
  }

  @override
  List<Object?> get props => [id, identity, isLocal, speaking, level];
}
