// ignore_for_file: public_member_api_docs, sort_constructors_first
import 'package:lklk/core/utils/logger.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:auto_size_text/auto_size_text.dart';
import 'dart:ui' as ui;
import 'package:lklk/core/app_size.dart';
import 'package:lklk/generated/l10n.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:lklk/core/constants/app_colors.dart';
import 'package:lklk/core/constants/assets.dart';
import 'package:lklk/core/constants/styles.dart';
import 'package:lklk/core/player/svga_custom_player.dart';
import 'package:lklk/features/auth/domain/entities/user_entity.dart';
import 'package:lklk/features/room/presentation/views/widgets/circular_user_image.dart';
import 'package:lklk/features/room/presentation/views/widgets/image_user_section_with_fram.dart';
import '../../../../../core/utils/gradient_text.dart';
import '../widgets/bottom_navigation_bar_s_v_i_p.dart';
import 'package:shimmer/shimmer.dart';

class SVIPPage extends StatefulWidget {
  const SVIPPage({
    super.key,
    required this.user,
  });

  final UserEntity user;

  @override
  State<SVIPPage> createState() => _SVIPPageState();
}

class _SVIPPageState extends State<SVIPPage> {
  int levelSVIP = 1;
  @override
  void initState() {
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    List<ItemSVIPClass> advantageItems = [];

    if (levelSVIP >= 1) {
      advantageItems = [
        ItemSVIPClass(
            title: S.of(context).lockRoom,
            svgaPath: 'assets/icons/44.svg',
            isActive: true), //
        // ItemSVIPClass(
        //     title: S.of(context).uniqueID,
        //     svgaPath: 'assets/icons/77.svg',
        //     isActive: true), //
        ItemSVIPClass(
            title: S.of(context).checkVisitors,
            svgaPath: 'assets/icons/33.svg',
            isActive: false), //2
        ItemSVIPClass(
            title: S.of(context).quickLevel,
            svgaPath: 'assets/icons/22.svg',
            isActive: false), //3,

        ItemSVIPClass(
            title: S.of(context).antikick,
            svgaPath: 'assets/icons/55.svg',
            isActive: false), //4
        ItemSVIPClass(
            title: S.of(context).hideAccess,
            svgaPath: 'assets/icons/66.svg',
            isActive: false),
        ItemSVIPClass(
            title: S.of(context).imageGIF,
            svgaPath: 'assets/icons/11.svg',
            isActive: false),
      ];
    }

    // For levelSVIP = 2
    if (levelSVIP >= 2) {
      advantageItems[1] = ItemSVIPClass(
          title: S.of(context).checkVisitors,
          svgaPath: 'assets/icons/33.svg',
          isActive: true);
    }

    // For levelSVIP = 3
    if (levelSVIP >= 3) {
      advantageItems[2] = ItemSVIPClass(
          title: S.of(context).quickLevel,
          svgaPath: 'assets/icons/22.svg',
          isActive: true);
    }

    if (levelSVIP >= 4) {
      advantageItems[3] = ItemSVIPClass(
          title: S.of(context).antikick,
          svgaPath: 'assets/icons/55.svg',
          isActive: true);
      // advantageItems[5] = ItemSVIPClass(
      //     title: 'anti ban & kick',
      //     svgaPath: 'assets/icons/55.svg',
      //     isActive: true);
    }

    if (levelSVIP >= 5) {
      advantageItems[4] = ItemSVIPClass(
          title: S.of(context).hideAccess,
          svgaPath: 'assets/icons/66.svg',
          isActive: true);
      advantageItems[5] = ItemSVIPClass(
          title: S.of(context).imageGIF,
          svgaPath: 'assets/icons/11.svg',
          isActive: true);
    }

    int advantageNumber = advantageItems.where((item) => item.isActive).length;

    return SafeArea(
      top: false,
      child: Scaffold(
        backgroundColor: Colors.transparent,
        body: Stack(
          children: [
            // Full-page background image
            Positioned.fill(
              child: Image.asset(
                'assets/vip_pages/VIP_backgruond.png',
                fit: BoxFit.cover,
              ),
            ),
            // Gradient overlay according to selected VIP
            Positioned.fill(
              child: Container(
                decoration: BoxDecoration(
                  gradient: _buildPageOverlayGradient(levelSVIP),
                ),
              ),
            ),
            // Foreground content
            Column(
              children: [
                const SizedBox(height: 12),
                SVIPLevelSelector(
                  user: widget.user,
                  initialLevel: levelSVIP,
                  onLevelChanged: (selectedLevel) {
                    setState(() {
                      levelSVIP = selectedLevel;
                      log('level is $levelSVIP');
                    });
                  },
                ),
                Expanded(
                  child: SingleChildScrollView(
                    child: Column(
                      children: [
                        const SizedBox(height: 12),
                        SVIPAdvantages(
                          level: levelSVIP,
                          advantageNumber: advantageNumber,
                          items: advantageItems,
                        ),
                      ],
                    ),
                  ),
                ),
              ],
            ),
          ],
        ),
        bottomNavigationBar: BottomNavigationBarSVIP(
          levelSVIP: levelSVIP,
        ),
      ),
    );
  }

