import 'dart:async';

import 'package:flutter/material.dart';
import 'package:lklk/components/call/add_user_button.dart';
import 'package:lklk/components/call/zego_cancel_button.dart';
// import 'package:lklk/core/zego/components/call/add_user_button.dart';
// import 'package:lklk/core/zego/components/call/zego_cancel_button.dart';

import '../../components/components.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:lklk/features/livekit_audio/presentation/cubit/livekit_audio_cubit.dart';
import 'call_container.dart';

class CallingPage extends StatefulWidget {
  const CallingPage({required this.callData, super.key});

  // Accept dynamic to avoid Zego type dependency
  final dynamic callData;

  @override
  State<CallingPage> createState() => _CallingPageState();
}

class _CallingPageState extends State<CallingPage> {
  List<StreamSubscription<dynamic>?> subscriptions = [];
  List<String> streamIDList = [];

  @override
  void initState() {
    super.initState();
    // LiveKit-only: enable mic/speaker via LiveKit cubit if available
    try {
      final cubit = context.read<LiveKitAudioCubit>();
      unawaited(cubit.toggleMic(true));
      unawaited(cubit.setSpeaker(true));
    } catch (_) {}
  }

  @override
  void dispose() {
    for (final subscription in subscriptions) {
      subscription?.cancel();
    }
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return PopScope(
      canPop: false,
      onPopInvoked: (_) {
        // End LiveKit session when leaving
        try {
          context.read<LiveKitAudioCubit>().disconnect();
        } catch (_) {}
        Navigator.of(context).maybePop();
      },
      child: Scaffold(
        body: SafeArea(
          child: Stack(
            children: [
              const CallContainer(),
              bottomBar(),
            ],
          ),
        ),
      ),
    );
  }

  Widget bottomBar() {
    return LayoutBuilder(builder: (context, containers) {
      return Padding(
        padding:
            EdgeInsets.only(left: 0, right: 0, top: containers.maxHeight - 70),
        child: buttonView(),
      );
    });
  }

  Widget buttonView() {
    // Treat as voice by default to avoid video dependencies for now
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceEvenly,
      children: [
        toggleMicButton(),
        endCallButton(),
        speakerButton(),
        inviteUserButton()
      ],
    );
  }

  Widget backgroundImage() {
    return Image.asset(
      'assets/icons/bg.png',
      width: double.infinity,
      height: double.infinity,
      fit: BoxFit.fill,
    );
  }

  Widget endCallButton() {
    return SizedBox(
      width: 50,
      height: 50,
      child: ZegoCancelButton(
        onPressed: () {
          // ZegoCallManager().quitCall();
        },
      ),
    );
  }

  Widget toggleMicButton() {
    return const SizedBox(
      width: 50,
      height: 50,
      child: ZegoToggleMicrophoneButton(),
    );
  }

  Widget toggleCameraButton() {
    return const SizedBox(
      width: 50,
      height: 50,
      child: ZegoToggleCameraButton(),
    );
  }

  Widget switchCameraButton() {
    return const SizedBox(
      width: 50,
      height: 50,
      child: ZegoSwitchCameraButton(),
    );
  }

  Widget speakerButton() {
    return const SizedBox(
      width: 50,
      height: 50,
      child: ZegoSpeakerButton(),
    );
  }

  Widget inviteUserButton() {
    return const SizedBox(
      width: 50,
      height: 50,
      child: ZegoCallAddUserButton(),
    );
  }

  void onStreamListUpdate(dynamic event) {
    // LiveKit-only: no Zego playing/stop logic
  }
}
