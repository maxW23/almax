import 'package:auto_size_text/auto_size_text.dart';
import 'dart:math' as math;
import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:lklk/core/constants/app_colors.dart';
import 'package:lklk/core/service_locator.dart';
import 'package:lklk/core/services/api_service.dart';
import 'package:lklk/features/auth/domain/entities/user_entity.dart';
import 'package:lklk/features/home/presentation/manger/top_user_cubit/top_users_cubit.dart';
import 'package:lklk/features/profile_users/presentaion/manger/user_cubit/user_cubit_cubit.dart';
import 'package:lklk/features/room/presentation/views/widgets/image_user_section_with_fram.dart';
import 'package:lklk/features/room/presentation/views/widgets/user_widget_title.dart';
import 'package:lklk/features/weekly_star_event/cubit/countdown_cubit.dart';
import 'package:lklk/features/tasks/presentation/views/widgets/skeletons/ranking_tab_skeleton.dart';

class WakalaChallengePage extends StatelessWidget {
  const WakalaChallengePage({super.key, required this.userCubit});

  final UserCubit userCubit;

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
      body: BlocProvider.value(
        value: userCubit,
        child: const _RankingTab(),
      ),
    );
  }

  Widget _buildPrizesSection() {
    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 16, 16, 32),
      child: InteractiveViewer(
        minScale: 0.7,
        maxScale: 3,
        child: const Center(
          child: _PrizeSectionComposition(),
        ),
      ),
    );
  }
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

class _BannerWithUser extends StatelessWidget {
  const _BannerWithUser({
    required this.bannerPath,
    required this.child,
    this.heightFactor = 1.3,
    this.childTopFactor = 0.3,
  });

  final String bannerPath;
  final Widget child;
  // height = width * heightFactor
  final double heightFactor;
  // top padding inside the banner space = height * childTopFactor
  final double childTopFactor;

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(builder: (context, constraints) {
      final width = constraints.maxWidth.isFinite
          ? constraints.maxWidth
          : MediaQuery.sizeOf(context).width;
      final double height = width * heightFactor;
      return SizedBox(
        width: width,
        height: height,
        child: Stack(
          alignment: Alignment.topCenter,
          children: [
            Positioned.fill(
              child: Image.asset(
                bannerPath,
                fit: BoxFit.contain,
              ),
            ),
            Positioned(
              top: height * childTopFactor,
              child: child,
            ),
          ],
        ),
      );
    });
  }
}

class _RankingTab extends StatelessWidget {
  const _RankingTab();

  static const String _bgPath =
      'assets/wakala_chanllage/قسم الترتيب خلفية الصفحة.png';
  static const String _headerPath =
      'assets/wakala_chanllage/القسم العلوي لتحدي الوكالات الاسدين.png';

  static const String _goldFramePng =
      'assets/wakala_chanllage/frame gold top 1.png';
  static const String _silverFrame =
      'assets/wakala_chanllage/frame silver top 2.png';
  static const String _bronzeFrame =
      'assets/wakala_chanllage/frame bronze top 3.png';

  // Vertical banner backgrounds
  static const String _bannerGold =
      'assets/wakala_chanllage/vertical banner gold.png';
  static const String _bannerSilver =
      'assets/wakala_chanllage/vertical banner silver.png';
  static const String _bannerBronze =
      'assets/wakala_chanllage/vertical banner bronze.png';

  // Prizes assets
  static const String _prizeBg =
      'assets/wakala_chanllage/prize_section_bg.png';
  static const String _wordTop1 =
      'assets/wakala_chanllage/TOP 1 كلمة.png';
  static const String _wordTop2 =
      'assets/wakala_chanllage/TOP 2 كلمة.png';
  static const String _wordTop3 =
      'assets/wakala_chanllage/TOP 3 كلمة.png';
  static const String _wordButtonBg =
      'assets/wakala_chanllage/button.png';
  static const String _redPanel =
      'assets/wakala_chanllage/reddish brown shape layer.png';
  static const String _goldSquareFrame =
      'assets/wakala_chanllage/اطار ذهبي مربع.png';
  static const String _decorTop = 'assets/wakala_chanllage/psd_565.png';
  static const String _decorBottom = 'assets/wakala_chanllage/psd_561.png';
  static const String _tagGold =
      'assets/wakala_chanllage/tag gold top 1.png';
  static const String _tagSilver =
      'assets/wakala_chanllage/tag silver top 2.png';
  static const String _tagBronze =
      'assets/wakala_chanllage/tag bronze top 3.png';
  static const String _frameGoldPrize =
      'assets/wakala_chanllage/frame gold top 1.png';
  static const String _frameSilverPrize =
      'assets/wakala_chanllage/frame silver top 2.png';
  static const String _frameBronzePrize =
      'assets/wakala_chanllage/frame bronze top 3.png';

