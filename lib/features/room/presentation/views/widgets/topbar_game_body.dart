import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:lklk/core/constants/app_colors.dart';
import 'package:lklk/core/constants/assets.dart';
import 'package:lklk/core/utils/gradient_text.dart';
import 'package:lklk/features/room/domain/entities/topbar_meesage_entity.dart';
import 'package:lklk/features/room/presentation/views/widgets/circular_user_image.dart';

class TopbarGameBody extends StatelessWidget {
  const TopbarGameBody({
    super.key,
    required this.msg,
  });

  final TopBarMessageEntity msg;

  @override
  Widget build(BuildContext context) {
    return Padding(
        padding: EdgeInsets.only(bottom: 11.r, right: 28.r, left: 19.r),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            CircularUserImage(
              imagePath: msg.giftImg,
              radius: 18.r,
            ),
            Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                SizedBox(
                  height: 3.h,
                ),
                GradientText(
                  "${msg.giftSender}",
                  style: TextStyle(
                    fontSize: 11.sp,
                    color: AppColors.white,
                    fontWeight: FontWeight.w700,
                  ),
                  gradient: LinearGradient(
                      begin: Alignment.centerLeft,
                      end: Alignment.bottomRight,
                      colors: [
                        AppColors.golden,
                        AppColors.white,
                        AppColors.golden,
                        AppColors.white,
                      ]),
                ),
                // SizedBox(
                //   height: 3.h,
                // ),
                Row(
                  children: [
                    Stack(
                      children: [
                        // الطبقة الأولى: النص مع الحد الأحمر
                        GradientText(
                          "${msg.message}",
                          gradient: LinearGradient(
                            begin: Alignment.centerLeft,
                            end: Alignment.bottomRight,
                            colors: [
                              AppColors.golden,
                              // AppColors.white,
                              AppColors.golden,
                              // AppColors.white,
                            ],
                          ),
                          style: TextStyle(
                            fontSize: 9.sp,
                            fontWeight: FontWeight.w700,
                            foreground: Paint()
                              ..style = PaintingStyle.stroke
                              ..strokeWidth = 2 // سماكة الحد
                              ..color = Colors.white,
                          ),
                        ),
                        // الطبقة الثانية: النص مع التدرج الأبيض
                        GradientText(
                          "${msg.message}",
                          style: TextStyle(
                            fontSize: 9.sp,
                            fontWeight: FontWeight.w700,
                          ),
                          gradient: LinearGradient(
                            begin: Alignment.centerLeft,
                            end: Alignment.bottomRight,
                            colors: [AppColors.white, AppColors.white],
                          ),
                        ),
                      ],
                    ),
                    SizedBox(
                      width: 7.w,
                    ),
                    Image.asset(
                      AssetsData.coins,
                      width: 7.w,
                      height: 7.h,
                    ),
                    SizedBox(
                      width: 2.w,
                    ),
                    GradientText(
                      "Got",
                      style: TextStyle(
                        fontSize: 9.sp,
                        color: AppColors.white,
                        fontWeight: FontWeight.w700,
                      ),
                      gradient: LinearGradient(
                          begin: Alignment.centerLeft,
                          end: Alignment.bottomRight,
                          colors: [
                            AppColors.golden,
                            AppColors.white,
                            AppColors.golden
                          ]),
                    ),
                  ],
                ),
              ],
            ),
            CircularUserImage(
              imagePath: msg.img,
              radius: 18.r,
            ),
          ],
        ));
  }
}
