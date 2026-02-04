import 'package:flutter/material.dart';
import 'package:lklk/core/constants/app_colors.dart';

Color getLevelColor(String type) {
  switch (type) {
    case 'owner':
      return AppColors.golden;
    case 'admin':
      return AppColors.fourthColor;
    default:
      return AppColors.grey;
  }
}
