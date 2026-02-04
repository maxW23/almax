import 'dart:async';

import 'package:flutter/material.dart';
import 'package:auto_size_text/auto_size_text.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:lklk/core/constants/app_colors.dart';
import 'package:lklk/core/constants/assets.dart';
import 'package:lklk/core/constants/styles.dart';
import 'package:lklk/core/utils/gradient_text.dart';
import 'package:intl/intl.dart';
import 'package:flutter/services.dart';
import 'package:lklk/core/utils/functions/date_utils_function.dart';
import 'package:lklk/core/utils/functions/is_arabic.dart';
import 'package:lklk/features/auth/domain/entities/user_entity.dart';
import 'package:lklk/features/home/presentation/manger/language/language_cubit.dart';
import 'package:lklk/features/home/presentation/manger/top_user_cubit/top_users_cubit.dart';
import 'package:lklk/features/home/presentation/views/slide_view/timer_counter_acc.dart';
import 'package:lklk/features/profile_users/presentaion/manger/user_cubit/user_cubit_cubit.dart';
import 'package:lklk/features/room/presentation/views/widgets/user_widget_title.dart';
import 'package:cached_network_image/cached_network_image.dart';

class Page50GiverTaker extends StatefulWidget {
  final UserCubit userCubit;
  final int numberOfCubitTopUsers;
  const Page50GiverTaker({
    super.key,
    required this.userCubit,
    required this.numberOfCubitTopUsers,
  });

  @override
  State<Page50GiverTaker> createState() => _Page50GiverTakerState();
}

class _Page50GiverTakerState extends State<Page50GiverTaker> {
  String _selectedLanguage = 'en';
  late Timer _timer;
  final ValueNotifier<String> _timeLeftNotifier = ValueNotifier<String>(
    DateUtilsFunction.calculateTimeUntilNextMonth(),
  );

  @override
  void initState() {
    super.initState();

    final languageCubit = context.read<LanguageCubit>();
    _selectedLanguage = languageCubit.state.languageCode;

    // تحديث الوقت المتبقي في كل ثانية بدون إعادة بناء الصفحة بالكامل
    _timer = Timer.periodic(const Duration(seconds: 1), (timer) {
      _timeLeftNotifier.value = DateUtilsFunction.calculateTimeUntilNextMonth();
    });
  }

