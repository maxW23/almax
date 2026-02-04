import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:lklk/core/foreground_service_manager.dart';
import 'package:lklk/core/services/background_download_service.dart';
import 'package:lklk/core/config/appwrite_config.dart';
import 'package:lklk/live_audio_room_manager.dart';

/// Centralized graceful shutdown for the whole app
class AppShutdown {
  /// Stop all foreground/background services that the app started
  static Future<void> shutdown(BuildContext context) async {
    // Stop foreground/task service (safe if not running)
    try {
      await ForegroundServiceManager.stopService(context);
    } catch (_) {}

    // Dispose our download update stream (local wrapper)
    try {
      DownloadService.instance.dispose();
    } catch (_) {}

    // Logout from Zego room if connected
    try {
      ZEGOSDKManager().logoutRoom();
    } catch (_) {}

    // Close Appwrite clients/sockets if any
    try {
      await AppwriteConfig.close();
    } catch (_) {}
  }

  /// Shutdown then close the app process politely
  static Future<void> exitApp(BuildContext context) async {
    await shutdown(context);
    try {
      // Recommended way on Android; on iOS this will just minimize if allowed
      await SystemNavigator.pop();
    } catch (_) {
      // Fallback for platforms where SystemNavigator.pop is not applicable
      if (Platform.isAndroid) {
        // ignore: deprecated_member_use
        exit(0);
      }
    }
  }
}
