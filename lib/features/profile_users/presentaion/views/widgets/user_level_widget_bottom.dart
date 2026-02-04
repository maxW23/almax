// ignore_for_file: public_member_api_docs, sort_constructors_first

import 'package:flutter/material.dart';
import 'package:auto_size_text/auto_size_text.dart';
import 'package:lklk/generated/l10n.dart';
import 'package:lklk/core/constants/app_colors.dart';
import 'package:lklk/features/auth/domain/entities/user_entity.dart';

class UserLevelWidgetBottom extends StatefulWidget {
  final UserEntity user;
  final int selectedTab; // 0 = wealth, 1 = charm, 2 = tasks

  const UserLevelWidgetBottom({
    super.key,
    required this.user,
    required this.selectedTab,
  });

  @override
  State<UserLevelWidgetBottom> createState() => _UserLevelWidgetBottomState();
}

class _UserLevelWidgetBottomState extends State<UserLevelWidgetBottom> {
  // int getUserLevel(int userMon) {
  //   int level = 0;

  //   if (userMon >= 3815 && userMon < 7631) {
  //     level = 1;
  //   } else if (userMon >= 7631 && userMon < 11428) {
  //     level = 2;
  //   } else if (userMon >= 11428 && userMon < 15243) {
  //     level = 3;
  //   } else if (userMon >= 15243 && userMon < 19058) {
  //     level = 4;
  //   } else if (userMon >= 19058 && userMon < 22873) {
  //     level = 5;
  //   } else if (userMon >= 22873 && userMon < 226688) {
  //     level = 6;
  //   } else if (userMon >= 226688 && userMon < 30503) {
  //     level = 7;
  //   } else if (userMon >= 30503 && userMon < 34318) {
  //     level = 8;
  //   } else if (userMon >= 34318 && userMon < 38133) {
  //     level = 9;
  //   } else if (userMon >= 38133 && userMon < 41948) {
  //     level = 10;
  //   } else if (userMon >= 41948 && userMon < 45763) {
  //     level = 11;
  //   } else if (userMon >= 45763 && userMon < 49578) {
  //     level = 12;
  //   } else if (userMon >= 49578 && userMon < 53420) {
  //     level = 13;
  //   } else if (userMon >= 53420 && userMon < 90027) {
  //     level = 14;
  //   } else if (userMon >= 90027 && userMon < 126634) {
  //     level = 15;
  //   } else if (userMon >= 126634 && userMon < 163241) {
  //     level = 16;
  //   } else if (userMon >= 163241 && userMon < 199848) {
  //     level = 17;
  //   } else if (userMon >= 199848 && userMon < 236455) {
  //     level = 18;
  //   } else if (userMon >= 236455 && userMon < 273062) {
  //     level = 19;
  //   } else if (userMon >= 273062 && userMon < 309669) {
  //     level = 20;
  //   } else if (userMon >= 309669 && userMon < 346276) {
  //     level = 21;
  //   } else if (userMon >= 346276 && userMon < 382883) {
  //     level = 22;
  //   } else if (userMon >= 382883 && userMon < 419390) {
  //     level = 23;
  //   } else if (userMon >= 419390 && userMon < 456097) {
  //     level = 24;
  //   } else if (userMon >= 456097 && userMon < 492704) {
  //     level = 25;
  //   } else if (userMon >= 492704 && userMon < 529311) {
  //     level = 26;
  //   } else if (userMon >= 529311 && userMon < 565918) {
  //     //
  //     level = 27;
  //   } else if (userMon >= 565918 && userMon < 585720) {
  //     level = 28;
  //   } else if (userMon >= 585720 && userMon < 768154) {
  //     level = 29;
  //   } else if (userMon >= 768154 && userMon < 930588) {
  //     level = 30;
  //   } else if (userMon >= 930588 && userMon < 1103022) {
  //     level = 31;
  //   } else if (userMon >= 1103022 && userMon < 1275456) {
  //     level = 32;
  //   } else if (userMon >= 1275456 && userMon < 1447890) {
  //     level = 33;
  //   } else if (userMon >= 1447890 && userMon < 1620324) {
  //     level = 34;
  //   } else if (userMon >= 1620324 && userMon < 1792758) {
  //     level = 35;
  //   } else if (userMon >= 1792758 && userMon < 1965192) {
  //     level = 36;
  //   } else if (userMon >= 1965192 && userMon < 2137626) {
  //     level = 37;
  //   } else if (userMon >= 2137626 && userMon < 2310060) {
  //     level = 38;
  //   } else if (userMon >= 2310060 && userMon < 2964605) {
  //     level = 39;
  //   } else if (userMon >= 2964605 && userMon < 3619150) {
  //     level = 40;
  //   } else if (userMon >= 3619150 && userMon < 4273695) {
  //     level = 41;
  //   } else if (userMon >= 4273695 && userMon < 4928240) {
  //     level = 42;
  //   } else if (userMon >= 4928240 && userMon < 5582785) {
  //     level = 43;
  //   } else if (userMon >= 5582785 && userMon < 6237330) {
  //     level = 44;
  //   } else if (userMon >= 6237330 && userMon < 6891875) {
  //     level = 45;
  //   } else if (userMon >= 6891875 && userMon < 7546420) {
  //     level = 46;
  //   } else if (userMon >= 7546420 && userMon < 8200965) {
  //     level = 47;
  //   } else if (userMon >= 8200965 && userMon < 8855510) {
  //     level = 48;
  //   } else if (userMon >= 8855510 && userMon < 9510050) {
  //     level = 49;
  //   } else if (userMon >= 9510050) {
  //     level = 50;
  //   }
  //   /*

