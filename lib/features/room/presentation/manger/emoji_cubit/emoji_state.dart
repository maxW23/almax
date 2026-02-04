part of 'emoji_cubit.dart';

abstract class EmojiState extends Equatable {
  const EmojiState();

  @override
  List<Object?> get props => [];
}

class EmojiInitial extends EmojiState {}

class EmojiSending extends EmojiState {}

class EmojiSentSuccess extends EmojiState {
  final dynamic emoji;

  const EmojiSentSuccess({required this.emoji});
}

class EmojiSentSuccessPrivate extends EmojiState {
  final dynamic emoji;
  final String senderID;
  const EmojiSentSuccessPrivate({required this.emoji, required this.senderID});
}

class EmojiSentFailure extends EmojiState {
  final String error;

  const EmojiSentFailure(this.error);

  @override
  List<Object?> get props => [error];
}

class EmojiLoaded extends EmojiState {
  final Map<int, String?> emojiMap;

  const EmojiLoaded({required this.emojiMap});

  @override
  List<Object?> get props => [emojiMap];
}