  @override
  Widget build(BuildContext context) {
    final userCubit =
        (context.findAncestorWidgetOfExactType<WakalaChallengePage>())
            ?.userCubit;

    return MultiBlocProvider(
      providers: [
        BlocProvider<TopUsersCubit>(
            create: (_) => TopUsersCubit()..wakalaTop(19)),
        BlocProvider<CountdownCubit>(create: (_) => CountdownCubit()..start()),
      ],
      child: BlocBuilder<TopUsersCubit, TopUsersState>(
        builder: (context, state) {
          if (state is TopUsersLoading) {
            return Container(
              decoration: const BoxDecoration(color: AppColors.black),
              child: CustomScrollView(
                slivers: [
                  SliverToBoxAdapter(
                    child: Image.asset(
                      _headerPath,
                      width: double.infinity,
                      fit: BoxFit.fill,
                    ),
                  ),
                  SliverToBoxAdapter(
                    child: Container(
                      height: MediaQuery.sizeOf(context).height,
                      width: MediaQuery.sizeOf(context).width,
                      decoration: BoxDecoration(
                        image: DecorationImage(
                          image: AssetImage(_bgPath),
                          fit: BoxFit.fill,
                        ),
                      ),
                      child: Column(
                        children: [
                          // timer (real, not skeleton)
                          Padding(
                            padding: const EdgeInsets.only(
                                left: 16, right: 16, top: 80, bottom: 10),
                            child: SizedBox(
                              height: 32,
                              child:
                                  BlocBuilder<CountdownCubit, CountdownState>(
                                buildWhen: (p, c) =>
                                    p.remainingDuration.inSeconds !=
                                    c.remainingDuration.inSeconds,
                                builder: (context, s) {
                                  final digits =
                                      _digitsFromDuration(s.remainingDuration);
                                  return Row(
                                    mainAxisAlignment: MainAxisAlignment.center,
                                    children: _buildTimerTiles(digits),
                                  );
                                },
                              ),
                            ),
                          ),
                          // podium skeleton
                          const Padding(
                            padding: EdgeInsets.symmetric(
                                horizontal: 16, vertical: 20),
                            child: PodiumSkeleton(height: 220),
                          ),
                          // list skeleton
                          Padding(
                            padding: const EdgeInsets.fromLTRB(16, 12, 16, 16),
                            child: ListView.builder(
                              shrinkWrap: true,
                              physics: const NeverScrollableScrollPhysics(),
                              itemCount: 8,
                              itemBuilder: (_, __) =>
                                  const RankingRowSkeleton(),
                            ),
                          ),
                          // prizes section at bottom while loading
                        ],
                      ),
                    ),
                  ),
                  SliverToBoxAdapter(child: _buildPrizesSection()),
                ],
              ),
            );
          }
          if (state is TopUsersError) {
            return Center(
              child: Text(
                state.message,
                style: const TextStyle(color: Colors.white),
              ),
            );
          }
          if (state is TopUsersLoaded) {
            final List<UserEntity> all = state.users;
            final List<UserEntity> top = all.take(10).toList();
            final top1 = top.isNotEmpty ? top[0] : null;
            final top2 = top.length > 1 ? top[1] : null;
            final top3 = top.length > 2 ? top[2] : null;
            final rest = top.length > 3 ? top.sublist(3) : <UserEntity>[];

            return Container(
              decoration: const BoxDecoration(color: AppColors.black),
              child: CustomScrollView(
                slivers: [
                  SliverToBoxAdapter(
                    child: Image.asset(
                      _headerPath,
                      width: double.infinity,
                      fit: BoxFit.fill,
                    ),
                  ),
                  SliverToBoxAdapter(
                    child: Container(
                      height: MediaQuery.sizeOf(context).height,
                      width: MediaQuery.sizeOf(context).width,
                      decoration: BoxDecoration(
                        image: DecorationImage(
                          image: AssetImage(_bgPath),
                          fit: BoxFit.fill,
                        ),
                      ),
                      child: Column(children: [
                        // here add timer
                        Padding(
                          padding: const EdgeInsets.only(
                              left: 16, right: 16, top: 80, bottom: 10),
                          child: SizedBox(
                            height: 32,
                            child: BlocBuilder<CountdownCubit, CountdownState>(
                              buildWhen: (p, c) =>
                                  p.remainingDuration.inSeconds !=
                                  c.remainingDuration.inSeconds,
                              builder: (context, state) {
                                final digits = _digitsFromDuration(
                                    state.remainingDuration);
                                return Row(
                                  mainAxisAlignment: MainAxisAlignment.center,
                                  children: _buildTimerTiles(digits),
                                );
                              },
                            ),
                          ),
                        ),

///// top
                        Padding(
                          padding: const EdgeInsets.only(
                              left: 16, right: 16, bottom: 20),
                          child: _buildTop3Row(context, top1, top2, top3),
                        ),
                        if (rest.isNotEmpty)
                          Padding(
                            padding: const EdgeInsets.fromLTRB(16, 12, 16, 16),
                            child: ListView.builder(
                              shrinkWrap: true,
                              physics: const NeverScrollableScrollPhysics(),
                              itemCount: rest.length,
                              itemBuilder: (ctx, index) {
                                final u = rest[index];
                                final totalSpent = (u.totalSpent ?? '').trim();
                                return Container(
                                  margin: const EdgeInsets.only(bottom: 8),
                                  decoration: BoxDecoration(
                                    color: Colors.black.withOpacity(0.35),
                                    borderRadius: BorderRadius.circular(12),
                                    border: Border.all(
                                        color: Colors.white24, width: 1),
                                  ),
                                  child: UserWidgetTitle(
                                      user: u,
                                      userCubit: userCubit,
                                      isImage: true,
                                      isID: false,
                                      isLevel: true,
                                      isWakel: false,
                                      isRoomTypeUser: false,
                                      contentPadding:
                                          const EdgeInsets.symmetric(
                                              horizontal: 12, vertical: 4),
                                      trailing: totalSpent.isEmpty
                                          ? null
                                          : Row(
                                              mainAxisSize: MainAxisSize.min,
                                              children: [
                                                const Icon(
                                                  Icons.flash_on,
                                                  color: Colors.orangeAccent,
                                                  size: 16,
                                                ),
                                                const SizedBox(width: 4),
                                                Text(
                                                  totalSpent,
                                                  style: const TextStyle(
                                                    color: Colors.white,
                                                    fontWeight: FontWeight.bold,
                                                    fontSize: 12,
                                                  ),
                                                ),
                                              ],
                                            )
                                      // Row(
                                      //     mainAxisSize: MainAxisSize.min,
                                      //     children: [
                                      //       const Icon(
                                      //         Icons.calendar_month,
                                      //         color: Colors.lightBlueAccent,
                                      //         size: 16,
                                      //       ),
                                      //       const SizedBox(width: 6),
                                      //       Text(
                                      //         monthPts,
                                      //         style: const TextStyle(
                                      //           color: Colors.white,
                                      //           fontWeight: FontWeight.bold,
                                      //           fontSize: 12,
                                      //         ),
                                      //       ),
                                      //     ],
                                      // ),
                                      ),
                                );
                              },
                            ),
                          ),
                      ]),
                    ),
                  ),
                  SliverToBoxAdapter(child: _buildPrizesSection()),
                ],
              ),
            );
          }

          return const SizedBox.shrink();
        },
      ),
    );
  }

