import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:lklk/core/constants/assets.dart';
import 'package:lklk/core/player/svga_custom_player.dart';
import 'package:lklk/features/room/presentation/views/widgets/circular_user_image.dart';
// Removed unused path import; we detect SVGA via string contains/endsWith
import 'package:cached_network_image/cached_network_image.dart';

class ImageUserSectionWithFram extends StatelessWidget {
  const ImageUserSectionWithFram({
    super.key,
    this.onTap,
    required this.isImage,
    this.padding = 0,
    this.paddingImageOnly = 0,
    this.img,
    this.linkPath,
    // تصغير القيم الافتراضية
    this.radius = 55, // زيادة من 40 إلى 55
    this.height = 85, // زيادة من 70 إلى 85
    this.width = 85, // زيادة من 70 إلى 85
  });

  final String? linkPath;
  final String? img;
  final void Function()? onTap;
  final double padding;
  final double paddingImageOnly;
  final bool isImage;
  final double? radius;
  final double? width;
  final double? height;

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: width,
      height: height,
      child: isImage
          ? GestureDetector(
              onTap: onTap,
              child: linkPath != null
                  ? (() {
                      final lower = linkPath!.toLowerCase();
                      final bool isSvga = lower.endsWith('.svga') || lower.contains('.svga');
                      if (isSvga) {
                        return SVGAImageSection(
                            height: height,
                            width: width,
                            linkPath: linkPath,
                            padding: padding,
                            img: img,
                            radius: radius);
                      } else {
                        // Treat gif/png/jpg/jpeg and any other raster as overlay image
                        return GifSection(
                            padding: padding,
                            img: img,
                            radius: radius,
                            linkPath: linkPath,
                            height: height,
                            width: width);
                      }
                    })()
                  : SizedBox(
                      width: (radius ?? 20) * 2,
                      height: (radius ?? 20) * 2,
                      child: Padding(
                        padding: EdgeInsets.all(paddingImageOnly.r),
                        child: CircularUserImage(
                          imagePath: img,
                          radius: radius,
                        ),
                      ),
                    ),
            )
          : SizedBox(
              width: (radius ?? 20) * 2,
              height: (radius ?? 20) * 2,
              child: Padding(
                padding: EdgeInsets.all(paddingImageOnly.r),
                child: CircularUserImage(
                  // Use a safe fallback when there is no image
                  imagePath: (img != null && img!.isNotEmpty)
                      ? img
                      : AssetsData.userTestNetwork,
                  radius: radius,
                ),
              ),
            ),
    );
  }
}

class GifSection extends StatelessWidget {
  const GifSection({
    super.key,
    required this.padding,
    required this.img,
    required this.radius,
    required this.linkPath,
    required this.height,
    required this.width,
  });

  final double padding;
  final String? img;
  final double? radius;
  final String? linkPath;
  final double? height;
  final double? width;

  @override
  Widget build(BuildContext context) {
    return Align(
      alignment: Alignment.center,
      child: Stack(
        alignment: Alignment.center,
        children: [
          Padding(
            // تقليل قيمة الـ padding لتصغير المساحة بين الصورة والإطار
            padding:
                EdgeInsets.all(padding * 0.8), // تقليل الـ padding بنسبة 20%
            child: CircularUserImage(
              imagePath: img ?? AssetsData.userTestNetwork,
              // تصغير نصف قطر الصورة بنسبة 20% من القيمة المرسلة
              radius: (radius ?? 30) * 0.8,
            ),
          ),
          // دعم روابط الشبكة وكذلك الأصول المحلية للإطارات غير SVGA
          (linkPath != null && (linkPath!.startsWith('http://') || linkPath!.startsWith('https://')))
              ? CachedNetworkImage(
                  imageUrl: linkPath!,
                  height: height,
                  width: width,
                  fit: BoxFit.fill,
                  fadeInDuration: Duration.zero,
                  fadeOutDuration: Duration.zero,
                )
              : Image.asset(
                  linkPath!,
                  height: height,
                  width: width,
                ),
        ],
      ),
    );
  }
}

class SVGAImageSection extends StatelessWidget {
  const SVGAImageSection({
    super.key,
    required this.height,
    required this.width,
    required this.linkPath,
    required this.padding,
    required this.img,
    required this.radius,
  });

  final double? height;
  final double? width;
  final String? linkPath;
  final double padding;
  final String? img;
  final double? radius;

  @override
  Widget build(BuildContext context) {
    // حساب نصف قطر الصورة بنسبة من عرض الإطار
    final double imageRadius = (radius ?? ((width ?? 70) * 0.4));

    return SizedBox(
      height: height,
      width: width,
      child: CustomSVGAWidget(
        isCircularChild: true,
        isPadding: false,
        height: height!,
        width: width!,
        isRepeat: true,
        pathOfSvgaFile: linkPath!,
        fit: BoxFit.fill, // ملء الإطار بشكل كامل عند كونها SVGA
        child: Center(
          child: SizedBox(
            // تصغير حجم مساحة الصورة بنسبة 80% من عرض الإطار
            width: (width! * 0.75),
            height: (height! * 0.75),
            child: CircularUserImage(
              imagePath: img,
              radius: imageRadius,
            ),
          ),
        ),
      ),
    );
  }
}
