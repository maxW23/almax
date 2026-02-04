import 'dart:async';

import 'package:background_downloader/background_downloader.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_downloader/flutter_downloader.dart';
import 'package:flutter_foreground_task/flutter_foreground_task.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:google_mobile_ads/google_mobile_ads.dart';
import 'package:hive_flutter/hive_flutter.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:url_launcher/url_launcher.dart';

import 'package:lklk/app_lifecycle_handler.dart';
import 'package:lklk/core/config/app_config.dart';
import 'package:lklk/core/config/appwrite_config.dart';
import 'package:lklk/core/config/env_loader.dart';
import 'package:lklk/core/foreground_service_manager.dart';
import 'package:lklk/core/service_locator.dart';
import 'package:lklk/core/services/background_download_service.dart';
import 'package:lklk/core/utils/functions/file_utils.dart';
import 'package:lklk/core/utils/logger.dart';
import 'package:lklk/features/auth/domain/entities/cached_user_data.dart';
import 'package:lklk/features/profile_users/domain/entities/elements_entity.dart';
import 'package:lklk/internal/sdk/livekit/livekit_audio_service.dart';
import 'package:lklk/internal/sdk/express/express_service.dart';

/// Centralized app initialization logic
class AppInitializer {
  static final FlutterLocalNotificationsPlugin _notificationsPlugin =
      FlutterLocalNotificationsPlugin();

  /// Initialize all app services and configurations
  static Future<void> initialize() async {
    // Ensure Flutter is ready
    WidgetsFlutterBinding.ensureInitialized();

    // Configure image cache based on AppConfig
    _configureImageCache();

    // Set device orientation
    await _setDeviceOrientation();

    // Initialize core services
    await _initializeCoreServices();

    // Initialize additional services in parallel (lightweight only)
    await Future.wait([
      _initializeNotifications(),
    ]);
  }

  static void _configureLiveKitFromEnv() {
    try {
      // LIVEKIT_URL=https://your-livekit-host (https or wss)
      var url = '';
      try {
        url = EnvLoader.get('LIVEKIT_URL');
      } catch (_) {}
      if (url.isEmpty) {
        // Fallback: derive from API_BASE_URL host => wss://<host>
        try {
          final api = Uri.parse(AppConfig.apiBaseUrl);
          if (api.hasAuthority) {
            final derived = Uri(
              scheme: 'wss',
              host: api.host,
              port: api.hasPort ? api.port : null,
            ).toString();
            url = derived;
          }
        } catch (_) {}
      }
      if (url.isNotEmpty) {
        LiveKitAudioService.instance.configure(serverUrl: url);
        if (AppConfig.enableLogging) {
          AppLogger.info('LiveKit configured with serverUrl=$url', tag: 'AppInitializer');
        }
      }

      // USE_LIVEKIT_AUDIO=1|true to enable runtime delegation
      bool enable = false;
      try {
        final flag = EnvLoader.get('USE_LIVEKIT_AUDIO');
        enable = flag == '1' || flag.toLowerCase() == 'true';
      } catch (_) {}
      ExpressService.instance.enableLiveKitAudio(enable);
      if (AppConfig.enableLogging) {
        AppLogger.info('LiveKit audio delegation: ${enable ? 'ENABLED' : 'DISABLED'}', tag: 'AppInitializer');
      }
    } catch (_) {}
  }

  /// Configure image cache settings
  static void _configureImageCache() {
    PaintingBinding.instance.imageCache.maximumSize =
        AppConfig.imageCacheMaxSize;
    PaintingBinding.instance.imageCache.maximumSizeBytes =
        AppConfig.imageCacheMaxSizeBytes;
  }

  /// Set device orientation to portrait only
  static Future<void> _setDeviceOrientation() async {
    await SystemChrome.setPreferredOrientations([
      DeviceOrientation.portraitUp,
      DeviceOrientation.portraitDown,
    ]);
  }

