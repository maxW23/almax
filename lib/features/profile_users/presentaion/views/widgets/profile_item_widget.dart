// ignore_for_file: public_member_api_docs, sort_constructors_first

import 'package:flutter/material.dart';
import 'package:auto_size_text/auto_size_text.dart';
import 'package:lklk/core/constants/app_colors.dart';
import 'package:flutter_svg/flutter_svg.dart';

class ProfileItemWidget extends StatelessWidget {
  const ProfileItemWidget({
    super.key,
    this.fillColor = false,
    this.icon = Icons.attach_money,
    required this.title,
    this.description = "",
    this.backgroundColor = AppColors.primary,
    this.iconColor = AppColors.white,
    this.onTap,
    required this.selectedLanguage,
    this.svgAsset,
    this.showDivider = true,
  });

  final bool fillColor;
  final IconData icon;
  final String title;
  final String description;
  final Color backgroundColor;
  final Color iconColor;
  final Function()? onTap;
  final String selectedLanguage;
  final String? svgAsset;
  final bool showDivider;

  @override
  Widget build(BuildContext context) {
    final bool isDisabled = onTap == null;
    return Column(
      children: [
        ListTile(
          onTap: isDisabled ? null : onTap,
          leading: Container(
            width: 40,
            height: 40,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              gradient: (fillColor && svgAsset == null)
                  ? const LinearGradient(
                      colors: [AppColors.primary, AppColors.secondColor],
                      begin: Alignment.topLeft,
                      end: Alignment.bottomRight,
                    )
                  : null,
              color: (fillColor && svgAsset == null) ? null : Colors.transparent,
            ),
            alignment: Alignment.center,
            child: svgAsset != null
                ? Opacity(
                    opacity: isDisabled ? 0.5 : 1,
                    child: SvgPicture.asset(
                      svgAsset!,
                      width: 30,
                      height: 30,
                      fit: BoxFit.cover,
                    ),
                  )
                : Icon(
                    icon,
                    size: 30,
                    color: isDisabled ? Colors.grey : iconColor,
                  ),
          ),
          title: AutoSizeText(
            title,
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.w700,
              color: isDisabled ? Colors.grey : Colors.black,
            ),
          ),
          dense: false,
          subtitle: description.isNotEmpty ? AutoSizeText(description) : null,
          trailing: Icon(
            selectedLanguage == 'ar'
                ? Icons.keyboard_arrow_left
                : Icons.keyboard_arrow_right,
            color: isDisabled ? Colors.grey : Colors.black54,
          ),
        ),
        if (showDivider)
          const Divider(
            height: 0,
            thickness: 0.3,
            indent: 20,
            endIndent: 30,
          ),
      ],
    );
  }
}