  @override
  void dispose() {
    _timer.cancel();
    _timeLeftNotifier.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    // final h = MediaQuery.of(context).size.height;

    return SafeArea(
      top: false,
      child: Scaffold(
        backgroundColor: Colors.transparent,
        body: BlocProvider(
          create: (context) =>
              TopUsersCubit()..fetchTopUsers(widget.numberOfCubitTopUsers),
          child: BlocBuilder<TopUsersCubit, TopUsersState>(
            builder: (context, state) {
              if (state is TopUsersLoaded) {
                return CustomScrollView(
                  slivers: [
                    SliverToBoxAdapter(
                      child: Container(
                        // decoration: BoxDecoration(
                        //     color: Colors.transparent,
                        //     image: DecorationImage(
                        //         image: AssetImage(
                        //           widget.numberOfCubitTopUsers == 4
                        //               ? AssetsData.top50GiverBackgroundImage
                        //               : AssetsData.top50TakerBackgroundImage,
                        //         ),
                        //         fit: BoxFit.cover)),
                        child: Column(
                          children: [
                            Padding(
                              padding: const EdgeInsets.only(top: 10.0),
                              child: Center(
                                child: TimerCounterAcc(),
                              ),
                            ),
                            Top3UsersPodiumExact(
                              users: state.users,
                            ),
                          ],
                        ),
                      ),
                    ),
                    // SliverToBoxAdapter(
                    //   child: ClipRRect(
                    //     borderRadius: const BorderRadius.only(
                    //       topLeft: Radius.circular(100),
                    //       topRight: Radius.circular(100),
                    //     ),
                    //     child: Container(
                    //       color: AppColors.white,
                    //       child: const SizedBox(
                    //         height: 40,
                    //       ),
                    //     ),
                    //   ),
                    // ),
                    SliverList(
                      delegate: SliverChildBuilderDelegate(
                        (context, index) => Container(
                          decoration: const BoxDecoration(
                            color: Color(0xFF100317),
                          ),
                          child: Column(
                            children: [
                              Directionality(
                                textDirection:
                                    getTextDirection(_selectedLanguage),
                                child: Row(
                                  children: [
                                    const SizedBox(width: 16),
                                    RankCircle(r: index + 4),
                                    Expanded(
                                      child: UserWidgetTitle(
                                          islevelTrailing: true,
                                          isImage: true,
                                          isLevel: true,
                                          isIcon: true,
                                          // show the 4th user for index==0 -> users[3]
                                          user: state.users[index + 3],
                                          userCubit: widget.userCubit,
                                          nameColor:
                                              widget.numberOfCubitTopUsers == 4
                                                  ? AppColors.white
                                                  : AppColors.white,
                                          isRoomTypeUser: false,
                                          isWakel: false,
                                          isID: true,
                                          idColor:
                                              widget.numberOfCubitTopUsers == 4
                                                  ? AppColors.white
                                                  : AppColors.white,
                                          numberOfCubitTopUsers:
                                              widget.numberOfCubitTopUsers),
                                    ),
                                  ],
                                ),
                              ),
                              Column(
                                children: [
                                  const SizedBox(height: 10),
                                  Divider(
                                    color: AppColors.grey.withValues(alpha: .2),
                                    indent: 12,
                                    endIndent: 12,
                                    thickness: .5,
                                  ),
                                  const SizedBox(height: 10),
                                ],
                              ),
                            ],
                          ),
                        ),
                        // we already display top-3 separately, so start the list
                        // from the 4th user (index 3). Therefore childCount = total - 3
                        childCount: state.users.length - 3,
                      ),
                    ),
                  ],
                );
              } else if (state is TopUsersError) {
                return Center(
                  child: AutoSizeText('Error ${state.message}'),
                );
              } else if (state is TopUsersLoading) {
                return const Center(
                  child: CircularProgressIndicator(
                    color: AppColors.black,
                  ),
                );
              } else {
                return const Center(
                  // child: AutoSizeText('state $state'),
                  child: SizedBox(),
                );
              }
            },
          ),
        ),
      ),
    );
  }
}

// Ensure image URLs are valid HTTP(S); otherwise fallback to placeholder
String _sanitizeImageUrl(String? raw) {
  final s = (raw ?? '').trim();
  if (s.isEmpty || s.toLowerCase() == 'null') return AssetsData.userTestNetwork;

  // Local asset path
  if (s.startsWith('assets/')) return s;

  // Already a valid web URL
  final u = Uri.tryParse(s);
  if (u != null &&
      (u.scheme == 'http' || u.scheme == 'https') &&
      u.host.isNotEmpty) {
    return s;
  }

  // file://... -> try to extract basename and use CDN base
  if (s.startsWith('file://')) {
    final parts = s.split('/');
    final name = parts.isNotEmpty ? parts.last : '';
    if (name.isNotEmpty) return 'https://lklklive.com/imguser/$name';
    return AssetsData.userTestNetwork;
  }

  // raw filename or path (e.g., 1764960623.jpg or upload/abc.png)
  return 'https://lklklive.com/imguser/$s';
}

// ======== Exact Top 3 podium using provided assets ========
class Top3UsersPodiumExact extends StatelessWidget {
  const Top3UsersPodiumExact({super.key, required this.users});

  final List<UserEntity> users;

