// ignore_for_file: public_member_api_docs, sort_constructors_first

import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:auto_size_text/auto_size_text.dart';
import 'package:lklk/core/constants/app_colors.dart';

class ButtonAnimatedPart extends StatelessWidget {
  const ButtonAnimatedPart({
    super.key,
    this.onPressed,
    required this.text,
    required this.isLevel,
    this.icon,
    required this.selectedColor,
    required this.unselectedColor,
  });

  final void Function()? onPressed;
  final String text;
  final bool isLevel;
  final IconData? icon;
  final Color selectedColor;
  final Color unselectedColor;
  @override
  Widget build(BuildContext context) {
    return InkWell(
      borderRadius: BorderRadius.circular(24.r),
      onTap: onPressed,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 250),
        height: 36.h,
        margin: EdgeInsets.symmetric(horizontal: 2.w, vertical: 2.h),
        padding: EdgeInsets.symmetric(horizontal: 12.w),
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(24.r),
          color: isLevel ? AppColors.white : Colors.transparent,
        ),
        child: Center(
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              if (icon != null) ...[
                Icon(
                  icon,
                  size: 16.sp,
                  color: isLevel ? selectedColor : unselectedColor.withValues(alpha: 0.9),
                ),
                SizedBox(width: 6.w),
              ],
              AutoSizeText(
                text,
                maxLines: 1,
                style: TextStyle(
                  fontWeight: FontWeight.w800,
                  fontSize: 14.sp,
                  color: isLevel ? selectedColor : unselectedColor,
                  letterSpacing: 0.2,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
