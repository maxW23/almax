import 'package:flutter/material.dart';
import 'package:flutter_spinkit/flutter_spinkit.dart';
import '../constants/app_colors.dart';

class OverlayLoadingWidget extends StatelessWidget {
  const OverlayLoadingWidget({
    super.key,
    this.size = 100,
    this.color = AppColors.white,
    this.borderWidth = 6.0,
    this.duration = const Duration(milliseconds: 1800),
  });
  final double size;
  final Color color;
  final double borderWidth;
  final Duration duration;
  @override
  Widget build(BuildContext context) {
    return Overlay(
      initialEntries: [
        OverlayEntry(
          builder: (context) => Center(
            child: SpinKitRipple(
              color: color,
              size: size,
              borderWidth: borderWidth,
              duration: duration,
            ),
          ),
        ),
      ],
    );
  }
}
