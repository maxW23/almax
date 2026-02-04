import 'package:lklk/core/utils/logger.dart';
import 'package:flutter/material.dart';
import 'package:lklk/core/constants/assets.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:lklk/core/services/seat_user.dart';
import 'package:lklk/core/utils/emoji_bottom_sheet.dart';
import 'package:lklk/features/auth/domain/entities/user_entity.dart';
import 'package:lklk/features/home/presentation/manger/room_cubit/room_cubit_cubit.dart';
import 'package:lklk/features/profile_users/presentaion/manger/user_cubit/user_cubit_cubit.dart';
import 'package:lklk/features/room/domain/entities/room_entity.dart';
import 'package:lklk/features/room/presentation/views/widgets/ads_button.dart';
import 'package:lklk/features/room/presentation/views/widgets/chat_private_btn.dart';
import 'package:lklk/features/room/presentation/views/widgets/game_section.dart';
import 'package:lklk/features/room/presentation/views/widgets/gifts_button.dart';
import 'package:lklk/features/room/presentation/views/widgets/more_room_settings_button.dart';
import 'package:lklk/features/room/presentation/views/widgets/send_message_button.dart';
import 'package:lklk/live_audio_room_manager.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:lklk/features/livekit_audio/presentation/cubit/livekit_audio_cubit.dart';
import 'package:lklk/features/livekit_audio/presentation/cubit/livekit_audio_state.dart';
import 'package:lklk/internal/sdk/livekit/livekit_audio_service.dart';

class RoomButtonsRow extends StatefulWidget {
  const RoomButtonsRow({
    super.key,
    required this.room,
    required this.user,
    required this.usersRoom,
    required this.userCubit,
    required this.role,
    this.fromOverlay,
    required this.roomCubit,
    required this.onSend,
    required this.deleteAllMessages,
    required this.addDeleteAllMessagesMessage,
  });
  final RoomCubit roomCubit;
  final void Function() addDeleteAllMessagesMessage;

  final RoomEntity room;
  final UserEntity user;
  final List<UserEntity> usersRoom;
  final UserCubit userCubit;
  final bool? fromOverlay;
  final ZegoLiveAudioRoomRole role;
  final void Function(ZIMMessage) onSend;
  final void Function() deleteAllMessages;

  @override
  State<RoomButtonsRow> createState() => _RoomButtonsRowState();
}

class _RoomButtonsRowState extends State<RoomButtonsRow> {
  // lklk_game_add
  late bool isMicMuted;
  @override
  void initState() {
    super.initState();
    if (!(widget.fromOverlay ?? false)) {
      SeatPreferences.initializeSeatState();
      // الحالة الابتدائية: إخفِ الأزرار دائماً حتى يتأكد الجلوس
      SeatPreferences.seatTakenNotifier.value = false;
      // mic UI state comes from LiveKit cubit; no need to set Zego notifiers
    } else {
      // keep UI responsive; LiveKit cubit will reflect real mic state after connect
      widget.userCubit.user!.isMicOnNotifier.value = true;
    }

    // مزامنة حالة الجلوس فقط

    // بعد أول إطار، مزامنة حالة الجلوس الحالية بدون فرض إظهار مبكر
    WidgetsBinding.instance.addPostFrameCallback((_) {
      final onSeatNow = getLocalUserSeatIndex() != -1;
      if (onSeatNow) {
        SeatPreferences.setSeatTaken(true);
      }
    });
  }

