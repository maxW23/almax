// ignore_for_file: public_member_api_docs, sort_constructors_first

import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:auto_size_text/auto_size_text.dart';
import 'package:lklk/core/constants/app_colors.dart';
import 'package:lklk/features/auth/domain/entities/user_entity.dart';
import 'package:lklk/features/room/presentation/views/widgets/circular_user_image.dart';

class UserLevelWidgetTop extends StatefulWidget {
  const UserLevelWidgetTop({
    super.key,
    required this.user,
    required this.selectedTab,
  });

  final UserEntity user;
  final int selectedTab; // 0 = wealth, 1 = charm, 2 = tasks

  @override
  State<UserLevelWidgetTop> createState() => _UserLevelWidgetTopState();
}

class _UserLevelWidgetTopState extends State<UserLevelWidgetTop> {
  double sliderValue = 0.0;

  @override
  void initState() {
    super.initState();
    _initializeSliderValue();
  }

  void _initializeSliderValue() {
    final double validUserMon = widget.selectedTab == 0
        ? double.tryParse(widget.user.monLevel ?? '0') ?? 0
        : widget.selectedTab == 1
            ? double.tryParse(widget.user.rmonLevelTwo ?? '0') ?? 0.0
            : double.tryParse(widget.user.level3 ?? '0') ?? 0;

    final int userMon = validUserMon.toInt();
    final int level = getUserLevel(userMon);
    final int validLevel = level.clamp(1, 50);
    final int levelEnd =
        userMon > 47503275 ? (47503275 * 5) : _getLevelEnd(validLevel);

    setState(() {
      sliderValue = validLevel == 50
          ? levelEnd.toDouble()
          : userMon.toDouble().clamp(0, levelEnd.toDouble());
    });
  }