  //  */

  //   else {
  //     level = 0;
  //   }

  //   return level;
  // }

  @override
  Widget build(BuildContext context) {
    // final int userMon = int.tryParse(widget.isLevel
    //         ? widget.user.mon ?? '0'
    //         : widget.user.rmonLevelTwo ?? '0') ??
    0;
    // final int level = getUserLevel(userMon);

    String experience = widget.selectedTab == 0
        ? widget.user.monLevel ?? '0'
        : widget.selectedTab == 1
            ? widget.user.rmonLevelTwo ?? '0'
            : widget.user.level3 ?? '0';

    return AnimatedContainer(
      duration: const Duration(milliseconds: 500),
      margin: const EdgeInsets.symmetric(horizontal: 0),
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
      decoration: BoxDecoration(
        color: AppColors.white,
        borderRadius: const BorderRadius.only(
          bottomLeft: Radius.circular(25),
          bottomRight: Radius.circular(25),
        ),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.08),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Row(
        children: [
          const SizedBox(width: 5),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                AutoSizeText(
                  widget.selectedTab == 0
                      ? "LV.${int.parse(widget.user.level1 ?? '0')}"
                      : widget.selectedTab == 1
                          ? "LV.${int.parse(widget.user.level2 ?? '0')}"
                          : "LV.${int.parse(widget.user.newlevel3 ?? '0')}",
                  style: const TextStyle(
                    color: AppColors.blackshade1,
                    fontSize: 16,
                    fontWeight: FontWeight.w800,
                    letterSpacing: 0.5,
                  ),
                ),
                const SizedBox(height: 4),
                AutoSizeText(
                  S.of(context).yourLevel,
                  style: const TextStyle(
                    color: AppColors.blackshade2,
                    fontSize: 13,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ],
            ),
          ),
          Container(
            width: 1.5,
            height: 40,
            decoration: BoxDecoration(
              gradient: LinearGradient(
                begin: Alignment.topCenter,
                end: Alignment.bottomCenter,
                colors: [
                  Colors.grey.withValues(alpha: 0.1),
                  Colors.grey.withValues(alpha: 0.4),
                  Colors.grey.withValues(alpha: 0.1),
                ],
              ),
            ),
          ),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.end,
              children: [
                AutoSizeText(
                  experience,
                  style: const TextStyle(
                    color: AppColors.blackshade1,
                    fontSize: 16,
                    fontWeight: FontWeight.w800,
                    letterSpacing: 0.5,
                  ),
                ),
                const SizedBox(height: 4),
                AutoSizeText(
                  S.of(context).yourExperience,
                  style: const TextStyle(
                    color: AppColors.blackshade2,
                    fontSize: 13,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(width: 5),
        ],
      ),
    );
  }
}
