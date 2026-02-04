import 'dart:ui';

import 'package:lklk/core/constants/app_colors.dart';

Color updateSVIPSettings(int levelSVIP, bool isWhite) {
  switch (levelSVIP) {
    case 1:
      return AppColors.svipFramColorOne;

    case 2:
      return AppColors.svipFramColorTwo;

    case 3:
      return AppColors.svipFramColorThree;

    case 4:
      return AppColors.svipFramColorFour;

    case 5:
      return AppColors.svipFramColorFive;

    default:
      return isWhite ? AppColors.white : AppColors.black;
  }
}