  // Widget _buildUserImageSection() {

  //   return UserImageWithBackgraoundImageSection(
  //     user: widget.user,
  //     colorNameOne: colorNameOne,
  //     colorNameTwo: colorNameTwo,
  //     getSvgaFramUser: getSvgaFramUser,
  //   );
  // }

  // ===== Helpers for overlay tint colors (page-level) =====
  LinearGradient _buildPageOverlayGradient(int level) {
    final colors = _vipOverlayColors(level);
    return LinearGradient(
      begin: Alignment.topCenter,
      end: Alignment.bottomCenter,
      colors: [
        AppColors.black.withValues(alpha: .99),
        colors[0].withValues(alpha: .88),
        colors[1].withValues(alpha: .6),
      ],
      stops: const [0.0, 0.5, 1.0],
    );
  }

  List<Color> _vipOverlayColors(int level) {
    switch (level) {
      case 1:
        return [AppColors.svipFramColorOne, AppColors.svipFramColorOne3];
      case 2:
        return [AppColors.svipFramColorTwo, AppColors.svipFramColorTwo3];
      case 3:
        return [AppColors.svipFramColorThree, AppColors.svipFramColorThree3];
      case 4:
        return [AppColors.svipFramColorFour, AppColors.svipFramColorFour3];
      case 5:
        return [AppColors.svipFramColorFive, AppColors.svipFramColorFive3];
      default:
        return [AppColors.black, AppColors.black];
    }
  }
}

