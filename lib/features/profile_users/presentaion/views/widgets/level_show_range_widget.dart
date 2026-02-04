import 'package:flutter/material.dart';
import 'package:auto_size_text/auto_size_text.dart';
import 'package:lklk/generated/l10n.dart';
import 'package:lklk/core/constants/app_colors.dart';
import 'package:lklk/core/constants/assets.dart';

import 'level_i_tem_show.dart';

class LevelShowRangeWidget extends StatelessWidget {
  const LevelShowRangeWidget({
    super.key,
    required this.selectedTab,
  });
  final int selectedTab; // 0 = wealth, 1 = charm, 2 = tasks

  String _getTaskBadge(int level) {
    if (level <= 20) return 'assets/badges/diamond_badges/1.png';
    if (level <= 40) return 'assets/badges/diamond_badges/2.png';
    if (level <= 80) return 'assets/badges/diamond_badges/3.png';
    if (level <= 160) return 'assets/badges/diamond_badges/4.png';
    if (level <= 320) return 'assets/badges/diamond_badges/5.png';
    return 'assets/badges/diamond_badges/6.png';
  }

  @override
  Widget build(BuildContext context) {
    // For tasks tab, show different level ranges with diamond badges
    if (selectedTab == 2) {
      return AnimatedContainer(
        duration: const Duration(milliseconds: 500),
        padding:
            const EdgeInsets.only(top: 25, bottom: 15, right: 15, left: 15),
        margin: const EdgeInsets.only(right: 20, left: 20, top: 40, bottom: 20),
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(25),
          color: AppColors.white,
          // gradient: LinearGradient(
          //   begin: Alignment.topLeft,
          //   end: Alignment.bottomRight,
          //   colors: [
          //     AppColors.white,
          //     AppColors.white,
          //   ],
          // ),
          boxShadow: [
            // BoxShadow(
            //   color: const Color(0xFF4A90E2).withValues(alpha: 0.12),
            //   blurRadius: 15,
            //   offset: const Offset(0, 5),
            //   spreadRadius: 2,
            // ),
            // BoxShadow(
            //   color: Colors.white.withValues(alpha: 0.7),
            //   blurRadius: 10,
            //   offset: const Offset(-3, -3),
            // ),
          ],
        ),
        child: Column(
          children: [
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 30, vertical: 5),
              child: Row(
                children: [
                  AutoSizeText(
                    S.of(context).levelIcon,
                    style: const TextStyle(
                      fontWeight: FontWeight.w700,
                      fontSize: 18,
                      color: Color(0xFF4A90E2),
                      letterSpacing: 0.5,
                    ),
                  ),
                  const Spacer(),
                  AutoSizeText(
                    S.of(context).levelRange,
                    style: const TextStyle(
                      fontWeight: FontWeight.w700,
                      fontSize: 18,
                      color: Color(0xFF4A90E2),
                      letterSpacing: 0.5,
                    ),
                  ),
                ],
              ),
            ),
            const Divider(
              thickness: 1.5,
              color: Color(0xFF4A90E2),
              indent: 20,
              endIndent: 20,
            ),
            const SizedBox(height: 10),
            LevelITemShow(
              colorOne: const Color(0xFF4A90E2),
              colorTwo: const Color(0xFF4A90E2).withValues(alpha: 0.6),
              image: _getTaskBadge(10),
              levelText: 'LV.1-20',
              levelCount: '1',
            ),
            LevelITemShow(
              colorOne: const Color(0xFF4A90E2),
              colorTwo: const Color(0xFF4A90E2).withValues(alpha: 0.6),
              image: _getTaskBadge(30),
              levelText: 'LV.21-40',
              levelCount: '21',
            ),
            LevelITemShow(
              colorOne: const Color(0xFF4A90E2),
              colorTwo: const Color(0xFF4A90E2).withValues(alpha: 0.6),
              image: _getTaskBadge(60),
              levelText: 'LV.41-80',
              levelCount: '41',
            ),
            LevelITemShow(
              colorOne: const Color(0xFF4A90E2),
              colorTwo: const Color(0xFF4A90E2).withValues(alpha: 0.6),
              image: _getTaskBadge(120),
              levelText: 'LV.81-160',
              levelCount: '81',
            ),
            LevelITemShow(
              colorOne: const Color(0xFF4A90E2),
              colorTwo: const Color(0xFF4A90E2).withValues(alpha: 0.6),
              image: _getTaskBadge(240),
              levelText: 'LV.161-320',
              levelCount: '161',
            ),
            LevelITemShow(
              colorOne: const Color(0xFF4A90E2),
              colorTwo: const Color(0xFF4A90E2).withValues(alpha: 0.6),
              image: _getTaskBadge(400),
              levelText: 'LV.320+',
              levelCount: '320',
            ),
          ],
        ),
      );
    }

    // Original code for wealth (0) and charm (1) tabs
    final bool isLevel = selectedTab == 0;
    return AnimatedContainer(
      duration: const Duration(milliseconds: 500),
      padding: const EdgeInsets.only(top: 20, bottom: 10, right: 10, left: 10),
      margin: const EdgeInsets.only(right: 20, left: 20, top: 40, bottom: 20),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(20),
        color: AppColors.white,
      ),
      child: Column(
        children: [
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 30),
            child: Row(
              children: [
                AutoSizeText(
                  S.of(context).levelIcon,
                  style: const TextStyle(
                    fontWeight: FontWeight.w700,
                    fontSize: 18,
                  ),
                ),
                const Spacer(),
                AutoSizeText(
                  S.of(context).levelRange,
                  style: const TextStyle(
                    fontWeight: FontWeight.w700,
                    fontSize: 18,
                  ),
                ),
              ],
            ),
          ),
          LevelITemShow(
            colorOne:
                isLevel ? AppColors.levelShieldOneG : AppColors.levelShieldOneR,
            colorTwo: isLevel
                ? AppColors.levelShieldOneGColorTwo
                : AppColors.levelShieldOneRColorTwo,
            image: isLevel ? AssetsData.levelImage1 : AssetsData.levelImage7,
            levelText: 'LV.1-9',
            levelCount: '1',
          ),
          LevelITemShow(
            colorOne:
                isLevel ? AppColors.levelShieldTwoG : AppColors.levelShieldTwoR,
            colorTwo: isLevel
                ? AppColors.levelShieldTwoGColorTwo
                : AppColors.levelShieldTwoRColorTwo,
            image: isLevel ? AssetsData.levelImage2 : AssetsData.levelImage8,
            levelText: 'LV.10-19',
            levelCount: '10',
          ),
          LevelITemShow(
            colorOne: isLevel
                ? AppColors.levelShieldThreeG
                : AppColors.levelShieldThreeR,
            colorTwo: isLevel
                ? AppColors.levelShieldThreeGColorTwo
                : AppColors.levelShieldThreeRColorTwo,
            image: isLevel ? AssetsData.levelImage3 : AssetsData.levelImage9,
            levelText: 'LV.20-29',
            levelCount: '20',
          ),
          LevelITemShow(
            colorOne: isLevel
                ? AppColors.levelShieldFourG
                : AppColors.levelShieldFourR,
            colorTwo: isLevel
                ? AppColors.levelShieldFourGColorTwo
                : AppColors.levelShieldFourRColorTwo,
            image: isLevel ? AssetsData.levelImage4 : AssetsData.levelImage10,
            levelText: 'LV.30-39',
            levelCount: '30',
          ),
          LevelITemShow(
            colorOne: isLevel
                ? AppColors.levelShieldFiveG
                : AppColors.levelShieldFiveR,
            colorTwo: isLevel
                ? AppColors.levelShieldFiveGColorTwo
                : AppColors.levelShieldFiveRColorTwo,
            image: isLevel ? AssetsData.levelImage5 : AssetsData.levelImage11,
            levelText: 'LV.40-49',
            levelCount: '40',
          ),
          LevelITemShow(
            colorOne: isLevel
                ? AppColors.levelShieldFiveG
                : AppColors.levelShieldFiveR,
            colorTwo: isLevel
                ? AppColors.levelShieldFiveGColorTwo
                : AppColors.levelShieldFiveRColorTwo,
            image: isLevel ? AssetsData.levelImage6 : AssetsData.levelImage12,
            levelText: 'LV.50',
            levelCount: '50',
          ),
        ],
      ),
    );
  }
}
