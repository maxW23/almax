import 'package:flutter/material.dart';

import '../constants/app_colors.dart';

class OpacityWidget extends StatelessWidget {
  const OpacityWidget({super.key, required this.child});
  final Widget child;
  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: OpacityWidgetDecoration.opacityCircleWidgetDecoration,
      child: child,
    );
  }
}

class CircleOpacityWidget extends StatelessWidget {
  const CircleOpacityWidget({super.key, required this.child, this.radius = 16});
  final Widget child;
  final double radius;
  @override
  Widget build(BuildContext context) {
    return CircleAvatar(
        backgroundColor: AppColors.whiteWithOpacity25,
        radius: radius,
        child: child);
  }
}

abstract class OpacityWidgetDecoration {
  static BoxDecoration opacityCircleWidgetDecoration = BoxDecoration(
      color: AppColors.whiteWithOpacity25, shape: BoxShape.circle);
}
