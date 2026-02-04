// ignore_for_file: public_member_api_docs, sort_constructors_first

import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:lklk/core/constants/app_colors.dart';
import 'package:lklk/features/auth/domain/entities/user_entity.dart';

import '../widgets/animated_container_three_button.dart';
import '../widgets/charm_info_upgrade.dart';
import '../widgets/level_show_range_widget.dart';
import '../widgets/user_level.dart';
import '../widgets/wealth_info_upgrade.dart';
import '../widgets/tasks_info_upgrade.dart';

class LevelPage extends StatefulWidget {
  final UserEntity user;

  const LevelPage({super.key, required this.user});

  @override
  State<LevelPage> createState() => _LevelPageState();
}

class _LevelPageState extends State<LevelPage> {
  int selectedTab = 0; // 0 = wealth, 1 = charm, 2 = tasks

  void onPressedWealth() {
    setState(() {
      selectedTab = 0;
    });
  }

  void onPressedCharm() {
    setState(() {
      selectedTab = 1;
    });
  }

  void onPressedTasks() {
    setState(() {
      selectedTab = 2;
    });
  }

  Color _getBackgroundColor() {
    switch (selectedTab) {
      case 0:
        return AppColors.orangePinkColor;
      case 1:
        return AppColors.pinkwhiteColor;
      case 2:
        return const Color(0xFF4A90E2); // لون أزرق للمهام
      default:
        return AppColors.orangePinkColor;
    }
  }

  Widget _getInfoWidget() {
    switch (selectedTab) {
      case 0:
        return const WealthInfoUpgrade();
      case 1:
        return const CharmInfoUpgrade();
      case 2:
        return const TasksInfoUpgrade();
      default:
        return const WealthInfoUpgrade();
    }
  }

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      top: false,
      child: Scaffold(
        backgroundColor: _getBackgroundColor(),
        body: SingleChildScrollView(
          physics: const BouncingScrollPhysics(),
          child: Column(
            children: [
              SizedBox(
                height: 60.h,
              ),
              // تبويبات محسّنة مع ظل
              Container(
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(30),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withValues(alpha: 0.15),
                      blurRadius: 15,
                      offset: const Offset(0, 5),
                      spreadRadius: 2,
                    ),
                  ],
                ),
                child: AnimatedContainerThreeButton(
                  selectedTab: selectedTab,
                  onPressedCharm: onPressedCharm,
                  onPressedWealth: onPressedWealth,
                  onPressedTasks: onPressedTasks,
                ),
              ),
              SizedBox(
                height: 50.h,
              ),
              // بطاقة معلومات المستخدم مع ظل محسّن
              Container(
                margin: EdgeInsets.symmetric(horizontal: 20.w),
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(25),
                  boxShadow: [
                    BoxShadow(
                      color: _getBackgroundColor().withValues(alpha: 0.3),
                      blurRadius: 20,
                      offset: const Offset(0, 8),
                      spreadRadius: 3,
                    ),
                  ],
                ),
                child: UserLevel(
                  widget: widget,
                  selectedTab: selectedTab,
                ),
              ),
              SizedBox(
                height: 30.h,
              ),
              // بطاقة نطاق المستوى مع ظل
              Container(
                decoration: BoxDecoration(
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withValues(alpha: 0.1),
                      blurRadius: 15,
                      offset: const Offset(0, 5),
                      spreadRadius: 1,
                    ),
                  ],
                ),
                child: LevelShowRangeWidget(selectedTab: selectedTab),
              ),
              SizedBox(
                height: 20.h,
              ),
              // بطاقة معلومات الترقية مع ظل
              Container(
                decoration: BoxDecoration(
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withValues(alpha: 0.08),
                      blurRadius: 12,
                      offset: const Offset(0, 4),
                      spreadRadius: 1,
                    ),
                  ],
                ),
                child: _getInfoWidget(),
              ),
              SizedBox(
                height: 30.h,
              ),
            ],
          ),
        ),
      ),
    );
  }
}
