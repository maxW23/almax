import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:lklk/features/auth/domain/entities/user_entity.dart';
import 'package:lklk/features/home/presentation/manger/top_user_cubit/top_users_cubit.dart';
import 'package:lklk/features/room/presentation/views/widgets/circular_user_image.dart';


class WeeklyBannerHeader extends StatelessWidget {
  const WeeklyBannerHeader({super.key});

  @override
  Widget build(BuildContext context) {
    final width = MediaQuery.of(context).size.width;
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 2),
      child: SizedBox(
        height: 320.h,
        child: Stack(
          clipBehavior: Clip.none,
          children: [
            Positioned.fill(
              child: Image.asset(
                'assets/event/weekly star 2 without bg.png',
                width: width,
                height: 300.h,
                fit: BoxFit.fill,
              ),
            ),
            // Top-3 frames overlay with user avatars and badges
            Positioned(
              top: 110.h,
              left: 0,
              right: 0,
              child: BlocBuilder<TopUsersCubit, TopUsersState>(
                buildWhen: (p, c) => p != c,
                builder: (context, state) {
                  List<UserEntity> users = [];
                  if (state is TopUsersLoaded) users = state.users;
                  final u1 = users.isNotEmpty ? users[0] : null; // rank 1
                  final u2 = users.length > 1 ? users[1] : null; // rank 2
                  final u3 = users.length > 2 ? users[2] : null; // rank 3

                  Widget buildTopItem({
                    required UserEntity? user,
                    required String frameAsset,
                    required String badgeAsset,
                    required double radius,
                    required double padding
                  }) {
                    return Column(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        CircularUserImage(
                          imagePath: user?.img,
                          radius: radius,
                          frameOverlayAsset: frameAsset,
                          innerPadding: padding,
                        ),
                        SizedBox(height: 8.h),
                        Image.asset(
                          badgeAsset,
                          height: 32.h,
                          fit: BoxFit.contain,
                        ),
                      ],
                    );
                  }

                  Widget buildCenterItem({
                    required UserEntity? user,
                    required String frameAsset,
                    required String badgeAsset,
                    required double radius,
                    required double padding,
                    Offset frameOffset = Offset.zero,
                  }) {
                    final double size = radius * 2;
                    return Transform.translate(
                      offset: Offset(0, -14.h), // raise rank 1 above others
                      child: Column(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          SizedBox(
                            width: size,
                            height: size,
                            child: Stack(
                              clipBehavior: Clip.none,
                              children: [
                                CircularUserImage(
                                  imagePath: user?.img,
                                  radius: radius,
                                  innerPadding: padding,
                                ),
                                Positioned.fill(
                                  child: Transform.translate(
                                    offset: frameOffset,
                                    child: IgnorePointer(
                                      child: Image.asset(
                                        frameAsset,
                                        fit: BoxFit.fill,
                                      ),
                                    ),
                                  ),
                                ),
                              ],
                            ),
                          ),
                          // SizedBox(height: 0.h),
                          Image.asset(
                            badgeAsset,
                            height: 32.h,
                            fit: BoxFit.contain,
                          ),
                        ],
                      ),
                    );
                  }
                  
                  Widget withPoints(Widget child, UserEntity? u) {
                    final total = (u?.totalSpent ?? '').trim();
                    if (total.isEmpty) return child;
                    return Column(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        child,
                        const SizedBox(height: 6),
                        Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            const Icon(Icons.flash_on,
                                color: Colors.orangeAccent, size: 16),
                            const SizedBox(width: 4),
                            Text(
                              total,
                              style: const TextStyle(
                                color: Colors.white,
                                fontWeight: FontWeight.bold,
                                fontSize: 12,
                              ),
                            ),
                          ],
                        ),
                      ],
                    );
                  }

                      return Row(
                        mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          withPoints(
                            buildTopItem(
                              user: u2,
                              frameAsset: 'assets/event/top 2 frame.png',
                              badgeAsset: 'assets/event/top 2 badge_1.png',
                              radius: 40.w,
                              padding: 8,
                            ),
                            u2,
                          ),
                          withPoints(
                            buildCenterItem(
                              user: u1,
                              frameAsset: 'assets/event/top 1 frame.png',
                              badgeAsset: 'assets/event/top 1 badge_1.png',
                              radius: 70.w,
                              padding: 40,
                              frameOffset: Offset(0, -30), // fine-tune frame alignment
                            ),
                            u1,
                          ),
                          withPoints(
                            buildTopItem(
                              user: u3,
                              frameAsset: 'assets/event/top 3 frame.png',
                              badgeAsset: 'assets/event/top 3 badge_1.png',
                              radius: 40.w,
                              padding: 8,
                            ),
                            u3,
                          ),
                        ],
                      );
                    },
                  ),
                ),
              ],
            ),
          ),
        );
  }
}


