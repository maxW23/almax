import 'package:flutter/material.dart';
import 'package:lklk/core/constants/app_colors.dart';

class RefreshOverlay extends StatelessWidget {
  final bool isVisible;

  const RefreshOverlay({super.key, required this.isVisible});

  @override
  Widget build(BuildContext context) {
    if (!isVisible) return const SizedBox.shrink();

    return Positioned(
      top: 240,
      left: 0,
      right: 0,
      child: Container(
        height: 40,
        width: 40,
        decoration: const BoxDecoration(
          shape: BoxShape.circle,
          color: AppColors.white,
        ),
        padding: const EdgeInsets.symmetric(horizontal: 16),
        child: const Center(
          child: SizedBox(
            width: 20,
            height: 20,
            child: CircularProgressIndicator(
              strokeWidth: 3,
              color: AppColors.black,
            ),
          ),
        ),
      ),
    );
  }
}
