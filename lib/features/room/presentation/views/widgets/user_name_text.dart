import 'package:flutter/material.dart';
import 'package:auto_size_text/auto_size_text.dart';
import 'package:lklk/core/constants/app_colors.dart';
import 'package:lklk/core/constants/styles.dart';

class UserNameText extends StatelessWidget {
  final String userName;

  const UserNameText({
    super.key,
    required this.userName,
  });

  @override
  Widget build(BuildContext context) {
    return AutoSizeText(
      userName,
      textAlign: TextAlign.center,
      maxLines: 2,
      overflow: TextOverflow.ellipsis,
      style: Styles.textStyle12bold.copyWith(
        color: AppColors.whiteIcon,
      ),
    );
  }
}
