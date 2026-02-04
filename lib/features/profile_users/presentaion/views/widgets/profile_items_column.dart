// ignore_for_file: public_member_api_docs, sort_constructors_first

import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:lklk/core/utils/functions/is_arabic.dart';
import 'package:lklk/core/utils/functions/file_utils.dart';
import 'package:lklk/features/home/presentation/manger/room_cubit/room_cubit_cubit.dart';
import 'package:lklk/features/home/presentation/manger/language/language_cubit.dart';
import 'package:lklk/features/profile_users/presentaion/manger/user_cubit/user_cubit_cubit.dart';
import 'package:lklk/features/profile_users/presentaion/views/help_screen.dart';
import 'package:lklk/features/profile_users/presentaion/views/pages/agency_center_page.dart';
import 'package:lklk/features/profile_users/presentaion/views/pages/profile_gifts_page.dart';
import 'package:lklk/features/profile_users/presentaion/views/settings_page.dart';
import 'package:lklk/features/profile_users/presentaion/views/widgets/profile_item_widget_s_v_g.dart';
import 'package:lklk/features/profile_users/presentaion/views/widgets/profile_quick_actions_row.dart';
import 'package:lklk/features/profile_users/presentaion/views/widgets/target_page.dart';
import 'package:lklk/generated/l10n.dart';
import 'package:lklk/core/constants/app_colors.dart';
import 'package:lklk/features/auth/domain/entities/user_entity.dart';
import 'package:lklk/features/profile_users/presentaion/views/widgets/post_center_page.dart';
import 'package:lklk/features/profile_users/presentaion/views/widgets/target_value_page.dart';
import 'package:lklk/features/profile_users/presentaion/views/widgets/store_profile_view.dart';
import '../pages/level_page.dart';
import 'package:lklk/features/invitations/presentation/views/invitation_center_page.dart';
import 'package:lklk/features/profile_users/domain/entities/elements_entity.dart';
import '../../../../../core/player/svga_custom_player.dart';
// import '../pages/level_page.dart';
import 'package:lklk/features/tasks/presentation/views/tasks_page.dart';
import 'package:lklk/features/home/presentation/manger/top_user_cubit/top_users_cubit.dart';
import 'package:lklk/features/room/presentation/views/widgets/circular_user_image.dart';
import 'package:flutter_svg/flutter_svg.dart';

class ProfileItemsColumn extends StatelessWidget {
  // ...
  final UserEntity user;
  final UserCubit userCubit;
  final RoomCubit roomCubit;
  final List<ElementEntity>? giftList;
  final List<ElementEntity>? frameList;
  final List<ElementEntity>? entryList;

  const ProfileItemsColumn({
    super.key,
    required this.user,
    required this.userCubit,
    required this.roomCubit,
    this.giftList,
    this.frameList,
    this.entryList,
  });
  @override
  Widget build(BuildContext context) {
    String selectedLanguage = 'en';
    final languageCubit = context.read<LanguageCubit>();
    selectedLanguage = languageCubit.state.languageCode;
    return Directionality(
      textDirection: getTextDirection(selectedLanguage),
      child: Column(
        children: [
          honorWallRow(context, selectedLanguage),
          horizintalProfileIcons(context, selectedLanguage),
          verticalProfileIcons(selectedLanguage, context),
        ],
      ),
    );
  }

