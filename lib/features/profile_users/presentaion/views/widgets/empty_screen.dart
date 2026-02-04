// ignore_for_file: public_member_api_docs, sort_constructors_first

import 'package:flutter/material.dart';
import 'package:auto_size_text/auto_size_text.dart';
import 'package:lklk/generated/l10n.dart';
import 'package:lklk/core/constants/app_colors.dart';
import 'package:lklk/core/constants/assets.dart';
import 'package:lklk/core/constants/styles.dart';

class EmptyScreen extends StatelessWidget {
  const EmptyScreen({
    super.key,
  });

  @override
  Widget build(BuildContext context) {
    return Center(
        child: Column(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        Image.asset(
          AssetsData.logoWhite,
          color: Colors.grey.withValues(alpha: .5),
          width: 200,
          height: 200,
        ),
        AutoSizeText(
          S.of(context).emptyList,
          style: Styles.textStyle20
              .copyWith(color: AppColors.grey.withValues(alpha: .5)),
        ),
      ],
    ));
  }
}
