import 'package:flutter/material.dart';
import 'package:flutter_image_slideshow/flutter_image_slideshow.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:lklk/core/constants/app_colors.dart';
import 'package:lklk/core/utils/logger.dart';

class ImageSlideshowWidget extends StatelessWidget {
  final double? width;
  final double height;
  final List<String> images;
  final double? indicatorRadius;
  final double? indicatorBottomPadding;
  final double? indicatorPadding;
  final int? initialPage;
  final BoxFit? fit;
  final bool disableUserScrolling;
  final bool isLoop;
  final void Function(int)? onPageChanged;
  final List<void Function()>? onTaps;

  const ImageSlideshowWidget({
    super.key,
    this.width = double.infinity,
    required this.height,
    required this.images,
    this.indicatorRadius = 3,
    this.indicatorBottomPadding = 10,
    this.indicatorPadding = 4,
    this.initialPage = 0,
    this.fit = BoxFit.fill,
    this.disableUserScrolling = false,
    this.isLoop = true,
    this.onPageChanged,
    this.onTaps,
  });

  @override
  Widget build(BuildContext context) {
    return ImageSlideshow(
      disableUserScrolling: disableUserScrolling,
      indicatorRadius: indicatorRadius ?? 3,
      indicatorBottomPadding: indicatorBottomPadding ?? 10,
      indicatorPadding: indicatorPadding ?? 4,
      width: width ?? double.infinity,
      height: height,
      initialPage: initialPage ?? 0,
      indicatorColor: AppColors.purpleColor,
      indicatorBackgroundColor: AppColors.grey,
      onPageChanged: onPageChanged,
      autoPlayInterval: isLoop ? 3000 : null,
      isLoop: isLoop,
      children: List.generate(images.length, (index) {
        return GestureDetector(
          onTap: onTaps != null && onTaps!.length > index
              ? onTaps![index]
              : () {
                  AppLogger.debug('Banner tapped at index: $index',
                      tag: 'ImageSlideshowWidget');
                },
          child: images[index].startsWith('https')
              ? CachedNetworkImage(
                  imageUrl: images[index],
                  // Keep previous frame when switching to avoid flicker
                  useOldImageOnUrlChange: true,
                  fadeInDuration: Duration.zero,
                  fadeOutDuration: Duration.zero,
                  // Build Image manually to enable gaplessPlayback
                  imageBuilder: (context, imageProvider) => Image(
                    image: imageProvider,
                    fit: fit,
                    gaplessPlayback: true,
                    filterQuality: FilterQuality.medium,
                  ),
                  // Keep layout without painting grey placeholders
                  placeholder: (context, url) => const SizedBox.expand(),
                  errorWidget: (context, url, error) => const Icon(Icons.error),
                  memCacheHeight: height.toInt(),
                  memCacheWidth: (width != null && width!.isFinite)
                      ? width!.toInt()
                      : null,
                )
              : Image.asset(
                  images[index],
                  fit: fit,
                ),
        );
      }),
    );
  }
}