class LevelItem extends StatelessWidget {
  const LevelItem({
    super.key,
    required this.level,
    required this.onLevelSelected,
    required this.isSelected,
  });
  final int level;
  final Function(int) onLevelSelected;
  final bool isSelected;
  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () {
        onLevelSelected(level);
      },
      child: Padding(
        padding: const EdgeInsets.symmetric(vertical: 2, horizontal: 20),
        child: Shimmer.fromColors(
          baseColor: isSelected ? AppColors.golden : AppColors.grey,
          highlightColor: AppColors.white,
          child: AutoSizeText(
            'SVIP $level',
            style: TextStyle(
              color: isSelected ? AppColors.golden : AppColors.grey,
              fontSize: 14,
              fontWeight: FontWeight.w900,
              shadows: const [
                Shadow(
                  color: AppColors.goldenwhitecolor,
                  blurRadius: BorderSide.strokeAlignCenter,
                  offset: Offset(.5, .5),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

// ===== New selector and header card for VIP level =====
class SVIPLevelSelector extends StatefulWidget {
  const SVIPLevelSelector({
    super.key,
    required this.user,
    required this.initialLevel,
    required this.onLevelChanged,
  });

  final UserEntity user;
  final int initialLevel;
  final ValueChanged<int> onLevelChanged;

  @override
  State<SVIPLevelSelector> createState() => _SVIPLevelSelectorState();
}

class _SVIPLevelSelectorState extends State<SVIPLevelSelector> {
  late final PageController _controller;

  @override
  void initState() {
    super.initState();
    _controller = PageController(
      viewportFraction: .92,
      initialPage: (widget.initialLevel - 1).clamp(0, 4),
    );
  }

  @override
  void didUpdateWidget(covariant SVIPLevelSelector oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.initialLevel != widget.initialLevel) {
      final target = (widget.initialLevel - 1).clamp(0, 4);
      if (_controller.hasClients) {
        _controller.animateToPage(
          target,
          duration: const Duration(milliseconds: 250),
          curve: Curves.easeOut,
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(top: 40),
      child: SizedBox(
        height: 210.h,
        child: PageView.builder(
          controller: _controller,
          itemCount: 5,
          onPageChanged: (index) => widget.onLevelChanged(index + 1),
          itemBuilder: (context, index) {
            final level = index + 1;
            return Padding(
              padding: EdgeInsets.symmetric(horizontal: 8.w, vertical: 8.h),
              child: SVIPHeaderCard(user: widget.user, level: level),
            );
          },
        ),
      ),
    );
  }
}

class SVIPHeaderCard extends StatelessWidget {
  const SVIPHeaderCard({super.key, required this.user, required this.level});
  final UserEntity user;
  final int level;

  @override
  Widget build(BuildContext context) {
    final colors = _colorsForLevel(level);
    final shieldPath = _shieldAsset(level);
    return Container(
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(16),
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [
            colors[0].withValues(alpha: .65),
            colors[1].withValues(alpha: .35),
            colors[2].withValues(alpha: .20),
          ],
        ),
        border: Border.all(
            color: AppColors.goldenwhitecolor.withValues(alpha: .35), width: 1),
        boxShadow: [
          BoxShadow(
              color: AppColors.black.withValues(alpha: .25),
              blurRadius: 14,
              offset: Offset(0, 8))
        ],
      ),
      child: Stack(
        children: [
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Row(
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: [
                    ImageUserSectionWithFram(
                        isImage: true,
                        img: user.img,
                        linkPath: _svipFrameAsset(level),
                        height: 36,
                        width: 36,
                        radius: 14),
                    const SizedBox(width: 8),
                    Expanded(
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Expanded(
                            child: AutoSizeText(
                              (user.name ?? '').toUpperCase(),
                              maxLines: 1,
                              style: const TextStyle(
                                color: AppColors.white,
                                fontWeight: FontWeight.w900,
                                fontSize: 16,
                              ),
                            ),
                          ),
                          const SizedBox(width: 6),
                          FaIcon(FontAwesomeIcons.crown,
                              size: 14, color: AppColors.goldenwhitecolor),
                          const SizedBox(width: 6),
                          Container(
                            padding: const EdgeInsets.symmetric(
                                horizontal: 8, vertical: 2),
                            decoration: BoxDecoration(
                              color: AppColors.black.withValues(alpha: .25),
                              borderRadius: BorderRadius.circular(14),
                              border: Border.all(
                                  color: AppColors.goldenwhitecolor
                                      .withValues(alpha: .45)),
                            ),
                            child: Text(
                              'VIP.' + level.toString(),
                              style: const TextStyle(
                                  color: AppColors.goldenwhitecolor,
                                  fontSize: 10,
                                  fontWeight: FontWeight.w800),
                            ),
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(width: 8),
                    AutoSizeText(
                      'VIP.' + level.toString() + ' HOLDER',
                      maxLines: 1,
                      style: const TextStyle(
                        color: AppColors.goldenwhitecolor,
                        fontSize: 12,
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                    const SizedBox(width: 10),
                    Image.asset(shieldPath,
                        width: 18, height: 18, fit: BoxFit.contain),
                  ],
                ),
                const SizedBox(height: 8),
                SizedBox(
                    height: 1,
                    child: DecoratedBox(
                        decoration: BoxDecoration(
                            color: AppColors.white.withValues(alpha: .12)))),
              ],
            ),
          ),
          Align(
            alignment: Alignment.center,
            child: Opacity(
              opacity: .20,
              child: Image.asset(shieldPath,
                  width: 140, height: 140, fit: BoxFit.contain),
            ),
          ),
          Align(
            alignment: Alignment.center,
            child: ImageUserSectionWithFram(
              isImage: true,
              img: user.img,
              linkPath: _svipFrameAsset(level),
              height: 76,
              width: 76,
              radius: 28,
            ),
          ),
          Positioned(
            right: 10,
            bottom: 10,
            child: Stack(
              alignment: Alignment.center,
              children: [
                Image.asset(shieldPath,
                    width: 60, height: 60, fit: BoxFit.contain),
                Opacity(
                  opacity: .8,
                  child: ImageFiltered(
                    imageFilter: ui.ImageFilter.blur(sigmaX: 8, sigmaY: 8),
                    child: Image.asset(shieldPath,
                        width: 60, height: 60, fit: BoxFit.contain),
                  ),
                ),
              ],
            ),
          ),
          Align(
            alignment: Alignment.center,
            child: Opacity(
              opacity: .20,
              child: Image.asset(shieldPath,
                  width: 140, height: 140, fit: BoxFit.contain),
            ),
          ),
          SizedBox.shrink(),
],
      ),
    );
  }

  static List<Color> _colorsForLevel(int level) {
    switch (level) {
      case 1:
        return [
          AppColors.svipFramColorOne,
          AppColors.svipFramColorOne2,
          AppColors.svipFramColorOne3
        ];
      case 2:
        return [
          AppColors.svipFramColorTwo,
          AppColors.svipFramColorTwo2,
          AppColors.svipFramColorTwo3
        ];
      case 3:
        return [
          AppColors.svipFramColorThree,
          AppColors.svipFramColorThree2,
          AppColors.svipFramColorThree3
        ];
      case 4:
        return [
          AppColors.svipFramColorFour,
          AppColors.svipFramColorFour2,
          AppColors.svipFramColorFour3
        ];
      case 5:
        return [
          AppColors.svipFramColorFive,
          AppColors.svipFramColorFive2,
          AppColors.svipFramColorFive3
        ];
      default:
        return [AppColors.black, AppColors.black, AppColors.black];
    }
  }

  static String _shieldAsset(int level) {
    switch (level) {
      case 1:
        return AssetsData.vip1SvgaSheild;
      case 2:
        return AssetsData.vip2SvgaSheild;
      case 3:
        return AssetsData.vip3SvgaSheild;
      case 4:
        return AssetsData.vip4SvgaSheild;
      case 5:
        return AssetsData.vip5SvgaSheild;
      default:
        return AssetsData.vip1SvgaSheild;
    }
  }

  static String _svipFrameAsset(int level) {
    switch (level) {
      case 1:
        return 'assets/vip_frames/svip1.svga';
      case 2:
        return 'assets/vip_frames/svip2.svga';
      case 3:
        return 'assets/vip_frames/svip3.svga';
      case 4:
        return 'assets/vip_frames/svip4.svga';
      case 5:
        return 'assets/vip_frames/svip5.svga';
      default:
        return 'assets/vip_frames/svip1.svga';
    }
  }
}

class _GlassButton extends StatelessWidget {
  const _GlassButton({
    required this.label,
    required this.onPressed,
    required this.fg,
    this.bg,
    required this.border,
    this.gradient,
  });
  final String label;
  final VoidCallback onPressed;
  final Color fg;
  final Color? bg;
  final Color border;
  final Gradient? gradient;

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: 40,
      child: Container(
        decoration: BoxDecoration(
          gradient: gradient,
          color: gradient == null ? bg : null,
          border: Border.all(color: border, width: 1),
          borderRadius: BorderRadius.circular(12),
        ),
        child: TextButton(
          onPressed: onPressed,
          style: TextButton.styleFrom(
            foregroundColor: fg,
            backgroundColor: Colors.transparent,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(12),
            ),
            padding: const EdgeInsets.symmetric(horizontal: 8),
          ),
          child: FittedBox(
            fit: BoxFit.scaleDown,
            child: Text(
              label,
              style: const TextStyle(fontWeight: FontWeight.w800),
            ),
          ),
        ),
      ),
    );
  }
}

class SVIPAdvantages extends StatelessWidget {
  const SVIPAdvantages({
    super.key,
    required this.items,
    required this.level,
    required this.advantageNumber,
  });

  final int level;
  final int advantageNumber;
  final List<ItemSVIPClass> items;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.only(top: 40, left: 40, right: 40, bottom: 20),
      decoration: BoxDecoration(
        borderRadius: const BorderRadius.only(
            topLeft: Radius.circular(30), topRight: Radius.circular(30)),
        color: Colors.transparent,
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          Column(
            children: [
              AutoSizeText(
                'VIP PRIVILEGES',
                style: Styles.textStyle28
                    .copyWith(color: AppColors.goldenwhitecolor),
              ),
              SizedBox(height: 6),
              Text(
                'Safer than your bank.',
                style: TextStyle(
                    color: AppColors.white.withValues(alpha: .6),
                    fontSize: 12,
                    fontWeight: FontWeight.w600),
              ),
            ],
          ),
          const SizedBox(height: 20),
          GridView.builder(
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            itemCount: items.length,
            gridDelegate: SliverGridDelegateWithMaxCrossAxisExtent(
              maxCrossAxisExtent: 150,
              childAspectRatio: .8,
              crossAxisSpacing: 8,
              mainAxisSpacing: 8,
            ),
            itemBuilder: (context, index) {
              return ItemSVIPAdvantages(
                svgIconPath: items[index].svgaPath,
                title: items[index].title,
                isActive: items[index].isActive,
              );
            },
          ),
        ],
      ),
    );
  }
}

class ItemSVIPAdvantages extends StatelessWidget {
  const ItemSVIPAdvantages({
    super.key,
    required this.svgIconPath,
    required this.title,
    required this.isActive,
  });

