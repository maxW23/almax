import 'package:flutter/foundation.dart';
import 'package:lklk/core/config/env_loader.dart';

/// Central configuration management for the entire application
class AppConfig {
  AppConfig._();

  // ============= Environment =============
  static const String environment = kDebugMode ? 'development' : 'production';

  // ============= Feature Flags =============
  static const bool enableLogging = kDebugMode;
  static const bool enableDetailedLogs =
      false; // For seat_item_view and other verbose logs
  static const bool enableAnalytics = !kDebugMode;
  static const bool enableCrashlytics = !kDebugMode;
  static const bool enablePerformanceMonitoring = !kDebugMode;

  // ============= Performance Settings =============
  static const int imageCacheMaxSize = 100; // Max number of images
  static const int imageCacheMaxSizeBytes = 100 << 20; // ~100 MB
  static const int maxConcurrentGifts = 8;
  static const int maxChatMessages = 25;
  static const int maxCachedChatMessages = 50;

  // ============= Network Settings =============
  static String get apiBaseUrl {
    try {
      final url = EnvLoader.get('API_BASE_URL');
      if (url.isNotEmpty && !url.contains('api.example.com')) {
        return url;
      }
    } catch (_) {
      // ignore and use fallback
    }
    // Fallback default
    return 'https://lklklive.com/api';
  }
  static const Duration connectionTimeout = Duration(seconds: 30);
  static const Duration receiveTimeout = Duration(seconds: 30);
  static const int maxRetryAttempts = 3;

  // ============= Room Settings =============
  static const int maxUsersPerRoom = 500;
  static const Duration roomReconnectDelay = Duration(seconds: 2);
  static const Duration userDataCheckInterval = Duration(seconds: 8);

  // ============= UI Settings =============
  static const double designWidth = 360;
  static const double designHeight = 756;
  static const bool keepScreenOn = false;
  static const bool enableHapticFeedback = true;

  // ============= Cache Settings =============
  static const Duration cacheExpiry = Duration(days: 7);
  static const int maxCacheSize = 500; // MB

  // ============= Audio Settings =============
  static const double defaultVolume = 0.7;
  static const bool enableEchoCancellation = true;
  static const bool enableNoiseSuppression = true;
  static const bool enableAutoGainControl = true;
  // Music pipe (WS) feature toggle and config
  static const bool enableMusicPipe = true; // فعّل التحويل إلى MusicPipe
static const String musicPipeWsUrl = 'ws://live.kfo-card.com:8080'; // أو wss:// إذا TLS
// يمكن تعديل التأخير إذا لزم (الافتراضي 15ms جيد لمعظم MP3)
static const Duration musicPipeChunkDelay = Duration(milliseconds: 15);

  // ============= Gift Animation Settings =============
  static const Duration giftAnimationDuration = Duration(milliseconds: 1400);
  static const Duration giftQueueProcessInterval = Duration(milliseconds: 100);
  static const int giftBatchSize = 5;

  // ============= Localization Settings =============
  static const String defaultLocale = 'ar';
  static const List<String> supportedLocales = ['ar', 'en'];

  // ============= Ads Settings =============
  static const bool enableAds = true;
  static const bool enableTestAds = kDebugMode;
  static const List<String> testDeviceIds = [
    'B3EEABB8EE11C2BE770B684D95219ECB', // Add your test device IDs
  ];

  // ============= App Info =============
  static const String appName = 'LKLK Live';
  static const String appVersion = '20';
  static const String appBuildNumber = '20';
  static const String playStoreUrl =
      'https://play.google.com/store/apps/details?id=com.bwmatbw.lklklivechatapp';

  // ============= Debug Settings =============
  static const bool showPerformanceOverlay = false;
  static const bool showSemanticDebugger = false;
  static const bool debugShowCheckedModeBanner = false;

  // ============= Helper Methods =============

  /// Check if we should show logs for a specific feature
  static bool shouldShowLogs(String feature) {
    if (!enableLogging) return false;

    switch (feature) {
      case 'seat_item_view':
      case 'room_view_body':
        return enableDetailedLogs;
      default:
        return true;
    }
  }

  /// Get environment-specific API endpoints
  static String getApiEndpoint(String endpoint) {
    final baseUrl = apiBaseUrl;
    return '$baseUrl$endpoint';
  }

  /// Check if a feature is enabled
  static bool isFeatureEnabled(String feature) {
    // This can be connected to a remote config service later
    switch (feature) {
      case 'gifts':
      case 'lucky_bag':
      case 'vip_system':
        return true;
      default:
        return false;
    }
  }
}
