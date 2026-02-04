import 'package:flutter/material.dart';
import 'package:lklk/core/constants/app_colors.dart';

class RoomsContainerJoker extends StatelessWidget {
  const RoomsContainerJoker({
    super.key,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.only(bottom: 7),
      height: 110,
      decoration: BoxDecoration(
        color: AppColors.grey.withValues(alpha: .6),
        borderRadius: const BorderRadius.all(
          Radius.circular(4),
        ),
        boxShadow: [
          BoxShadow(
            color: AppColors.grey.withValues(alpha: .5),
            blurRadius: 1,
            spreadRadius: .4,
            blurStyle: BlurStyle.inner,
          ),
        ],
      ),
    );
  }
}
