import 'dart:io';

import 'package:lklk/core/services/api_service.dart';
import 'package:bloc/bloc.dart';

/// الحالات المحتملة للكيوبت
abstract class MessageProgressCubitState {}

class MessageProgressCubitInitial extends MessageProgressCubitState {}

class MessageSent extends MessageProgressCubitState {}

class ChatImageSentSuccess extends MessageProgressCubitState {}

class ChatVoiceSentSuccess extends MessageProgressCubitState {}

class MessageLoading extends MessageProgressCubitState {}

class MessageError extends MessageProgressCubitState {
  final String error;
  MessageError(this.error);
}

/// الكيوبت لإدارة إرسال الرسائل
class MessageProgressCubitCubit extends Cubit<MessageProgressCubitState> {
  MessageProgressCubitCubit() : super(MessageProgressCubitInitial());

  /// إرسال رسالة نصية
  Future<void> sendMessage(String userId, String message) async {
    emit(MessageLoading());
    try {
      final response = await ApiService().post(
        '/user/massage/send/$userId',
        data: {'massage': message},
      );

      if (response.statusCode == 200 && response.data == 'message sent') {
        emit(MessageSent());
      } else {
        emit(MessageError(
            'Failed to send message: ${response.data ?? response.statusMessage}'));
      }
    } catch (error) {
      emit(MessageError('Network error: $error'));
    }
  }

  /// إرسال صورة
  Future<void> sendImage(String idReceiverUser, File imageFile) async {
    emit(MessageLoading());
    try {
      final response = await ApiService().uploadFile(
        '/user/massage/send/pics/$idReceiverUser',
        file: imageFile,
        fieldName: 'img',
      );

      if (response.statusCode == 200) {
        emit(ChatImageSentSuccess());
      } else {
        emit(MessageError('Failed to send image: ${response.statusMessage}'));
      }
    } catch (error) {
      emit(MessageError('Error sending image: $error'));
    }
  }

  /// إرسال رسالة صوتية
  Future<void> sendVoice(String idReceiverUser, File voiceFile) async {
    emit(MessageLoading());
    try {
      final response = await ApiService().uploadFile(
        '/user/massage/send/voice/$idReceiverUser',
        file: voiceFile,
        fieldName: 'voice',
      );

      if (response.statusCode == 200) {
        emit(ChatVoiceSentSuccess());
      } else {
        emit(MessageError('Failed to send voice: ${response.statusMessage}'));
      }
    } catch (error) {
      emit(MessageError('Error sending voice: $error'));
    }
  }
}