  @override
  Widget build(BuildContext context) {
    final double validUserMon = widget.selectedTab == 0
        ? double.tryParse(widget.user.monLevel ?? '0') ?? 0
        : widget.selectedTab == 1
            ? double.tryParse(widget.user.rmonLevelTwo ?? '0') ?? 0.0
            : double.tryParse(widget.user.level3 ?? '0') ?? 0;

    final int userMon = validUserMon.toInt();
    final int level = getUserLevel(userMon);
    final int validLevel = level.clamp(1, 50);

    final int levelStart = _getLevelStart(validLevel);
    final int levelEnd =
        userMon > 47503275 ? (47503275 * 5) : _getLevelEnd(validLevel);

    // Update sliderValue when level or userMon changes
    sliderValue = validLevel == 50
        ? levelEnd.toDouble()
        : userMon.toDouble().clamp(0, levelEnd.toDouble());
    //log('~~~~~~~~~~~~ level=$level -- levelEnd=$levelEnd ----levelStart=$levelStart userMon=$userMon r=${widget.user.rmonLevelTwo}');
    //log('User rmonLevelTwo: ${widget.user.rmonLevelTwo}');
    //log('Parsed userMon: $userMon');
    //log('Valid Level: $validLevel');
    //log('Level Start: $levelStart');
    //log('Level End: $levelEnd');
    //log('Slider Value: $sliderValue');
    return AnimatedContainer(
      duration: const Duration(milliseconds: 500),
      margin: EdgeInsets.symmetric(horizontal: 0.r),
      padding: EdgeInsetsDirectional.symmetric(horizontal: 25.r, vertical: 8.r),
      decoration: BoxDecoration(
        color: AppColors.white,
        borderRadius: BorderRadius.only(
          topLeft: Radius.circular(25.r),
          topRight: Radius.circular(25.r),
        ),
        gradient: _getGradient(widget.selectedTab),
        boxShadow: [
          BoxShadow(
            color:
                _getBackgroundColor(widget.selectedTab).withValues(alpha: 0.2),
            blurRadius: 12,
            offset: const Offset(0, 4),
            spreadRadius: 1,
          ),
        ],
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceEvenly,
        children: [
          Container(
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withValues(alpha: 0.15),
                  blurRadius: 8,
                  offset: const Offset(0, 3),
                ),
              ],
            ),
            child: CircularUserImage(
              imagePath: widget.user.img,
              isEmpty: false,
              radius: 30.r,
            ),
          ),
          Expanded(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                SizedBox(height: 8.h),
                SizedBox(
                  width: double.infinity,
                  child: Padding(
                    padding: EdgeInsets.symmetric(horizontal: 10.r),
                    child: AutoSizeText(
                      widget.user.name!,
                      overflow: TextOverflow.ellipsis,
                      style: TextStyle(
                        color: AppColors.black,
                        fontSize: 19.sp,
                        fontWeight: FontWeight.w900,
                        letterSpacing: 0.5,
                      ),
                    ),
                  ),
                ),
                Container(
                  height: 20,
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(12.r),
                    // لون خفيف جداً فقط لتمكين ظهور الظل بدون تغيير التصميم
                    color: Colors.white.withValues(alpha: 0.02),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withValues(alpha: 0.15),
                        blurRadius: 20,
                        offset: const Offset(0, 0),
                      ),
                    ],
                  ),
                  padding: EdgeInsets.symmetric(horizontal: 4.r, vertical: 2.r),
                  child: SliderTheme(
                    data: SliderTheme.of(context).copyWith(
                      thumbShape: SliderComponentShape.noThumb,
                    ),
                    child: Slider(
                      value: sliderValue,
                      min: 0,
                      max: levelEnd.toDouble(),
                      divisions: (levelEnd - levelStart > 0)
                          ? (levelEnd - levelStart)
                          : levelStart + 100,
                      activeColor: widget.selectedTab == 0
                          ? AppColors.orangePinkColorBlack
                          : widget.selectedTab == 1
                              ? AppColors.pinkwhiteColorBlack
                              : const Color(0xFF4A90E2),
                      inactiveColor: widget.user.rmonLevelTwo != null
                          ? Colors.white
                          : AppColors.pinkwhiteColorBlack,
                      onChanged: (double value) {
                        setState(() {
                          sliderValue = value;
                        });
                      },
                    ),
                  ),
                ),
              ],
            ),
          ),
          SizedBox(
            width: 22.w,
            child: AutoSizeText(
              widget.selectedTab == 0
                  ? widget.user.level1 == '50'
                      ? 'Max'
                      : ("LV.\n${int.parse(widget.user.level1 ?? '0') + 1}")
                  : widget.selectedTab == 1
                      ? widget.user.level2 == '50'
                          ? 'Max'
                          : ("LV.\n${int.parse(widget.user.level2 ?? '0') + 1}")
                      : ("LV.\n${int.parse(widget.user.newlevel3 ?? '0') + 1}"),
              style: TextStyle(
                color: AppColors.blackshade1,
                fontSize: 13.sp,
                fontWeight: FontWeight.w800,
              ),
              textAlign: TextAlign.center,
            ),
          ),
        ],
      ),
    );
  }

  Color _getBackgroundColor(int selectedTab) {
    if (selectedTab == 0) {
      return AppColors.orangePinkTwoColor;
    } else if (selectedTab == 1) {
      return AppColors.pinkwhiteTwoColor;
    } else {
      return const Color(0xFF4A90E2);
    }
  }

  int getUserLevel(int userMon) {
    // List of thresholds for levels
    final List<int> thresholds = [
      95375,
      190775,
      285700,
      381075,
      476450,
      571825,
      667200,
      762575,
      857950,
      953325,
      1046700,
      11480575,
      1239450,
      1335500,
      2250675,
      3165850,
      4081025,
      4996200,
      5911375,
      6826550,
      7741725,
      8656900,
      9572075,
      10497250,
      11401325,
      12305400,
      13209475,
      14643000,
      14643000,
      94769250,
      116323500,
      138877750,
      159432000,
      180986250,
      202540500,
      224094750,
      245649000,
      267203250,
      288757500,
      310311750,
      370576250,
      452393750,
      534211250,
      616028750,
      697846250,
      779663750,
      861481250,
      943298750,
      1029112500,
      1119947500,
      1210782500
    ];

    for (int i = 0; i < thresholds.length; i++) {
      if (userMon < thresholds[i]) {
        return i + 1; // Levels start from 1
      }
    }
    return thresholds.length; // If all thresholds are crossed
  }

  int _getLevelStart(int level) {
    final List<int> levelStarts = [
      95375,
      190775,
      285700,
      381075,
      476450,
      571825,
      667200,
      762575,
      857950,
      953325,
      1046700,
      11480575,
      1239450,
      1335500,
      2250675,
      3165850,
      4081025,
      4996200,
      5911375,
      6826550,
      7741725,
      8656900,
      9572075,
      10497250,
      11401325,
      12305400,
      13209475,
      14643000,
      14643000,
      94769250,
      116323500,
      138877750,
      159432000,
      180986250,
      202540500,
      224094750,
      245649000,
      267203250,
      288757500,
      310311750,
      370576250,
      452393750,
      534211250,
      616028750,
      697846250,
      779663750,
      861481250,
      943298750,
      1029112500,
      1119947500,
      1210782500
    ];
    return (level > 0 && level <= levelStarts.length)
        ? levelStarts[level - 1]
        : 0;
  }

  int _getLevelEnd(int level) {
    final List<int> levelEnds = [
      190775,
      285700,
      381075,
      476450,
      571825,
      667200,
      762575,
      857950,
      953325,
      1046700,
      11480575,
      1239450,
      1335500,
      2250675,
      3165850,
      4081025,
      4996200,
      5911375,
      6826550,
      7741725,
      8656900,
      9572075,
      10497250,
      11401325,
      12305400,
      13209475,
      14643000,
      14643000,
      94769250,
      116323500,
      138877750,
      159432000,
      180986250,
      202540500,
      224094750,
      245649000,
      267203250,
      288757500,
      310311750,
      370576250,
      452393750,
      534211250,
      616028750,
      697846250,
      779663750,
      861481250,
      943298750,
      1029112500,
      1119947500,
      1210782500,
      999999999999
    ];
    return (level > 0 && level <= levelEnds.length) ? levelEnds[level - 1] : 0;
  }

  LinearGradient _getGradient(int selectedTab) {
    Color color1, color2;
    if (selectedTab == 0) {
      color1 = AppColors.orangePinkTwoColor;
      color2 = AppColors.orangePinkTwoColor.withValues(alpha: .5);
    } else if (selectedTab == 1) {
      color1 = AppColors.pinkwhiteTwoColor;
      color2 = AppColors.pinkwhiteTwoColor.withValues(alpha: .5);
    } else {
      color1 = const Color(0xFF4A90E2);
      color2 = const Color(0xFF4A90E2).withValues(alpha: .5);
    }
    return LinearGradient(colors: [color2, color1, color2]);
  }
}
