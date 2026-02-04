import 'package:flutter/material.dart';
import 'package:auto_size_text/auto_size_text.dart';
import '../../../../../core/constants/app_colors.dart';

class CustomTextButtonIcon extends StatelessWidget {
  const CustomTextButtonIcon({
    super.key,
    required this.buttonHeight,
    required this.iconHeight,
    required this.iconpadding,
    required this.text,
    required this.icon,
    required this.sizeIcon,
    this.onPressed,
  });
  final double buttonHeight;
  final double iconHeight;
  final EdgeInsetsGeometry iconpadding;

  final String text;
  final IconData icon;
  final double sizeIcon;
  final void Function()? onPressed;
  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: buttonHeight,
      child: TextButton.icon(
        style: ButtonStyle(
          backgroundColor: WidgetStateProperty.resolveWith<Color?>(
            (Set<WidgetState> states) {
              // Return the primary color regardless of state
              return AppColors.graywhite.withValues(alpha: 0.5);
            },
          ),
        ),
        icon: Icon(
          icon,
          size: sizeIcon,
          color: AppColors.black, // Set icon color to primary color,
        ),
        //  Container(
        //   height: iconHeight,
        //   padding: iconpadding, // Adjust padding as needed
        //   decoration: BoxDecoration(
        //     color: AppColors.secondColorsemi,
        //     borderRadius:
        //         BorderRadius.circular(30), // Optional: Set border radius
        //   ),
        //   child: Icon(
        //     icon,
        //     size: sizeIcon,
        //     color: AppColors.white, // Set icon color to primary color,
        //   ),
        // ),
        onPressed: onPressed,
        label: AutoSizeText(
          text,
          style: const TextStyle(
              color: AppColors.black,
              fontSize: 14,
              fontWeight: FontWeight.bold),
        ),
      ),
    );
  }
}
