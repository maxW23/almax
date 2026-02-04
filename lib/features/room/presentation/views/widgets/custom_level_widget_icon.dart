import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:auto_size_text/auto_size_text.dart';
import '../../../../../core/constants/app_colors.dart';

class RoomUserTypeWidget extends StatelessWidget {
  const RoomUserTypeWidget({
    super.key,
    required this.text,
    this.image,
    this.colorOne = AppColors.purpleColor,
    this.colorTwo = AppColors.secondColor,
  });

  final String text;
  final String? image;
  final Color colorOne;
  final Color colorTwo;
  final double height = 17.5;
  final double width = 17.5 * 2;

  @override
  Widget build(BuildContext context) {
    return Container(
      // padding: const EdgeInsets.symmetric(horizontal: 0, vertical: 0),
      decoration:
          BoxDecoration(borderRadius: BorderRadius.all(Radius.circular(30.r))),
      child: Stack(
        alignment:
            image != null ? AlignmentDirectional.topStart : Alignment.center,
        children: [
          Container(
              decoration: BoxDecoration(
                  gradient: LinearGradient(colors: [
                    colorTwo,
                    colorOne,
                  ]),
                  borderRadius: BorderRadius.circular(24.r)),
              height: height.h,
              width: width.w,
              child: SizedBox(
                height: height.h,
                width: width.w,
              )),
          Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                image != null
                    ? Container(
                        height: height.h,
                        width: 24.w,
                        padding: const EdgeInsets.symmetric(
                          horizontal: 0,
                        ),
                        child: Image.asset(
                          image!,
                          fit: BoxFit.cover,
                          height: height.h - 4.h,
                          width: 24.w,
                        ))
                    : const SizedBox(
                        width: 0,
                      ),
                image != null
                    ? int.parse(text) > 9
                        ? const SizedBox(
                            width: 0,
                          )
                        : SizedBox(width: 2.w)
                    : const SizedBox(),
                AutoSizeText(
                  text,
                  minFontSize: 8, // Remove .sp to use a fixed value
                  maxFontSize: 12, // Remove .sp to use a fixed value
                  stepGranularity: 1, // Explicitly set stepGranularity
                  style: TextStyle(
                      color: AppColors.white,
                      fontWeight: FontWeight.w800,
                      fontSize: 8.sp),
                ),
                // const SizedBox(
                //   width: 10,
                // ),
              ]),
        ],
      ),
    );
  }
}
//////////////////////////////////////////////////////////////////////////
//////////////////////////////////////////////////////////////////////////
//////////////////////////////////////////////////////////////////////////
//////////////////////////////////////////////////////////////////////////
//////////////////////////////////////////////////////////////////////////

// Shimmer(
//   enabled: true,
//   period: const Duration(milliseconds: 2000),
//   gradient: LinearGradient(
//     begin: Alignment.topRight,
//     end: Alignment.bottomLeft,
//     colors: [
//       colorOne,
//       colorTwo,
//     ],
//   ),
//   child: Container(
//     decoration: BoxDecoration(
//         color: AppColors.white,
//         borderRadius: BorderRadius.circular(14)),
//     height: 18,
//     width: 41,
//   ),
// ),
//
//
//
// // ShimmerContainer(
//   height: 20,
//   width: 42,
//   radius: 20,
//   millisecondsDelay: 2000,
//   highlightColor: AppColors.transparent,
//   baseColor: AppColors.white.withValues(alpha: .2),
// ),
