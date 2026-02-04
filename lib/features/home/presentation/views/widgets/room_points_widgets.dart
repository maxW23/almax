import 'package:flutter/material.dart';
import 'package:auto_size_text/auto_size_text.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';

import '../../../../../core/constants/app_colors.dart';

class RoomPointsWidgets extends StatelessWidget {
  const RoomPointsWidgets({
    super.key,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.only(bottom: 16, right: 4),
      decoration: BoxDecoration(
          color: AppColors.blackWithOpacity5,
          borderRadius: BorderRadius.circular(30)),
      width: 55,
      height: 20,
      child: Row(
        mainAxisAlignment: MainAxisAlignment.center,
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          FaIcon(
            FontAwesomeIcons.fire,
            color: AppColors.danger.withValues(alpha: .8),
            size: 14,
          ),
          const SizedBox(
            width: 4,
          ),
          const AutoSizeText('9999'),
        ],
      ),
    );
  }
}
