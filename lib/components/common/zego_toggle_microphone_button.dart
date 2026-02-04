import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import 'package:lklk/features/livekit_audio/presentation/cubit/livekit_audio_cubit.dart';
import 'package:lklk/features/livekit_audio/presentation/cubit/livekit_audio_state.dart';

/// switch cameras
class ZegoToggleMicrophoneButton extends StatelessWidget {
  const ZegoToggleMicrophoneButton({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<LiveKitAudioCubit, LiveKitAudioState>(
      builder: (context, state) {
        final isMicOn = state.micOn;
        return GestureDetector(
          onTap: () => context.read<LiveKitAudioCubit>().toggleMic(!isMicOn),
          child: Container(
            width: 96,
            height: 96,
            decoration: BoxDecoration(
              color: isMicOn
                  ? const Color.fromARGB(255, 51, 52, 56).withValues(alpha: 0.6)
                  : Colors.grey,
              shape: BoxShape.circle,
            ),
            child: SizedBox(
              width: 56,
              height: 56,
              child: isMicOn
                  ? const Image(
                      image:
                          AssetImage('assets/icons/toolbar_mic_normal.png'))
                  : const Image(
                      image: AssetImage('assets/icons/toolbar_mic_off.png')),
            ),
          ),
        );
      },
    );
  }
}
