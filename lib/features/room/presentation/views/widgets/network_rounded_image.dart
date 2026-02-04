import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:lklk/core/constants/app_colors.dart';
import 'package:lklk/core/utils/custom_fading_widget.dart';

class NetworkRoundedImage extends StatelessWidget {
  const NetworkRoundedImage({
    super.key,
    required this.imageUrl,
    required this.height,
    required this.width,
    required this.borderRadius,
    this.fit = BoxFit.fill,
  });

  final String imageUrl;
  final double height;
  final double width;
  final double borderRadius;
  final BoxFit fit;

  @override
  Widget build(BuildContext context) {
    // حساب حجم الكاش بناءً على كثافة الشاشة لتفادي الصور الضبابية
    final dpr = MediaQuery.of(context).devicePixelRatio;
    final cacheWidth = (width * dpr).round();
    final cacheHeight = (height * dpr).round();

    return CachedNetworkImage(
      height: height,
      width: width,
      imageUrl: imageUrl,
      memCacheWidth: cacheWidth,
      memCacheHeight: cacheHeight,
      maxWidthDiskCache: cacheWidth,
      maxHeightDiskCache: cacheHeight,
      placeholder: (context, url) => CustomFadingWidget(
        child: Container(
          height: height,
          width: width,
          decoration: BoxDecoration(
            color: AppColors.grey,
            borderRadius: BorderRadius.circular(borderRadius),
          ),
        ),
      ),
      errorWidget: (context, url, error) => const Icon(
        Icons.error,
        color: const Color(0xFFFF0000),
      ),
      imageBuilder: (context, imageProvider) => Container(
        height: height,
        width: width,
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(borderRadius),
          image: DecorationImage(
            image: imageProvider,
            fit: fit,
            filterQuality: FilterQuality.high,
          ),
        ),
      ),
    );
  }
}
