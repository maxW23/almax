import 'dart:async';
import 'dart:collection';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:lklk/core/utils/logger.dart';

import 'package:equatable/equatable.dart';
import 'package:lklk/features/home/presentation/manger/top_bar_room_cubit/has_message.dart';
import 'package:lklk/features/room/domain/entities/topbar_meesage_entity.dart';

part 'money_bag_top_bar_state.dart';

class MoneyBagTopBarCubit extends Cubit<MoneyBagTopBarState> {
  MoneyBagTopBarCubit() : super(MoneyBagTopBarInitial());

  final Queue<TopBarMessageEntity> _messageQueue = Queue<TopBarMessageEntity>();
  bool _isProcessing = false;
  Timer? _currentTimer;
  bool _isClosed = false;

  void updateTopBar(TopBarMessageEntity message) {
    if (_isClosed) return;

    log('[MoneyBagTopBarCubit] Adding message to queue: ${message.id}');
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
    log('[MoneyBagTopBarCubit] Processing message: ${message.id}');

    int displaySeconds = message.timer ?? 4;
    if (displaySeconds <= 0) {
      displaySeconds = 4;
    }
    final displayDuration = Duration(seconds: displaySeconds);

    final newState =
        MoneyBagTopBarShow(message, DateTime.now().millisecondsSinceEpoch);
    emit(newState);

    _currentTimer?.cancel();
    _currentTimer = Timer(displayDuration, () {
      if (_isClosed) return;

      log('[MoneyBagTopBarCubit] Hiding message: ${message.id}');
      if (state == newState) {
        emit(MoneyBagTopBarInitial());
      }

      Timer(const Duration(milliseconds: 300), () {
        if (_isClosed) return;
        _processNextMessage();
      });
    });
  }

  @override
  void emit(MoneyBagTopBarState state) {
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
