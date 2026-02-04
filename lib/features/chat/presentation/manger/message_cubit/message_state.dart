part of 'message_cubit.dart';

enum MessageStatus { initial, sent, loaded, lastLoaded, error, loading }

extension MessageStatusX on MessageStatus {
  bool get isInitial => this == MessageStatus.initial;
  bool get isSent => this == MessageStatus.sent;
  bool get isLoaded => this == MessageStatus.loaded;
  bool get isLastLoaded => this == MessageStatus.lastLoaded;
  bool get isLoading => this == MessageStatus.loading;
  bool get isError => this == MessageStatus.error;
}

@immutable
class MessageState {
  final MessageStatus status;
  final List<MessagePrivate>? messages;
  final List<HomeMessageEntity>? lastMessages;
  final String? error;

  const MessageState({
    required this.status,
    this.messages,
    this.lastMessages,
    this.error,
  });

  MessageState copyWith({
    MessageStatus? status,
    List<MessagePrivate>? messages,
    List<HomeMessageEntity>? lastMessages,
    String? error,
  }) {
    return MessageState(
      status: status ?? this.status,
      messages: messages ?? this.messages,
      lastMessages: lastMessages ?? this.lastMessages,
      error: error ?? this.error,
    );
  }
}

// @immutable
// abstract class MessageState

// class MessageInitial extends MessageState

// class MessageSent extends MessageState

// class MessageLoaded extends MessageState {
//   final List<MessagePrivate> messages;

//   MessageLoaded(this.messages);
// }

// class MessageLastLoaded extends MessageState {
//   final List<HomeMessageEntity> messages;

//   MessageLastLoaded(this.messages);
// }

// class MessageError extends MessageState {
//   final String error;

//   MessageError(this.error);
// }
