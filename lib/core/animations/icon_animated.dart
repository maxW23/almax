import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:auto_size_text/auto_size_text.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:lklk/core/constants/app_colors.dart';

class AnimatedIconButton extends StatelessWidget {
  const AnimatedIconButton({
    super.key,
    required this.text,
    required this.onPressed,
    required this.isBanned,
  });

  final String text;
  final VoidCallback onPressed;
  final bool isBanned;

  @override
  Widget build(BuildContext context) {
    return TextButton(
      onPressed: onPressed,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.center,
        mainAxisSize: MainAxisSize.min,
        children: [
          AnimatedSwitcher(
            duration: const Duration(milliseconds: 300),
            transitionBuilder: (child, animation) {
              return RotationTransition(turns: animation, child: child);
            },
            child: Icon(
              isBanned
                  ? FontAwesomeIcons.userCheck
                  : FontAwesomeIcons.userSlash,
              key: ValueKey<bool>(isBanned),
              color: AppColors.black,
              size: 25.r,
            ),
          ),
          AutoSizeText(
            text,
            minFontSize: 8,
            maxFontSize: 12,
            style: const TextStyle(
              color: AppColors.black,
              fontSize: 11,
              fontWeight: FontWeight.w400,
            ),
          ),
        ],
      ),
    );
  }
}