  Widget _buildTop3Row(BuildContext context, UserEntity? top1, UserEntity? top2,
      UserEntity? top3) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        // Top 1 at the top (center) with gold banner behind
        _BannerWithUser(
          bannerPath: _bannerGold,
          heightFactor: .8,
          childTopFactor: 0.17,
          child: _TopUserCard(
            user: top1,
            avatarScale: 0.7,
            framePath: 'https://lklklive.com/asset/frame/newframe/f1.png',
            isCenterBig: true,
          ),
        ),
        const SizedBox(height: 12),
        // Row with Top3 (bronze) on the left and Top2 (silver) on the right
        Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Expanded(
              child: _BannerWithUser(
                bannerPath: _bannerBronze,
                heightFactor: 1.4,
                childTopFactor: 0.2,
                child: _TopUserCard(
                  user: top3,
                  framePath: _bronzeFrame,
                  avatarScale: 0.6,
                ),
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: _BannerWithUser(
                bannerPath: _bannerSilver,
                heightFactor: 1.4,
                childTopFactor: 0.2,
                child: _TopUserCard(
                  user: top2,
                  framePath: _silverFrame,
                  avatarScale: 0.6,
                ),
              ),
            ),
          ],
        )
      ],
    );
  }

  Widget _buildPrizesSection() {
    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 16, 16, 32),
      child: InteractiveViewer(
        minScale: 0.7,
        maxScale: 3,
        child: const Center(
          child: _PrizeSectionComposition(),
        ),
      ),
    );
  }
}

