import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:lklk/features/auth/domain/entities/user_entity.dart';
import 'package:lklk/features/home/presentation/manger/room_cubit/room_cubit_cubit.dart';
import 'package:lklk/features/profile_users/presentaion/manger/user_cubit/user_cubit_cubit.dart';
import 'package:lklk/features/profile_users/presentaion/views/pages/profile_state_widget.dart';
import 'package:lklk/features/profile_users/presentaion/views/widgets/profile_header_common.dart';
import 'package:lklk/features/profile_users/presentaion/views/widgets/relation_bar.dart';
import 'package:lklk/features/profile_users/presentaion/views/pages/other_user_profile.dart';
import 'package:lklk/features/profile_users/presentaion/manger/relation_progress_cubit/relation_progress_cubit.dart';
import 'package:lklk/core/utils/functions/snackbar_helper.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:lklk/features/room/domain/entities/room_entity.dart';
import 'package:lklk/features/home/presentation/views/widgets/room_item_widget_titles_container.dart';

/// Common profile body layout shared between self and other profile screens.
///
/// This widget composes:
/// - Cover + header card via `ProfileHeaderCommon`
/// - Optional join section under header
/// - Profile state row
/// - Relation bar
/// - Custom quick actions
class ProfileCommonBody extends StatelessWidget {
  const ProfileCommonBody({
    super.key,
    required this.user,
    required this.userCubit,
    required this.roomCubit,
    required this.countsRow,
    required this.trailing,
    required this.quickActions,
    this.isOther = false,
    this.isWakel = true,
    this.onCoverTap,
    this.onCoverSecondaryTap,
    this.joinSection,
    this.room,
    this.showSvgaBadges = true,
    this.onUserTitleTap,  this.showRoom =true,
  });

  final UserEntity user;
  final UserCubit userCubit;
  final RoomCubit roomCubit;

  final Widget countsRow;
  final Widget trailing;
  final Widget quickActions;

  /// Optional: user's room to preview inside the profile
  final RoomEntity? room;

  final bool isOther;
  final bool isWakel;

  final VoidCallback? onCoverTap;
  final VoidCallback? onCoverSecondaryTap;
  final VoidCallback? onUserTitleTap;

  /// Optional section inserted between header and profile state row
  final Widget? joinSection;

  /// Whether to show SVGA badges row under level in the header
  final bool showSvgaBadges , showRoom;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        ProfileHeaderCommon(
          user: user,
          userCubit: userCubit,
          roomCubit: roomCubit,
          showSvgaBadges: showSvgaBadges,
          isOther: isOther,
          isWakel: isWakel,
          onCoverTap: onCoverTap,
          onCoverSecondaryTap: onCoverSecondaryTap,
          onUserTitleTap: onUserTitleTap,
          countsRow: countsRow,
          trailing: trailing,
        ),
        const SizedBox(height: 10),
        if (joinSection != null) ...[
          joinSection!,
          const SizedBox(height: 10),
        ],
        if (isOther) ...[
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 20),
            child: Row(
              children: [
                ProfileStateWidget(
                  profileState: user.profile_state ?? "",
                ),
                SizedBox(width: 10.w),
              ],
            ),
          ),
          const SizedBox(height: 16),
          cp(),
          const SizedBox(height: 5),
          BlocProvider<RelationProgressCubit>(
            create: (context) => RelationProgressCubit(),
            child: BlocListener<RelationProgressCubit, RelationProgressState>(
              listener: (context, state) async {
                const loaderName = 'RELATION_DELETE_PROGRESS';
                if (state is RelationProgressLoading) {
                  showDialog(
                    context: context,
                    barrierDismissible: false,
                    barrierColor: Colors.black26,
                    routeSettings: const RouteSettings(name: loaderName),
                    builder: (_) => const Center(
                      child: CircularProgressIndicator(),
                    ),
                  );
                } else {
                  Navigator.of(context, rootNavigator: true)
                      .popUntil((route) => route.settings.name != loaderName);
                  if (state is RelationProgressRelationRequestDeleted) {
                    SnackbarHelper.showMessage(context, 'تم إلغاء الارتباط بنجاح');
                    await userCubit.getProfileUser('RelationBar');
                  } else if (state is RelationProgressError) {
                    SnackbarHelper.showMessage(context, state.message);
                  }
                }
              },
              child: Builder(
                builder: (providerCtx) => Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 16.0),
                  child: RelationBar(
                    leftUser1: user,
                    rightImagePath: user.imgrelation,
                    scale: 1.5,
                    onVisitProfile: () async {
                      final id = user.idrelation;
                      if (id != null && id.isNotEmpty && id != 'null') {
                        await userCubit.getUserProfileById(id);
                        final st = userCubit.state;
                        if (st.status.isLoadedById && st.userOther != null) {
                          Navigator.of(context).push(
                            MaterialPageRoute(
                              builder: (_) => OtherUserProfile(
                                user: st.userOther!,
                                entryList: st.entryListOther,
                                frameList: st.frameListOther,
                                giftList: st.giftListOther,
                                userCubit: userCubit,
                                friendStatus: st.freindOther,
                                friendNumber: st.friendNumberOther!,
                                visitorNumber: st.visitorNumberOther!,
                                roomCubit: roomCubit,
                              ),
                            ),
                          );
                        } else if (st.status.isError) {
                          SnackbarHelper.showMessage(
                              context, 'UserCubitError: ${st.message}');
                        }
                      }
                    },
                    onRequestUnlink: () async {
                      final id = user.idrelation;
                      if (id != null && id.isNotEmpty && id != 'null') {
                        providerCtx
                            .read<RelationProgressCubit>()
                            .deleteRelationRequest(id);
                      }
                    },
                  ),
                ),
              ),
            ),
          ),
          const SizedBox(height: 16),
        ],
        quickActions,
        const SizedBox(height: 20),
        if (room != null && showRoom)
          Padding(
            padding: const EdgeInsets.only(bottom: 10, right: 20, left: 20),
            child: RoomItemWidgetTitlesContainer(
              key: ValueKey(room!.id),
              isList: true,
              roomCubit: roomCubit,
              room: room!,
              userCubit: userCubit,
            ),
          ),
        const SizedBox(height: 8),
      ],
    );
  }

  Padding cp() {
    return Padding(
        padding: const EdgeInsets.symmetric(horizontal: 24.0),
        child: RichText(
          text: TextSpan(
            style: TextStyle(
              fontSize: 20.0,
              fontWeight: FontWeight.w600,
              color: Colors.black,
              letterSpacing: 1.2,
              shadows: [
                Shadow(
                  color: Colors.grey.withOpacity(0.3),
                  blurRadius: 2.0,
                  offset: const Offset(1, 1),
                ),
              ],
            ),
            children: const [
              TextSpan(
                text: 'CP ',
              ),
              TextSpan(
                text: '❤️',
                style: TextStyle(
                  fontSize: 22.0,
                  shadows: [
                    Shadow(
                      color: Colors.black,
                      blurRadius: 3.0,
                      offset: Offset(0, 1),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      );
  }
}
