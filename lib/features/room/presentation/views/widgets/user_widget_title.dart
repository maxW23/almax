import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:lklk/core/utils/functions/file_utils.dart';
import 'package:lklk/core/utils/functions/is_arabic.dart';
import 'package:lklk/features/home/presentation/manger/language/language_cubit.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:lklk/features/profile_users/presentaion/manger/user_cubit/user_cubit_cubit.dart';
import 'package:lklk/features/room/presentation/views/widgets/animated_icon_widget.dart';
import 'package:lklk/features/room/presentation/views/widgets/default_icon.dart';
import 'package:lklk/features/room/presentation/views/widgets/i_d_section_with_flag_gender.dart';
import 'package:lklk/features/room/presentation/views/widgets/is_add_icon_red.dart';
import 'package:lklk/features/room/presentation/views/widgets/islevel_trailing_widget.dart';
import 'package:lklk/features/room/presentation/views/widgets/level_row_user_title_widget_section.dart';
import 'package:lklk/features/room/presentation/views/widgets/svga_badges_row_widget.dart';
import 'package:lklk/features/room/presentation/views/widgets/user_name_section_user_title.dart';
import '../../../../../core/constants/app_colors.dart';
import '../../../../auth/domain/entities/user_entity.dart';
import 'image_user_section_with_fram.dart';

class UserWidgetTitle extends StatefulWidget {
  const UserWidgetTitle(
      {super.key,
      required this.user,
      required this.userCubit,
      this.isID = false,
      this.onTap,
      this.isIcon = false,
      this.isPressIcon,
      this.icon = FontAwesomeIcons.circlePlus,
      this.iconSecond = FontAwesomeIcons.circleCheck,
      this.isImage = true,
      this.isLevel = true,
      this.isAdd = false,
      this.isWakel = true,
      this.isRoomTypeUser = true,
      this.isAnimatedIcon = false,
      this.islevelTrailing = false,
      this.iconColor = AppColors.danger,
      this.isPressIcon2,
      this.onUserAction,
      this.isRTL = false,
      this.roomId,
      this.numberOfCubitTopUsers = 4,
      this.contentPadding = const EdgeInsets.symmetric(horizontal: 10),
      this.trailing,
      this.paddingImageOnly,
      this.typeOfIconRoomSettings,
      this.isSmall = false,
      this.isNameOnly = false,
      this.nameColor,
      this.idColor,
      this.isVerticalLayout = false,
      this.maxAvatarSide,
      this.showSvgaBadges = false});

  final UserEntity user;
  final UserCubit? userCubit;

  final void Function()? onTap;

  final bool isImage;
  final void Function()? isPressIcon;
  final void Function()? isPressIcon2;
  final bool isIcon;
  final IconData? icon;
  final IconData? iconSecond;

  final bool isID;
  final bool isLevel;
  final bool isAdd;
  final bool isRoomTypeUser;
  final bool isAnimatedIcon;
  final bool islevelTrailing;
  final bool isRTL;
  final bool isWakel;
  final Color iconColor;
  final Function(int, String, String)? onUserAction;
  final int? roomId;
  final double? paddingImageOnly;
  final int numberOfCubitTopUsers;
  final EdgeInsetsGeometry? contentPadding;
  final Widget? trailing;
  final String? typeOfIconRoomSettings;
  // Compact sizing for tight list rows
  final bool isSmall, isNameOnly;
  // Optional: override username color (e.g., Colors.white)
  final Color? nameColor;
  // Optional: override ID text and copy icon color
  final Color? idColor;
  // New: render content vertically (image on top, then name, ID, level)
  final bool isVerticalLayout;
  // Optional: maximum avatar side (width/height). When provided, avatar will be clamped to this square size
  // to avoid non-square constraints that can produce oval clipping in tight rows.
  final double? maxAvatarSide;
  // New: show SVGA badges row under level row (default: false)
  final bool showSvgaBadges;
  @override
  State<UserWidgetTitle> createState() => _UserWidgetTitleState();
}

class _UserWidgetTitleState extends State<UserWidgetTitle> {
  String selectedLanguage = 'en';

  bool _hasUserSvgaBadges(UserEntity u) {
    final list = [
      u.ic1,
      u.ic2,
      u.ic3,
      u.ic4,
      u.ic5,
      u.ic6,
      u.ic7,
      u.ic8,
      u.ic9,
      u.ic10,
      u.ic11,
      u.ic12,
      u.ic13,
      u.ic14,
      u.ic15,
      u.ws1,
      u.ws2,
      u.ws3,
      u.ws4,
      u.ws5,
    ];
    for (final s in list) {
      if (s != null) {
        final t = s.trim();
        if (t.isNotEmpty && t != 'null') return true;
      }
    }
    return false;
  }

