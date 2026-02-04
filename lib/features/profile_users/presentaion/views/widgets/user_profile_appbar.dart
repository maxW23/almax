import 'package:flutter/material.dart';
import 'package:auto_size_text/auto_size_text.dart';
import '../../../../../core/constants/app_colors.dart';
import 'package:lklk/generated/l10n.dart';

class UserProfileAppbar extends StatelessWidget implements PreferredSizeWidget {
  const UserProfileAppbar({super.key});

  @override
  Size get preferredSize => const Size.fromHeight(kToolbarHeight);

  @override
  Widget build(BuildContext context) {
    return PreferredSize(
        preferredSize: const Size(double.infinity, kToolbarHeight),
        child: AppBar(
            backgroundColor: AppColors.transparent,
            title: AutoSizeText(
              S.of(context).userProfile,
              style: const TextStyle(color: AppColors.black),
            ),
            centerTitle: true,
            automaticallyImplyLeading: false));
  }
}
