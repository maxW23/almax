import 'package:flutter/material.dart';
import 'package:auto_size_text/auto_size_text.dart';
import 'package:lklk/core/constants/app_colors.dart';

class MessageCounterAlert extends StatelessWidget {
  const MessageCounterAlert({
    super.key,
    required this.howManyTime,
    this.size = 15,
    this.fontSize = 10,
  });

  final String howManyTime;
  final double size, fontSize;
  @override
  Widget build(BuildContext context) {
    return Container(
      height: size,
      width: size,
      alignment: Alignment.center,
      decoration: const BoxDecoration(
        shape: BoxShape.circle,
        gradient: LinearGradient(
            colors: [AppColors.secondColor, AppColors.primary],
            begin: Alignment.topRight,
            end: Alignment.bottomLeft),
      ),
      child: AutoSizeText(
        howManyTime,
        style: TextStyle(
          color: AppColors.white,
          fontSize: fontSize,
          fontWeight: FontWeight.w800,
        ),
        textAlign: TextAlign.center,
      ),
    );
  }
}
