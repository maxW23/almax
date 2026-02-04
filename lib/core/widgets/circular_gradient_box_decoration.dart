import 'package:flutter/material.dart';

abstract class CircularGradientBoxDecoration {
  static BoxDecoration circularGradient(double opacity,
      {double raduis = 0.35}) {
    return BoxDecoration(
      shape: BoxShape.circle,
      gradient: RadialGradient(
        center: Alignment.center,
        radius: raduis,
        colors: [
          Colors.black.withValues(alpha: opacity),
          Colors.white.withValues(alpha: opacity - .1),
          Colors.white.withValues(alpha: opacity - .2),
          Colors.white.withValues(alpha: opacity),
        ],
      ),
    );
  }
}