  final String svgIconPath;
  final String title;
  final bool isActive;
  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.center,
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        SvgPicture.asset(
          svgIconPath,
          width: 30,
          alignment: Alignment.center,
          colorFilter: ColorFilter.mode(
              isActive ? AppColors.golden : AppColors.grey, BlendMode.srcIn),
        ),
        const SizedBox(
          height: 8,
        ),
        AutoSizeText(
          title,
          maxLines: 1,
          overflow: TextOverflow.ellipsis,
          textAlign: TextAlign.center,
          style: const TextStyle(
            fontWeight: FontWeight.w900,
            fontSize: 13,
          ).copyWith(
            color: isActive ? AppColors.goldenwhitecolor : AppColors.white,
          ),
        ),
        SizedBox(height: 2),
        Text(
          'Safer than your bank.',
          textAlign: TextAlign.center,
          style: TextStyle(
              color: AppColors.white.withValues(alpha: .5), fontSize: 10),
        ),
      ],
    );
  }
}

class SVIPPrivillageSection extends StatelessWidget {
  const SVIPPrivillageSection({
    super.key,
    required this.items,
  });
  final List<Item> items;
  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 40),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(30),
        gradient: const LinearGradient(
          colors: [AppColors.purpleColor, AppColors.black],
          begin: Alignment.topCenter,
          end: Alignment.bottomCenter,
        ),
      ),
      child: Column(
        children: [
          const SizedBox(
            height: 20,
          ),
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              AutoSizeText(
                S.of(context).sVIPPrivilege,
                style: Styles.textStyle28.copyWith(color: AppColors.white),
              ),
            ], // Closing square bracket for Row
          ),
          GridView.builder(
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            gridDelegate: const SliverGridDelegateWithMaxCrossAxisExtent(
              maxCrossAxisExtent: 150, // Adjust this value as needed
              childAspectRatio: .69,
              crossAxisSpacing: 8,
              mainAxisSpacing: 8,
            ),
            itemCount: items.length,
            itemBuilder: (BuildContext context, int index) {
              return ItemVip(
                name: items[index].name,
                imagePath: items[index].imagePath,
              );
            },
          ),
        ],
      ),
    );
  }
}

