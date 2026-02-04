import 'package:flutter/material.dart';
import 'package:auto_size_text/auto_size_text.dart';
import 'package:flutter_svg/flutter_svg.dart';

class ButtonIconWithTextWidget extends StatelessWidget {
  const ButtonIconWithTextWidget({
    super.key,
    this.colorIcon,
    this.colorText,
    this.icon,
    this.svgAsset,
    required this.text,
  });
  final Color? colorIcon;
  final Color? colorText;
  final IconData? icon;
  final String? svgAsset;
  final String text;
  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        if (svgAsset != null)
          SvgPicture.asset(
            svgAsset!,
            width: 24,
            height: 24,
            // If the asset is monochrome and supports color, apply it; otherwise the asset color will be used.
            colorFilter: colorIcon != null
                ? ColorFilter.mode(colorIcon!, BlendMode.srcIn)
                : null,
          )
        else
          Icon(
            icon,
            color: colorIcon,
          ),
        AutoSizeText(
          text,
          minFontSize: 8,
          maxFontSize: 12,
          textAlign: TextAlign.center,
          style: TextStyle(
            color: colorText,
            fontWeight: FontWeight.w800,
          ),
        ),
      ],
    );
  }
}
