import 'package:flutter/material.dart';
import 'package:lklk/features/cp_challenge/presentation/views/cp_challenge_page.dart';
import 'animated_top_button.dart';
import 'animated_relation_button.dart';
import 'package:lklk/features/home/presentation/views/slide_view/tap_bar_top_50_page.dart';
import 'package:lklk/features/profile_users/presentaion/manger/user_cubit/user_cubit_cubit.dart';

/// Widget رئيسي يعرض قسم الأزرار الأربعة (Wealth, Attraction, Room, Relation)
/// في صفين، كل صف يحتوي على زرين
class TopButtonsSection extends StatelessWidget {
  const TopButtonsSection({super.key, required this.userCubit});

  final UserCubit userCubit;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 10),
      child: Column(
        children: [
          // الصف الأول: Wealth و Attraction
          Row(
            children: [
              // زر Wealth (الثروة) - API code 44
              Expanded(
                child: AspectRatio(
                  aspectRatio: 3, // نسبة العرض إلى الارتفاع للزر
                  child: AnimatedTopButton(
                    buttonImagePath: 'assets/top_frames/wealth_btn_top.png',
                    apiCode: 44, // API للثروة
                    frameImagePath: 'assets/top_frames/frame_for_top_btn.png',
                    onTap: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (context) => TapBarTop50Page(
                            userCubit: userCubit,
                            initialTabIndex: 2, // Wealth tab
                          ),
                        ),
                      );
                    },
                  ),
                ),
              ),

              const SizedBox(width: 8), // مسافة بين الزرين

              // زر Attraction (الجاذبية) - API code 55
              Expanded(
                child: AspectRatio(
                  aspectRatio: 3,
                  child: AnimatedTopButton(
                    buttonImagePath: 'assets/top_frames/attraction_btn_top.png',
                    apiCode: 55, // API للجاذبية
                    frameImagePath: 'assets/top_frames/frame_for_top_btn.png',
                    onTap: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (context) => TapBarTop50Page(
                            userCubit: userCubit,
                            initialTabIndex: 3, // Attraction tab
                          ),
                        ),
                      );
                    },
                  ),
                ),
              ),
            ],
          ),

          const SizedBox(height: 8), // مسافة بين الصفين

          // الصف الثاني: Room و Relation
          Row(
            children: [
              // زر Room (الغرفة) - API toproom1
              Expanded(
                child: AspectRatio(
                  aspectRatio: 3,
                  child: AnimatedTopButton(
                    buttonImagePath: 'assets/top_frames/room_btn_top.png',
                    apiCode: 1, // API للغرف (toproom1)
                    frameImagePath: 'assets/top_frames/frame_for_top_btn.png',
                    onTap: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (context) => TapBarTop50Page(
                            userCubit: userCubit,
                            initialTabIndex: 0, // Rooms tab
                          ),
                        ),
                      );
                    },
                  ),
                ),
              ),

              const SizedBox(width: 8), // مسافة بين الزرين

              // زر Relation (العلاقات) - API code 88
              Expanded(
                child: AspectRatio(
                  aspectRatio: 3,
                  child: AnimatedRelationButton(
                    buttonImagePath: 'assets/top_frames/relation_btn_top.png',
                    frameImagePath: 'assets/top_frames/frame_for_top_btn.png',
                    heartIconPath:
                        'assets/images/my_profile_icon/relation_bar/relation_herat_stand.png',
                    onTap: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                            builder: (context) => CpChallengePage()),
                      );
                    },
                  ),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}
