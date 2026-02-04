import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:lklk/features/livekit_audio/presentation/cubit/livekit_audio_cubit.dart';
import 'package:lklk/features/livekit_audio/presentation/cubit/livekit_audio_state.dart';

/// switch cameras
class ZegoSpeakerButton extends StatelessWidget {
  const ZegoSpeakerButton({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<LiveKitAudioCubit, LiveKitAudioState>(
      builder: (context, state) {
        final isUsingSpeaker = state.speakerOn;
        return GestureDetector(
          onTap: () =>
              context.read<LiveKitAudioCubit>().setSpeaker(!isUsingSpeaker),
          child: Container(
            width: 96,
            height: 96,
            decoration: BoxDecoration(
              color: isUsingSpeaker
                  ? const Color.fromARGB(255, 51, 52, 56).withValues(alpha: 0.6)
                  : Colors.grey,
              shape: BoxShape.circle,
            ),
            child: SizedBox.fromSize(
              size: const Size(56, 56),
              child: isUsingSpeaker
                  ? const Image(
                      image:
                          AssetImage('assets/icons/icon_speaker_normal.png'))
                  : const Image(
                      image: AssetImage('assets/icons/icon_speaker_off.png')),
            ),
          ),
        );
      },
    );
  }
}
