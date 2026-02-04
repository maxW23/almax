import 'package:auto_size_text/auto_size_text.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:lklk/features/auth/domain/entities/user_entity.dart';
import 'package:lklk/features/home/presentation/manger/top_user_cubit/top_users_cubit.dart';
import 'package:lklk/features/weekly_star_event/view/btn_event_week.dart';
import 'package:lklk/features/weekly_star_event/view/btns_row_section.dart';
import 'package:lklk/features/weekly_star_event/widgets/weekly_banner_header.dart';
import 'package:lklk/features/weekly_star_event/cubit/weekly_tab_cubit.dart';
import 'package:lklk/features/weekly_star_event/widgets/weekly_timer_strip_points.dart';
import 'package:lklk/features/weekly_star_event/widgets/weekly_top_three.dart';
import 'package:lklk/features/weekly_star_event/widgets/weekly_users_list.dart';

class WeeklyStarEventViewBody extends StatelessWidget {
  const WeeklyStarEventViewBody({super.key});

  @override
  Widget build(BuildContext context) {
    return DecoratedBox(
      decoration: const BoxDecoration(
        image: DecorationImage(
          image: AssetImage('assets/event/bg.png'),
          fit: BoxFit.fitWidth,
          alignment: Alignment.topCenter,
        ),
      ),
      child: CustomScrollView(
        slivers: [
          const SliverToBoxAdapter(
              child: ImagesOnlyShow(image: "assets/event/top_section.png")),
          const SliverToBoxAdapter(child: SizedBox(height: 16)),

          const SliverToBoxAdapter(child: WeeklyBannerHeader()),
          const SliverToBoxAdapter(child: SizedBox(height: 16)),
          const SliverToBoxAdapter(child: BtnsRowSection()),
          // Conditional block controlled by WeeklyTabCubit
          SliverToBoxAdapter(
            child: BlocBuilder<WeeklyTabCubit, WeeklyTab>(
              buildWhen: (p, c) => p != c,
              builder: (context, tab) {
                final show = tab == WeeklyTab.thisWeek;
                return Column(
                  children: [
                    if (show) ...[
                      const SizedBox(height: 16),
                      const WeeklyTimerStripPoints(),
                      const SizedBox(height: 16),
                      const ImagesOnlyShow(
                        image: "assets/event/next week gift without bg.png",
                      ),
                    ],
                    if (!show) ...[
                      const ImagesOnlyShow(
                          image: "assets/event/top 1 without bg.png"),
                      const ImagesOnlyShow(
                          image: "assets/event/top 2 without bg.png"),
                      const ImagesOnlyShow(
                          image: "assets/event/top 3 without bg.png"),
                    ],
                  ],
                );
              },
            ),
          ),
          const SliverToBoxAdapter(child: SizedBox(height: 50)),
          // Top users section uses existing TopUsersCubit
          // SliverToBoxAdapter(
          //   child: BlocBuilder<TopUsersCubit, TopUsersState>(
          //     buildWhen: (p, c) => p != c,
          //     builder: (context, state) {
          //       if (state is TopUsersLoading) {
          //         return _loadingSection();
          //       }
          //       if (state is TopUsersError) {
          //         return _errorSection(state.message);
          //       }
          //       if (state is TopUsersLoaded) {
          //         final all = state.users;
          //         final topThree = all.take(3).toList();
          //         final others =
          //             all.length > 3 ? all.sublist(3) : <UserEntity>[];
          //         return Column(
          //           crossAxisAlignment: CrossAxisAlignment.stretch,
          //           children: [
          //             // WeeklyTopThree(users: topThree),
          //             const SizedBox(height: 16),

          //             // WeeklyUsersList(users: others),
          //             const SizedBox(height: 24),
          //           ],
          //         );
          //       }
          //       // Initial state fallback
          //       return _loadingSection();
          //     },
          //   ),
          // ),
        ],
      ),
    );
  }

  Widget _loadingSection() {
    return Column(
      children: [
        const _ShimmerBar(height: 180),
        const SizedBox(height: 12),
        const _ShimmerBar(height: 80),
        const SizedBox(height: 12),
        ...List.generate(6, (i) => const _ShimmerTile()).toList(),
      ],
    );
  }

  Widget _errorSection(String message) {
    return Padding(
      padding: const EdgeInsets.all(16.0),
      child: Column(
        children: [
          const _ShimmerBar(height: 180),
          const SizedBox(height: 12),
          Text(
            message,
            style: const TextStyle(color: Colors.white),
          ),
        ],
      ),
    );
  }
}

class _ShimmerBar extends StatelessWidget {
  final double height;
  const _ShimmerBar({required this.height});

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 16),
      height: height,
      decoration: BoxDecoration(
        color: Colors.white.withOpacity(0.08),
        borderRadius: BorderRadius.circular(12),
      ),
    );
  }
}

class _ShimmerTile extends StatelessWidget {
  const _ShimmerTile();
  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 6),
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: Colors.white.withOpacity(0.06),
        borderRadius: BorderRadius.circular(12),
      ),
      child: Row(
        children: [
          ClipRRect(
            borderRadius: BorderRadius.circular(8),
            child: Container(
              width: 56,
              height: 56,
              color: Colors.white.withOpacity(0.08),
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Container(
                  height: 12,
                  width: 120,
                  color: Colors.white.withOpacity(0.08),
                ),
                const SizedBox(height: 8),
                Container(
                  height: 10,
                  width: 60,
                  color: Colors.white.withOpacity(0.08),
                ),
              ],
            ),
          )
        ],
      ),
    );
  }
}

class ImagesOnlyShow extends StatelessWidget {
  const ImagesOnlyShow(
      {super.key, required this.image, this.fit = BoxFit.fill});
  final String image;
  final BoxFit? fit;
  @override
  Widget build(BuildContext context) {
    return Image.asset(
      image,
      fit: fit,
    );
  }
}