class ItemVip extends StatelessWidget {
  const ItemVip({
    super.key,
    required this.name,
    required this.imagePath,
  });
  final String name;
  final String imagePath;
  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(10),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(30),
        gradient: LinearGradient(
          colors: [
            AppColors.black.withValues(alpha: .5),
            AppColors.black.withValues(alpha: .4),
          ],
          begin: Alignment.topCenter,
          end: Alignment.bottomCenter,
        ),
      ),
      child: Column(
        mainAxisSize: MainAxisSize.max,
        mainAxisAlignment: MainAxisAlignment.center,
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          Expanded(
            child: Image.asset(
              imagePath,
              fit: BoxFit.contain,
            ),
          ),
          const SizedBox(height: 5),
          AutoSizeText(
            name,
            textAlign: TextAlign.center,
            style: const TextStyle(
              color: AppColors.white,
            ),
          ),
        ],
      ),
    );
  }
}

class UserImageWithBackgraoundImageSection extends StatefulWidget {
  const UserImageWithBackgraoundImageSection({
    super.key,
    required this.user,
    required this.levelSVIP,
  });

  final UserEntity user;
  final int levelSVIP;

  @override
  State<UserImageWithBackgraoundImageSection> createState() =>
      _UserImageWithBackgraoundImageSectionState();
}