  @override
  void initState() {
    super.initState();
    final languageCubit = context.read<LanguageCubit>();
    selectedLanguage = languageCubit.state.languageCode;
  }

/////////////////
  @override
  Widget build(BuildContext context) {
    return BlocBuilder<UserCubit, UserCubitState>(
      builder: (context, state) {
        final selectedLanguageLocal =
            context.select<LanguageCubit, String>((c) => c.state.languageCode);
        return Directionality(
          textDirection: getTextDirection(selectedLanguageLocal),
          child: Padding(
            padding: widget.contentPadding ?? EdgeInsets.zero,
            child: Container(
              padding: EdgeInsets.symmetric(vertical: widget.isSmall ? 6 : 10),
              child: Builder(builder: (context) {
                // Respect current text direction
                final textDir = Directionality.of(context);
                final bool isRtl = textDir == TextDirection.rtl;
                // Build avatar (with optional frame) once to reuse
                Widget buildAvatar() {
                  final frameLink = SvgaUtils.getValidFilePath(
                          widget.user.elementFrame?.elamentId) ??
                      widget.user.elementFrame?.linkPathLocal ??
                      widget.user.elementFrame?.linkPath;
                  final hasFrame = (frameLink != null && frameLink.isNotEmpty);
                  // Base sizes
                  double baseSize = widget.isSmall
                      ? (hasFrame ? 56 : 70)
                      : (hasFrame ? 75 : 84);
                  // Clamp to maxAvatarSide if provided to fit tight rows (e.g., 36-40px)
                  final double size = widget.maxAvatarSide == null
                      ? baseSize
                      : (baseSize <= widget.maxAvatarSide!
                          ? baseSize
                          : widget.maxAvatarSide!);
                  // Derive radius and clamp so diameter does not exceed the final size
                  double baseRadius = widget.isSmall
                      ? (hasFrame ? 16 : 20)
                      : (hasFrame ? 21 : 24);
                  final double maxAllowedRadius = size / 2;
                  final double radius = baseRadius > maxAllowedRadius
                      ? maxAllowedRadius
                      : baseRadius;
                  return ImageUserSectionWithFram(
                    height: size,
                    width: size,
                    radius: radius,
                    img: widget.user.img,
                    linkPath: frameLink,
                    isImage: widget.isImage,
                    onTap: widget.onTap,
                    padding: 10,
                    paddingImageOnly: widget.paddingImageOnly ?? 10.r,
                  );
                }

                final nameAndMeta = Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  // In vertical layout, avoid expanding with spaceBetween which creates large gaps
                  mainAxisAlignment: widget.isVerticalLayout
                      ? MainAxisAlignment.start
                      : MainAxisAlignment.spaceBetween,
                  children: [
                    UserNameSectionUserTitle(
                      currentUser: widget.user,
                      isSmall: widget.isSmall,
                      isNameOnly: widget.isNameOnly,
                      nameColor: widget.nameColor,
                    ),
                    if (widget.isID)
                      Padding(
                        padding: EdgeInsets.only(top: 1.r),
                        child: IDSectionWithFlagGender(widget: widget),
                      ),
                    if (widget.isLevel)
                      Padding(
                        padding: EdgeInsets.only(top: 1.r),
                        child: LevelRowUserTitleWidgetSection(
                          isRoomTypeUser: widget.isRoomTypeUser,
                          isWakel: widget.isWakel,
                          user: widget.user,
                          roomID: widget.roomId.toString(),
                          size: widget.isSmall
                              ? LevelRowSize.small
                              : LevelRowSize.normal,
                        ),
                      ),
                    if (widget.showSvgaBadges &&
                        _hasUserSvgaBadges(widget.user))
                      Padding(
                        padding: EdgeInsets.only(top: 1.r),
                        child: UserSvgaBadgesRow(
                          user: widget.user,
                          size: widget.isSmall
                              ? LevelRowSize.small
                              : LevelRowSize.normal,
                          mainAxisAlignment: MainAxisAlignment.start,
                          // حَدٌّ أعظمي ثابت لارتفاع كل صف من الشارات لضمان ثبات المقاسات
                          maxRowHeight: widget.isSmall ? 20.0 : 24.0,
                        ),
                      ),
                  ],
                );

                if (widget.isVerticalLayout) {
                  return Column(
                    crossAxisAlignment: isRtl
                        ? CrossAxisAlignment.end
                        : CrossAxisAlignment.start,
                    children: [
                      Align(
                        alignment: isRtl
                            ? Alignment.centerRight
                            : Alignment.centerLeft,
                        child: buildAvatar(),
                      ),
                      SizedBox(height: widget.isSmall ? 2 : 4),
                      nameAndMeta,
                      if (widget.trailing != null)
                        Padding(
                          padding: const EdgeInsets.only(top: 6),
                          child: widget.trailing!,
                        )
                      else ...[
                        if (_buildTrailing() != null)
                          Padding(
                            padding: const EdgeInsets.only(top: 6),
                            child: _buildTrailing()!,
                          ),
                      ]
                    ],
                  );
                }

                return Row(
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: [
                    buildAvatar(),
                    Expanded(child: nameAndMeta),
                    if (widget.trailing != null)
                      widget.trailing!
                    else
                      _buildTrailing() ?? SizedBox(),
                  ],
                );
              }),
            ),
          ),
        );
      },
    );
  }

  Widget? _buildTrailing() {
    if (widget.isIcon) {
      if (widget.isAnimatedIcon) {
        return AnimatedIconWidget(widget: widget);
      }
      if (widget.isAdd) {
        return IsAddIconRed(
          widget: widget,
          type: widget.typeOfIconRoomSettings,
        );
      }
      if (widget.islevelTrailing) {
        return IslevelTrailingWidget(widget: widget);
      } else if (widget.isPressIcon != null && widget.icon != null) {
        return DefaultIcon(widget: widget);
      } else {
        return null;
      }
    }
    return null;
  }
}
