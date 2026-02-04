import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:lklk/core/constants/app_colors.dart';
import 'package:lklk/core/constants/assets.dart';
import 'package:lklk/core/utils/gradient_text.dart';
import 'package:lklk/features/room/domain/entities/topbar_meesage_entity.dart';
import 'package:lklk/features/room/presentation/views/widgets/circular_user_image.dart';

class LuckyBagBody extends StatelessWidget {
  const LuckyBagBody({
    super.key,
    required this.msg,
  });

  final TopBarMessageEntity msg;

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: EdgeInsets.only(left: 10.r, right: 27.r, top: 0.r, bottom: 20.r),
      // padding:
      //     const EdgeInsets.only(top: 22, bottom: 10, left: 10, right: 10),
      child: Directionality(
        textDirection: TextDirection.rtl,
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            CircularUserImage(
              imagePath: msg.img,
              radius: 18.r,
            ),
            // Spacer(),
            // SizedBox(
            //   width: 20,
            // ),
            SizedBox(
              width: 150.w,
              child: Column(
                children: [
                  SizedBox(
                    height: 7.h,
                  ),
                  GradientText(
                    msg.giftSender ?? "",
                    gradient: const LinearGradient(colors: [
                      AppColors.golden,
                      AppColors.goldenRoyal,
                    ]),
                    style: TextStyle(
                      fontSize: 13.sp,
                      fontWeight: FontWeight.w800,
                    ),
                  ),
                  GradientText(
                    msg.message ?? "",
                    gradient: const LinearGradient(colors: [
                      AppColors.white,
                      AppColors.goldenhad2,
                    ]),
                    style: TextStyle(
                      fontSize: 10.sp,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ],
              ),
            ),
            Column(
              children: [
                SizedBox(height: 20.h),
                Row(
                  children: [
                    GradientText(
                      msg.giftId ?? "",
                      gradient: const LinearGradient(colors: [
                        AppColors.golden,
                        AppColors.goldenRoyal,
                      ]),
                      style: TextStyle(
                        fontSize: 9.sp,
                        fontWeight: FontWeight.w800,
                      ),
                    ),
                    Image.asset(AssetsData.coins, width: 14.w, height: 14.h),
                    SizedBox(width: 5.w)
                  ],
                ),
              ],
            ),
            // Spacer(),
          ],
        ),
      ),
    );
  }
}