class _UserImageWithBackgraoundImageSectionState
    extends State<UserImageWithBackgraoundImageSection> {
  late Color colorNameOne;
  late Color colorNameTwo;
  late String svgaFilePath;

  @override
  void initState() {
    super.initState();
    _updateSVIPSettings(widget.levelSVIP);
  }

  @override
  void didUpdateWidget(UserImageWithBackgraoundImageSection oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.levelSVIP != widget.levelSVIP) {
      _updateSVIPSettings(widget.levelSVIP);
    }
  }

  void _updateSVIPSettings(int levelSVIP) {
    switch (levelSVIP) {
      case 1:
        colorNameOne = AppColors.svipFramColorOne;
        colorNameTwo = AppColors.svipFramColorOne3;
        svgaFilePath = 'assets/vip_frames/svip1.svga';
        break;
      case 2:
        colorNameOne = AppColors.svipFramColorTwo;
        colorNameTwo = AppColors.svipFramColorTwo3;
        svgaFilePath = 'assets/vip_frames/svip2.svga';
        break;
      case 3:
        colorNameOne = AppColors.svipFramColorThree;
        colorNameTwo = AppColors.svipFramColorThree3;
        svgaFilePath = 'assets/vip_frames/svip3.svga';
        break;
      case 4:
        colorNameOne = AppColors.svipFramColorFour;
        colorNameTwo = AppColors.svipFramColorFour3;
        svgaFilePath = 'assets/vip_frames/svip4.svga';
        break;
      case 5:
        colorNameOne = AppColors.svipFramColorFive;
        colorNameTwo = AppColors.svipFramColorFive3;
        svgaFilePath = 'assets/vip_frames/svip5.svga';
        break;
      default:
        colorNameOne = AppColors.black;
        colorNameTwo = Colors.black;
        svgaFilePath = '';
        break;
    }
    setState(() {});
  }

  @override
  Widget build(BuildContext context) {
    log('getSvgaFramUser $svgaFilePath');

    return Stack(
      alignment: Alignment.center,
      children: [
        SizedBox(
            height: 240.h,
            child: Image.asset(
              AssetsData.goldenStairs,
              fit: BoxFit.fill,
            )),
        Container(
          decoration:
              BoxDecoration(color: AppColors.black.withValues(alpha: .2)),
          child: SizedBox(
            height: 240.h,
            width: 250.w,
          ),
        ),
        Positioned(
          bottom: 60,
          left: 0,
          right: 0,
          child: CustomSVGAWidget(
            height: 150,
            width: 150,
            isRepeat: true,
            pathOfSvgaFile: svgaFilePath,
            child: CircularUserImage(
              imagePath: widget.user.img,
              radius: 50,
            ),
          ),
        ),
        Positioned(
          bottom: 30,
          child: GradientText(
            widget.user.name!,
            style: const TextStyle(
              fontSize: 28,
              fontWeight: FontWeight.bold,
              shadows: [
                Shadow(
                  color: AppColors.black,
                  blurRadius: BorderSide.strokeAlignCenter,
                  offset: Offset(.1, .1),
                ),
              ],
            ),
            gradient: LinearGradient(
              colors: [
                colorNameOne,
                colorNameTwo,
              ],
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
            ),
          ),
        ),
      ],
    );
  }
}

class Item {
  final String name;
  final String imagePath;

  const Item(this.name, this.imagePath);
}

