import 'dart:async';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:lklk/features/livekit_audio/domain/repositories/audio_repository.dart';
import 'package:lklk/features/livekit_audio/presentation/cubit/livekit_audio_state.dart';

class LiveKitAudioCubit extends Cubit<LiveKitAudioState> {
  final AudioRepository _repo;
  StreamSubscription? _partsSub;
  StreamSubscription? _statusSub;

  LiveKitAudioCubit(this._repo) : super(LiveKitAudioState.initial());

  Future<void> connect({required String roomId, required String identity}) async {
    emit(state.copyWith(roomStatus:  LiveKitAudioState.initial().roomStatus));
    try {
      await _repo.connect(roomId: roomId, identity: identity);
      _subscribeStreams();
    } catch (e) {
      emit(state.copyWith(error: e.toString()));
    }
  }

  Future<void> disconnect() async {
    await _repo.disconnect();
    await _partsSub?.cancel();
    await _statusSub?.cancel();
    _partsSub = null;
    _statusSub = null;
  }

  Future<void> toggleMic(bool on) async {
    await _repo.setMic(on);
    emit(state.copyWith(micOn: on));
  }

  Future<void> setSpeaker(bool on) async {
    await _repo.setSpeaker(on);
    emit(state.copyWith(speakerOn: on));
  }

  void _subscribeStreams() {
    _partsSub?.cancel();
    _statusSub?.cancel();
    _partsSub = _repo.observeParticipants().listen((parts) {
      emit(state.copyWith(participants: parts));
    });
    _statusSub = _repo.observeStatus().listen((st) {
      emit(state.copyWith(roomStatus: st));
    });
  }

  @override
  Future<void> close() async {
    await _partsSub?.cancel();
    await _statusSub?.cancel();
    return super.close();
  }
}
