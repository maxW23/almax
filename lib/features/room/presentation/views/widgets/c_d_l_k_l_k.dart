import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:lklk/core/constants/assets.dart';

class CDLKLK extends StatelessWidget {
  const CDLKLK({super.key});

  @override
  Widget build(BuildContext context) {
    return IgnorePointer(
      child: Stack(
        alignment: Alignment.center,
        children: [
          Image.asset(AssetsData.musicCD, height: 40.h, width: 40.w),
          ClipRRect(
            borderRadius: BorderRadius.circular(50.r),
            child: Image.asset(AssetsData.logoWhiteLittle,
                height: 13.h, width: 13.w),
          ),
        ],
      ),
    );
  }
}