class ItemSVIPClass {
  final String title;
  final String svgaPath;
  final bool isActive;

  ItemSVIPClass(
      {required this.title, required this.svgaPath, this.isActive = true});
}

// class UserImageWithBackgraoundImageSection extends StatefulWidget {
//   const UserImageWithBackgraoundImageSection({
//     super.key,
//     required this.user,
//     required this.levelSVIP,
//   });

//   final UserEntity user;
//   final int levelSVIP;

//   @override
//   State<UserImageWithBackgraoundImageSection> createState() =>
//       _UserImageWithBackgraoundImageSectionState();
// }

// class _UserImageWithBackgraoundImageSectionState
//     extends State<UserImageWithBackgraoundImageSection> {
//   late Color colorNameOne;
//   late Color colorNameTwo;
//   late String svgaFilePath;

//   @override
//   void initState() {
//     super.initState();
//     _updateSVIPSettings(widget.levelSVIP);
//   }

//   @override
//   void didUpdateWidget(UserImageWithBackgraoundImageSection oldWidget) {
//     super.didUpdateWidget(oldWidget);
//     if (oldWidget.levelSVIP != widget.levelSVIP) {
//       _updateSVIPSettings(widget.levelSVIP);
//     }
//   }

//   void _updateSVIPSettings(int levelSVIP) {
//     switch (levelSVIP) {
//       case 1:
//         colorNameOne = AppColors.svipFramColorOne;
//         colorNameTwo = AppColors.white;
//         svgaFilePath = 'assets/vip_frames/svip1.svga';
//         break;
//       case 2:
//         colorNameOne = AppColors.svipFramColorTwo;
//         colorNameTwo = AppColors.white;
//         svgaFilePath = 'assets/vip_frames/svip2.svga';
//         break;
//       case 3:
//         colorNameOne = AppColors.svipFramColorThree;
//         colorNameTwo = AppColors.white;
//         svgaFilePath = 'assets/vip_frames/svip3.svga';
//         break;
//       case 4:
//         colorNameOne = AppColors.svipFramColorFour;
//         colorNameTwo = AppColors.white;
//         svgaFilePath = 'assets/vip_frames/svip4.svga';
//         break;
//       case 5:
//         colorNameOne = AppColors.svipFramColorFive;
//         colorNameTwo = AppColors.white;
//         svgaFilePath = 'assets/vip_frames/svip5.svga';
//         break;
//       default:
//         colorNameOne = AppColors.white;
//         colorNameTwo = Colors.white;
//         svgaFilePath = '';
//         break;
//     }
//     setState(() {});
//   }

//   @override
//   Widget build(BuildContext context) {
//     log('getSvgaFramUser $svgaFilePath');

//     return Stack(
//       alignment: Alignment.center,
//       children: [
//         SizedBox(height: 240, child: Image.asset(AssetsData.goldenStairs)),
//         Container(
//           decoration: BoxDecoration(color: AppColors.black.withValues(alpha: .2)),
//           child: const SizedBox(
//             height: 240,
//             width: 200,
//           ),
//         ),
//         Positioned(
//           bottom: 60,
//           left: 0,
//           right: 0,
//           child: CustomSVGAWidget(
//             height: 150,
//             width: 150,
//             isRepeat: true,
//             pathOfSvgaFile: svgaFilePath,
//             child: CircularUserImage(
//               imagePath: widget.user.img,
//               radius: 50,
//             ),
//           ),
//         ),
//         Positioned(
//           bottom: 30,
//           child: GradientText(
//             widget.user.name!,
//             style: const TextStyle(
//               fontSize: 28,
//               fontWeight: FontWeight.bold,
//               shadows: [
//                 Shadow(
//                   color: AppColors.black,
//                   blurRadius: BorderSide.strokeAlignCenter,
//                   offset: Offset(.1, .1),
//                 ),
//               ],
//             ),
//             gradient: LinearGradient(
//               colors: [
//                 colorNameOne,
//                 colorNameTwo,
//               ],
//               begin: Alignment.topLeft,
//               end: Alignment.bottomRight,
//             ),
//           ),
//         ),
//       ],
//     );
//   }
// }
