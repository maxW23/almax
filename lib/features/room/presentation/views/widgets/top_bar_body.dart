import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:lklk/core/constants/app_colors.dart';
import 'package:lklk/core/constants/assets.dart';
import 'package:lklk/core/constants/styles.dart';
import 'package:lklk/core/utils/gradient_text.dart';

import 'package:lklk/features/room/presentation/views/widgets/circular_user_image.dart';

class TopBarGiftBody extends StatelessWidget {
  const TopBarGiftBody({
    super.key,
    required this.manyGifts,
    required this.priceGifts,
    this.img,
    this.giftImage,
    this.reciverImage,
  });

  final String? manyGifts;
  final String? priceGifts;
  final String? img;
  final String? giftImage;
  final String? reciverImage;

  @override
  Widget build(BuildContext context) {
    // log("000000000000 img : $img giftImage : $giftImage manyGifts : $manyGifts priceGifts : $priceGifts ");
    return Container(
      margin: EdgeInsets.only(left: 10.r, right: 30.r, top: 0.r, bottom: 5.r),
      // padding:
      //     const EdgeInsets.only(top: 22, bottom: 10, left: 10, right: 10),
      child: Directionality(
        textDirection: TextDirection.rtl,
        child: Row(
          mainAxisAlignment: MainAxisAlignment.start,
          children: [
            CircularUserImage(
              imagePath: img,
              radius: 18.r,
            ),
            Spacer(),
            GradientText(
              manyGifts ?? "",
              gradient: const LinearGradient(colors: [
                AppColors.white,
                AppColors.goldenhad2,
              ]),
              style: TextStyle(
                fontSize: 13.sp,
                fontWeight: FontWeight.w600,
              ),
            ),
            // GiftImage(
            //   gift: gift,
            //   height: 30,
            //   width: 30,
            // ),123412341234,
            /////////////////////
            /////////////////////
            Spacer(),
            SizedBox(
              width: 20,
            ),

            CircularUserImage(
              imagePath: giftImage,
              radius: 18.r,
            ),
            Spacer(),

            /////////////////////
            /////////////////////
            Row(
              children: [
                GradientText(
                  priceGifts ?? "",
                  gradient: const LinearGradient(colors: [
                    AppColors.white,
                    AppColors.goldenhad2,
                  ]),
                  style: Styles.textStyle12bold.copyWith(),
                ),
                Image.asset(
                  AssetsData.coins,
                  width: 20.w,
                  height: 20.h,
                ),
              ],
            ),
            Spacer(),

            CircularUserImage(
              imagePath: reciverImage,
              radius: 18.r,
            ),
          ],
        ),
      ),
    );
  }
}
