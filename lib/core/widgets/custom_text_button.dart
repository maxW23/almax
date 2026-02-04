import 'package:flutter/material.dart';
import 'package:auto_size_text/auto_size_text.dart';
import 'package:lklk/core/constants/app_colors.dart';

class CustomTextButton extends StatelessWidget {
  final String text;
  final int index;
  final int selectedIndex;
  final VoidCallback onPressed;

  const CustomTextButton(
      this.text, this.index, this.selectedIndex, this.onPressed,
      {super.key});

  @override
  Widget build(BuildContext context) {
    return AnimatedContainer(
      duration: const Duration(milliseconds: 500),
      curve: Curves.easeOutQuart,
      child: TextButton(
        onPressed: onPressed,
        style: TextButton.styleFrom(
            foregroundColor:
                selectedIndex == index ? AppColors.black : AppColors.grey),
        child: AutoSizeText(
          text,
          maxLines: 1,
          minFontSize: 7,
          maxFontSize: 13,
          style: const TextStyle(
            fontSize: 10,
            fontWeight: FontWeight.w900,
          ),
        ),
      ),
    );
  }
}
