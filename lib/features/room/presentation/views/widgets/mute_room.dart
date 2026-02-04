import 'package:flutter/material.dart';
import 'package:auto_size_text/auto_size_text.dart';
import 'package:lklk/core/constants/app_colors.dart';
import 'package:lklk/features/room/presentation/manger/is_active_gifts_cubit/is_active_gifts_cubit.dart';
import 'package:lklk/generated/l10n.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:lklk/features/livekit_audio/presentation/cubit/livekit_audio_cubit.dart';
import 'package:flutter_svg/flutter_svg.dart';

class MuteRoomButton extends StatefulWidget {
  const MuteRoomButton({super.key});

  @override
  State<MuteRoomButton> createState() => _MuteRoomButtonState();
}

class _MuteRoomButtonState extends State<MuteRoomButton> {
  final IsMuteRoomManager _muteManager = IsMuteRoomManager();
  late bool isMuted;

  @override
  void initState() {
    super.initState();
    isMuted = _muteManager.isMuteNotifier.value;

    // الاستماع للتغيرات في ValueNotifier
    _muteManager.isMuteNotifier.addListener(_onValueChanged);
  }

  void _onValueChanged() {
    setState(() {
      isMuted = _muteManager.isMuteNotifier.value;
    });
  }

  @override
  void dispose() {
    _muteManager.isMuteNotifier.removeListener(_onValueChanged);
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.symmetric(vertical: 8, horizontal: 16),
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      decoration: BoxDecoration(
        gradient: const LinearGradient(
          colors: [AppColors.primary, AppColors.secondColor],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(16),
        boxShadow: const [
          BoxShadow(color: Colors.black26, blurRadius: 8, offset: Offset(2, 2)),
        ],
      ),
      child: Row(
        children: [
          AnimatedSwitcher(
            duration: const Duration(milliseconds: 300),
            child: SvgPicture.asset(
              'assets/icons/room_btn/mute_room_icon.svg',
              key: ValueKey<bool>(isMuted),
              width: 24,
              height: 24,
              colorFilter: const ColorFilter.mode(Colors.white, BlendMode.srcIn),
            ),
          ),
          const SizedBox(width: 10),
          AutoSizeText(
            S.of(context).muteRoom,
            style: const TextStyle(
              color: Colors.white,
              fontWeight: FontWeight.bold,
              fontSize: 16,
            ),
          ),
          const Spacer(),
          Switch(
            value: isMuted,
            activeColor: Colors.white,
            activeTrackColor: Colors.white38,
            inactiveThumbColor: Colors.white70,
            inactiveTrackColor: Colors.white24,
            onChanged: (value) async {
              await _muteManager.setIsMute(value);
              // LiveKit: toggle speaker route as a room-level mute for local device
              try {
                // When value==true (mute room), turn speaker off
                context.read<LiveKitAudioCubit>().setSpeaker(!value);
              } catch (_) {}
              // لا حاجة لـ setState هنا لأن ValueNotifier سيتكفل بالتحديث
            },
          )
        ],
      ),
    );
  }
}
