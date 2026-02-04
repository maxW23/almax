// ignore_for_file: public_member_api_docs, sort_constructors_first

import 'package:flutter/material.dart';
import 'package:lklk/core/utils/logger.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:lklk/core/dialog_amont.dart';
import 'package:lklk/core/utils/functions/snackbar_helper.dart';
import 'package:lklk/features/home/presentation/manger/room_cubit/room_cubit_cubit.dart';
import 'package:lklk/features/profile_users/presentaion/manger/join_to_wakala/join_to_wakala_cubit.dart';
import 'package:lklk/features/profile_users/presentaion/manger/post_charger/post_charger_cubit.dart';
import 'package:lklk/features/profile_users/presentaion/views/pages/join_to_wakala_section_mini_wakel.dart';
import 'package:lklk/features/profile_users/presentaion/views/pages/other_user_profile.dart';
import 'package:lklk/features/profile_users/presentaion/views/widgets/count_profile_edit_row.dart';
import 'package:lklk/features/profile_users/presentaion/views/widgets/profile_quick_actions_variants.dart';
import 'package:lklk/features/room/domain/entities/room_entity.dart';
import 'package:lklk/features/room/presentation/views/widgets/password_input_dialog.dart';
import 'package:lklk/features/room/presentation/views/widgets/room_view_bloc.dart';
import 'package:lklk/generated/l10n.dart';
import 'package:lklk/features/profile_users/presentaion/views/widgets/other_profile_header_actions.dart';
import 'package:lklk/features/profile_users/presentaion/views/widgets/profile_common_body.dart';
import 'package:lklk/features/profile_users/presentaion/manger/user_cubit/user_cubit_cubit.dart';

class OtherUserProfileBody extends StatelessWidget {
  const OtherUserProfileBody({
    super.key,
    required this.widget,
  });