class _TopUserCard extends StatelessWidget {
  const _TopUserCard({
    required this.user,
    required this.framePath,
    this.isCenterBig = false,
    this.avatarScale = 1.0,
  });

  final UserEntity? user;
  final String framePath;
  final bool isCenterBig;

  /// معامل لتكبير/تصغير حجم صورة المستخدم داخل الإطار.
  /// 1.0 = الحجم الأصلي، 0.8 = أصغر بـ 20%، 1.2 = أكبر بـ 20%.
  final double avatarScale;
  // optional displayed points under the card

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (context, constraints) {
        final double maxSide = constraints.maxWidth.isFinite
            ? constraints.maxWidth
            : (isCenterBig ? 160 : 130);
        final double desired = isCenterBig ? 160 : 130;
        final double size = math.min(desired, maxSide) * avatarScale;
        final double baseRadius = isCenterBig ? 46 : 50;
        final double radius = baseRadius * (size / desired);

        return Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            if (user != null)
              Stack(
                alignment: Alignment.topCenter,
                children: [
                  Padding(
                    padding: EdgeInsets.only(top: isCenterBig ? 6 : 10),
                    child: ImageUserSectionWithFram(
                      img: user!.img,
                      linkPath: framePath,
                      isImage: true,
                      padding: 10,
                      height: size,
                      width: size,
                      radius: radius,
                    ),
                  ),
                ],
              )
            else
              const SizedBox(height: 160),
            const SizedBox(height: 8),
            if (user != null) ...[
              Container(
                padding:
                    const EdgeInsets.symmetric(horizontal: 24, vertical: 6),
                decoration: BoxDecoration(
                  color: Colors.white.withOpacity(0.8),
                  borderRadius: BorderRadius.circular(30),
                ),
                child: AutoSizeText(
                  user!.name ?? '',
                  maxLines: 1,
                  minFontSize: 10,
                  textAlign: TextAlign.center,
                  style: const TextStyle(
                    fontSize: 12,
                    fontWeight: FontWeight.w700,
                  ),
                ),
              ),
              const SizedBox(height: 6),
              if (user!.totalSpent != null && user!.totalSpent!.isNotEmpty)
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    if ((user!.totalSpent ?? '').isNotEmpty) ...[
                      const Icon(Icons.flash_on,
                          color: Colors.orangeAccent, size: 16),
                      const SizedBox(width: 4),
                      Text(
                        user!.totalSpent!,
                        style: const TextStyle(
                          color: Colors.white,
                          fontWeight: FontWeight.bold,
                          fontSize: 12,
                        ),
                      ),
                    ],
                  ],
                ),
            ],
          ],
        );
      },
    );
  }
}

class _PrizesTab extends StatelessWidget {
  const _PrizesTab();

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: const BoxDecoration(),
      child: InteractiveViewer(
        minScale: 0.7,
        maxScale: 3,
        child: const Center(
          child: _PrizeSectionComposition(),
        ),
      ),
    );
  }
}

