import 'package:flutter/cupertino.dart';
import 'package:lklk/core/constants/app_colors.dart';

abstract class Styles {
  static const blackContainerShadow = BoxShadow(
      offset: Offset(.5, .5), blurRadius: 2.5, color: AppColors.black);
  static const blackShadow = Shadow(
    color: AppColors.black,
    blurRadius: 2.5,
    offset: Offset(.5, .5),
  );
  static const textStyle18 = TextStyle(
    fontSize: 18,
    fontWeight: FontWeight.w600,
  );
  static const textStyle20 = TextStyle(
    fontSize: 20,
    fontWeight: FontWeight.normal,
  );
  static const textStyle26 = TextStyle(
    fontSize: 26,
    fontWeight: FontWeight.w900,
    letterSpacing: 1.2,
  );
  static const textStyle24 = TextStyle(
    fontSize: 24,
    fontWeight: FontWeight.w900,
    letterSpacing: 1.2,
  );
  static const textStyle34 = TextStyle(
    fontSize: 34,
    fontWeight: FontWeight.w900,
  );
  static const textStyle28 = TextStyle(
    fontSize: 28,
    fontWeight: FontWeight.w900,
  );
  static const textStyle14 = TextStyle(
    fontSize: 14,
    fontWeight: FontWeight.normal,
  ); //
  static const textStyle14bold = TextStyle(
    fontSize: 14,
    fontWeight: FontWeight.bold,
  );
  static const textStyle12gray = TextStyle(
    fontSize: 12,
    fontWeight: FontWeight.normal,
    color: AppColors.grey,
  ); //
  static const textStyle16 = TextStyle(
    fontSize: 16,
    fontWeight: FontWeight.w500,
  );
  static const textStyle12bold = TextStyle(
    fontSize: 12,
    fontWeight: FontWeight.bold,
  );
  static const textStyle12 = TextStyle(
    fontSize: 12,
    fontWeight: FontWeight.w300,
  );
}

const TextStyle textStyle = TextStyle();
