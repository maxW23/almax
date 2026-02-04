// ignore_for_file: public_member_api_docs, sort_constructors_first

import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:lklk/core/constants/app_colors.dart';
import 'package:lklk/generated/l10n.dart';

import 'button_animated_part.dart';

class AnimatedContainerTwoButton extends StatelessWidget {
  const AnimatedContainerTwoButton({
    super.key,
    required this.onPressedWealth,
    required this.onPressedCharm,
    required this.isLevel,
  });
  final void Function()? onPressedWealth;
  final void Function()? onPressedCharm;
  final bool isLevel;
  @override
  Widget build(BuildContext context) {
    return AnimatedContainer(
      duration: Duration(milliseconds: 500),
      height: 40.h,
      width: 220.w,
      decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(30),
          color: AppColors.black.withValues(alpha: .5),
          border: Border.all(color: AppColors.black, width: .3)),
      child: Row(
        children: [
          ButtonAnimatedPart(
            text: S.of(context).wealth,
            onPressed: onPressedWealth,
            isLevel: isLevel,
            icon: Icons.workspace_premium_outlined,
            selectedColor: AppColors.orangePinkColorBlack,
            unselectedColor: Colors.white,
          ),
          const Spacer(),
          ButtonAnimatedPart(
            text: S.of(context).charm,
            onPressed: onPressedCharm,
            isLevel: !isLevel,
            icon: Icons.favorite_border,
            selectedColor: AppColors.pinkwhiteColorBlack,
            unselectedColor: Colors.white,
          ),
        ],
      ),
    );
  }
}
