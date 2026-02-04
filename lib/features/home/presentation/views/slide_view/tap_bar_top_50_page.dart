import 'package:dynamic_tabbar/dynamic_tabbar.dart';
import 'package:flutter/material.dart';
import 'package:lklk/core/constants/assets.dart';

import 'package:lklk/generated/l10n.dart';
import 'package:lklk/core/constants/app_colors.dart';
import 'package:lklk/features/home/presentation/views/slide_view/page_50_giver_taker.dart';
import 'package:lklk/features/home/presentation/views/slide_view/top50roomsPage.dart';
import 'package:lklk/features/profile_users/presentaion/manger/user_cubit/user_cubit_cubit.dart';
import 'package:lklk/features/home/presentation/views/slide_view/top_relation_page.dart';
import 'package:lklk/core/utils/gradient_text.dart';
import 'package:lklk/core/utils/gradient_underline_indicator.dart';

class TapBarTop50Page extends StatefulWidget {
  final UserCubit userCubit;
  final int initialTabIndex;

  const TapBarTop50Page({
    super.key,
    required this.userCubit,
    this.initialTabIndex = 0, // Default to the first tab (wealth)
  });

  @override
  State<TapBarTop50Page> createState() => _TapBarTop50PageState();
}

class _TapBarTop50PageState extends State<TapBarTop50Page>
    with SingleTickerProviderStateMixin {
  int _currentIndex = 0;
  bool _appliedInitialIndex = false;
  Widget _tabTitle(String text) => GradientText(
        text,
        gradient: AppColors.goldenGradient,
        style: const TextStyle(
          fontWeight: FontWeight.bold,
          shadows: [
            Shadow(
              color: Colors.black,
              offset: Offset(1, 1),
              blurRadius: 25,
            ),
          ],
        ),
        maxLines: 1,
        minFontSize: 9,
        maxFontSize: 12,
        stepGranularity: 0.5,
        wrapWords: false,
        textAlign: TextAlign.center,
      );

  @override
  void initState() {
    super.initState();
    _currentIndex = widget.initialTabIndex;
  }

  @override
  void dispose() {
    super.dispose();
  }

  Gradient _bgGradientForIndex(int index) {
    switch (index) {
      case 0: // Rooms
        return const LinearGradient(
          colors: [Color(0xFF030617), Color(0xFF10217D)],
          begin: Alignment.topCenter,
          end: Alignment.bottomCenter,
        );
      case 1: // Relation
        return const LinearGradient(
          colors: [Color(0xFF160309), Color(0xFF7C1133)],
          begin: Alignment.topCenter,
          end: Alignment.bottomCenter,
        );
      case 2: // Wealth
        return const LinearGradient(
          colors: [
            // Color(0xFFAD935D),
            Color(0xFFC9A66B),
            // Color(0xFF947E4D),
            // Color(0xFF453F28),
            AppColors.black,
            AppColors.black,
            AppColors.black,
            AppColors.black,
          ],
          begin: Alignment.topCenter,
          end: Alignment.bottomCenter,
        );
      case 3: // Attraction
        return const LinearGradient(
          colors: [Color(0xFF100317), Color(0xFF57107D)],
          begin: Alignment.topCenter,
          end: Alignment.bottomCenter,
        );
      default:
        return const LinearGradient(colors: [Colors.black, Colors.black]);
    }
  }

  @override
  Widget build(BuildContext context) {
    List<TabData> tabs = [
      // Rooms tab (index 0)
      TabData(
        index: 0,
        title: Tab(child: _tabTitle(S.of(context).rooms)),
        content: KeyedSubtree(
          key: const ValueKey('tab_0'),
          child: Column(
            children: const [Expanded(child: Top50roomspage())],
          ),
        ),
      ),
      // Relation tab (index 1)
      // TabData(
      //   index: 1,
      //   title: Tab(
      //     child: _tabTitle(
      //       (Directionality.of(context) == TextDirection.rtl ||
      //               Localizations.localeOf(context)
      //                       .languageCode
      //                       .toLowerCase() ==
      //                   'ar')
      //           ? 'العلاقة'
      //           : 'Relation',
      //     ),
      //   ),
      //   content: KeyedSubtree(
      //     key: const ValueKey('tab_1'),
      //     child: Column(
      //       children: const [Expanded(child: TopRelationPage())],
      //     ),
      //   ),
      // ),
      // Wealth tab (index 2)
      TabData(
        index: 2,
        title: Tab(
          child: _tabTitle(
            (S.of(context).wealth),
          ),
        ),
        content: KeyedSubtree(
          key: const ValueKey('tab_2'),
          child: Stack(
            children: [
              // Gradient background
              Container(
                decoration: const BoxDecoration(
                  gradient: LinearGradient(
                    colors: [
                      Color(0xFFAD935D),
                      Color(0xFFC9A66B),
                      Color(0xFF947E4D),
                      Color(0xFF453F28),
                    ],
                    stops: [0.0, 0.3, 0.6, 1.0],
                    begin: Alignment.topCenter,
                    end: Alignment.bottomCenter,
                  ),
                ),
              ),
              // Texture overlay
              Positioned.fill(
                child: Image.asset(
                  AssetsData.texture,
                  fit: BoxFit.cover,
                  opacity: const AlwaysStoppedAnimation(0.5),
                ),
              ),
              // Content
              Column(
                children: [
                  Expanded(
                    child: Page50GiverTaker(
                      userCubit: widget.userCubit,
                      numberOfCubitTopUsers: 4,
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
      // Attraction tab (index 3)
      TabData(
        index: 3,
        title: Tab(child: _tabTitle(S.of(context).attraction)),
        content: KeyedSubtree(
          key: const ValueKey('tab_3'),
          child: Stack(
            children: [
              // Gradient background
              Container(
                decoration: const BoxDecoration(
                  gradient: LinearGradient(
                    colors: [
                      Color(0xFF100317),
                      Color(0xFF57107D),
                      // Color(0xFF57107D),
                    ],
                    // stops: [1.0, 0.0],
                    begin: Alignment.topCenter,
                    end: Alignment.bottomCenter,
                  ),
                ),
              ),
              // Texture overlay
              // Positioned.fill(
              //   child: Image.asset(
              //     AssetsData.texture,
              //     fit: BoxFit.cover,
              //     opacity: const AlwaysStoppedAnimation(0.5),
              //   ),
              // ),
              // Content
              Column(
                children: [
                  Expanded(
                    child: Page50GiverTaker(
                      userCubit: widget.userCubit,
                      numberOfCubitTopUsers: 5,
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    ];

    return SafeArea(
      top: false,
      child: Scaffold(
        backgroundColor: Colors.transparent,
        body: Container(
          decoration: BoxDecoration(
            gradient: _bgGradientForIndex(_currentIndex),
          ),
          child: SafeArea(
            child: Column(
              children: [
                Expanded(
                  child: DynamicTabBarWidget(
                    dynamicTabs: tabs,
                    isScrollable: false,
                    labelColor: AppColors.golden,
                    indicator: const GradientUnderlineIndicator(
                      gradient: AppColors.goldenGradient,
                      strokeWidth: 2,
                    ),
                    onTabControllerUpdated: (controller) {
                      // طبّق initialTabIndex مرة واحدة على المتحكم الداخلي للـ DynamicTabBar
                      if (!_appliedInitialIndex) {
                        final target = widget.initialTabIndex;
                        if (controller.index != target) {
                          // اضبط المؤشر مباشرة ثم حرّكه لضمان تزامن المحتوى
                          controller.index = target;
                          WidgetsBinding.instance.addPostFrameCallback((_) {
                            if (mounted) controller.animateTo(target);
                          });
                        }
                        _appliedInitialIndex = true;
                      }
                    },
                    onTabChanged: (index) {
                      final int safeIndex = index is int
                          ? index
                          : (index as int? ?? _currentIndex);
                      if (safeIndex != _currentIndex) {
                        setState(() {
                          _currentIndex = safeIndex;
                        });
                      }
                    },
                    onAddTabMoveTo: MoveToTab.last,
                    showBackIcon: true,
                    showNextIcon: true,
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
