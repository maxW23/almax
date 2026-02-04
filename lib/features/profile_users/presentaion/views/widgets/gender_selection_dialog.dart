import 'package:flutter/material.dart';
import 'package:auto_size_text/auto_size_text.dart';
import 'package:lklk/core/constants/app_colors.dart';
import 'package:lklk/generated/l10n.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';

class GenderSelectionDialog extends StatelessWidget {
  const GenderSelectionDialog({super.key});

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: AutoSizeText(
        S.of(context).selectGender,
        textAlign: TextAlign.center,
      ),
      content: Row(
        mainAxisSize: MainAxisSize.min,
        mainAxisAlignment: MainAxisAlignment.spaceEvenly,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: <Widget>[
          InkWell(
            onTap: () {
              Navigator.of(context).pop("male");
            },
            child: Row(
              children: <Widget>[
                const Icon(
                  FontAwesomeIcons.male,
                  color: AppColors.primary,
                ),
                const SizedBox(width: 10),
                AutoSizeText(
                  S.of(context).male,
                  style: const TextStyle(
                      color: AppColors.primary, fontWeight: FontWeight.w700),
                ),
              ],
            ),
          ),
          const SizedBox(height: 10),
          InkWell(
            onTap: () {
              Navigator.of(context).pop("female");
            },
            child: Row(
              children: <Widget>[
                const Icon(
                  FontAwesomeIcons.female,
                  color: AppColors.secondColorDark,
                ),
                const SizedBox(width: 10),
                AutoSizeText(
                  S.of(context).female,
                  style: const TextStyle(
                      color: AppColors.secondColorDark,
                      fontWeight: FontWeight.w700),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
