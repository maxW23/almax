import 'package:auto_size_text/auto_size_text.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:lklk/core/constants/app_colors.dart';
import 'package:lklk/features/home/domain/entities/relation_entity.dart';
import 'package:lklk/features/home/presentation/manger/top_user_cubit/top_users_cubit.dart';
import 'package:lklk/features/home/presentation/views/slide_view/top_relation_page.dart';
import 'package:lklk/features/room/presentation/views/widgets/image_user_section_with_fram.dart';
import 'package:lklk/features/weekly_star_event/cubit/countdown_cubit.dart';

class CpChallengePage extends StatelessWidget {
  const CpChallengePage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        toolbarHeight: 0,
        iconTheme: const IconThemeData(color: Colors.white),
      ),
      body: MultiBlocProvider(
        providers: [
          BlocProvider<TopUsersCubit>(
              create: (_) => TopUsersCubit()..fetchTopUsers(8)),
          BlocProvider<CountdownCubit>(
              create: (_) => CountdownCubit()..start()),
        ],
        child: const _CpBody(),
      ),
    );
  }
}

// Timer helpers (same UI as other pages)
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
          const SizedBox(width: 8),
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

class _CpBody extends StatelessWidget {
  const _CpBody();

  static const String _bgPath = 'assets/cp_chanllage/cp_background.png';
  static const String _top3Bg =
      'assets/cp_chanllage/rank_background_tops_users.png';

  // frames: defined and used inside _Top3Section

  static const String _restBg =
      'assets/cp_chanllage/backgound_users_from_4th_to_10th.png';

  static const String _prizesImg = 'assets/cp_chanllage/cp_prizes.png';

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<TopUsersCubit, TopUsersState>(
      builder: (context, state) {
        if (state is TopUsersLoading) {
          return const Center(
            child: CircularProgressIndicator(color: AppColors.pinkwhiteColor),
          );
        }
        if (state is TopUsersError) {
          return Center(
            child: AutoSizeText(
              'Error: ${state.message}',
              style: const TextStyle(color: Colors.white),
            ),
          );
        }
        if (state is TopUserRelationUsersLoaded) {
          final List<UserRelation> list = state.users;
          final List<UserRelation> top10 =
              list.isNotEmpty ? list.take(10).toList() : <UserRelation>[];
          final UserRelation? top1 = top10.isNotEmpty ? top10[0] : null;
          final UserRelation? top2 = top10.length > 1 ? top10[1] : null;
          final UserRelation? top3 = top10.length > 2 ? top10[2] : null;
          final List<UserRelation> rest =
              top10.length > 3 ? top10.sublist(3) : <UserRelation>[];

          return Container(
            decoration: BoxDecoration(
              image: DecorationImage(
                image: AssetImage(_bgPath),
                fit: BoxFit.fill,
              ),
            ),
            child: CustomScrollView(
              slivers: [
                // countdown timer above Top3 section

                SliverToBoxAdapter(
                  child: Padding(
                    padding: const EdgeInsets.only(
                        left: 12, right: 12, top: 400, bottom: 16),
                    child: _Top3Section(
                      top1: top1,
                      top2: top2,
                      top3: top3,
                      bgPath: _top3Bg,
                    ),
                  ),
                ),
                if (rest.isNotEmpty)
                  SliverList(
                    delegate: SliverChildBuilderDelegate(
                      (context, index) {
                        final r = rest[index];
                        return Container(
                          margin: const EdgeInsets.fromLTRB(12, 4, 12, 8),
                          decoration: BoxDecoration(
                            image: DecorationImage(
                              image: AssetImage(_restBg),
                              fit: BoxFit.cover,
                            ),
                          ),
                          child: RelationListItem(
                            rank: index + 4,
                            user1Name: r.user1Name ?? '',
                            user2Name: r.user2Name ?? '',
                            user1Img: r.user1Img,
                            user2Img: r.user2Img,
                            level: r.level ?? '0',
                          ),
                        );
                      },
                      childCount: rest.length,
                    ),
                  ),
                SliverToBoxAdapter(
                  child: Padding(
                    padding: const EdgeInsets.symmetric(
                        horizontal: 12, vertical: 16),
                    child: SizedBox(
                      width: double.infinity,
                      height: MediaQuery.sizeOf(context).height * 0.8,
                      child: Image.asset(
                        _prizesImg,
                        fit: BoxFit.fill,
                      ),
                    ),
                  ),
                ),
              ],
            ),
          );
        }
        return const SizedBox.shrink();
      },
    );
  }
}

class _Top3Section extends StatelessWidget {
  const _Top3Section({
    required this.top1,
    required this.top2,
    required this.top3,
    required this.bgPath,
  });

  final UserRelation? top1;
  final UserRelation? top2;
  final UserRelation? top3;
  final String bgPath;

