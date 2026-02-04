// ignore_for_file: public_member_api_docs, sort_constructors_first

import 'package:flutter/material.dart';
import 'package:auto_size_text/auto_size_text.dart';
import 'package:lklk/generated/l10n.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:lklk/core/constants/app_colors.dart';

import 'info_widget_item.dart';

class WealthInfoUpgrade extends StatelessWidget {
  const WealthInfoUpgrade({super.key});

  @override
  Widget build(BuildContext context) {
    return AnimatedContainer(
      duration: const Duration(milliseconds: 500),
      padding: const EdgeInsets.only(top: 20, bottom: 10, right: 10, left: 10),
      margin: const EdgeInsets.only(right: 20, left: 20, top: 40, bottom: 20),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(20),
        color: AppColors.white,
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          AutoSizeText(
            S.of(context).howToUpgrade,
            textAlign: TextAlign.center,
            style: const TextStyle(
                color: AppColors.black, fontWeight: FontWeight.bold),
          ),
          const Divider(),
          InfoWidgetItem(
            icon: FontAwesomeIcons.gift,
            textUP: S.of(context).sendGift,
            textCenter: S.of(context).coins4Expernice,
            textBottom: S.of(context).coins4ExperniceTitle,
          ),
          const SizedBox(
            height: 4,
          ),
          const Divider(
            indent: 50,
            endIndent: 50,
          ),
          const SizedBox(
            height: 4,
          ),
          InfoWidgetItem(
            icon: FontAwesomeIcons.dice,
            textUP: S.of(context).playGame,
            textCenter: S.of(context).coins2Expernice,
            textBottom: '',
            istextBottom: false,
          ),
          const SizedBox(
            height: 4,
          ),
          const Divider(
            indent: 50,
            endIndent: 50,
          ),
          const SizedBox(
            height: 4,
          ),
          InfoWidgetItem(
            icon: FontAwesomeIcons.car,
            textUP: S.of(context).buyCar,
            textCenter: S.of(context).coins4Expernice,
            textBottom: '',
            istextBottom: false,
          ),
          const SizedBox(
            height: 4,
          ),
          const Divider(
            indent: 50,
            endIndent: 50,
          ),
          const SizedBox(
            height: 4,
          ),
          InfoWidgetItem(
            icon: FontAwesomeIcons.sun,
            textUP: S.of(context).buyFrame,
            textCenter: S.of(context).coins4Expernice,
            textBottom: '',
            istextBottom: false,
          ),
          const SizedBox(
            height: 4,
          ),
          const Divider(
            indent: 50,
            endIndent: 50,
          ),
          const SizedBox(
            height: 4,
          ),
          InfoWidgetItem(
            icon: FontAwesomeIcons.crown,
            textUP: S.of(context).buySVIP,
            textCenter: S.of(context).coins4Expernice,
            textBottom: '',
            istextBottom: false,
          ),
          const SizedBox(
            height: 14,
          ),
        ],
      ),
    );
  }
}
