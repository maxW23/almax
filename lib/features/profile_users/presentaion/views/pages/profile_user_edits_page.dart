import 'package:flutter/material.dart';
import 'package:auto_size_text/auto_size_text.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:lklk/features/auth/domain/entities/user_entity.dart';
import 'package:lklk/features/home/presentation/manger/room_cubit/room_cubit_cubit.dart';
import 'package:lklk/features/profile_users/domain/entities/elements_entity.dart';
import 'package:lklk/features/profile_users/presentaion/manger/user_cubit/user_cubit_cubit.dart';
import 'package:lklk/features/profile_users/presentaion/views/widgets/profile_common_body.dart';
import 'package:lklk/features/profile_users/presentaion/views/widgets/edit_profile_icon.dart';
import 'package:lklk/features/room/presentation/views/widgets/circular_user_image.dart';
import 'package:lklk/features/profile_users/presentaion/views/widgets/relation_icon_request.dart';
import 'package:lklk/features/profile_users/presentaion/views/widgets/count_profile_row.dart';
import '../../../../../core/constants/app_colors.dart';
import '../../../../../core/utils/status_bar_util.dart';
import '../widgets/profile_quick_actions_variants.dart';

class ProfileUserTitlesPage extends StatefulWidget {
  const ProfileUserTitlesPage({
    super.key,
    required this.user,
    required this.userCubit,
    this.friendNumber,
    this.visitorNumber,
    required this.giftList,
    required this.frameList,
    required this.entryList,
    required this.roomCubit,
  });
  final UserEntity user;
  final UserCubit userCubit;
  final RoomCubit roomCubit;

  final int? friendNumber;
  final int? visitorNumber;
  final List<ElementEntity>? giftList;
  final List<ElementEntity>? frameList;
  final List<ElementEntity>? entryList;
  @override
  State<ProfileUserTitlesPage> createState() => _ProfileUserTitlesPageState();
}

class _ProfileUserTitlesPageState extends State<ProfileUserTitlesPage> {
  late UserEntity currentUser;
  final ScrollController _scrollController = ScrollController();
  Color? appBarBackground;
  late double topPosition;
  @override
  void initState() {
    currentUser = widget.user; //

    topPosition = -60;
    appBarBackground = Colors.transparent;
    super.initState();
    _scrollController.addListener(_onScroll);
    // Ensure we always refresh my profile data when this self page opens
    // to avoid any stale 'other' data lingering in the cubit state.
    widget.userCubit.getProfileUser('ProfileUserTitlesPage:init');
  }

  double _getOpacity() {
    double op = (topPosition + 60) / 60;
    return op > 1 || op < 0 ? 1 : op;
  }

  _onScroll() {
    if (_scrollController.offset > 30) {
      if (topPosition < 0) {
        setState(() {
          topPosition = -90 + _scrollController.offset;
          if (_scrollController.offset > 90) topPosition = 0;
        });
      }
    } else {
      if (topPosition > -60) {
        setState(() {
          topPosition--;
          if (_scrollController.offset <= 0) topPosition = -60;
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    StatusBarUtil.setStatusBarColor(
      topPosition == 0 ? AppColors.white : AppColors.transparent,
    );

    return BlocConsumer<UserCubit, UserCubitState>(
      // في ثغره هون
      listener: (context, state) {
        // Only react to MY profile loads; ignore 'loadedById' (other user)
        if (state.status.isLoaded ||
            state.status.isLoadedProfile ||
            state.status.isLoadedProfileCached) {
          final UserEntity? newUser = state.user;
          if (newUser != null && mounted) {
            setState(() {
              currentUser = newUser;
            });
          }
        }
      },
      builder: (context, state) {
        return SafeArea(
          top: false,
          child: Scaffold(
            body: SafeArea(
              child: Stack(
                children: [
                  SingleChildScrollView(
                    controller: _scrollController,
                    child: ProfileCommonBody(
                      user: currentUser,
                      userCubit: widget.userCubit,
                      roomCubit: widget.roomCubit,
                      room: state.myRoom,
                      isOther: true,
                      isWakel: true,
                      countsRow: CountProfileRow(
                        userCubit: widget.userCubit,
                        roomCubit: widget.roomCubit,
                        friendNumber: widget.friendNumber ?? 0,
                        visitorNumber: widget.visitorNumber ?? 0,
                        friendRequest: 0,
                        relationRequest: 0,
                        user: currentUser,
                      ),
                      trailing: RelationIconRequest(
                        userCubit: widget.userCubit,
                        roomCubit: widget.roomCubit,
                        user: currentUser,
                      ),
                      quickActions: SelfProfileQuickActionsRow(
                        user: currentUser,
                        userCubit: widget.userCubit,
                        roomCubit: widget.roomCubit,
                        giftList: widget.giftList,
                        frameList: widget.frameList,
                        entryList: widget.entryList,
                      ),
                    ),
                  ),
                  hiddenAppbar(),
                ],
              ),
            ),
          ),
        );
      },
    );
  }

  Positioned hiddenAppbar() {
    return Positioned(
        top: topPosition,
        left: 0,
        right: 0,
        child: Container(
          padding: const EdgeInsets.only(left: 10, top: 10, right: 10),
          alignment: Alignment.centerLeft,
          decoration: BoxDecoration(
              borderRadius:
                  const BorderRadius.only(bottomRight: Radius.circular(30.0)),
              gradient: LinearGradient(colors: [
                AppColors.white.withValues(alpha: _getOpacity()),
                AppColors.white.withValues(alpha: _getOpacity()),
              ])),
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              CircularUserImage(
                imagePath: widget.user.img,
                isEmpty: false,
                radius: 25,
              ),
              const SizedBox(
                width: 10,
              ),
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisAlignment: MainAxisAlignment.start,
                children: [
                  AutoSizeText(
                    widget.user.name!,
                    style: const TextStyle(
                      color: AppColors.black,
                      fontSize: 16,
                    ),
                  ),
                  AutoSizeText(
                    'ID : ${widget.user.iduser}',
                    style: const TextStyle(
                      color: AppColors.black,
                      fontSize: 16,
                    ),
                  ),
                ],
              ),
              const Spacer(),
              EditProfileIcon(userCubit: widget.userCubit, user: widget.user),
            ],
          ),
        ));
  }
}
