import 'package:auto_size_text/auto_size_text.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:lklk/core/constants/app_colors.dart';
import 'package:lklk/core/utils/gradient_text.dart';

class BtnEventWeek extends StatelessWidget {
  const BtnEventWeek({
    super.key,
    required this.imageBtn,
    required this.text,
  });
  final String imageBtn, text;
  @override
  Widget build(BuildContext context) {
    return Stack(
      alignment: AlignmentGeometry.center,
      children: [
        Image.asset(
          imageBtn,
          height: 58.h,
          width: 150.w,
          fit: BoxFit.fill,
        ),
        Positioned(
          bottom: 14,
          child: GradientText(
            text,
            gradient: const LinearGradient(colors: [
              AppColors.goldenRoyal,
              AppColors.white,
              AppColors.golden,
            ]),
            style: const TextStyle(fontSize: 15, fontWeight: FontWeight.w800),
          ),
        )
      ],
    );
  }
}
