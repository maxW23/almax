import 'package:flutter/material.dart';
import 'package:lklk/core/constants/app_colors.dart';
import 'package:lklk/core/constants/assets.dart';
import 'package:lklk/core/constants/styles.dart';
import 'package:lklk/core/utils/gradient_text.dart';
import 'package:lklk/features/room/presentation/views/widgets/user_widget_title.dart';

class IslevelTrailingWidget extends StatelessWidget {
  const IslevelTrailingWidget({
    super.key,
    required this.widget,
  });

  final UserWidgetTitle widget;

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        GradientText(
          widget.numberOfCubitTopUsers == 4
              ? (widget.user.monLevel ?? "0000")
              : (widget.user.rmonLevelTwo ?? "0000"),
          // textDirectionBool: true,
          gradient: const LinearGradient(colors: [
            AppColors.goldenhad1,
            AppColors.brownshad1,
            AppColors.brownshad2,
            AppColors.goldenhad2,
          ]),
          style: const TextStyle(
            fontWeight: FontWeight.bold,
            fontSize: 10,
            shadows: [
              Shadow(
                color: Colors.black,
                offset: Offset(1, 1),
                blurRadius: 3,
              ),
            ],
          ),
        ),
        const SizedBox(
            width: 4), // Add spacing between text and image if needed
        Image.asset(
          AssetsData.coins,
          width: 16, // Adjust the size as needed
          height: 16, // Adjust the size as needed
        ),
      ],
    );
  }
}
