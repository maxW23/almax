import 'package:flutter/material.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:lklk/core/utils/custom_fading_widget.dart';

class ImageLoader extends StatelessWidget {
  final String imageUrl;
  final double width;
  final double height;
  final BoxFit fit;
  final ShapeBorder shape;
  final Color placeholderColor;
  final Widget? fallbackWidget;
  // Multiplier for DPR-aware cache size to improve sharpness on small icons
  // Safe range: 1.0 - 1.6 (values >1 sharpen but use slightly more cache)
  final double sharpnessScale;

  const ImageLoader({
    super.key,
    required this.imageUrl,
    required this.width,
    required this.height,
    this.fit = BoxFit.cover,
    this.shape = const RoundedRectangleBorder(),
    this.placeholderColor = Colors.grey,
    this.fallbackWidget,
    this.sharpnessScale = 1.0,
  });

  @override
  Widget build(BuildContext context) {
    final media = MediaQuery.of(context);
    final dpr = media.devicePixelRatio;
    // Handle Infinity/NaN/zero sizes gracefully using screen size fallback
    final double safeW =
        (width.isFinite && width > 0) ? width : media.size.width;
    final double safeH =
        (height.isFinite && height > 0) ? height : media.size.height;
    final double scale = sharpnessScale.clamp(1.0, 1.6);
    final double rawMemW = safeW * dpr * scale;
    final double rawMemH = safeH * dpr * scale;
    final int memW = (rawMemW.isFinite && rawMemW > 0)
        ? rawMemW.clamp(64, 4096).toInt()
        : (media.size.width * dpr).clamp(64, 4096).toInt();
    final int memH = (rawMemH.isFinite && rawMemH > 0)
        ? rawMemH.clamp(64, 4096).toInt()
        : (media.size.height * dpr).clamp(64, 4096).toInt();
    return ClipPath(
      clipper: ShapeBorderClipper(shape: shape),
      child: CachedNetworkImage(
        imageUrl: imageUrl,
        cacheKey: imageUrl,
        fit: fit,
        width: width,
        height: height,
        memCacheWidth: memW,
        memCacheHeight: memH,
        maxWidthDiskCache: memW,
        maxHeightDiskCache: memH,
        placeholder: (context, url) => CustomFadingWidget(
          child: Container(
            width: width,
            height: height,
            color: placeholderColor,
          ),
        ),
        imageBuilder: (context, imageProvider) => Image(
          image: imageProvider,
          width: width,
          height: height,
          fit: fit,
          filterQuality: FilterQuality.high,
          gaplessPlayback: true,
          repeat: ImageRepeat.noRepeat,
          frameBuilder: (context, child, frame, wasSynchronouslyLoaded) {
            if (wasSynchronouslyLoaded) return child;
            return AnimatedSwitcher(
              duration: const Duration(milliseconds: 200),
              child: child,
            );
          },
        ),
        errorWidget: (context, url, error) =>
            fallbackWidget ??
            Container(
              width: width,
              height: height,
              color: Colors.grey.shade400,
              child: Center(
                child: Icon(
                  Icons.broken_image,
                  color: const Color(0xFFEF5350),
                  size: 40,
                ),
              ),
            ),
      ),
    );
  }
}
/**
 ImageLoader(
  imageUrl: "https://example.com/image.png",
  width: 100,
  height: 100,
  shape: CircleBorder(),
  placeholderColor: Colors.blue.shade100,
)


//////////////////////////////////////////

ImageLoader(
  imageUrl: "https://example.com/image.png",
  width: 200,
  height: 150,
  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(15)),
  placeholderColor: Colors.grey.shade200,
  fallbackWidget: Center(
    child: AutoSizeText(
      'Image failed to load',
      style: TextStyle(color: const Color(0xFFFF0000)),
    ),
  ),
)
/////////////////////////////////////////////////

placeholder: (context, url) => Shimmer.fromColors(
  baseColor: Colors.grey.shade300,
  highlightColor: Colors.white,
  child: Container(
    width: width,
    height: height,
    color: placeholderColor,
  ),
),
/////////////////////////////////////////////////////


Hero(
  tag: imageUrl,
  child: ImageLoader(
    imageUrl: imageUrl,
    width: 300,
    height: 200,
    shape: RoundedRectangleBorder(),
  ),
),

 */