  /// Initialize core services
  static Future<void> _initializeCoreServices() async {
    // Load environment variables
    await EnvLoader.load();

    // Initialize service locator
    await init();

    // Configure LiveKit from environment without manual edits
    _configureLiveKitFromEnv();

    // Initialize foreground task communication
    FlutterForegroundTask.initCommunicationPort();

    // Initialize Hive database
    await _initializeHive();

    // Run parallel initializations
    await Future.wait([
      SharedPreferences.getInstance(),
      AppDirectories.instance.init(),
      ForegroundServiceManager.initialize(),
    ]);

    if (AppConfig.enableLogging) {
      AppLogger.info(
        "appDirectory: ${AppDirectories.instance.appDirectory.path}",
        tag: 'AppInitializer',
      );
    }

    // Initialize lifecycle handler
    AppLifecycleHandler();
  }

  /// Initialize Hive database
  static Future<void> _initializeHive() async {
    await Hive.initFlutter();

    // Register adapters
    Hive.registerAdapter(ElementEntityAdapter());
    Hive.registerAdapter(CachedUserDataAdapter());

    // Open boxes
    await Future.wait([
      Hive.openBox<List<ElementEntity>>('elementsBox'),
      Hive.openBox('cachedProfileElementsData'),
      Hive.openBox<List>('giftCacheBox'),
      Hive.openBox<List<ElementEntity>>('frameCacheBox'),
      Hive.openBox<List<ElementEntity>>('entryCacheBox'),
    ]);
  }

  /// Initialize local notifications
  static Future<void> _initializeNotifications() async {
    const AndroidInitializationSettings androidSettings =
        AndroidInitializationSettings('@mipmap/ic_launcher');
    const DarwinInitializationSettings iosSettings =
        DarwinInitializationSettings();
    const InitializationSettings initSettings = InitializationSettings(
      android: androidSettings,
      iOS: iosSettings,
    );

    await _notificationsPlugin.initialize(
      initSettings,
      onDidReceiveNotificationResponse: _onNotificationResponse,
    );
  }

  /// Handle notification response
  static Future<void> _onNotificationResponse(
    NotificationResponse response,
  ) async {
    if (response.payload == 'update_app') {
      final url = Uri.parse(AppConfig.playStoreUrl);
      if (await canLaunchUrl(url)) {
        await launchUrl(url, mode: LaunchMode.externalApplication);
      }
    }
  }

  /// Initialize mobile ads (deferred)
  static Future<void> initializeAds() async {
    if (!AppConfig.enableAds) return;

    await MobileAds.instance.initialize();

    if (AppConfig.enableTestAds) {
      await MobileAds.instance.updateRequestConfiguration(
        RequestConfiguration(
          testDeviceIds: AppConfig.testDeviceIds,
        ),
      );
    }
  }

  /// Initialize download services (deferred)
  static Future<void> initializeDownloads() async {
    await FlutterDownloader.initialize(debug: AppConfig.enableLogging);
    await FileDownloader().ready;

    FileDownloader().registerCallbacks(
      taskStatusCallback: (update) {
        DownloadService.instance.handleStatus(update);
      },
    );

    await FileDownloader().trackTasks();
    await FileDownloader().resumeFromBackground();
    await FileDownloader().rescheduleKilledTasks();
    await FileDownloader().start();
  }

  /// Initialize Appwrite backend
  static Future<void> _initializeAppwrite() async {
    await AppwriteConfig.close();
    try {
      await AppwriteConfig.init();
    } catch (e) {
      if (AppConfig.enableLogging) {
        AppLogger.error(
          'Failed to initialize Appwrite',
          tag: 'AppInitializer',
          error: e as Object?,
        );
      }
    }
  }

  /// Public wrapper to initialize Appwrite later (post-frame) to avoid blocking startup.
  static Future<void> initializeAppwriteDeferred() async {
    await _initializeAppwrite();
  }

  /// Get the notifications plugin instance
  static FlutterLocalNotificationsPlugin get notificationsPlugin =>
      _notificationsPlugin;
}