  void syncMicStateWithEngine() async {}

//////////////////////////////////////////////////////////////////////////////////////////////////////
//////////////////////////////////////////////////////////////////////////////////////////////////////
//////////////////////////////////////////////////////////////////////////////////////////////////////
//////////////////////////////////////////////////////////////////////////////////////////////////////
//////////////////////////////////////////////////////////////////////////////////////////////////////
//////////////////////////////////////////////////////////////////////////////////////////////////////
//////////////////////////////////////////////////////////////////////////////////////////////////////
//////////////////////////////////////////////////////////////////////////////////////////////////////
//////////////////////////////////////////////////////////////////////////////////////////////////////
  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(12, 6, 12, 12),
      child: LayoutBuilder(
        builder: (context, constraints) {
          return FittedBox(
            fit: BoxFit.scaleDown,
            alignment: Alignment.center,
            child: Container(
              constraints: BoxConstraints(minWidth: constraints.maxWidth),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      SendMessageButton(
                        widget: widget,
                        onSend: widget.onSend,
                      ),
                      const SizedBox(width: 8),
                      MoreRoomSettingsButton(
                        roomId: widget.room.id,
                        deleteAllMessages: widget.deleteAllMessages,
                        addDeleteAllMessagesMessage:
                            widget.addDeleteAllMessagesMessage,
                        role: widget.role,
                        userID: widget.user.id.toString(),
                        fromOverlay: widget.fromOverlay,
                      ),
                      const SizedBox(width: 8),
                      AnimatedBuilder(
                        animation: Listenable.merge([
                          SeatPreferences.seatTakenNotifier,
                          ...ZegoLiveAudioRoomManager()
                              .seatList
                              .map((s) => s.currentUser),
                        ]),
                        builder: (context, _) {
                          final isSeatTaken =
                              SeatPreferences.seatTakenNotifier.value;
                          final hasLocalSeat = getLocalUserSeatIndex() != -1;
                          final onSeat = isSeatTaken || hasLocalSeat;
                          return onSeat
                              ? Row(
                                  children: [
                                    emojiButton(context),
                                    const SizedBox(width: 8),
                                    muteMicButton(),
                                    const SizedBox(width: 8),
                                  ],
                                )
                              : const SizedBox(width: 0, height: 0);
                        },
                      ),
                    ],
                  ),
                  Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      ChatPrivateBtn(
                        userCubit: widget.userCubit,
                        roomCubit: widget.roomCubit,
                      ),
                      const SizedBox(width: 8),
                      AdsButton(
                        userCubit: widget.userCubit,
                      ),
                      const SizedBox(width: 8),
                      GameSection(
                        roomId: widget.room.id,
                      ),
                      const SizedBox(width: 8),
                      GiftsButton(widget: widget),
                    ],
                  ),
                ],
              ),
            ),
          );
        },
      ),
    );
  }

  ValueListenableBuilder<bool> emojiAndMuteSection() {
    return ValueListenableBuilder<bool>(
      valueListenable: SeatPreferences.seatTakenNotifier,
      builder: (context, isSeatTaken, child) {
        return Row(
          children: [
            emojiButton(context),
            const SizedBox(width: 8),
            muteMicButton(),
          ],
        );
      },
    );
  }

//////////////////////////////////////////////////////////////////////////////////////////////////////
//////////////////////////////////////////////////////////////////////////////////////////////////////
//////////////////////////////////////////////////////////////////////////////////////////////////////
//////////////////////////////////////////////////////////////////////////////////////////////////////
//////////////////////////////////////////////////////////////////////////////////////////////////////
//////////////////////////////////////////////////////////////////////////////////////////////////////
//////////////////////////////////////////////////////////////////////////////////////////////////////
//////////////////////////////////////////////////////////////////////////////////////////////////////
//////////////////////////////////////////////////////////////////////////////////////////////////////
  Widget muteMicButton() {
    return ValueListenableBuilder<bool>(
      valueListenable: LiveKitAudioService.instance.localMicNotifier,
      builder: (context, engineMicOn, _) {
        return GestureDetector(
          onTap: () {
            if (getLocalUserSeatIndex() != -1) {
              // Toggle based on actual engine state to avoid inversion bugs
              context.read<LiveKitAudioCubit>().toggleMic(!engineMicOn);
            }
          },
          child: SvgPicture.asset(
            engineMicOn
                ? AssetsData.microphoneIconBtnSvg
                : AssetsData.muteMicrophoneIconBtnSvg,
            width: MediaQuery.of(context).size.width * 0.10,
            height: MediaQuery.of(context).size.width * 0.10,
          ),
        );
      },
    );
  }

  Widget emojiButton(BuildContext context) {
    return GestureDetector(
      onTap: () {
        (getLocalUserSeatIndex() != -1)
            ? EmojiBottomSheetWidget.showBasicModalBottomSheet(
                context, widget.room.id.toString())
            : null;
      },
      child: SvgPicture.asset(
        AssetsData.emojiIconBtnSvg,
        width: MediaQuery.of(context).size.width * 0.10,
        height: MediaQuery.of(context).size.width * 0.10,
      ),
    );
  }

  // Method to toggle mic state and update UI
  void toggleMicrophone(bool isMicOn) async {}

  Future<void> muteMicrophoneForYourself(bool mute) async {}

  // Method to check if the mic is muted
  Future<bool> isMicrophoneMutedYourself() async {
    // الحالة تقرأ من LiveKitAudioCubit وليس من Zego
    final ctx = context.mounted ? context : null;
    if (ctx == null) return false;
    try {
      final state = ctx.read<LiveKitAudioCubit>().state;
      return !state.micOn;
    } catch (_) {
      return false;
    }
  }

  int getLocalUserSeatIndex() {
    for (final element in ZegoLiveAudioRoomManager().seatList) {
      if (element.currentUser.value?.iduser ==
          ZEGOSDKManager().currentUser!.iduser) {
        return element.seatIndex;
      }
    }
    return -1;
  }
}
