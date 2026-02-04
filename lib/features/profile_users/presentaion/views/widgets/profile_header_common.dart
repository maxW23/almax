import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:lklk/core/constants/app_colors.dart';
import 'package:lklk/core/utils/functions/is_arabic.dart';
import 'package:lklk/features/auth/domain/entities/user_entity.dart';
import 'package:lklk/features/home/presentation/manger/language/language_cubit.dart';
import 'package:lklk/features/home/presentation/manger/room_cubit/room_cubit_cubit.dart';
import 'package:lklk/features/profile_users/presentaion/manger/user_cubit/user_cubit_cubit.dart';
import 'package:lklk/features/profile_users/presentaion/views/pages/cover_image_profile_user.dart';
import 'package:lklk/features/room/presentation/views/widgets/user_widget_title.dart';

/// A reusable profile header that matches the new design used in
/// UserProfileViewBodySuccess and can be shared by self/other profile pages.
class ProfileHeaderCommon extends StatelessWidget {
  const ProfileHeaderCommon({
    super.key,
    required this.user,
    required this.userCubit,
    required this.roomCubit,
    required this.countsRow,
    required this.trailing,
    this.isOther = false,
    this.isWakel = true,
    this.onCoverTap,
    this.onCoverSecondaryTap,
    this.showSvgaBadges = true,
    this.onUserTitleTap,
  });

  final UserEntity user;
  final UserCubit userCubit;
  final RoomCubit roomCubit;

  /// The row widget that shows counts (customizable per page).
  final Widget countsRow;

  /// The widget displayed on the top-right of the white card
  /// (Edit button for self, action icons for other).
  final Widget trailing;

  /// Whether this header is used for viewing another user.
  final bool isOther;

  /// Whether the user is a wakel/agent (passed to cover widget when needed).
  final bool isWakel;

  /// Primary tap on cover image (e.g., navigate to room for other user).
  final VoidCallback? onCoverTap;

  /// Secondary tap on cover (optional action used for chargers in old screen).
  final VoidCallback? onCoverSecondaryTap;

  /// Whether to show SVGA badges under the level row
  final bool showSvgaBadges;

  /// Optional tap handler for the user title/avatar (used in self profile)
  final VoidCallback? onUserTitleTap;

  @override
  Widget build(BuildContext context) {
    final selectedLanguage =
        context.select<LanguageCubit, String>((c) => c.state.languageCode);
    final bool hasSvga = _hasUserSvga(user);
    final double cardHeight = hasSvga ? 215.h : 170.h;

    return Stack(
      alignment: Alignment.bottomCenter,
      children: [
        CoverImageProfileUser(
          imagePath: user.img,
          power: user.power,
          isWakel: isWakel,
          isOther: isOther,
          onTap: onCoverTap,
          onTap2: onCoverSecondaryTap,
        ),
        Container(
          height: 150,
          decoration: BoxDecoration(
            color: AppColors.white,
            borderRadius: const BorderRadius.only(
              topLeft: Radius.circular(10),
              topRight: Radius.circular(10),
            ),
          ),
        ),
        Directionality(
          textDirection: getTextDirection(selectedLanguage),
          child: Container(
            margin: EdgeInsets.symmetric(horizontal: 20.r),
            child: Stack(
              alignment: Alignment.bottomCenter,
              children: [
                // Card background (dynamic height if no SVGA)
                Container(
                  height: cardHeight,
                  decoration: BoxDecoration(
                    color: AppColors.white,
                    borderRadius: BorderRadius.circular(20),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withOpacity(0.1),
                        blurRadius: 10,
                        offset: const Offset(0, 4),
                        spreadRadius: 0,
                      ),
                    ],
                  ),
                ),
                // Content
                Column(
                  children: [
                    _titleRow(context, selectedLanguage),
                    const SizedBox(height: 5),
                    countsRow,
                    const SizedBox(height: 5),
                  ],
                ),
              ],
            ),
          ),
        ),
      ],
    );
  }

  Widget _titleRow(BuildContext context, String selectedLanguage) {
    final isArabic = selectedLanguage.toLowerCase().startsWith('ar');

    // Base content: User info row occupies the layout normally
    final baseRow = Row(
      textDirection: TextDirection.ltr,
      children: [
        Expanded(
          child: UserWidgetTitle(
            isID: true,
            isRoomTypeUser: false,
            isWakel: true,
            isVerticalLayout: true,
            onTap: onUserTitleTap,
            user: user,
            userCubit: userCubit,
            showSvgaBadges: showSvgaBadges,
          ),
        ),
        // We intentionally avoid putting `trailing` here so it doesn't affect layout
      ],
    );

    // Overlay trailing so it doesn't consume layout space nor push UserWidgetTitle
    return Stack(
      alignment: Alignment.center,
      children: [
        baseRow,
        Align(
          alignment: isArabic ? Alignment.centerLeft : Alignment.centerRight,
          child: Padding(
            padding: EdgeInsets.only(
              left: 1.r,
              right: 1.r,
              bottom: 14.r,
            ),
            child: trailing,
          ),
        ),
      ],
    );
  }

  bool _hasUserSvga(UserEntity u) {
    final list = <String?>[
      // ic*
      u.ic1, u.ic2, u.ic3, u.ic4, u.ic5, u.ic6, u.ic7, u.ic8, u.ic9, u.ic10,
      u.ic11, u.ic12, u.ic13, u.ic14, u.ic15,
      // ws*
      u.ws1, u.ws2, u.ws3, u.ws4, u.ws5,
    ];
    for (final s in list) {
      if (s != null) {
        final t = s.trim();
        if (t.isNotEmpty && t != 'null') return true;
      }
    }
    return false;
  }
}
