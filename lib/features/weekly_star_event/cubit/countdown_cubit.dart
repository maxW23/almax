import 'dart:async';
import 'package:equatable/equatable.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:shared_preferences/shared_preferences.dart';

class CountdownState extends Equatable {
  final Duration remainingDuration;
  final DateTime currentCycleEndDate;

  const CountdownState({
    required this.remainingDuration,
    required this.currentCycleEndDate,
  });

  CountdownState copyWith({
    Duration? remainingDuration,
    DateTime? currentCycleEndDate,
  }) => CountdownState(
        remainingDuration: remainingDuration ?? this.remainingDuration,
        currentCycleEndDate: currentCycleEndDate ?? this.currentCycleEndDate,
      );

  @override
  List<Object> get props => [remainingDuration.inSeconds, currentCycleEndDate];
}

class CountdownCubit extends Cubit<CountdownState> {
  CountdownCubit()
      : super(CountdownState(
          remainingDuration: Duration.zero,
          currentCycleEndDate: DateTime.now(),
        ));

  static const String _prefsKey = 'weekly_event_cycle_end';
  static const Duration _cycle = Duration(days: 7);

  Timer? _ticker;
  bool _starting = false;

  Future<void> start() async {
    if (_starting) return;
    _starting = true;
    _ticker?.cancel();

    final prefs = await SharedPreferences.getInstance();

    // Load saved end date or create a new cycle end = now + 7 days
    DateTime end = _loadEndDate(prefs);
    end = _normalizeEnd(end);

    final now = DateTime.now();
    final initialRemaining = end.difference(now);
    emit(state.copyWith(
      remainingDuration: initialRemaining,
      currentCycleEndDate: end,
    ));

    _ticker = Timer.periodic(const Duration(seconds: 1), (_) {
      final now = DateTime.now();
      DateTime currentEnd = state.currentCycleEndDate;

      // If we reached/passed the end, roll forward by full 7-day cycles
      if (!now.isBefore(currentEnd)) {
        do {
          currentEnd = currentEnd.add(_cycle);
        } while (!now.isBefore(currentEnd));
        // Persist the new cycle end
        prefs.setString(_prefsKey, currentEnd.toIso8601String());
      }

      final remaining = currentEnd.difference(now);
      emit(state.copyWith(
        remainingDuration: remaining,
        currentCycleEndDate: currentEnd,
      ));
    });
  }

  DateTime _loadEndDate(SharedPreferences prefs) {
    final s = prefs.getString(_prefsKey);
    if (s != null) {
      try {
        return DateTime.parse(s);
      } catch (_) {
        // fallthrough to create a fresh cycle if parsing fails
      }
    }
    final now = DateTime.now();
    final end = now.add(_cycle);
    prefs.setString(_prefsKey, end.toIso8601String());
    return end;
  }

  DateTime _normalizeEnd(DateTime end) {
    // Ensure the stored end is in the future; if not, roll forward by 7-day chunks
    DateTime e = end;
    final now = DateTime.now();
    while (!now.isBefore(e)) {
      e = e.add(_cycle);
    }
    return e;
  }

  @override
  Future<void> close() {
    _ticker?.cancel();
    return super.close();
  }
}
