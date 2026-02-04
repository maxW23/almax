class RoomSwitchGuard {
  static bool _isSwitching = false;

  static bool get isSwitching => _isSwitching;

  static void start() {
    _isSwitching = true;
  }

  static void end() {
    _isSwitching = false;
  }
}
