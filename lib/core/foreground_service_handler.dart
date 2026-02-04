import 'dart:async';
import 'package:flutter_foreground_task/flutter_foreground_task.dart';

class MyTaskHandler extends TaskHandler {
  StreamSubscription<int>? _sub;
  // int _counter = 0;

  @override
  Future<void> onStart(DateTime timestamp, TaskStarter starter) async {
    _sub = Stream<int>.periodic(const Duration(seconds: 1)).listen((int tick) {
      // keep the service active; perform any periodic work here if needed
    });
  }

  @override
  void onRepeatEvent(DateTime timestamp) {
    // _counter++;
    // FlutterForegroundTask.updateService(
    //   notificationText: 'المكالمة نشطة منذ $_counter ثواني',
    // );
  }

  @override
  Future<void> onDestroy(DateTime timestamp) async {
    await _sub?.cancel();
  }

  @override
  void onNotificationButtonPressed(String id) {
    if (id == 'exit') {
      // 1) أرسل إشارة للـ UI
      FlutterForegroundTask.sendDataToMain({'action': 'exit_service'});
      // 2) أزل الخدمة فورًا
      FlutterForegroundTask.stopService();
    }
  }
}
