// ignore_for_file: public_member_api_docs, sort_constructors_first

import 'package:flutter/material.dart';
import 'package:auto_size_text/auto_size_text.dart';
import 'package:lklk/core/constants/app_colors.dart';
import 'package:lklk/core/constants/assets.dart';

class InfoWidgetItem extends StatelessWidget {
  const InfoWidgetItem({
    super.key,
    required this.icon,
    required this.textUP,
    required this.textCenter,
    required this.textBottom,
    this.istextBottom = true,
  });
  final IconData icon;
  final String textUP;
  final String textCenter;
  final String textBottom;
  final bool istextBottom;
  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      crossAxisAlignment: CrossAxisAlignment.center,
      children: [
        Container(
          padding: const EdgeInsets.all(8),
          decoration: BoxDecoration(
              shape: BoxShape.circle,
              gradient: LinearGradient(colors: [
                AppColors.orangePinkColor.withValues(alpha: .8),
                AppColors.orangePinkTwoColor.withValues(alpha: .4),
              ])),
          child: Center(
              child: Icon(
            icon,
            color: AppColors.orangePinkColor,
          )),
        ),
        const SizedBox(
          width: 14,
        ),
        Column(
          mainAxisAlignment: MainAxisAlignment.center,
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            AutoSizeText(
              textUP,
              style: const TextStyle(
                  color: AppColors.black, fontWeight: FontWeight.w400),
            ),
            const SizedBox(
              height: 5,
            ),
            Row(
              children: [
                Image.asset(
                  AssetsData.coins,
                  height: 20,
                  width: 20,
                ),
                const SizedBox(
                  width: 5,
                ),
                AutoSizeText(
                  textCenter,
                  style: const TextStyle(
                      color: AppColors.golden, fontWeight: FontWeight.w600),
                ),
              ],
            ),
            istextBottom
                ? SizedBox(
                    width: 100,
                    child: AutoSizeText(
                      textBottom,
                      maxLines: 3,
                      textAlign: TextAlign.center,
                      style: const TextStyle(
                          fontSize: 8,
                          color: AppColors.grey,
                          fontWeight: FontWeight.w100),
                    ),
                  )
                : const SizedBox(),
          ],
        ),
      ],
    );
  }
}
