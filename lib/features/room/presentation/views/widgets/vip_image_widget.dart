import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:lklk/core/player/svga_custom_player.dart';
import 'package:lklk/features/room/presentation/views/widgets/level_row_user_title_widget_section.dart';

// إضافة خاصية الحجم إلى VipImageWidget
class VipImageWidget extends StatelessWidget {
  const VipImageWidget({
    super.key,
    required this.assetPath,
    this.size = LevelRowSize.normal,
  });

  final String assetPath;
  final LevelRowSize size;

  @override
  Widget build(BuildContext context) {
    final double height = size == LevelRowSize.small ? 14.h : 18.h;
    final double width = size == LevelRowSize.small ? 28.w : 36.w;

    return Image.asset(
      assetPath,
      height: height,
      width: width,
      fit: BoxFit.fill,
    );
  }
}

// إضافة خاصية الحجم إلى VipSVGAWidget
class VipSVGAWidget extends StatelessWidget {
  const VipSVGAWidget({
    super.key,
    required this.assetPath,
    this.size = LevelRowSize.normal,
  });

  final String assetPath;
  final LevelRowSize size;

  @override
  Widget build(BuildContext context) {
    final double height = size == LevelRowSize.small ? 16.h : 18.h;
    final double width = size == LevelRowSize.small ? 32.w : 36.w;

    return CustomSVGAWidget(
      pathOfSvgaFile: assetPath,
      height: height,
      width: width,
      fit: BoxFit.fill,
      isRepeat: true,
      isPadding: false,
      clearsAfterStop: false,
    );
  }
}
