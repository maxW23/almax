import 'dart:async';
import 'dart:collection';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:lklk/core/utils/logger.dart';

import 'package:equatable/equatable.dart';
import 'package:lklk/features/home/presentation/manger/top_bar_room_cubit/has_message.dart';
import 'package:lklk/features/room/domain/entities/topbar_meesage_entity.dart';

part 'top_bar_room_state.dart';

class TopBarRoomCubit extends Cubit<TopBarRoomState> {
  TopBarRoomCubit() : super(TopBarRoomInitial());

  final Queue<TopBarMessageEntity> _messageQueue = Queue<TopBarMessageEntity>();
  bool _isProcessing = false;
  Timer? _currentTimer;
  bool _isClosed = false;

  void updateTopBar(TopBarMessageEntity message) {
    if (_isClosed) return;

    log('[TopBarCubit] Adding message to queue: ${message.id}');
    _messageQueue.add(message);

    if (!_isProcessing) {
      _processNextMessage();
    }
  }

  void _processNextMessage() {
    if (_messageQueue.isEmpty) {
      _isProcessing = false;
      return;
    }

    _isProcessing = true;
    final message = _messageQueue.removeFirst();
    log('[TopBarCubit] Processing message: ${message.id}');

    // استخدام قيمة timer من الرسالة، مع قيمة افتراضية 4 ثوانٍ إذا كانت القيمة غير صالحة
    int displaySeconds = message.timer ?? 4;
    if (displaySeconds <= 0) {
      displaySeconds = 4;
    }
    final displayDuration = Duration(seconds: displaySeconds);

    final newState = TopBarShow(message, DateTime.now().millisecondsSinceEpoch);
    emit(newState);

    _currentTimer?.cancel();
    _currentTimer = Timer(displayDuration, () {
      if (_isClosed) return;

      log('[TopBarCubit] Hiding message: ${message.id}');
      if (state == newState) {
        emit(TopBarRoomInitial());
      }

      // انتظر لفترة قصيرة قبل عرض الرسالة التالية
      Timer(const Duration(milliseconds: 300), () {
        if (_isClosed) return;
        _processNextMessage();
      });
    });
  }

  @override
  void emit(TopBarRoomState state) {
    if (!_isClosed) {
      super.emit(state);
    }
  }

  @override
  Future<void> close() {
    _isClosed = true;
    _currentTimer?.cancel();
    _messageQueue.clear();
    return super.close();
  }
}
