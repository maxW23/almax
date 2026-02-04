import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:auto_size_text/auto_size_text.dart';
import 'package:lklk/core/constants/app_colors.dart';
import 'package:lklk/features/room/presentation/views/widgets/level_row_user_title_widget_section.dart';

class LevelImageWidget extends StatelessWidget {
  const LevelImageWidget({
    super.key,
    required this.level,
    required this.isPrimary,
    required this.imageProviderResolver,
    required this.displayValue,
    this.size = LevelRowSize.normal,
  });

  final int level;
  final bool isPrimary;
  final String Function(int level, bool isPrimary) imageProviderResolver;
  final String displayValue;
  final LevelRowSize size;

  @override
  Widget build(BuildContext context) {
    final double height = size == LevelRowSize.small ? 14.h : 17.5.h;
    final double width = size == LevelRowSize.small ? 28.w : 36.w;
    final double fontSize = size == LevelRowSize.small ? 10.sp : 15.sp;
    final double paddingLeft = size == LevelRowSize.small ? 12.r : 16.r;

    return Container(
      height: height,
      width: width,
      decoration: BoxDecoration(
        image: DecorationImage(
          image: AssetImage(imageProviderResolver(level, isPrimary)),
          fit: BoxFit.fill,
        ),
      ),
      alignment: Alignment.center,
      child: Padding(
        padding: EdgeInsets.only(left: paddingLeft),
        child: AutoSizeText(
          displayValue,
          minFontSize: 5,
          maxFontSize: 10,
          maxLines: 1,
          style: TextStyle(
            color: AppColors.white,
            fontWeight: FontWeight.w900,
            fontSize: fontSize,
          ),
          textAlign: TextAlign.center,
        ),
      ),
    );
  }
}
