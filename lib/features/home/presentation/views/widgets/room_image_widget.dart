import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:lklk/core/utils/custom_fading_widget.dart';
import '../../../../../core/constants/app_colors.dart';

class RoomImageWidget extends StatelessWidget {
  final String? imageUrl;

  const RoomImageWidget({
    super.key,
    this.imageUrl,
  });

  @override
  Widget build(BuildContext context) {
    final dpr = MediaQuery.of(context).devicePixelRatio;
    final thumbW = 110.w;
    final thumbH = 110.h;
    final memW = (thumbW * dpr).toInt();
    final memH = (thumbH * dpr).toInt();
    return Container(
      width: thumbW,
      height: thumbH,
      decoration: BoxDecoration(
        color: AppColors.white.withValues(alpha: .35),
        borderRadius: BorderRadius.circular(4.r),
      ),
      child: ClipRRect(
          borderRadius: BorderRadius.circular(4.r),
          child: CachedNetworkImage(
            imageUrl: imageUrl!.contains('https://lklklive.com/img/')
                ? (imageUrl!)
                : ('https://lklklive.com/img/$imageUrl'),
            memCacheWidth: memW,
            memCacheHeight: memH,
            maxWidthDiskCache: memW,
            maxHeightDiskCache: memH,
            fit: BoxFit.cover,
            imageBuilder: (context, imageProvider) => Container(
              width: thumbW,
              height: thumbH,
              decoration: BoxDecoration(
                image: DecorationImage(
                  image: imageProvider,
                  fit: BoxFit.cover,
                  filterQuality: FilterQuality.high,
                ),
              ),
              child: const SizedBox(),
            ),
            placeholder: (context, url) => CustomFadingWidget(
              child: Container(
                  width: thumbW,
                  height: thumbH,
                  decoration: const BoxDecoration(color: AppColors.grey),
                  child: const SizedBox()),
            ),
          )),
    );
  }
}
