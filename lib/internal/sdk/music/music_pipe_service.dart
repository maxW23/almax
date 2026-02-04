import 'dart:async';
import 'dart:convert';
import 'dart:io';
import 'dart:typed_data';

import 'package:lklk/core/config/app_config.dart';
import 'package:web_socket_channel/io.dart';
import 'package:web_socket_channel/status.dart' as ws_status;

class MusicPipeState {
  final bool connected;
  final bool isPlaying;
  final int positionMs;
  final int durationMs;
  final String? title;
  final String? error;

  const MusicPipeState({
    required this.connected,
    required this.isPlaying,
    required this.positionMs,
    required this.durationMs,
    this.title,
    this.error,
  });

  MusicPipeState copyWith({
    bool? connected,
    bool? isPlaying,
    int? positionMs,
    int? durationMs,
    String? title,
    String? error,
  }) => MusicPipeState(
        connected: connected ?? this.connected,
        isPlaying: isPlaying ?? this.isPlaying,
        positionMs: positionMs ?? this.positionMs,
        durationMs: durationMs ?? this.durationMs,
        title: title ?? this.title,
        error: error ?? this.error,
      );

  static const initial = MusicPipeState(
    connected: false,
    isPlaying: false,
    positionMs: 0,
    durationMs: 0,
  );
}

class MusicPipeService {
  final String wsUrl;
  IOWebSocketChannel? _channel;
  StreamSubscription? _channelSub;
  bool _sending = false;
  final _stateCtrl = StreamController<MusicPipeState>.broadcast();
  MusicPipeState _state = MusicPipeState.initial;

  Stream<MusicPipeState> get stateStream => _stateCtrl.stream;
  MusicPipeState get state => _state;

  MusicPipeService({required this.wsUrl});

  Future<void> _ensureConnected() async {
    if (_channel != null) return;
    final socket = await WebSocket.connect(wsUrl);
    _channel = IOWebSocketChannel(socket);
    _channelSub = _channel!.stream.listen(_onMessage, onDone: _onDone, onError: _onError);
    _emit(_state.copyWith(connected: true));
  }

  void _onMessage(dynamic data) {
    try {
      if (data is String) {
        final json = jsonDecode(data) as Map<String, dynamic>;
        final type = json['type'];
        if (type == 'state') {
          _emit(_state.copyWith(
            isPlaying: json['isPlaying'] == true,
            positionMs: (json['positionMs'] ?? 0) as int,
            durationMs: (json['durationMs'] ?? 0) as int,
            title: json['title'] as String?,
          ));
        } else if (type == 'error') {
          _emit(_state.copyWith(error: json['message'] as String?));
        }
      }
    } catch (_) {}
  }

  void _onDone() {
    _emit(_state.copyWith(connected: false));
    _disposeChannel();
  }

  void _onError(Object e) {
    _emit(_state.copyWith(connected: false, error: e.toString()));
    _disposeChannel();
  }

  void _disposeChannel() {
    try { _channelSub?.cancel(); } catch (_) {}
    _channelSub = null;
    try { _channel?.sink.close(ws_status.normalClosure); } catch (_) {}
    _channel = null;
  }

  void _emit(MusicPipeState s) {
    _state = s;
    if (!_stateCtrl.isClosed) {
      _stateCtrl.add(_state);
    }
  }

  Future<void> startStreaming({
    required String roomName,
    required String token,
    required File file,
    String? title,
    String? mime,
  }) async {
    await _ensureConnected();

    // Send start metadata
    final meta = {
      'action': 'start',
      'roomName': roomName,
      'token': token,
      if (title != null) 'title': title,
      if (mime != null) 'mime': mime,
    };
    _channel!.sink.add(jsonEncode(meta));

    // Pipe file contents as binary chunks
    _sending = true;
    try {
      final stream = file.openRead();
      await for (final chunk in stream) {
        if (!_sending) break;
        if (_channel == null) break;
        // Send as binary
        _channel!.sink.add(Uint8List.fromList(chunk));
        // Lightweight pacing to avoid flooding server buffer
        await Future.delayed(AppConfig.musicPipeChunkDelay);
      }
      // Signal EOF explicitly
      if (_channel != null) {
        _channel!.sink.add(jsonEncode({'action': 'eof'}));
      }
    } catch (e) {
      _emit(_state.copyWith(error: e.toString()));
    }
  }

  void pause() {
    _channel?.sink.add(jsonEncode({'action': 'pause'}));
  }

  void resume() {
    _channel?.sink.add(jsonEncode({'action': 'resume'}));
  }

  void seek(int ms) {
    _channel?.sink.add(jsonEncode({'action': 'seek', 'ms': ms}));
  }

  void next() {
    _channel?.sink.add(jsonEncode({'action': 'next'}));
  }

  void prev() {
    _channel?.sink.add(jsonEncode({'action': 'prev'}));
  }

  void setVolume(double volume) {
    _channel?.sink.add(jsonEncode({'action': 'volume', 'value': volume}));
  }

  Future<void> stop() async {
    _sending = false;
    _channel?.sink.add(jsonEncode({'action': 'stop'}));
    await Future.delayed(const Duration(milliseconds: 50));
    _disposeChannel();
    _emit(MusicPipeState.initial);
  }

  Future<void> dispose() async {
    await stop();
    try { await _stateCtrl.close(); } catch (_) {}
  }
}
