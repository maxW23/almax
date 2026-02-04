import 'package:country_flags/country_flags.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:auto_size_text/auto_size_text.dart';
import 'package:lklk/core/animations/lines_animation.dart';
import 'package:lklk/core/utils/functions/build_marquee_text.dart';
import '../../../../room/domain/entities/room_entity.dart';

import '../../../../../core/constants/app_colors.dart';
import '../../../../../core/constants/styles.dart';

class RoomTitlesWidget extends StatelessWidget {
  final RoomEntity room;

  const RoomTitlesWidget({
    super.key,
    required this.room,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: EdgeInsets.symmetric(vertical: 10.r, horizontal: 10.r),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisAlignment: MainAxisAlignment.spaceBetween, // Add this line
        children: [
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              AutoSizeText(
                room.name,
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                style: Styles.textStyle14.copyWith(
                  fontWeight: FontWeight.bold,
                  color: AppColors.black,
                ),
              ),
              SizedBox(height: 10.h),
              SizedBox(
                height: 25.h,
                child: Row(
                  children: [
                    Container(
                      decoration: BoxDecoration(
                        color: AppColors.primaryWithOpacity2,
                        borderRadius: BorderRadius.circular(10.r),
                      ),
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          CountryFlag.fromCountryCode(
                            room.country,
                            shape: RoundedRectangle(3.r),
                            height: 17.h,
                            width: 24.w,
                            // borderRadius: 2,
                          ),
                          SizedBox(
                            width: 4.w,
                          ),
                          AutoSizeText(
                            'ID : ${room.id}',
                            style: const TextStyle(
                              fontWeight: FontWeight.bold,
                              color: AppColors.black,
                            ),
                          ),
                        ],
                      ),
                    ),
                    const Spacer(),
                    AutoSizeText(
                      room.fire ?? '100',
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: Styles.textStyle12.copyWith(
                        fontWeight: FontWeight.w600,
                        color: AppColors.black,
                      ),
                    ),
                    SizedBox(
                      width: 4.w,
                    ),
                    Directionality(
                      textDirection: TextDirection.ltr,
                      child: const AnimatedLinesWidget(
                        isWhite: false,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
          SizedBox(
              height: 22.h,
              width: double.infinity,
              child: buildMarqueeText(room.helloText,
                  style: TextStyle(
                    color: AppColors.black,
                  ))), // Use room.announcementRoomTitle
        ],
      ),
    );
  }
}
