import 'package:flutter/material.dart';
import 'package:lklk/core/constants/app_colors.dart';

class LinearGradientWidget extends StatelessWidget {
  const LinearGradientWidget({
    super.key,
    this.child,
  });
  final Widget? child;
  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: const BoxDecoration(
        gradient:
            LinearGradient(colors: [AppColors.primary, AppColors.secondColor]),
      ),
      child: child,
    );
  }
}
