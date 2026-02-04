import 'package:flutter/material.dart';
import 'package:marquee/marquee.dart';

import '../../constants/styles.dart';

Widget buildMarqueeText(String text,
    {TextStyle? style = Styles.textStyle14bold, double blankSpace = 230}) {
  return Marquee(
    text: text,
    style: style,
    scrollAxis: Axis.horizontal,
    crossAxisAlignment: CrossAxisAlignment.start,
    blankSpace: blankSpace,
    velocity: 100.0,
    pauseAfterRound: const Duration(seconds: 3),
    showFadingOnlyWhenScrolling: true,
    fadingEdgeStartFraction: 0.1,
    fadingEdgeEndFraction: 0.1,
    numberOfRounds: 7,
    startPadding: 10.0,
    accelerationDuration: const Duration(milliseconds: 500),
    accelerationCurve: Curves.linear,
    decelerationDuration: const Duration(milliseconds: 100),
    decelerationCurve: Curves.easeOut,
  );
}

// TextDirection _getTextDirection(String text) {
//   final arabicRegex = RegExp(
//       r'[\u0600-\u06FF\u0750-\u077F\u08A0-\u08FF\uFB50-\uFDFF\uFE70-\uFEFF]');
//   return arabicRegex.hasMatch(text) ? TextDirection.rtl : TextDirection.ltr;
// }