  Widget honorWallRow(BuildContext context, String selectedLanguage) {
    // Taps anywhere on the row open TasksPage (Road to Top)
    final title = selectedLanguage == 'ar' ? 'لوحة الشرف' : 'Honor Wall';
    return GestureDetector(
      onTap: () {
        Navigator.push(
          context,
          MaterialPageRoute(builder: (_) => const TasksPage()),
        );
      },
      child: Container(
        margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 12),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(16),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.05),
              blurRadius: 12,
              offset: const Offset(0, 4),
            ),
          ],
        ),
        child: BlocProvider(
          create: (_) =>
              TopUsersCubit()..fetchTopUsersCached(15), // Monthly top
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              SizedBox(
                width: 84,
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    SvgPicture.asset(
                      'assets/images/my_profile_icon/cup_icon_star.svg',
                      width: 34,
                      height: 34,
                    ),
                    const SizedBox(height: 6),
                    Text(
                      title,
                      textAlign: TextAlign.center,
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                      style: const TextStyle(
                        fontSize: 14,
                        fontWeight: FontWeight.w700,
                        color: Colors.black87,
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(width: 8),
              // Top 3 users
              Expanded(
                child: BlocBuilder<TopUsersCubit, TopUsersState>(
                  builder: (context, state) {
                    if (state is TopUsersLoaded) {
                      final top3 = state.users.take(3).toList();
                      return Row(
                        mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                        children: List.generate(
                            3,
                            (i) => _HonorUserCard(
                                  user: i < top3.length ? top3[i] : null,
                                  rank: i + 1,
                                )),
                      );
                    }
                    // Loading or error -> placeholders
                    return Row(
                      mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                      children: List.generate(
                        3,
                        (i) => _HonorUserCard(user: null, rank: i + 1),
                      ),
                    );
                  },
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Column verticalProfileIcons(String selectedLanguage, BuildContext context) {
    return Column(
      children: [
        // ProfileItemWidgetSVG(
        //   title: S.of(context).theme,
        //   isArabic: selectedLanguage == "ar",
        //   icon: AssetsData.themeIconsSvg,
        //   iconColor: AppColors.black,
        //   onTap: () {
        //     Navigator.push(context,
        //         MaterialPageRoute(builder: (context) => MediaPlayerResourceSelectionPage()));
        //   },
        // ), //
        // moved to ProfileQuickActionsRow: level
        // moved to ProfileQuickActionsRow: invitationCentre
        // moved to ProfileQuickActionsRow: road to top

        // Keep only these list items at bottom
        ProfileItemWidgetProfile(
          isArabic: selectedLanguage == "ar",
          title: S.of(context).postCenter,
          // icon: AssetsData.wakalaIconsSvg,
          icon: "assets/images/my_profile_icon/Coins_Agency_icon.svg",
          iconColor: AppColors.black,
          onTap: () {
            Navigator.push(
              context,
              MaterialPageRoute(
                builder: (context) => const PostCenterPage(),
              ),
            );
          },
        ),
        ProfileItemWidgetProfile(
          isArabic: selectedLanguage == "ar",
          title: S.of(context).target,
          icon: "assets/images/my_profile_icon/target_icon.svg",
          iconColor: AppColors.black,
          onTap: () {
            Navigator.push(
              context,
              MaterialPageRoute(
                builder: (context) => const TargetValuePage(),
              ),
            );
          },
        ),
        ProfileItemWidgetProfile(
          title: S.of(context).help,
          isArabic: selectedLanguage == "ar",
          icon: "assets/images/my_profile_icon/Services-icon.svg",
          // icon: AssetsData.helpIconsSvg,
          iconColor: AppColors.black,
          onTap: () {
            //SoundlevelSpectrumPage
            Navigator.push(context,
                MaterialPageRoute(builder: (context) => const HelpScreen()));
          },
        ),
        ProfileItemWidgetProfile(
          title: S.of(context).settings,
          icon: "assets/images/my_profile_icon/Settings_icon.svg",
          // icon: AssetsData.setingsIconsSvg,
          iconColor: AppColors.black,
          isArabic: selectedLanguage == "ar",
          onTap: () {
            //SoundlevelSpectrumPage
            Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) =>
                      //  RealtimeTestPage()
                      SettingsPage(
                    user: user,
                    roomCubit: roomCubit,
                    userCubit: userCubit,
                  ),
                ));
          },
        ),

        // ProfileItemWidgetProfile(
        //   title: S.of(context).settings,
        //   icon: AssetsData.settings,
        //   // icon: AssetsData.setingsIconsSvg,
        //   iconColor: AppColors.black,
        //   isArabic: selectedLanguage == "ar",
        //   onTap: () {
        //     //SoundlevelSpectrumPage
        //     Navigator.push(
        //         context,
        //         MaterialPageRoute(builder: (context) =>
        //          RealtimeTestPage()
        //             //  SettingsPage(
        //             //   user: user,
        //             //   roomCubit: roomCubit,
        //             //   userCubit: userCubit,
        //             // ),
        //             ));
        //   },
        // ),
      ],
    );
  }

  ProfileQuickActionsRow horizintalProfileIcons(
      BuildContext context, String selectedLanguage) {
    return ProfileQuickActionsRow(
      items: [
        ProfileQuickActionItem(
          title: S.of(context).bag,
          icon: 'assets/images/my_profile_icon/Bag_icon.svg',
          onTap: () {
            Navigator.push(
              context,
              MaterialPageRoute(
                builder: (_) => StoreProfileView(
                  user: user,
                  appBarTitle: S.of(context).bag,
                  // Show only: Your Frame, Your Entry, VIP
                  showFrame: false,
                  showEntry: false,
                  showYourFrame: true,
                  showYourEntry: true,
                  showVip: true,
                ),
              ),
            );
          },
        ),
        ProfileQuickActionItem(
          title: S.of(context).store,
          icon: "assets/images/my_profile_icon/mall_icon.svg",
          onTap: () {
            Navigator.push(
              context,
              MaterialPageRoute(
                builder: (context) => StoreProfileView(
                  user: user,
                  showVip: false,
                  showYourEntry: false,
                  showYourFrame: false,
                ),
              ),
            );
          },
        ),
        ProfileQuickActionItem(
          title: S.of(context).level,
          icon: "assets/images/my_profile_icon/level_icon.svg",
          onTap: () {
            Navigator.push(
              context,
              MaterialPageRoute(
                builder: (context) => LevelPage(user: user),
              ),
            );
          },
        ),
        ProfileQuickActionItem(
          title: S.of(context).invitationCentre,
          icon: "assets/images/my_profile_icon/invite-icon.svg",
          onTap: () {
            Navigator.push(
              context,
              MaterialPageRoute(
                builder: (context) => const InvitationCenterPage(),
              ),
            );
          },
        ),

        ProfileQuickActionItem(
          title: S.of(context).gifts,
          icon: 'assets/images/my_profile_icon/gift_icon_red.svg',
          onTap: () {
            Navigator.push(
              context,
              MaterialPageRoute(
                builder: (_) => ProfileGiftsPage(
                  gifts: giftList ?? const [],
                  frames: frameList ?? const [],
                  cars: entryList ?? const [],
                ),
              ),
            );
          },
        ),
        // ProfileQuickActionItem(
        //   title: S.of(context).agency,
        //   icon: 'assets/images/my_profile_icon/agency_icon.svg',
        //   onTap: () {
        //     Navigator.push(
        //       context,
        //       MaterialPageRoute(
        //         builder: (_) => AgencyCenterPage(user: user),
        //       ),
        //     );
        //   },
        // ),
      ],
    );
  }
}

class _HonorUserCard extends StatelessWidget {
  const _HonorUserCard({required this.user, required this.rank});
  final UserEntity? user;
  final int rank;

  Color get _badgeColor {
    switch (rank) {
      case 1:
        return const Color(0xFFFFD700); // gold
      case 2:
        return const Color(0xFFC0C0C0); // silver
      default:
        return const Color(0xFFCD7F32); // bronze
    }
  }

  @override
  Widget build(BuildContext context) {
    const double radius = 34; // image ~68px
    final String name = (user?.name ?? '').trim().isEmpty ? '—' : (user!.name!);
    // Choose frame overlay per rank
    final String? frameAsset = rank == 1
        ? 'assets/images/my_profile_icon/frame_1r.png'
        : rank == 2
            ? 'assets/images/my_profile_icon/frame_2r.png.png'
            : 'assets/images/my_profile_icon/frame_3r.png';
    return Column(
      mainAxisSize: MainAxisSize.min,
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        SizedBox(
          width: radius * 2,
          height: radius * 2,
          child: Stack(
            clipBehavior: Clip.none,
            children: [
              // avatar
              Positioned.fill(
                child: CircularUserImage(
                  imagePath: user?.img?.toString(),
                  isSquare: true,
                  cornerRadius: 12,
                  radius: radius,
                  frameOverlayAsset: frameAsset,
                ),
              ),
              // rank badge
              // Positioned(
              //   top: 4,
              //   right: 4,
              //   child: Container(
              //     width: 22,
              //     height: 22,
              //     decoration: BoxDecoration(
              //       color: _badgeColor,
              //       shape: BoxShape.circle,
              //       border: Border.all(color: Colors.white, width: 2),
              //     ),
              //     alignment: Alignment.center,
              //     child: Text(
              //       '$rank',
              //       style: const TextStyle(
              //         color: Colors.black,
              //         fontSize: 12,
              //         fontWeight: FontWeight.w800,
              //       ),
              //     ),
              //   ),
              // ),
            ],
          ),
        ),
        const SizedBox(height: 6),
        SizedBox(
          height: 20,
          width: radius * 2,
          child: Text(
            name,
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
            textAlign: TextAlign.center,
            style: const TextStyle(
              fontSize: 12,
              fontWeight: FontWeight.w600,
              color: Colors.black87,
            ),
          ),
        ),
      ],
    );
  }
}

class TestPage extends StatefulWidget {
  const TestPage({super.key});

  @override
  State<TestPage> createState() => _TestPageState();
}

class _TestPageState extends State<TestPage> {
  @override
  Widget build(BuildContext context) {
    return SafeArea(
      top: false,
      child: Scaffold(
        body: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            CustomSVGAWidget(
              height: MediaQuery.of(context).size.height,
              width: MediaQuery.of(context).size.width,
              clearsAfterStop: true,
              pathOfSvgaFile:
                  "${AppDirectories.instance.appDirectory.path}/downloads/fileName.svga",
            ),
          ],
        ),
      ),
    );
  }
}