  static const String _top1Blue =
      'assets/cp_chanllage/blue avatar frame_top_1.svga';
  static const String _top1Pink =
      'assets/cp_chanllage/pink avatar frame_top 1.svga';
  static const String _top2Blue = 'assets/cp_chanllage/cp blue top 2.svga';
  static const String _top2Pink = 'assets/cp_chanllage/cp pink top 2.svga';
  static const String _top3Blue = 'assets/cp_chanllage/blue top 3.svga';
  static const String _top3Pink = 'assets/cp_chanllage/pink top 3.svga';

  @override
  Widget build(BuildContext context) {
    final double width = MediaQuery.sizeOf(context).width;
    final double h = width * 1.05; // banner-like block height

    return SizedBox(
      width: width,
      height: h,
      child: Stack(
        alignment: Alignment.center,
        children: [
          Positioned.fill(
            child: Image.asset(
              bgPath,
              fit: BoxFit.fill,
            ),
          ),
          // Center top1
          if (top1 != null)
            Positioned(
              top: h * 0.19,
              child: _CpPairCard(
                relation: top1!,
                blueFrame: _top1Blue,
                pinkFrame: _top1Pink,
                nameStyle: const TextStyle(
                  color: Colors.white,
                  fontSize: 12,
                  fontWeight: FontWeight.w800,
                ),
                levelStyle: const TextStyle(
                  color: Colors.white,
                  fontSize: 11,
                  fontWeight: FontWeight.bold,
                ),
                scale: 1.1,
              ),
            ),
          // Left top3
          if (top3 != null)
            Positioned(
              left: width * 0.01,
              bottom: h * 0.000001,
              child: _CpPairCard(
                relation: top3!,
                blueFrame: _top3Blue,
                pinkFrame: _top3Pink,
                scale: 0.95,
              ),
            ),
          // Right top2
          if (top2 != null)
            Positioned(
              right: width * 0.01,
              bottom: h * 0.000001,
              child: _CpPairCard(
                relation: top2!,
                blueFrame: _top2Blue,
                pinkFrame: _top2Pink,
                scale: 0.95,
              ),
            ),

          Positioned(
            bottom: 50,
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
        ],
      ),
    );
  }
}

class _CpPairCard extends StatelessWidget {
  const _CpPairCard({
    required this.relation,
    required this.blueFrame,
    required this.pinkFrame,
    this.scale = 1.0,
    this.nameStyle,
    this.levelStyle,
  });

  final UserRelation relation;
  final String blueFrame;
  final String pinkFrame;
  final double scale;
  final TextStyle? nameStyle;
  final TextStyle? levelStyle;

  @override
  Widget build(BuildContext context) {
    final double base = 70 * scale;
    final double frame = 80 * scale;

    return SizedBox(
      height: 200.h,
      child: Column(
        // mainAxisSize: MainAxisSize.min,
        children: [
          Stack(
            alignment: Alignment.center,
            children: [
              Padding(
                padding: const EdgeInsets.only(right: 50),
                child: ImageUserSectionWithFram(
                  isImage: true,
                  img: relation.user1Img,
                  linkPath: blueFrame,
                  width: frame,
                  height: frame,
                  radius: base * 0.42,
                ),
              ),
              // const SizedBox(width: 12),
              Padding(
                padding: const EdgeInsets.only(left: 50),
                child: ImageUserSectionWithFram(
                  isImage: true,
                  img: relation.user2Img,
                  linkPath: pinkFrame,
                  width: frame,
                  height: frame,
                  radius: base * 0.42,
                ),
              ),
            ],
          ),
          const SizedBox(height: 6),
          SizedBox(
            width: frame * 2 + 12,
            child: Column(
              children: [
                AutoSizeText(
                  '${relation.user1Name ?? ''}',
                  maxLines: 1,
                  textAlign: TextAlign.center,
                  style: nameStyle ??
                      const TextStyle(
                        color: Colors.white,
                        fontWeight: FontWeight.w700,
                        fontSize: 11,
                      ),
                ),
                AutoSizeText(
                  '${relation.user2Name ?? ''}',
                  maxLines: 1,
                  textAlign: TextAlign.center,
                  style: nameStyle ??
                      const TextStyle(
                        color: Colors.white,
                        fontWeight: FontWeight.w700,
                        fontSize: 11,
                      ),
                ),
                const SizedBox(height: 4),
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    const Icon(Icons.favorite,
                        color: Colors.pinkAccent, size: 16),
                    const SizedBox(width: 4),
                    AutoSizeText(
                      relation.level ?? '0',
                      maxLines: 1,
                      style: levelStyle ??
                          const TextStyle(
                            color: Colors.white,
                            fontSize: 10,
                            fontWeight: FontWeight.bold,
                          ),
                    ),
                  ],
                )
              ],
            ),
          ),
        ],
      ),
    );
  }
}