  @override
  Widget build(BuildContext context) {
    if (users.isEmpty) return const SizedBox();
    final u1 = users.isNotEmpty ? users[0] : null;
    final u2 = users.length > 1 ? users[1] : null;
    final u3 = users.length > 2 ? users[2] : null;

    return SizedBox(
      height: 275,
      child: LayoutBuilder(
        builder: (context, constraints) {
          final w = constraints.maxWidth;

          // Base height depends on width (image aspect ratio), not container height
          final baseH = w * 0.2;

          // Fixed size for stands (60x100 as requested)
          final standW = 80.0;
          final standH = 180.0;

          // Center the middle stand
          final centerX = (w - standW) / 2;

          // Position side stands next to the center one
          final gap = 10.0;
          final leftX = centerX - standW - gap;
          final rightX = centerX + standW + gap;

          // Move stands down by 60 (same as relation)
          final centerBottom = (baseH + 20) - 60;
          final sideBottom = (baseH + 5) - 60;

          return Stack(
            clipBehavior: Clip.none,
            children: [
              // Base stand
              Align(
                alignment: Alignment.bottomCenter,
                child: Image.asset(
                  AssetsData.podiumBaseStand,
                  width: w * 0.92,
                  fit: BoxFit.contain,
                ),
              ),

              // Left (2)
              if (u2 != null)
                Positioned(
                  left: leftX,
                  bottom: sideBottom,
                  child: _StandUserCardExact(
                    width: standW,
                    height: standH,
                    standAsset: AssetsData.stand2,
                    frameAsset: AssetsData.framestand2,
                    user: u2,
                    rank: 2,
                  ),
                ),

              // Center (1)
              if (u1 != null)
                Positioned(
                  left: centerX,
                  bottom: centerBottom,
                  child: _StandUserCardExact(
                    width: standW,
                    height: standH,
                    standAsset: AssetsData.stand1,
                    frameAsset: AssetsData.framestand1,
                    user: u1,
                    rank: 1,
                  ),
                ),

              // Right (3)
              if (u3 != null)
                Positioned(
                  left: rightX,
                  bottom: sideBottom,
                  child: _StandUserCardExact(
                    width: standW,
                    height: standH,
                    standAsset: AssetsData.stand3,
                    frameAsset: AssetsData.framestand3,
                    user: u3,
                    rank: 3,
                  ),
                ),
            ],
          );
        },
      ),
    );
  }
}

class _StandUserCardExact extends StatelessWidget {
  const _StandUserCardExact({
    required this.width,
    required this.height,
    required this.standAsset,
    required this.frameAsset,
    required this.user,
    required this.rank,
  });

  final double width;
  final double height;
  final String standAsset;
  final String frameAsset;
  final UserEntity user;
  final int rank; // 1,2,3

