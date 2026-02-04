import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:auto_size_text/auto_size_text.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:country_flags/country_flags.dart';
import 'package:lklk/core/animations/lines_animation.dart';
import 'package:lklk/core/constants/app_colors.dart';
import 'package:lklk/features/home/presentation/views/widgets/room_item_widget_titles_container.dart';

class RoomGridTitleItem extends StatelessWidget {
  const RoomGridTitleItem({
    super.key,
    required this.widget,
  });

  final RoomItemWidgetTitlesContainer widget;

  @override
  Widget build(BuildContext context) {
    final imageUrl = widget.room.img.contains('https://lklklive.com/img/')
        ? widget.room.img
        : 'https://lklklive.com/img/${widget.room.img}';

    final devicePixelRatio = MediaQuery.of(context).devicePixelRatio;
    // Double quality: request 2x DPR and widen safe clamps
    final int optimalWidth = ((160.w) * devicePixelRatio * 2).clamp(256, 1024).round();
    final int optimalHeight = ((160.h) * devicePixelRatio * 2).clamp(256, 1024).round();

    return Container(
      height: 160.h,
      width: 160.w,
      decoration: BoxDecoration(
        color: AppColors.whitewhite,
        borderRadius: BorderRadius.all(Radius.circular(4.r)),
        boxShadow: const [
          BoxShadow(
            color: AppColors.grey,
            blurRadius: 1,
            spreadRadius: .4,
            blurStyle: BlurStyle.inner,
          ),
        ],
      ),
      child: Stack(
        children: [
          // صورة الخلفية مع تحسين الجودة
          Positioned.fill(
            child: ClipRRect(
              borderRadius: BorderRadius.circular(4.r),
              child: CachedNetworkImage(
                imageUrl: imageUrl,
                fit: BoxFit.cover,
                // استخدام maxWidth وmaxHeight بدلاً من memCache للتحكم بالجودة
                maxWidthDiskCache: optimalWidth,
                maxHeightDiskCache: optimalHeight,
                memCacheWidth: optimalWidth,
                memCacheHeight: optimalHeight,
                // تحسين جودة الصورة
                fadeInDuration: Duration.zero,
                fadeOutDuration: Duration.zero,
                // placeholder محسن
                placeholder: (context, url) => Container(
                  color: AppColors.grey.withValues(alpha: 0.2),
                  child: Center(
                    child: SizedBox(height: 1, width: 1),
                  ),
                ),
                errorWidget: (context, url, error) => Container(
                  color: AppColors.grey.withValues(alpha: 0.2),
                  child: Icon(
                    Icons.image_not_supported_outlined,
                    color: AppColors.grey.withValues(alpha: 0.5),
                    size: 40.r,
                  ),
                ),
                // إعدادات إضافية لتحسين الجودة
                imageBuilder: (context, imageProvider) => Container(
                  decoration: BoxDecoration(
                    image: DecorationImage(
                      image: imageProvider,
                      fit: BoxFit.cover,
                      // جودة أعلى للتقديم
                      filterQuality: FilterQuality.high,
                    ),
                  ),
                ),
              ),
            ),
          ),

          // محتوى النص
          Padding(
            padding: EdgeInsets.symmetric(horizontal: 8.r, vertical: 8.r),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    CountryFlag.fromCountryCode(
                      widget.room.country,
                      shape: RoundedRectangle(3.r),
                      height: 18.h,
                      width: 28.w,
                    ),
                    SizedBox(width: 4.w),
                    Expanded(
                      child: AutoSizeText(
                        widget.room.name,
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        minFontSize: 10,
                        style: TextStyle(
                          fontSize: 14.sp,
                          color: AppColors.white,
                          fontWeight: FontWeight.w700,
                          shadows: [
                            Shadow(
                              color: Colors.black.withValues(alpha: 0.8),
                              blurRadius: 4,
                              offset: const Offset(1, 1),
                            ),
                          ],
                        ),
                      ),
                    ),
                    SizedBox(width: 4.w),
                    AutoSizeText(
                      widget.room.fire ?? '100',
                      maxLines: 1,
                      minFontSize: 8,
                      style: TextStyle(
                        fontSize: 12.sp,
                        color: AppColors.white,
                        fontWeight: FontWeight.w600,
                        shadows: [
                          Shadow(
                            color: Colors.black.withValues(alpha: 0.8),
                            blurRadius: 4,
                            offset: const Offset(1, 1),
                          ),
                        ],
                      ),
                    ),
                    SizedBox(width: 4.w),
                    SizedBox(
                      height: 18.h,
                      child: Directionality(
                        textDirection: TextDirection.ltr,
                        child: const AnimatedLinesWidget(isWhite: true),
                      ),
                    ),
                  ],
                ),
                const Spacer(),
                AutoSizeText(
                  'ID : ${widget.room.id}',
                  maxLines: 1,
                  minFontSize: 10,
                  style: TextStyle(
                    fontSize: 12.sp,
                    color: AppColors.white,
                    fontWeight: FontWeight.bold,
                    shadows: [
                      Shadow(
                        color: Colors.black.withValues(alpha: 0.8),
                        blurRadius: 4,
                        offset: const Offset(1, 1),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
