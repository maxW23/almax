// ignore_for_file: public_member_api_docs, sort_constructors_first

import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:lklk/core/constants/app_colors.dart';
import 'package:lklk/generated/l10n.dart';

import 'button_animated_part.dart';

class AnimatedContainerThreeButton extends StatelessWidget {
  const AnimatedContainerThreeButton({
    super.key,
    required this.onPressedWealth,
    required this.onPressedCharm,
    required this.onPressedTasks,
    required this.selectedTab,
  });
  final void Function()? onPressedWealth;
  final void Function()? onPressedCharm;
  final void Function()? onPressedTasks;
  final int selectedTab; // 0 = wealth, 1 = charm, 2 = tasks

  @override
  Widget build(BuildContext context) {
    return AnimatedContainer(
      duration: const Duration(milliseconds: 500),
      height: 40.h,
      width: 320.w,
      decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(30),
          color: AppColors.black.withValues(alpha: .5),
          border: Border.all(color: AppColors.black, width: .3)),
      child: Row(
        children: [
          Expanded(
            child: ButtonAnimatedPart(
              text: S.of(context).wealth,
              onPressed: onPressedWealth,
              isLevel: selectedTab == 0,
              icon: Icons.workspace_premium_outlined,
              selectedColor: AppColors.orangePinkColorBlack,
              unselectedColor: Colors.white,
            ),
          ),
          Expanded(
            child: ButtonAnimatedPart(
              text: S.of(context).charm,
              onPressed: onPressedCharm,
              isLevel: selectedTab == 1,
              icon: Icons.favorite_border,
              selectedColor: AppColors.pinkwhiteColorBlack,
              unselectedColor: Colors.white,
            ),
          ),
          Expanded(
            child: ButtonAnimatedPart(
              text: S.of(context).tasks,
              onPressed: onPressedTasks,
              isLevel: selectedTab == 2,
              icon: Icons.check_circle_outline,
              selectedColor: const Color(0xFF4A90E2),
              unselectedColor: Colors.white,
            ),
          ),
        ],
      ),
    );
  }
}
