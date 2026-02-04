import 'package:equatable/equatable.dart';
import 'package:bloc/bloc.dart';
import 'dart:async';

part 'emoji_state.dart';

class EmojiCubit extends Cubit<EmojiState> {
  EmojiCubit() : super(EmojiInitial());

  void selectEmoji(dynamic emoji) {
    emit(EmojiSentSuccess(emoji: emoji));
    Future.delayed(const Duration(seconds: 4), () {
      emit(EmojiInitial());
    });
  }
}

class EmojiPrivateCubit extends Cubit<EmojiState> {
  EmojiPrivateCubit() : super(EmojiInitial());

  void selectEmojiPrivate(dynamic emoji, String userID) {
    emit(EmojiSentSuccessPrivate(emoji: emoji, senderID: userID));
    Future.delayed(const Duration(seconds: 4), () {
      emit(EmojiInitial());
    });
  }
}
