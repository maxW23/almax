import 'package:flutter/material.dart';
import 'package:auto_size_text/auto_size_text.dart';
import 'package:lklk/features/home/presentation/views/slide_view/timer_counter_acc.dart';
import 'package:lklk/generated/l10n.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import 'package:lklk/core/constants/app_colors.dart';
import 'package:lklk/core/constants/assets.dart';
import 'package:lklk/core/utils/gradient_text.dart';
import 'package:lklk/features/home/presentation/manger/top_user_cubit/top_users_cubit.dart';
import 'package:lklk/features/room/presentation/views/widgets/circular_user_image.dart';
import 'package:intl/intl.dart';

class TopRelationPage extends StatefulWidget {
  const TopRelationPage({super.key});

  @override
  State<TopRelationPage> createState() => _TopRelationPageState();
}

class Top3RelationsPodiumExact extends StatelessWidget {
  const Top3RelationsPodiumExact({
    super.key,
    required this.first,
    this.second,
    this.third,
    this.height = 260,
  });

  final _PairUsers first;
  final _PairUsers? second;
  final _PairUsers? third;
  final double height;

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: height,
      child: LayoutBuilder(
        builder: (context, constraints) {
          final w = constraints.maxWidth;

          // Base height depends on width (image aspect ratio), not container height
          final baseH = w * 0.2;

          // Fixed size for stands
          final standW = 80.0;
          final standH = 230.0;

          // Center the middle stand
          final centerX = (w - standW) / 2;

          // Position side stands next to the center one
          // Adjust gap as needed
          final gap = 10.0;
          final leftX = centerX - standW - gap;
          final rightX = centerX + standW + gap;

          // Move stands down by 60 (from previous request)
          // Using fixed offsets instead of h-based to allow resizing container
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
              if (second != null)
                Positioned(
                  left: leftX,
                  bottom: sideBottom,
                  child: _RelationStandCardExact(
                    width: standW,
                    height: standH,
                    standAsset: AssetsData.topUser2Stand,
                    users: second!,
                    rank: 2,
                  ),
                ),

              // Center (1)
              Positioned(
                left: centerX,
                bottom: centerBottom,
                child: _RelationStandCardExact(
                  width: standW,
                  height: standH,
                  standAsset: AssetsData.topUser1Stand,
                  users: first,
                  rank: 1,
                ),
              ),

              // Right (3)
              if (third != null)
                Positioned(
                  left: rightX,
                  bottom: sideBottom,
                  child: _RelationStandCardExact(
                    width: standW,
                    height: standH,
                    standAsset: AssetsData.topUser3Stand,
                    users: third!,
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

class _RelationStandCardExact extends StatelessWidget {
  const _RelationStandCardExact({
    required this.width,
    required this.height,
    required this.standAsset,
    required this.users,
    required this.rank,
  });

  final double width;
  final double height;
  final String standAsset;
  final _PairUsers users;
  final int rank; // 1,2,3

  @override
  Widget build(BuildContext context) {
    // User requested image size 40x40
    const double ringDia = 40.0;
    final medalSize = ringDia * 0.42;
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

          // Twin rings + heart medal above the stand
          Positioned(
            top: (-ringDia * 0.48) + 20,
            child: SizedBox(
              width: ringDia * 1.9,
              height: ringDia,
              child: Stack(
                alignment: Alignment.center,
                children: [
                  // Left ring
                  Positioned(
                    left: 0,
                    child: Container(
                      width: ringDia,
                      height: ringDia,
                      decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        border: Border.all(
                            color: const Color(0xFFFF3C8B), width: 2),
                      ),
                      child: ClipOval(
                        child: CircularUserImage(
                          imagePath: users.u1,
                          radius: ringDia / 2,
                        ),
                      ),
                    ),
                  ),
                  // Right ring
                  Positioned(
                    right: 0,
                    child: Container(
                      width: ringDia,
                      height: ringDia,
                      decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        border: Border.all(
                            color: const Color(0xFFFF3C8B), width: 2),
                      ),
                      child: ClipOval(
                        child: CircularUserImage(
                          imagePath: users.u2,
                          radius: ringDia / 2,
                        ),
                      ),
                    ),
                  ),
                  // Heart medal in middle
                  // Container(
                  //   width: medalSize,
                  //   height: medalSize,
                  //   decoration: BoxDecoration(
                  //     shape: BoxShape.circle,
                  //     boxShadow: [
                  //       BoxShadow(
                  //         color: Colors.black.withOpacity(.25),
                  //         blurRadius: 10,
                  //         offset: const Offset(0, 4),
                  //       )
                  //     ],
                  //   ),
                  //   child:
                  //       Image.asset(AssetsData.heartImage, fit: BoxFit.contain),
                  // ),
                ],
              ),
            ),
          ),

          // Text block inside stand
          Positioned(
            top: 100,
            left: 4,
            right: 4,
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                AutoSizeText(
                  '${users.n1}',
                  maxLines: 1,
                  style: const TextStyle(
                    color: Colors.black,
                    fontSize: 10,
                    fontWeight: FontWeight.w800,
                  ),
                ),
                AutoSizeText(
                  '${users.n2}',
                  maxLines: 1,
                  style: const TextStyle(
                    color: Colors.black,
                    fontSize: 10,
                    fontWeight: FontWeight.w800,
                  ),
                ),
                // const SizedBox(height: 4),
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
                        users.level,
                        maxLines: 1,
                        style: const TextStyle(
                          color: Colors.black,
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
                        color: Colors.black,
                      ),
                      const SizedBox(width: 2),
                      Flexible(
                        child: AutoSizeText(
                          dateStr,
                          maxLines: 1,
                          style: const TextStyle(
                            color: Colors.black,
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

class _TopRelationPageState extends State<TopRelationPage> {
  @override
  Widget build(BuildContext context) {
    final h = MediaQuery.of(context).size.height;

    return BlocProvider<TopUsersCubit>(
      create: (context) => TopUsersCubit()..fetchTopUsers(8),
      child: SafeArea(
        top: false,
        child: Scaffold(
          backgroundColor: Colors.transparent,
          body: Stack(
            children: [
              // خلفية متدرجة بدل الصورة الثابتة لتقارب تصميم Figma
              Positioned.fill(
                child: DecoratedBox(
                  decoration: BoxDecoration(
                    gradient: const LinearGradient(
                      begin: Alignment.topCenter,
                      end: Alignment.bottomCenter,
                      colors: [
                        Color(0xFF2C0A16), // غامق علوي
                        Color(0xFF160309), // منتصف خمري
                        Color(0xFF0A0105), // أسفل شبه أسود
                      ],
                      stops: [0.0, 0.5, 1.0],
                    ),
                  ),
                ),
              ),
              BlocBuilder<TopUsersCubit, TopUsersState>(
                // bloc: BlocProvider.of<TopUsersCubit>(context)..fetchTopUsers(8),
                builder: (context, state) {
                  if (state is TopUserRelationUsersLoaded) {
                    return CustomScrollView(
                      slivers: [
                        SliverToBoxAdapter(
                          child: Column(
                            children: [
                              const Center(
                                child: Padding(
                                  padding: EdgeInsets.only(top: 10),
                                  child: TimerCounterAcc(),
                                ),
                              ),
                              // منصة تتويج Top 3 مطابقة للأصول (stands + base)
                              if (state.users.isNotEmpty)
                                Top3RelationsPodiumExact(
                                  first: _PairUsers(
                                    u1: state.users[0].user1Img,
                                    u2: state.users[0].user2Img,
                                    level: '${state.users[0].level}',
                                    n1: '${state.users[0].user1Name}',
                                    n2: '${state.users[0].user2Name}',
                                  ),
                                  second: state.users.length > 1
                                      ? _PairUsers(
                                          u1: state.users[1].user1Img,
                                          u2: state.users[1].user2Img,
                                          level: '${state.users[1].level}',
                                          n1: '${state.users[1].user1Name}',
                                          n2: '${state.users[1].user2Name}',
                                        )
                                      : null,
                                  third: state.users.length > 2
                                      ? _PairUsers(
                                          u1: state.users[2].user1Img,
                                          u2: state.users[2].user2Img,
                                          level: '${state.users[2].level}',
                                          n1: '${state.users[2].user1Name}',
                                          n2: '${state.users[2].user2Name}',
                                        )
                                      : null,
                                  height: h / 3.2,
                                ),
                              const SizedBox(height: 20),
                            ],
                          ),
                        ),
                        SliverList(
                          delegate: SliverChildBuilderDelegate(
                            (context, index) {
                              final u = state.users[index + 3];
                              return Container(
                                color: const Color(0xFF160309),
                                child: RelationListItem(
                                  rank: index + 4,
                                  user1Name: '${u.user1Name}',
                                  user2Name: '${u.user2Name}',
                                  user1Img: u.user1Img,
                                  user2Img: u.user2Img,
                                  level: u.level ?? '0',
                                ),
                              );
                            },
                            childCount: state.users.length > 3
                                ? state.users.length - 3
                                : 0,
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
                        color: AppColors.pinkwhiteColor,
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
            ],
          ),
        ),
      ),
    );
  }
}

class RelationListItem extends StatelessWidget {
  const RelationListItem({
    super.key,
    required this.rank,
    required this.user1Name,
    required this.user2Name,
    required this.user1Img,
    required this.user2Img,
    required this.level,
  });

  final int rank;
  final String user1Name;
  final String user2Name;
  final String? user1Img;
  final String? user2Img;
  final String level;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(vertical: 10),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          const SizedBox(width: 16),
          _rankCircle(rank),
          const SizedBox(width: 16),
          TwoUsersImageRelationWithFrameStack(
            imagePathFirstUser: user1Img,
            imagePathSecondUser: user2Img,
          ),
          const SizedBox(width: 8),
          TwoUsersRelationNameColumn(
            user1Name: user1Name,
            user2Name: user2Name,
          ),
          const Spacer(),
          Container(
            decoration: BoxDecoration(
              boxShadow: [
                BoxShadow(
                  color: AppColors.black.withValues(alpha: .5),
                  blurRadius: 5,
                  spreadRadius: 1,
                  offset: const Offset(0, 3),
                ),
              ],
              borderRadius: BorderRadius.circular(10),
            ),
            child: LevelWithLoveIcon(level: level),
          ),
          const SizedBox(width: 20),
        ],
      ),
    );
  }

  Widget _rankCircle(int r) {
    // دوائر بسيطة للترتيب مع تدرّج ذهبي خفيف كما في التصميم
    return Stack(
      alignment: Alignment.center,
      children: [
        AutoSizeText(
          '$r',
          maxLines: 1,
          style: const TextStyle(
            color: Colors.grey,
            fontWeight: FontWeight.w900,
            fontSize: 15,
          ),
        ),
      ],
    );
  }
}

class TopWidgetTitle extends StatelessWidget {
  const TopWidgetTitle({
    super.key,
    required this.index,
    this.color,
  });
  final int index;
  final Color? color;
  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.only(bottom: 4),
      // padding: const EdgeInsets.all(4),
      width: 55,
      alignment: Alignment.center,
      decoration: BoxDecoration(
        boxShadow: [
          BoxShadow(
            color: AppColors.black.withValues(alpha: .5),
            blurRadius: 5,
            spreadRadius: 1,
            offset: const Offset(0, 3),
          ),
        ],
        borderRadius: BorderRadius.circular(10),
      ),
      child: AutoSizeText(
        '${S.of(context).top} $index',
        style: TextStyle(
          color: color,
          fontSize: 15,
          fontWeight: FontWeight.w900,
        ),
      ),
    );
  }
}

class TwoUsersRelationNameColumn extends StatelessWidget {
  const TwoUsersRelationNameColumn({
    super.key,
    required this.user1Name,
    required this.user2Name,
  });
  final String user1Name;
  final String user2Name;
  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        GradientText(
          user1Name,
          gradient: const LinearGradient(colors: [
            AppColors.white,
            AppColors.white,
          ]),
          style: const TextStyle(fontSize: 13, fontWeight: FontWeight.bold),
        ),
        GradientText(
          user2Name,
          gradient: const LinearGradient(colors: [
            AppColors.white,
            AppColors.white,
          ]),
          style: const TextStyle(fontSize: 13, fontWeight: FontWeight.bold),
        ),
      ],
    );
  }
}

class TwoUsersImageRelationWithFrameStack extends StatelessWidget {
  const TwoUsersImageRelationWithFrameStack({
    super.key,
    this.imagePathFirstUser,
    this.imagePathSecondUser,
  });
  final String? imagePathFirstUser;
  final String? imagePathSecondUser;
  @override
  Widget build(BuildContext context) {
    return Stack(
      children: [
        ImageUserWithFrameRealtion(
          imagePath: imagePathFirstUser,
          height: 50,
          width: 50,
          heightFrame: 59,
          widthFrame: 59,
        ),
        ImageUserWithFrameRealtion(
          imagePath: imagePathSecondUser,
          height: 50,
          width: 50,
          heightFrame: 59,
          widthFrame: 59,
          margin: const EdgeInsets.only(left: 42),
        ),
      ],
    );
  }
}

class BottomSectionRelationTopUser extends StatelessWidget {
  const BottomSectionRelationTopUser({
    super.key,
    required this.level,
  });
  final String level;
  @override
  Widget build(BuildContext context) {
    return Container(
      width: 90,
      height: 30,
      decoration: BoxDecoration(
        color: AppColors.pinkWhiteTwo.withValues(alpha: .7),
        border: Border.all(color: AppColors.white, width: .4),
        boxShadow: const [
          BoxShadow(
              color: AppColors.white,
              blurRadius: 4,
              blurStyle: BlurStyle.outer,
              offset: Offset(1, 1))
        ],
        borderRadius: const BorderRadius.only(
          topRight: Radius.circular(20),
          bottomRight: Radius.circular(20),
          bottomLeft: Radius.circular(20),
          topLeft: Radius.circular(20),
        ),
      ),
      alignment: Alignment.center,
      child: LevelWithLoveIcon(level: level),
    );
  }
}

class LevelWithLoveIcon extends StatelessWidget {
  const LevelWithLoveIcon({
    super.key,
    required this.level,
  });

  final String level;

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        AutoSizeText(
          level,
          style: const TextStyle(
            color: AppColors.white,
            fontSize: 14,
            fontWeight: FontWeight.bold,
            shadows: [
              Shadow(
                color: Colors.black,
                blurRadius: 2,
                offset: Offset(1, 1),
              ),
            ],
          ),
        ),
        const SizedBox(
          width: 5,
        ),
        Image.asset(
          AssetsData.doubleHeartIcon,
          width: 20,
          height: 20,
        ),
      ],
    );
  }
}

class TopSectionRelationTopUser extends StatelessWidget {
  const TopSectionRelationTopUser({
    super.key,
    this.imagePathFirstUser,
    this.imagePathSecondUser,
  });
  final String? imagePathFirstUser;
  final String? imagePathSecondUser;
  @override
  Widget build(BuildContext context) {
    return Stack(
      alignment: Alignment.topCenter,
      children: [
        // Image.asset(
        //   AssetsData.heartImage,
        //   height: 40,
        //   width: 40,
        //   fit: BoxFit.contain,
        // ),
        Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            ImageUserWithFrameRealtion(
              imagePath: imagePathFirstUser,
            ),
            ImageUserWithFrameRealtion(
              imagePath: imagePathSecondUser,
            ),
          ],
        ),
      ],
    );
  }
}

class ImageUserWithFrameRealtion extends StatelessWidget {
  const ImageUserWithFrameRealtion({
    super.key,
    this.imagePath,
    this.width = 65,
    this.widthFrame = 80,
    this.height = 65,
    this.heightFrame = 80,
    this.margin,
  });
  final String? imagePath;
  final double? width;
  final double? widthFrame;
  final double? height;
  final double? heightFrame;
  final EdgeInsetsGeometry? margin;
  @override
  Widget build(BuildContext context) {
    return Container(
      margin: margin,
      child: Stack(
        alignment: Alignment.center,
        children: [
          SizedBox(
            width: width,
            height: height,
            child: CircularUserImage(imagePath: imagePath),
          ),
          Image.asset(
            width: widthFrame,
            height: heightFrame,
            AssetsData.relationFrameOne,
            fit: BoxFit.cover,
          ),
        ],
      ),
    );
  }
}

class _PairUsers {
  const _PairUsers({
    required this.u1,
    required this.u2,
    required this.level,
    required this.n1,
    required this.n2,
  });
  final String? u1;
  final String? u2;
  final String level;
  final String n1;
  final String n2;
}
