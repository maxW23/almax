import 'dart:io';

import 'package:flutter/material.dart';
import 'package:auto_size_text/auto_size_text.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:lklk/core/constants/app_colors.dart';
import 'package:lklk/core/constants/assets.dart';
import 'package:lklk/core/utils/custom_fading_widget.dart';
import 'package:lklk/core/utils/image_loader.dart';
import 'package:lklk/generated/l10n.dart';

class StoreItemCardElement extends StatelessWidget {
  const StoreItemCardElement({
    super.key,
    required this.name,
    required this.image,
    required this.price,
    required this.period,
    required this.isSelected,
    required this.onTap,
    // this.isLocal = true,
    required this.index,
    this.buy = true,
    required this.icononTap,
    this.cupborad = false,
    this.still,
  });

  final String name, price;
  final String? image, still;
  final int index;
  final dynamic period;
  final bool isSelected, buy, cupborad;
  final VoidCallback onTap;
  final VoidCallback icononTap;

  @override
  Widget build(BuildContext context) {
    //log("$index -- $buy");
    double w = MediaQuery.of(context).size.width;
    return Stack(
      children: [
        GestureDetector(
          onTap: onTap,
          child: Container(
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(10),
              border: isSelected
                  ? Border.all(
                      color: AppColors.thirdColorPurple.withValues(alpha: .6),
                      width: 3,
                    )
                  : null,
            ),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.start,
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                SizedBox(
                  height: w / 2.5,
                  width: double.infinity,
                  child: Container(
                    decoration: BoxDecoration(
                      // color: _calculateColor(index),
                      color: AppColors.white,
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: image != null
                        ? (image!.startsWith('/data/user')
                            ? Image.file(
                                File(image!),
                                fit: BoxFit.cover,
                                width: double.infinity,
                                height: double.infinity,
                              )
                            : ImageLoader(
                                imageUrl: image!,
                                width: double.infinity,
                                height: double.infinity,
                                fit: BoxFit.fill,
                                placeholderColor: Colors.grey.shade300,
                                fallbackWidget: Container(
                                  width: double.infinity,
                                  height: double.infinity,
                                  decoration: const BoxDecoration(
                                    color: Colors.grey,
                                  ),
                                  child: const Icon(
                                    Icons.error,
                                    color: const Color(0xFFFF0000),
                                    size: 40,
                                  ),
                                ),
                              ))
                        : (const CustomFadingWidget(
                            child: SizedBox(
                            width: double.infinity,
                            height: double.infinity,
                          ))),
                  ),
                ),
                AutoSizeText(
                  name,
                  style: const TextStyle(
                      fontSize: 12, fontWeight: FontWeight.w400),
                ),
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    cupborad
                        ? const SizedBox()
                        : buy
                            ? Image.asset(
                                AssetsData.coins,
                                height: 17,
                              )
                            : const SizedBox(),
                    cupborad
                        ? buy
                            ? Row(
                                children: [
                                  AutoSizeText(
                                    S.of(context).used,
                                    overflow: TextOverflow.ellipsis,
                                    style: const TextStyle(
                                      fontSize: 11,
                                      fontWeight: FontWeight.w900,
                                      color: AppColors.golden,
                                    ),
                                  ),
                                  if (still != null)
                                    AutoSizeText(
                                      "/$still",
                                      overflow: TextOverflow.ellipsis,
                                      style: const TextStyle(
                                        fontSize: 11,
                                        fontWeight: FontWeight.w900,
                                        color: AppColors.golden,
                                      ),
                                    ),
                                ],
                              )
                            : Row(
                                children: [
                                  AutoSizeText(
                                    S.of(context).unUse,
                                    overflow: TextOverflow.ellipsis,
                                    style: const TextStyle(
                                      fontSize: 11,
                                      fontWeight: FontWeight.w900,
                                      color: AppColors.grey,
                                    ),
                                  ),
                                  if (still != null)
                                    AutoSizeText(
                                      "/$still",
                                      overflow: TextOverflow.ellipsis,
                                      style: const TextStyle(
                                        fontSize: 11,
                                        fontWeight: FontWeight.w900,
                                        color: AppColors.golden,
                                      ),
                                    ),
                                ],
                              )
                        : buy
                            ? AutoSizeText(
                                ' \$$price / $period',
                                overflow: TextOverflow.ellipsis,
                                style: const TextStyle(
                                  fontSize: 11,
                                  fontWeight: FontWeight.w900,
                                  color: AppColors.golden,
                                ),
                              )
                            : AutoSizeText(
                                S.of(context).notForSell,
                                style: const TextStyle(
                                  fontSize: 11,
                                  fontWeight: FontWeight.w900,
                                  color: AppColors.grey,
                                ),
                              ),
                  ],
                ),
              ],
            ),
          ),
        ),
        GestureDetector(
          behavior: HitTestBehavior.opaque,
          onTap: icononTap,
          child: Container(
            margin: const EdgeInsets.only(top: 3, left: 3, right: 3),
            decoration: BoxDecoration(
              color: AppColors.black.withValues(alpha: .5),
              borderRadius: BorderRadius.circular(10),
            ),
            height: 30,
            width: 30,
            child: const Icon(
              FontAwesomeIcons.arrowsUpDownLeftRight,
              color: AppColors.white,
            ),
          ),
        )
      ],
    );
  }
}
