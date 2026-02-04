import 'package:flutter/material.dart';
import 'package:auto_size_text/auto_size_text.dart';
import 'package:lklk/generated/l10n.dart';

import '../../../../../core/constants/app_colors.dart';

class SlidingText extends StatelessWidget {
  const SlidingText({
    super.key,
    required this.slidingAnimation,
  });

  final Animation<Offset> slidingAnimation;

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
        animation: slidingAnimation,
        builder: (context, _) {
          return SlideTransition(
            position: slidingAnimation,
            child: AutoSizeText(
              S.of(context).enjoyWithChatingAandVoiceCallsRooms,
              style: const TextStyle(fontSize: 16, color: AppColors.white),
              textAlign: TextAlign.center,
            ),
          );
        });
  }
}
