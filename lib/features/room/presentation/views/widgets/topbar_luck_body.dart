import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:lklk/core/constants/app_colors.dart';
import 'package:lklk/core/constants/assets.dart';
import 'package:lklk/core/utils/gradient_text.dart';
import 'package:lklk/features/room/domain/entities/topbar_meesage_entity.dart';
import 'package:lklk/features/room/presentation/views/widgets/circular_user_image.dart';

class TopbarLuckBody extends StatelessWidget {
  const TopbarLuckBody({super.key, required this.msg});

  final TopBarMessageEntity msg;

  String _extractMultiplier() {
    // Priority 1: gift_id numeric or x-prefixed
    final gid = (msg.giftId ?? '').trim();
    if (gid.isNotEmpty) {
      // Try xNN or XNN
      final mX = RegExp(r'[xX](\d+)').firstMatch(gid);
      if (mX != null) {
        return 'X${mX.group(1)}';
      }
      // Try pure digits
      final mDigits = RegExp(r'^\d+$').firstMatch(gid);
      if (mDigits != null) {
        return 'X${mDigits.group(0)}';
      }
      // Try extract first digit group anywhere
      final anyDigits = RegExp(r'\d+').firstMatch(gid)?.group(0);
      if (anyDigits != null) return 'X$anyDigits';
    }

    // Priority 2: message contains xNN or digits
    final rawMsg = (msg.message ?? '').trim();
    final m2 = RegExp(r'[xX](\d+)').firstMatch(rawMsg);
    if (m2 != null) {
      return 'X${m2.group(1)}';
    }
    final msgDigits = RegExp(r'\d+').firstMatch(rawMsg)?.group(0);
    if (msgDigits != null) return 'X$msgDigits';

    // Priority 3: giftsMany digits
    final gm = msg.giftsMany?.toString();
    if (gm != null && gm.isNotEmpty) {
      final digits = RegExp(r'\d+').firstMatch(gm)?.group(0);
      if (digits != null) return 'X$digits';
    }

    return '';
  }

  @override
  Widget build(BuildContext context) {
    final multiplier = _extractMultiplier();

    return Padding(
      padding: EdgeInsets.only(bottom: 5.r, right: 28.r, left: 13.r),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          // Left: Gift image
          CircularUserImage(
            imagePath: msg.giftImg,
            radius: 18.r,
          ),
          // Center: Sender + message + coins + multiplier
          nameAndCoinsSection(multiplier),
          // Right: User image
          CircularUserImage(
            imagePath: msg.img,
            radius: 18.r,
          ),
        ],
      ),
    );
  }

  Widget nameAndCoinsSection(String multiplier) {
    return Padding(
      padding: const EdgeInsets.only(left: 16),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          SizedBox(height: 3.h,),
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
              ],
            ),
          ),
          // SizedBox(height: 3.h),
          // SizedBox(height: 1.h),
          Row(
            children: [
              // Outlined message text (same style as TopbarGameBody)
              Stack(
                children: [
                  GradientText(
                    "${msg.message}",
                    gradient: const LinearGradient(
                      begin: Alignment.centerLeft,
                      end: Alignment.bottomRight,
                      colors: [
                        AppColors.golden,
                        AppColors.golden,
                      ],
                    ),
                    style: TextStyle(
                      fontSize: 9.sp,
                      fontWeight: FontWeight.w700,
                      foreground: Paint()
                        ..style = PaintingStyle.stroke
                        ..strokeWidth = 2
                        ..color = AppColors.golden,
                    ),
                  ),
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
              SizedBox(width: 7.w),
              Image.asset(
                AssetsData.coins,
                width: 12.w,
                height: 12.h,
                fit: BoxFit.cover,
              ),
              SizedBox(width: 4.w),
              // Multiplier: XNN
              if (multiplier.isNotEmpty)
                GradientText(
                  multiplier,
                  style: TextStyle(
                    fontSize: 10.sp,
                    color: AppColors.white,
                    fontWeight: FontWeight.w800,
                  ),
                  gradient: LinearGradient(
                    begin: Alignment.centerLeft,
                    end: Alignment.bottomRight,
                    colors: [
                      AppColors.golden,
                      AppColors.white,
                      AppColors.golden,
                    ],
                  ),
                ),
            ],
          ),
        ],
      ),
    );
  }
}
