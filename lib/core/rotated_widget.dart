import 'package:flutter/material.dart';

class RotatedWidget extends StatelessWidget {
  final Widget child; // العنصر المراد تدويره
  final double angle; // الزاوية بالدرجات

  const RotatedWidget({
    super.key,
    required this.child,
    this.angle = 90, // زاوية افتراضية 90 درجة
  });

  @override
  Widget build(BuildContext context) {
    return Transform.rotate(
      angle: angle *
          (3.1415926535897932 / 180), // تحويل الزاوية من درجات إلى راديان
      child: child,
    );
  }
}
