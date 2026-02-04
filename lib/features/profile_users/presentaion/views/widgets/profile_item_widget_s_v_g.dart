// ignore_for_file: public_member_api_docs, sort_constructors_first

import 'package:flutter/material.dart';
import 'package:auto_size_text/auto_size_text.dart';
import 'package:lklk/core/constants/app_colors.dart';
import 'package:flutter_svg/flutter_svg.dart';

class ProfileItemWidgetProfile extends StatelessWidget {
  const ProfileItemWidgetProfile({
    super.key,
    this.fillColor = false,
    required this.icon,
    required this.title,
    this.description = "",
    this.backgroundColor = AppColors.secondColor,
    this.iconColor = AppColors.white,
    this.onTap,
    this.isArabic = false,
  });
  final bool fillColor;
  final String icon;
  final String title;
  final String description;
  final Color backgroundColor;
  final Color iconColor;
  final Function()? onTap;
  final bool isArabic;
  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        ListTile(
          onTap: onTap,
          leading: icon.toLowerCase().endsWith('.svg')
              ? SvgPicture.asset(
                  icon,
                  width: 30,
                  fit: BoxFit.cover,
                  height: 30,
                )
              : Image.asset(
                  icon,
                  width: 30,
                  height: 30,
                ),
          title: AutoSizeText(
            title,
            maxLines: 1,
            minFontSize: 14,
            stepGranularity: 0.5,
            overflow: TextOverflow.ellipsis,
            style: const TextStyle(
              fontSize: 18.0,
              fontWeight: FontWeight.w400,
              letterSpacing: 0.2,
              height: 1.2,
              color: AppColors.black,
            ),
          ),
          dense: false,
          subtitle: description.isNotEmpty
              ? AutoSizeText(
                  description,
                  maxLines: 2,
                  minFontSize: 10,
                  stepGranularity: 0.5,
                  overflow: TextOverflow.ellipsis,
                  style: TextStyle(
                    fontSize: 13.0,
                    fontWeight: FontWeight.w400,
                    letterSpacing: 0.1,
                    height: 1.3,
                    color: AppColors.grey,
                  ),
                )
              : null,
          trailing: Icon(isArabic
              ? Icons.keyboard_arrow_left
              : Icons.keyboard_arrow_right),
        ),
        // const Divider(height: 0.0, thickness: 0.3, indent: 20, endIndent: 30),
      ],
    );
  }
}