  @override
  Widget build(BuildContext context) {
    // Fixed user image size (40x40 as per relation page)
    const double ringDia = 40.0;
    final dateStr = DateFormat('dd-MM-yy').format(DateTime.now());

    return SizedBox(
      width: width,
      height: height,
      child: Stack(
        clipBehavior: Clip.none,
        alignment: Alignment.topCenter,
        children: [
          // Stand/backplate
          Positioned.fill(
            child: Image.asset(
              standAsset,
              fit: BoxFit.fill,
            ),
          ),

          // User image (circular) - centered above the stand
          Positioned(
            top: rank != 1 ? (-ringDia * 0.48) + 4 : (-ringDia * 0.48) + 12,
            left: (width - (ringDia * 1.05)) / 2,
            child: Container(
              width: ringDia * 1.05,
              height: ringDia * 1.05,
              decoration: const BoxDecoration(
                shape: BoxShape.circle,
              ),
              child: ClipOval(
                child: _AvatarImage(user: user),
              ),
            ),
          ),

          // Frame image - centered on top of user image, LARGE SIZE
          Positioned(
            top: (-ringDia * 0.48) - (80 - ringDia * 1.85) / 2,
            left: rank != 3 ? (width - 80) / 2 : (width - 70) / 2,
            child: Image.asset(
              frameAsset,
              width: rank != 3 ? 80 : 70,
              height: rank != 3 ? 80 : 70,
              fit: BoxFit.cover,
            ),
          ),

          // Text block inside stand
          Positioned(
            top: 50,
            left: 4,
            right: 4,
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                AutoSizeText(
                  user.name ?? '',
                  maxLines: 1,
                  textAlign: TextAlign.center,
                  style: const TextStyle(
                    color: Colors.black,
                    fontSize: 10,
                    fontWeight: FontWeight.w800,
                  ),
                ),
                const SizedBox(height: 4),
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Image.asset(
                      AssetsData.doubleHeartIcon,
                      width: 20,
                      height: 20,
                    ),
                    const SizedBox(width: 2),
                    Flexible(
                      child: AutoSizeText(
                        user.monLevel ?? user.rmonLevelTwo ?? '0',
                        maxLines: 1,
                        style: const TextStyle(
                          color: AppColors.black,
                          fontSize: 10,
                          fontWeight: FontWeight.w700,
                        ),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 2),
                SizedBox(
                  width: 60,
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Image.asset(
                        AssetsData.timeIcon,
                        width: 20,
                        height: 20,
                        color: AppColors.black,
                      ),
                      const SizedBox(width: 2),
                      Flexible(
                        child: AutoSizeText(
                          dateStr,
                          maxLines: 1,
                          style: const TextStyle(
                            color: AppColors.black,
                            fontSize: 9,
                            fontWeight: FontWeight.w700,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _AvatarImage extends StatelessWidget {
  const _AvatarImage({required this.user});
  final UserEntity user;

  @override
  Widget build(BuildContext context) {
    final url = _sanitizeImageUrl(user.img);
    return CachedNetworkImage(
      imageUrl: url,
      fit: BoxFit.cover,
      fadeInDuration: Duration.zero,
      fadeOutDuration: Duration.zero,
    );
  }
}

// ======== Top 3 podium (cards + medals) ========
// class _Top3UsersPodium extends StatelessWidget {
//   const _Top3UsersPodium({required this.users, required this.isWealth});
//   final List<UserEntity> users;
//   final bool isWealth;

//   @override
//   Widget build(BuildContext context) {
//     if (users.isEmpty) return const SizedBox();
//     final u1 = users.length > 0 ? users[0] : null;
//     final u2 = users.length > 1 ? users[1] : null;
//     final u3 = users.length > 2 ? users[2] : null;

//     return Column(
//       mainAxisAlignment: MainAxisAlignment.center,
//       children: [
//         Row(
//           mainAxisAlignment: MainAxisAlignment.spaceEvenly,
//           crossAxisAlignment: CrossAxisAlignment.end,
//           children: [
//             // if (u2 != null)
//             // _PodiumCard(
//             //   user: u2,
//             //   rank: 2,
//             //   isWealth: isWealth,
//             //   scale: 0.9,
//             //   ringColors: const [Colors.white70, Colors.grey],
//             // ),
//             // if (u1 != null)
//             // _PodiumCard(
//             //   user: u1,
//             //   rank: 1,
//             //   isWealth: isWealth,
//             //   scale: 1.05,
//             //   ringColors: const [
//             //     AppColors.goldenhad1,
//             //     AppColors.brownshad1
//             //   ],
//             // ),
//             // if (u3 != null)
//             // _PodiumCard(
//             //   user: u3,
//             //   rank: 3,
//             //   isWealth: isWealth,
//             //   scale: 0.9,
//             //   ringColors: const [Color(0xFFE0A168), Color(0xFF8B5E3C)],
//             // ),
//           ],
//         ),
//       ],
//     );
//   }
// }

class RankCircle extends StatelessWidget {
  const RankCircle({super.key, required this.r});
  final int r;

  @override
  Widget build(BuildContext context) {
    return Stack(
      alignment: Alignment.center,
      children: [
        // Container(
        //   width: 30,
        //   height: 30,
        //   decoration: const BoxDecoration(
        //     shape: BoxShape.circle,
        //     gradient: LinearGradient(
        //       colors: [Color(0xFFB78E54), Color(0xFFEBD3A5)],
        //     ),
        //   ),
        // ),
        AutoSizeText(
          '$r',
          maxLines: 1,
          style: const TextStyle(
            color: Colors.white,
            fontWeight: FontWeight.w900,
            fontSize: 15,
          ),
        ),
      ],
    );
  }
}
