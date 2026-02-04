import 'package:flutter/material.dart';
import 'package:auto_size_text/auto_size_text.dart';
import 'package:lklk/core/constants/app_colors.dart';

class LevelITemShow extends StatelessWidget {
  const LevelITemShow({
    super.key,
    required this.colorOne,
    required this.colorTwo,
    required this.image,
    required this.levelText,
    required this.levelCount,
  });
  final Color colorOne;
  final Color colorTwo;
  final String image;
  final String levelText;
  final String levelCount;
  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        const Divider(),
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 50, vertical: 8),
          child: Row(
            children: [
              // CustomLevelWidgetIcon(
              //   colorOne: colorOne,
              //   colorTwo: colorTwo,
              //   text: levelCount,
              //   image: image,
              // ),
              Container(
                height: 16,
                width: 50,
                decoration: BoxDecoration(
                  image: DecorationImage(
                      image: AssetImage(image), fit: BoxFit.cover),
                ),
                alignment: Alignment.center,
                child: Padding(
                  padding: const EdgeInsets.only(left: 20),
                  child: AutoSizeText(
                    levelCount,
                    style: const TextStyle(
                        color: AppColors.white,
                        fontWeight: FontWeight.w700,
                        fontSize: 12),
                    textAlign: TextAlign.center,
                  ),
                ),
              ),
              const Spacer(),
              AutoSizeText(
                levelText,
                style: const TextStyle(
                  color: AppColors.grey,
                  fontSize: 10,
                  fontWeight: FontWeight.w600,
                ),
              )
            ],
          ),
        ),
      ],
    );
  }
}
