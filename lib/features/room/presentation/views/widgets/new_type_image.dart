import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:lklk/features/room/presentation/views/widgets/level_row_user_title_widget_section.dart';
import 'package:lklk/features/room/presentation/views/widgets/network_rounded_image.dart';

class NewTypeImage extends StatelessWidget {
  const NewTypeImage({
    super.key,
    required this.widget,
    this.size = LevelRowSize.normal,
  });

  final LevelRowUserTitleWidgetSection widget;
  final LevelRowSize size;

  @override
  Widget build(BuildContext context) {
    final double height = size == LevelRowSize.small ? 20.h : 25.h;
    final double width = size == LevelRowSize.small ? 48.w : 60.w;
    final double borderRadius = size == LevelRowSize.small ? 4.r : 4.r;

    return NetworkRoundedImage(
      imageUrl: widget.user.newType!,
      height: height,
      width: width,
      borderRadius: borderRadius,
    );
  }
}