  final OtherUserProfile widget;

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: SingleChildScrollView(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            BlocBuilder<UserCubit, UserCubitState>(
              bloc: widget.userCubit,
              builder: (context, state) {
                return ProfileCommonBody(
                  user: widget.user,
                  userCubit: widget.userCubit,
                  roomCubit: widget.roomCubit,
                  showSvgaBadges: true,
                  room: state.otherRoom,
                  isOther: true,
                  isWakel: widget.user.type == 'charge',
                  onCoverTap: () async {
                    await _navigateToRoom(context, widget.user.iduser);
                  },
                  onCoverSecondaryTap: () async {
                    final amount = await showAmountDialog(context);
                    if (amount != null) {
                      String message = await context
                          .read<PostChargerCubit>()
                          .convertCoins(widget.user.iduser, '$amount');
                      switch (message) {
                        case 'done':
                          message = S.of(context).done;
                          // تحديث الملف الشخصي بعد نجاح التحويل
                          await widget.userCubit.getProfileUser('convertCoins');
                          break;
                        case 'error':
                          message = S.of(context).error;
                          break;
                        case 'failed':
                          message = S.of(context).fail;
                          break;
                      }
                      SnackbarHelper.showMessage(context, message);
                    }
                  },
                  countsRow: CountProfileEditRow(
                    userCubit: widget.userCubit,
                    friendNumber: widget.friendNumber,
                    visitorNumber: widget.visitorNumber,
                    giftReciver: widget.user.giftRecive,
                    giftSend: widget.user.giftSend,
                  ),
                  trailing: FutureBuilder<int?>(
                    future:
                        widget.roomCubit.getUserRoomIdIfAny(widget.user.iduser),
                    builder: (ctx, snap) {
                      final roomId = snap.data;
                      final canTrack = roomId != null;
                      return OtherProfileHeaderActions(
                        user: widget.user,
                        userCubit: widget.userCubit,
                        roomCubit: widget.roomCubit,
                        friendStatus: widget.friendStatus,
                        showTrack: canTrack,
                        onEnterRoom: () async {
                          await _navigateToRoom(
                            context,
                            widget.user.iduser,
                            knownRoomId: roomId,
                          );
                        },
                      );
                    },
                  ),
                  quickActions: OtherProfileQuickActionsRow(
                    user: widget.user,
                    userCubit: widget.userCubit,
                    roomCubit: widget.roomCubit,
                    giftList: widget.giftList,
                    frameList: widget.frameList,
                    entryList: widget.entryList,
                  ),
                  // joinSection: (widget.user.type == 'mini' &&
                  //         (widget.user.power == 'null' || widget.user.power == null))
                  //     ? BlocProvider<JoinToWakalaCubit>(
                  //         create: (context) => JoinToWakalaCubit(),
                  //         child: JoinToWakalaSectionMiniWakel(widget: widget),
                  //       )
                  //     : null,
                );
              },
            ),
            const SizedBox(height: 60),
          ],
        ),
      ),
    );
  }

  Future<void> _navigateToRoom(BuildContext context, String userId,
      {bool showSnackbar = false, int? knownRoomId}) async {
    final roomCubit = BlocProvider.of<RoomCubit>(context);
    try {
      RoomEntity? room;
      // Fast path: if we already know the room id, fetch minimal data then navigate
      if (knownRoomId != null) {
        await roomCubit.updatedfetchRoomById(knownRoomId.toString(), 'track');
        room = roomCubit.roomCubit ?? roomCubit.state.room;
        // Fallback if for some reason minimal fetch failed
        room ??= await roomCubit.trackUserRoom(userId);
      } else {
        room = await roomCubit.trackUserRoom(userId);
      }

      if (room == null) {
        throw Exception("Room not found");
      }
      final r = room;
      log("Room ID: ${r.id}");

      // التحقق إذا كانت الصفحة مفتوحة بالفعل
      if (ModalRoute.of(context)?.settings.name == 'RoomViewBloc_${r.id}') {
        log("Already in the target room");
        return;
      }

      if (!context.mounted) return;

      if (r.pass != null) {
        String? pass;

        pass = await showDialog<String>(
          context: context,
          builder: (context) => const PasswordSetupDialog(),
        );
        if (pass == r.pass && pass != null) {
          Navigator.pushReplacement(
            context,
            PageRouteBuilder(
              settings: RouteSettings(name: 'RoomViewBloc_${r.id}'),
              transitionDuration: Duration.zero,
              reverseTransitionDuration: Duration.zero,
              pageBuilder: (_, __, ___) => RoomViewBloc(
                isForce: true,
                roomId: r.id,
                roomCubit: roomCubit,
                userCubit: widget.userCubit,
                backgroundImage: r.background,
                pass: pass,
                //   initialRoom: r,
              ),
            ),
          );
        }
      } else {
        Navigator.pushReplacement(
          context,
          PageRouteBuilder(
            settings: RouteSettings(name: 'RoomViewBloc_${r.id}'),
            transitionDuration: Duration.zero,
            reverseTransitionDuration: Duration.zero,
            pageBuilder: (_, __, ___) => RoomViewBloc(
              isForce: true,
              roomId: r.id,
              roomCubit: roomCubit,
              userCubit: widget.userCubit,
              backgroundImage: r.background,
              //    initialRoom: r,
            ),
          ),
        );
      }
    } on Exception catch (e) {
      final err = e.toString();
      if (err.toLowerCase().contains('not in room')) {
        SnackbarHelper.showMessage(
            context, S.of(context).theUserIsNotInAnyRoom);
      } else if (err.contains("already in the same room")) {
        SnackbarHelper.showMessage(context, S.of(context).youAreInSameRoom);
      } else if (err.contains("User is banned")) {
        SnackbarHelper.showMessage(context, 'You are banned from this room');
      } else if (showSnackbar) {
        SnackbarHelper.showMessage(
            context, S.of(context).theUserIsNotInAnyRoom);
      }
      log("Error navigating to room: $e");
    }
  }
}
