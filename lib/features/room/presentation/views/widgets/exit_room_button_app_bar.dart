import 'package:flutter/material.dart';

import 'package:lklk/core/constants/app_colors.dart';
import 'package:lklk/core/constants/assets.dart';

import 'package:lklk/features/home/presentation/manger/room_cubit/room_cubit_cubit.dart';
import 'package:lklk/features/profile_users/presentaion/manger/user_cubit/user_cubit_cubit.dart';
import 'package:lklk/features/room/presentation/manger/room_exit_service.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:auto_size_text/auto_size_text.dart';
import 'package:lklk/generated/l10n.dart';
import 'package:x_overlay/x_overlay.dart';
import 'package:lklk/core/widgets/overlay/defines.dart';
import 'package:lklk/features/home/presentation/views/home_view.dart';
import 'package:lklk/live_audio_room_manager.dart';
import '../../../domain/entities/room_entity.dart';

class ExitRoomButtonAppBar extends StatefulWidget {
  const ExitRoomButtonAppBar({
    super.key,
    required this.userCubit,
    required this.roomCubit,
    required this.room,
  });
  final UserCubit userCubit;
  final RoomCubit roomCubit;
  final RoomEntity room;
  @override
  State<ExitRoomButtonAppBar> createState() => _ExitRoomButtonAppBarState();
}

class _ExitRoomButtonAppBarState extends State<ExitRoomButtonAppBar> {
  bool _isExiting = false;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      behavior: HitTestBehavior.opaque,
      onTap: () async {
        if (_isExiting) return;
        await _showExitAndMinimizeDialog(context);
      },
      child: Padding(
        padding: const EdgeInsets.only(right: 10),
        child: _isExiting
            ? SizedBox(
                width: MediaQuery.of(context).size.width * 0.10,
                height: MediaQuery.of(context).size.width * 0.10,
                child: const Padding(
                  padding: EdgeInsets.all(8.0),
                  child: CircularProgressIndicator(
                    color: AppColors.white,
                  ),
                ),
              )
            : SvgPicture.asset(
                AssetsData.exitRoomButtonAppBarSvg,
                width: MediaQuery.of(context).size.width * 0.10,
                height: MediaQuery.of(context).size.width * 0.10,
              ),
      ),
    );
  }

  Future<dynamic> _showExitAndMinimizeDialog(BuildContext pageContext) {
    return showDialog(
      context: pageContext,
      barrierDismissible: true,
      barrierLabel: '',
      barrierColor: Colors.black.withValues(alpha: 0.5),
      builder: (dialogContext) {
        return StatefulBuilder(builder: (context, setState) {
          return Center(
            child: AlertDialog(
              backgroundColor: AppColors.transparent,
              contentPadding: EdgeInsets.zero,
              content: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.center,
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  SizedBox(
                    height: 130,
                    width: 130,
                    child: _overlayButton(
                      context: pageContext,
                      room: widget.room,
                      label: S.of(context).minimize,
                      icon: AssetsData.resizeIconBtn,
                    ),
                  ),
                  const SizedBox(
                    height: 30,
                    width: 30,
                  ),
                  SizedBox(
                    height: 130,
                    width: 130,
                    child: _buildActionButton(
                      context: pageContext,
                      label: S.of(context).exit,
                      icon: AssetsData.exitIconBtn,
                      onPressed: () async {
                        if (_isExiting) return;
                        setState(() => _isExiting = true);
                        try {
                          // أغلق نافذة الحوار أولاً لتفادي تعارض التنقل
                          try {
                            Navigator.of(context, rootNavigator: true).pop();
                          } catch (_) {}
                          await RoomExitService.exitRoom(
                            context: pageContext,
                            userCubit: widget.userCubit,
                            roomCubit: widget.roomCubit,
                            delayDuration:
                                const Duration(milliseconds: 500),
                          );
                        } finally {
                          if (mounted) setState(() => _isExiting = false);
                        }
                      },
                    ),
                  ),
                ],
              ),
            ),
          );
        });
      },
    );
  }

  Widget _overlayButton({
    required BuildContext context,
    required RoomEntity room,
    required String label,
    required String icon,
  }) {
    return XOverlayButton(
      buttonSize: const Size(80, 80),
      backgroundColor: AppColors.transparent,
      iconSize: const Size(80, 80),
      onWillPressed: () {
        bool navigated = false;
        void navigate() {
          if (navigated) return;
          navigated = true;
          WidgetsBinding.instance.addPostFrameCallback((_) async {
            if (!mounted) return;
            Navigator.pushAndRemoveUntil(
              context,
              MaterialPageRoute(
                builder: (context) => HomeView(
                  userCubit: widget.userCubit,
                  roomCubit: widget.roomCubit,
                ),
              ),
              (Route<dynamic> route) => false,
            );
          });
        }

        if (audioRoomOverlayController.pageStateNotifier.value ==
            XOverlayPageState.overlaying) {
          navigate();
        } else {
          late VoidCallback listener;
          listener = () {
            if (audioRoomOverlayController.pageStateNotifier.value ==
                XOverlayPageState.overlaying) {
              audioRoomOverlayController.pageStateNotifier
                  .removeListener(listener);
              navigate();
            }
          };
          audioRoomOverlayController.pageStateNotifier.addListener(listener);
          // Fallback in case listener doesn't fire fast
          Future.delayed(const Duration(milliseconds: 700), () {
            try {
              audioRoomOverlayController.pageStateNotifier
                  .removeListener(listener);
            } catch (_) {}
            navigate();
          });
        }
      },
      controller: audioRoomOverlayController,
      icon: Column(
        children: [
          CircleAvatar(
            radius: 40,
            child: Image.asset(icon),
          ),
          const SizedBox(height: 4),
          AutoSizeText(
            label,
            style: const TextStyle(
              color: AppColors.white,
              fontSize: 16,
              fontWeight: FontWeight.bold,
            ),
            textAlign: TextAlign.center,
          ),
        ],
      ),
      dataQuery: () {
        final role = ZegoLiveAudioRoomManager().roleNoti.value;
        return AudioRoomOverlayData(
          roomID: room.id.toString(),
          roomPass: room.pass.toString(),
          role: role,
          roomImg: room.img,
          backgroundImage: room.background,
        );
      },
    );
  }

  Widget _buildActionButton({
    required BuildContext context,
    required String label,
    required VoidCallback onPressed,
    required String icon,
  }) {
    return GestureDetector(
      onTap: _isExiting ? null : onPressed,
      child: Column(
        children: [
          CircleAvatar(
            radius: 40,
            child: _isExiting
                ? const CircularProgressIndicator(
                    color: AppColors.white,
                    strokeWidth: 3,
                  )
                : Image.asset(icon),
          ),
          const SizedBox(height: 4),
          AutoSizeText(
            _isExiting ? S.of(context).exiting : label,
            style: const TextStyle(
              color: AppColors.white,
              fontSize: 16,
              fontWeight: FontWeight.bold,
            ),
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );
  }
}
