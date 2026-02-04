import 'dart:async';

import 'package:flutter/material.dart';
import 'package:auto_size_text/auto_size_text.dart';
import 'package:lklk/core/constants/app_colors.dart';
import 'package:lklk/core/utils/functions/date_utils_function.dart';

class TimerCounterAcc extends StatefulWidget {
  const TimerCounterAcc(
      {super.key,
      this.color = AppColors.white,
      this.shadowColor = Colors.black});
  final Color color, shadowColor;
  @override
  State<TimerCounterAcc> createState() => _TimerCounterAccState();
}

class _TimerCounterAccState extends State<TimerCounterAcc> {
  late Timer _timer;

  final ValueNotifier<String> _timeLeftNotifier = ValueNotifier<String>(
    DateUtilsFunction.calculateTimeUntilNextMonth(),
  );
  @override
  void initState() {
    super.initState();
    _timer = Timer.periodic(
      const Duration(seconds: 1),
      (timer) {
        _timeLeftNotifier.value =
            DateUtilsFunction.calculateTimeUntilNextMonth();
      },
    );
  }

  @override
  void dispose() {
    super.dispose();
    _timer.cancel();
    _timeLeftNotifier.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return ValueListenableBuilder<String>(
      valueListenable: _timeLeftNotifier,
      builder: (context, timeLeft, _) {
        return AutoSizeText(
          timeLeft,
          textAlign: TextAlign.center,
          style: TextStyle(
              color: widget.color,
              fontSize: 14,
              shadows: [
                Shadow(
                  color: widget.shadowColor,
                  blurRadius: 2,
                  offset: const Offset(1, 1),
                ),
              ],
              fontWeight: FontWeight.bold),
        );
      },
    );
  }
}
