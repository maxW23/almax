import 'package:flutter/foundation.dart';

/// Tracks room visibility state to filter events (e.g., gifts) after resume.
class RoomVisibilityManager {
  RoomVisibilityManager._internal();
  static final RoomVisibilityManager _instance = RoomVisibilityManager._internal();
  factory RoomVisibilityManager() => _instance;

  String? _currentRoomId;
  final Map<String, int> _lastResumeAtMsByRoom = <String, int>{};

  /// Set the room that is currently visible in UI.
  void setCurrentRoom(String roomId) {
    _currentRoomId = roomId;
  }

  /// Mark the room as resumed (visible) now.
  /// If [serverTimestampMs] is provided (>0), it will be used instead of local time.
  void markResumed(String roomId, {int? serverTimestampMs}) {
    _currentRoomId = roomId;
    final nowMs = DateTime.now().millisecondsSinceEpoch;
    final resume = (serverTimestampMs != null && serverTimestampMs > 0)
        ? serverTimestampMs
        : nowMs;
    _lastResumeAtMsByRoom[roomId] = resume;
    assert(() {
      // ignore: avoid_print
      if (kDebugMode) {
        print('[RoomVisibility] markResumed room=$roomId at=$resume');
      }
      return true;
    }());
  }

  /// Returns the last resume timestamp (ms) for this [roomId].
  int lastResumeAtMsFor(String roomId) => _lastResumeAtMsByRoom[roomId] ?? 0;

  /// Returns currently active room id, if any.
  String? get currentRoomId => _currentRoomId;

  /// Returns last resume timestamp (ms) for the current room, or 0 if unknown.
  int get currentRoomLastResumeAtMs {
    final id = _currentRoomId;
    if (id == null) return 0;
    return _lastResumeAtMsByRoom[id] ?? 0;
  }
}
