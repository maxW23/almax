import 'dart:math' as math;
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:lklk/core/constants/app_colors.dart';
import 'package:lklk/features/home/presentation/manger/top_user_cubit/top_users_cubit.dart';
import 'package:lklk/features/profile_users/presentaion/manger/user_cubit/user_cubit_cubit.dart';
import 'package:lklk/features/room/presentation/views/widgets/user_widget_title.dart';
import 'package:lklk/features/weekly_star_event/cubit/countdown_cubit.dart';

class WeeklyTimerStrip extends StatelessWidget {
  const WeeklyTimerStrip({super.key});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 12.0),
      child: SizedBox(
        height: 800.h,
        child: Stack(
          fit: StackFit.expand,
          children: [
            // Section header background constrained
            Image.asset(
              'assets/event/this week section.png',
              fit: BoxFit.fill,
            ),
            // Digits row overlays the header
            Positioned(
              top: 36,
              right: 0,
              left: 0,
              child: SizedBox(
                height: 32,
                child: BlocBuilder<CountdownCubit, CountdownState>(
                  buildWhen: (p, c) =>
                      p.remainingDuration.inSeconds !=
                      c.remainingDuration.inSeconds,
                  builder: (context, state) {
                    final digits = _digitsFromDuration(state.remainingDuration);
                    return Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: _buildTimerTiles(digits),
                    );
                  },
                ),
              ),
            ),
            Positioned(
              top: 280,
              right: 0,
              left: 0,
              child: Padding(
                padding: const EdgeInsetsDirectional.symmetric(horizontal: 10),
                child: SizedBox(
                  height: 600.h,
                  child: BlocBuilder<TopUsersCubit, TopUsersState>(
                    buildWhen: (p, c) => p != c,
                    builder: (context, state) {
                      if (state is! TopUsersLoaded) {
                        return const SizedBox();
                      }
                      final users = state.users;
                      if (users.length <= 0) return const SizedBox();
                      final end = math.min(10, users.length);
                      final list = users.sublist(0, end); // ranks 1..10

                      return ListView.separated(
                        physics: const NeverScrollableScrollPhysics(),
                        padding: EdgeInsets.zero,
                        itemCount: list.length,
                        separatorBuilder: (_, __) => SizedBox(height: 8.h),
                        itemBuilder: (context, index) {
                          final u = list[index];
                          final rank = index + 1; // 1-based rank
                          return Container(
                            height: 48.h,
                            decoration: BoxDecoration(
                              color: Colors.white.withOpacity(0.06),
                              borderRadius: BorderRadius.circular(12),
                              border:
                                  Border.all(color: Colors.white24, width: 1),
                            ),
                            padding: const EdgeInsets.symmetric(horizontal: 10),
                            child: Row(
                              children: [
                                Expanded(
                                  child: UserWidgetTitle(
                                    user: u,
                                    userCubit: context.read<UserCubit>(),
                                    isID: true,
                                    isLevel: false,
                                    isIcon: false,
                                    isAnimatedIcon: false,
                                    islevelTrailing: false,
                                    isRoomTypeUser: false,
                                    isWakel: false,
                                    isSmall: true,
                                    isNameOnly: true,
                                    contentPadding: const EdgeInsets.symmetric(
                                        horizontal: 0),
                                    // Ensure avatar stays circular in tight row constraints
                                    maxAvatarSide: 36.h,
                                    paddingImageOnly: 4,
                                    nameColor: AppColors.white,
                                    idColor: AppColors.white,
                                  ),
                                ),
                                SizedBox(
                                  width: 36,
                                  child: Center(
                                    child: () {
                                      if (rank == 1) {
                                        return Image.asset(
                                          'assets/event/top 1 badge_1.png',
                                          height: 24,
                                          fit: BoxFit.contain,
                                        );
                                      } else if (rank == 2) {
                                        return Image.asset(
                                          'assets/event/top 2 badge_1.png',
                                          height: 24,
                                          fit: BoxFit.contain,
                                        );
                                      } else if (rank == 3) {
                                        return Image.asset(
                                          'assets/event/top 3 badge_1.png',
                                          height: 24,
                                          fit: BoxFit.contain,
                                        );
                                      }
                                      return Text(
                                        '$rank',
                                        style: const TextStyle(
                                          color: Colors.white,
                                          fontWeight: FontWeight.bold,
                                        ),
                                      );
                                    }(),
                                  ),
                                ),
                              ],
                            ),
                          );
                        },
                      );
                    },
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  List<String> _digitsFromDuration(Duration d) {
    final days = d.inDays;
    final hours = d.inHours.remainder(24);
    final minutes = d.inMinutes.remainder(60);
    final seconds = d.inSeconds.remainder(60);
    String two(int n) => n.toString().padLeft(2, '0');
    final dayStr = days.toString().padLeft(2, '0');
    final s = '$dayStr:${two(hours)}:${two(minutes)}:${two(seconds)}';
    return s.split('');
  }

  List<Widget> _buildTimerTiles(List<String> digits) {
    return digits.map((d) {
      if (d == ':') {
        return Padding(
          padding: const EdgeInsets.symmetric(horizontal: 1.0),
          child: Text(
            ':',
            style: TextStyle(
              color: Colors.white.withOpacity(0.9),
              fontSize: 12,
              fontWeight: FontWeight.bold,
            ),
          ),
        );
      }
      return Padding(
        padding: const EdgeInsets.symmetric(horizontal: 1.0),
        child: Stack(
          alignment: Alignment.center,
          children: [
            Image.asset(
              'assets/event/timer_item.png',
              height: 24,
              fit: BoxFit.contain,
            ),
            Text(
              d,
              style: const TextStyle(
                color: Colors.white,
                fontWeight: FontWeight.bold,
                fontSize: 12,
              ),
            ),
          ],
        ),
      );
    }).toList();
  }
}
