import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:lklk/core/constants/app_colors.dart';
import 'package:lklk/core/utils/custom_fading_widget.dart';
import 'package:lklk/core/utils/gradient_text.dart';
import 'package:lklk/core/utils/image_loader.dart';
import 'package:lklk/features/profile_users/domain/entities/elements_entity.dart';

class GiftsSection extends StatelessWidget {
  const GiftsSection({
    super.key,
    required this.giftList,
    this.isLength = true,
  });
  final List<ElementEntity> giftList;
  final bool isLength;
  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 10, vertical: 10),
      decoration: const BoxDecoration(
          // borderRadius: BorderRadius.circular(20),
          // gradient: const LinearGradient(colors: [
          //   AppColors.purpleColor,
          //   AppColors.thirdColorPurple,
          // ]),
          ),
      alignment: Alignment.center,
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 10),
      child: GridView.count(
        physics: const NeverScrollableScrollPhysics(),
        crossAxisCount: 4,
        shrinkWrap: true,
        crossAxisSpacing: 5,
        mainAxisSpacing: 5,
        children: List.generate(giftList.length, (index) {
          return giftItem(index);
        }),
      ),
    );
  }

  SizedBox giftItem(int index) {
    // log("imgElementLocal ${giftList[index].imgElementLocal}");
    // log("imgElement ${giftList[index].imgElement}");
    return SizedBox(
      width: 70.w, // Increased the width a bit
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          CircleAvatar(
            radius: 30,
            backgroundColor: AppColors.transparent,
            child: ClipOval(
              child: giftList[index].imgElementLocal != null ||
                      giftList[index].imgElement != null
                  ? (giftList[index].imgElementLocal != null
                      ? Image.file(
                          File(giftList[index].imgElementLocal!),
                          fit: BoxFit.fill,
                          width: 60,
                          height: 60,
                        )
                      : giftList[index].imgElement != null
                          ? ImageLoader(
                              imageUrl: giftList[index].imgElement!,
                              width: 60,
                              height: 60,
                              fit: BoxFit.fill,
                              shape: const CircleBorder(),
                              placeholderColor: Colors.grey.shade300,
                              fallbackWidget: Container(
                                width: 60,
                                height: 60,
                                decoration: BoxDecoration(
                                  shape: BoxShape.circle,
                                  color: Colors.grey.shade300,
                                ),
                                child: const Icon(
                                  Icons.broken_image,
                                  color: const Color(0xFFFF0000),
                                  size: 20,
                                ),
                              ),
                            )
                          : (const CustomFadingWidget(
                              child: SizedBox(
                              width: 60,
                              height: 60,
                            ))))
                  : (const CustomFadingWidget(
                      child: SizedBox(
                      width: 60,
                      height: 60,
                    ))),
            ),
          ),
          SizedBox(
            height: 3.h,
          ),
          if (isLength)
            Flexible(
              child: GradientText(
                "X ${giftList[index].giftCount ?? ""}",
                gradient: const LinearGradient(colors: [
                  AppColors.goldenhad1,
                  AppColors.brownshad1,
                  AppColors.brownshad2,
                  AppColors.brownshad1,
                ]),
                style: const TextStyle(
                  fontSize: 14,
                  fontWeight: FontWeight.w500,
                ),
                maxLines: 1,
              ),
            ),
        ],
      ),
    );
  }
}
