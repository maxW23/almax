import 'package:lklk/core/utils/logger.dart';

import 'package:flutter/material.dart';
import 'package:flutter_foreground_task/flutter_foreground_task.dart';
import 'package:lklk/core/foreground_service_handler.dart';
import 'dart:io';
import 'package:flutter/services.dart';

class ForegroundServiceManager {
  static Future<void> initialize() async {
    FlutterForegroundTask.init(
      androidNotificationOptions: AndroidNotificationOptions(
        channelId: 'voice_channel',
        channelName: 'مكالمة صوتية',
        channelDescription: 'قناة إشعارات المكالمات النشطة',
        priority: NotificationPriority.MAX,
        visibility: NotificationVisibility.VISIBILITY_PUBLIC,
      ),
      iosNotificationOptions: const IOSNotificationOptions(
        showNotification: true,
        playSound: false,
      ),
      foregroundTaskOptions: ForegroundTaskOptions(
        eventAction: ForegroundTaskEventAction.repeat(5000),
        autoRunOnBoot: false,
        allowWakeLock: true,
      ),
    );
  }

  static Future<bool> startService(String roomName) async {
    try {
      final result = await FlutterForegroundTask.startService(
        notificationTitle: 'في غرفة: $roomName',
        notificationText: '',
        callback: startCallback,
        notificationButtons: [
          // const NotificationButton(
          //   id: 'mute',
          //   text: 'كتم',
          // ),
          // const NotificationButton(
          //   id: 'exit',
          //   text: 'exit',
          // ),
        ],
      );
      return result == const ServiceRequestSuccess();
    } catch (e) {
      AppLogger.debug('Error starting service: $e');
      return false;
    }
  }

  static Future<void> exitService(BuildContext context) async {
    log('⏺ 1Notification ⏺⏺⏺⏺⏺⏺⏺⏺⏺⏺⏺⏺⏺');

    await stopService(context);
    log('⏺ 2Notification ⏺⏺⏺⏺⏺⏺⏺⏺⏺⏺⏺⏺⏺');

    await closeApplication();
  }

  static Future<void> closeApplication() async {
    if (Platform.isAndroid) {
      // للأندرويد: استخدام SystemNavigator لإغلاق التطبيق
      await SystemNavigator.pop(animated: true);
    } else if (Platform.isIOS) {
      // لـ iOS: استخدام مخرجات النظام (مسموح فقط في حالات نادرة)
      try {
        await _exitiOSApp();
      } catch (e) {
        // تجنب التعطل في حال عدم وجود القناة أو منع Apple للإغلاق البرمجي
        AppLogger.debug('closeApplication on iOS ignored: $e');
      }
    }
  }

// وظيفة خاصة لتنفيذ الإغلاق على iOS
  static Future<void> _exitiOSApp() async {
    await const MethodChannel('flutter.exit').invokeMethod('exitApp');
  }

  // في ملف ForegroundServiceManager.dart
  static Future<void> stopService(BuildContext context) async {
    // bool exitSuccess = false;
    // int retryCount = 0;

    // while (!exitSuccess && retryCount < 3) {
    //   try {
    //     log('⏺ fetchRoomsNotification ⏺⏺⏺⏺⏺⏺⏺⏺⏺⏺⏺⏺⏺');

    //      BlocProvider.of<RoomsCubit>(context)
    //         .fetchRooms(1, "exit_service");
    //     log('⏺ 2fetchRoomsNotification ⏺⏺⏺⏺⏺⏺⏺⏺⏺⏺⏺⏺⏺');

    //     exitSuccess = true;
    //   } catch (e) {
    //     retryCount++;
    //     await Future.delayed(Duration(seconds: 2));
    //   }
    // }

    await FlutterForegroundTask.stopService();
  }

  static void handleButtonPress(String buttonId, BuildContext context) async {
    switch (buttonId) {
      // case 'mute':
      //   _toggleMicrophone();
      //   break;
      case 'exit':
        await stopService(context);
        break;
    }
  }

  // static void _toggleMicrophone() {
  //   FlutterForegroundTask.sendDataToTask({'command': 'toggle_mute'});
  // }
}

@pragma('vm:entry-point')
void startCallback() {
  FlutterForegroundTask.setTaskHandler(MyTaskHandler());
}

// @pragma('vm:entry-point')
// void startCallback(TaskHandler handler) {
//   FlutterForegroundTask.setTaskHandler(handler);
// }
