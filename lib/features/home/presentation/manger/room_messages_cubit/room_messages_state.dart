part of 'room_messages_cubit.dart';

abstract class RoomMessagesState {}

enum RoomMessageStatus { initial, loading, loaded, error, sent, sentDice }

extension RoomMessageStatusX on RoomMessageStatus {
  bool get isInitial => this == RoomMessageStatus.initial;
  bool get isLoading => this == RoomMessageStatus.loading;
  bool get isLoaded => this == RoomMessageStatus.loaded;
  bool get isSent => this == RoomMessageStatus.sent;
  bool get isSentDice => this == RoomMessageStatus.sentDice;
}

@immutable
class RoomMessageState {
  final RoomMessageStatus status;
  final List<Message>? messages;
  final String? errorMessage;

  const RoomMessageState({
    required this.status,
    this.messages,
    this.errorMessage,
  });

  RoomMessageState copyWith({
    RoomMessageStatus? status,
    List<Message>? messages,
    String? errorMessage,
  }) {
    return RoomMessageState(
      status: status ?? this.status,
      messages: messages ?? this.messages,
      errorMessage: errorMessage ?? this.errorMessage,
    );
  }
}
