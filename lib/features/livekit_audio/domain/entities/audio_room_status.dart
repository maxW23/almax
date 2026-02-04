import 'package:equatable/equatable.dart';

enum AudioConnectionState { idle, connecting, connected, disconnected, error }

class AudioRoomStatus extends Equatable {
  final AudioConnectionState state;
  final String? reason;

  const AudioRoomStatus(this.state, {this.reason});

  @override
  List<Object?> get props => [state, reason];

  const AudioRoomStatus.idle() : this(AudioConnectionState.idle);
  const AudioRoomStatus.connecting() : this(AudioConnectionState.connecting);
  const AudioRoomStatus.connected() : this(AudioConnectionState.connected);
  const AudioRoomStatus.disconnected({String? reason})
      : this(AudioConnectionState.disconnected, reason: reason);
  const AudioRoomStatus.error(String reason)
      : this(AudioConnectionState.error, reason: reason);
}
