import 'dart:async';
import 'dart:convert';

import 'package:lklk/core/services/api_service.dart';
import 'package:lklk/features/chat/domain/enitity/home_message_entity.dart';
import 'package:lklk/features/chat/domain/enitity/message_entity.dart';
import 'package:bloc/bloc.dart';
import 'package:meta/meta.dart';

part 'message_state.dart';

class MessageCubit extends Cubit<MessageState> {
  MessageCubit() : super(const MessageState(status: MessageStatus.initial)) {
    _startPeriodicFetch();
  }

  StreamSubscription<void>? _timerSubscription;
  String _userId = '';

  /// بدء جلب الرسائل بشكل دوري
  void _startPeriodicFetch() {
    _timerSubscription = Stream.periodic(const Duration(milliseconds: 2000))
        .listen((_) => _userId.isNotEmpty ? fetchMessages(_userId) : null);
  }

  /// إيقاف الجلب الدوري
  void stopPeriodicFetch() {
    _timerSubscription?.cancel();
  }

  /// جلب الرسائل
  Future<void> fetchMessages(String userId) async {
    if (state.status == MessageStatus.loading) {
      return; // منع جلب مكرر أثناء التحميل
    }
    emit(state.copyWith(status: MessageStatus.loading));
    _userId = userId;

    try {
      final response = await ApiService().get('/user/massage/$userId');
      final parsedData = jsonDecode(response.data);

      if (response.statusCode == 200) {
        final List<dynamic> messageJsonList = parsedData['Massage'] ?? [];
        final List<MessagePrivate> messages = messageJsonList
            .map((json) => MessagePrivate.fromJson(json))
            .toList()
            .reversed
            .toList();

        emit(state.copyWith(
          status: MessageStatus.loaded,
          messages: messages,
        ));
      } else {
        _handleError('Failed to load messages', parsedData);
      }
    } catch (e) {
      _handleError('Failed to load messages', e.toString());
    }
  }

  /// حذف رسالة
  Future<void> deleteMessage(String messageID) async {
    emit(state.copyWith(status: MessageStatus.loading));

    try {
      final response = await ApiService().post(
        '/usermassage/delete',
        data: {'selected_massage': messageID}, //
      );

      if (response.statusCode == 200) {
        emit(state.copyWith(status: MessageStatus.sent));
      } else {
        _handleError('Failed to delete message', response.data);
      }
    } catch (e) {
      _handleError('Failed to delete message', e.toString());
    }
  }

  /// إغلاق الكيوبت وإلغاء المؤقت
  @override
  Future<void> close() {
    stopPeriodicFetch();
    return super.close();
  }

  /// معالجة الأخطاء
  void _handleError(String message, String? details) {
    emit(state.copyWith(
      status: MessageStatus.error,
      error: '$message: $details',
    ));
  }
}
