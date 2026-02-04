// ignore_for_file: public_member_api_docs, sort_constructors_first

import 'package:flutter/material.dart';
import 'package:auto_size_text/auto_size_text.dart';
import 'package:lklk/generated/l10n.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:lklk/core/constants/app_colors.dart';
import 'package:lklk/core/constants/assets.dart';

class CharmInfoUpgrade extends StatelessWidget {
  const CharmInfoUpgrade({
    super.key,
  });

  @override
  Widget build(BuildContext context) {
    return AnimatedContainer(
      duration: const Duration(milliseconds: 500),
      padding: const EdgeInsets.only(top: 20, bottom: 10, right: 10, left: 10),
      margin: const EdgeInsets.only(right: 20, left: 20, top: 40, bottom: 20),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(20),
        color: AppColors.white,
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          AutoSizeText(
            S.of(context).howToUpgrade,
            textAlign: TextAlign.center,
            style: const TextStyle(
                color: AppColors.black, fontWeight: FontWeight.bold),
          ),
          const Divider(),
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              Container(
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    gradient: LinearGradient(colors: [
                      AppColors.pinkwhiteTwoColor,
                      AppColors.pinkwhiteColor.withValues(alpha: .4),
                    ])),
                child: const Center(
                    child: Icon(
                  FontAwesomeIcons.gift,
                  color: AppColors.pinkwhiteColor,
                )),
              ),
              const SizedBox(
                width: 10,
              ),
              Column(
                mainAxisAlignment: MainAxisAlignment.center,
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  AutoSizeText(
                    '${S.of(context).diamondGifts} ',
                    style: const TextStyle(
                        color: AppColors.black, fontWeight: FontWeight.w400),
                  ),
                  const SizedBox(
                    height: 5,
                  ),
                  Row(
                    children: [
                      Image.asset(
                        AssetsData.diamondImg,
                        height: 20,
                        width: 20,
                      ),
                      const SizedBox(
                        width: 5,
                      ),
                      AutoSizeText(
                        '${S.of(context).diamondExperince} ',
                        style: const TextStyle(
                            color: AppColors.pinkwhiteColor,
                            fontWeight: FontWeight.w400),
                      ),
                    ],
                  ),
                ],
              ),
            ],
          ),
          const SizedBox(
            height: 10,
          ),
        ],
      ),
    );
  }
}
