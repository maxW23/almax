import 'package:flutter/material.dart';
import 'package:lklk/core/constants/app_colors.dart';
import 'package:lklk/core/constants/styles.dart';
import 'package:lklk/core/utils/gradient_text.dart';

import 'package:lklk/generated/l10n.dart';

class GiftTextMessage extends StatelessWidget {
  const GiftTextMessage({
    super.key,
    required this.giftReciver,
  });

  final String giftReciver;

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.end,
      children: [
        Flexible(
          child: GradientText(
            "${S.of(context).sendto} $giftReciver", // النص مدمج بشكل صحيح
            gradient: const LinearGradient(colors: [
              AppColors.orangePinkTwoColor,
              AppColors.pinkwhiteColor,
            ]),
            style: Styles.textStyle16.copyWith(
              color: AppColors.white,
              // يمكن إزالة overflow من هنا لأنه موجود في GradientText
            ),
            maxLines: 5, // ممتاز - يحدد 3 أسطر كحد أقصى
            overflow: TextOverflow.ellipsis, // ممتاز - يعرض ... عند القص
            textAlign: TextAlign.center, // إضافة محاذاة للنص إذا needed
          ),
        ),
      ],
    );
  }
}