// ==================== PRIZES SECTION (Layered UI) ====================
class _PrizeSectionComposition extends StatelessWidget {
  const _PrizeSectionComposition();

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (context, constraints) {
        final double w = constraints.maxWidth.isFinite
            ? constraints.maxWidth
            : MediaQuery.sizeOf(context).width;
        // Background aspect ~486:1024 (w:h)
        final double h = w * (1024.0 / 486.0);

        final double sidePad = w * 0.08;
        final double spacing = w * 0.095;
        final double cardW = w * 0.35;
        final double cardH = cardW * 0.86;

        return SizedBox(
          width: w,
          height: h,
          child: Stack(
            children: [
              Positioned.fill(
                child: Image.asset(_RankingTab._prizeBg, fit: BoxFit.fill),
              ),
              Positioned.fill(
                child: Padding(
                  padding: EdgeInsets.only(top: h * 0.155, bottom: h * 0.045),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: [
                      const _PrizeTitle(wordPath: _RankingTab._wordTop1),
                      SizedBox(height: w * 0.03),
                      Row(
                        children: [
                          SizedBox(width: sidePad),
                          _PrizeCard(
                            width: cardW,
                            height: cardH,
                            redPanelPath: _RankingTab._redPanel,
                            goldFramePath: _RankingTab._goldSquareFrame,
                            contentPath: _RankingTab._tagGold,
                            showDecor: true,
                          ),
                          SizedBox(width: spacing),
                          _PrizeCard(
                            width: cardW,
                            height: cardH,
                            redPanelPath: _RankingTab._redPanel,
                            goldFramePath: _RankingTab._goldSquareFrame,
                            contentPath: 'https://lklklive.com/asset/frame/newframe/f1.png',
                            showDecor: true,
                          ),
                          SizedBox(width: sidePad),
                        ],
                      ),
                      SizedBox(height: w * 0.06),
                      const _PrizeTitle(wordPath: _RankingTab._wordTop2),
                      SizedBox(height: w * 0.03),
                      Row(
                        children: [
                          SizedBox(width: sidePad),
                          _PrizeCard(
                            width: cardW,
                            height: cardH,
                            redPanelPath: _RankingTab._redPanel,
                            goldFramePath: _RankingTab._goldSquareFrame,
                            contentPath: _RankingTab._tagSilver,
                            showDecor: true,
                          ),
                          SizedBox(width: spacing),
                          _PrizeCard(
                            width: cardW,
                            height: cardH,
                            redPanelPath: _RankingTab._redPanel,
                            goldFramePath: _RankingTab._goldSquareFrame,
                            contentPath: _RankingTab._frameSilverPrize,
                            showDecor: true,
                          ),
                          SizedBox(width: sidePad),
                        ],
                      ),
                      SizedBox(height: w * 0.06),
                      const _PrizeTitle(wordPath: _RankingTab._wordTop3),
                      SizedBox(height: w * 0.03),
                      Row(
                        children: [
                          SizedBox(width: sidePad),
                          _PrizeCard(
                            width: cardW,
                            height: cardH,
                            redPanelPath: _RankingTab._redPanel,
                            goldFramePath: _RankingTab._goldSquareFrame,
                            contentPath: _RankingTab._tagBronze,
                            showDecor: false,
                          ),
                          SizedBox(width: spacing),
                          _PrizeCard(
                            width: cardW,
                            height: cardH,
                            redPanelPath: _RankingTab._redPanel,
                            goldFramePath: _RankingTab._goldSquareFrame,
                            contentPath: _RankingTab._frameBronzePrize,
                            showDecor: false,
                          ),
                          SizedBox(width: sidePad),
                        ],
                      ),
                    ],
                  ),
                ),
              ),
            ],
          ),
        );
      },
    );
  }
}

class _PrizeTitle extends StatelessWidget {
  const _PrizeTitle({required this.wordPath});
  final String wordPath;

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(builder: (context, c) {
      final w = c.maxWidth;
      final double bw = w * 0.42;
      return Center(
        child: SizedBox(
          width: bw,
          height: bw * 0.28,
          child: Stack(
            alignment: Alignment.center,
            children: [
              Positioned.fill(
                child: Image.asset(_RankingTab._wordButtonBg, fit: BoxFit.fill),
              ),
              Image.asset(wordPath, fit: BoxFit.contain),
            ],
          ),
        ),
      );
    });
  }
}

class _PrizeCard extends StatelessWidget {
  const _PrizeCard({
    required this.width,
    required this.height,
    required this.redPanelPath,
    required this.goldFramePath,
    required this.contentPath,
    this.showDecor = false,
  });

  final double width;
  final double height;
  final String redPanelPath;
  final String goldFramePath;
  final String contentPath;
  final bool showDecor;

  @override
  Widget build(BuildContext context) {
    final double decorOverlap = height * 0.12;
    return SizedBox(
      width: width,
      height: height,
      child: Stack(
        clipBehavior: Clip.none,
        children: [
          Positioned.fill(
            child: Image.asset(redPanelPath, fit: BoxFit.fill),
          ),
          Positioned.fill(
            child: Image.asset(goldFramePath, fit: BoxFit.fill),
          ),
          Positioned.fill(
            child: Padding(
              padding: EdgeInsets.all(width * 0.12),
              child: FittedBox(
                fit: BoxFit.contain,
                child: contentPath.startsWith('http')
                    ? CachedNetworkImage(
                        imageUrl: contentPath,
                        fadeInDuration: Duration.zero,
                        fadeOutDuration: Duration.zero,
                        fit: BoxFit.contain,
                      )
                    : Image.asset(contentPath),
              ),
            ),
          ),
          if (showDecor) ...[
            Positioned(
              top: -decorOverlap,
              left: 0,
              right: 0,
              child: Image.asset(
                _RankingTab._decorTop,
                width: width,
                fit: BoxFit.contain,
              ),
            ),
            Positioned(
              bottom: -decorOverlap,
              left: 0,
              right: 0,
              child: Image.asset(
                _RankingTab._decorBottom,
                width: width,
                fit: BoxFit.contain,
              ),
            ),
          ],
        ],
      ),
    );
  }
}
