import 'package:lklk/core/utils/logger.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'memory_manager.dart';
import 'network_optimizer.dart';

/// مدير الأداء الشامل للتطبيق
/// يجمع جميع تحسينات الأداء في مكان واحد لضمان تشغيل سلس للغرف عالية الكثافة
class PerformanceManager {
  static final PerformanceManager _instance = PerformanceManager._internal();
  factory PerformanceManager() => _instance;
  PerformanceManager._internal();

  final MemoryManager _memoryManager = MemoryManager();
  final NetworkOptimizer _networkOptimizer = NetworkOptimizer();

  bool _isInitialized = false;
  bool _isHighPerformanceMode = false;

  /// تهيئة مدير الأداء
  Future<void> initialize() async {
    if (_isInitialized) return;

    try {
      if (kDebugMode) {
        log('[PerformanceManager] Initializing performance optimizations...');
      }

      // تحسين إعدادات النظام
      await _optimizeSystemSettings();

      // تحسين إعدادات الذاكرة
      _memoryManager.optimizePerformanceSettings();

      // بدء مراقبة الأداء
      _memoryManager.startMemoryManagement();

      _isInitialized = true;

      if (kDebugMode) {
        log('[PerformanceManager] Performance manager initialized successfully');
      }
    } catch (e) {
      if (kDebugMode) {
        log('[PerformanceManager] Error initializing performance manager: $e');
      }
    }
  }

  /// تفعيل وضع الأداء العالي للغرف الكثيفة
  Future<void> enableHighPerformanceMode() async {
    if (_isHighPerformanceMode) return;

    try {
      if (kDebugMode) {
        log('[PerformanceManager] Enabling high performance mode...');
      }

      // تحسينات إضافية للأداء العالي
      await _applyHighPerformanceSettings();

      // تنظيف فوري للذاكرة
      await _memoryManager.forceMemoryCleanup();

      _isHighPerformanceMode = true;

      if (kDebugMode) {
        log('[PerformanceManager] High performance mode enabled');
      }
    } catch (e) {
      if (kDebugMode) {
        log('[PerformanceManager] Error enabling high performance mode: $e');
      }
    }
  }

  /// إلغاء تفعيل وضع الأداء العالي
  void disableHighPerformanceMode() {
    if (!_isHighPerformanceMode) return;

    try {
      if (kDebugMode) {
        log('[PerformanceManager] Disabling high performance mode...');
      }

      _isHighPerformanceMode = false;

      if (kDebugMode) {
        log('[PerformanceManager] High performance mode disabled');
      }
    } catch (e) {
      if (kDebugMode) {
        log('[PerformanceManager] Error disabling high performance mode: $e');
      }
    }
  }

  /// تحسين إعدادات النظام
  Future<void> _optimizeSystemSettings() async {
    try {
      // تفعيل edge-to-edge مع إبقاء أشرطة النظام مرئية وعدم إخفاء شريط النظام السفلي
      await SystemChrome.setEnabledSystemUIMode(SystemUiMode.edgeToEdge);
      SystemChrome.setSystemUIOverlayStyle(const SystemUiOverlayStyle(
        systemNavigationBarColor: Colors.black,
        systemNavigationBarIconBrightness: Brightness.light,
        systemNavigationBarDividerColor: Colors.black,
        statusBarColor: Colors.transparent,
        statusBarIconBrightness: Brightness.light,
      ));

      // تحسين اتجاه الشاشة (إذا كان مطلوباً)
      await SystemChrome.setPreferredOrientations([
        DeviceOrientation.portraitUp,
      ]);
    } catch (e) {
      if (kDebugMode) {
        log('[PerformanceManager] Error optimizing system settings: $e');
      }
    }
  }

  /// تطبيق إعدادات الأداء العالي
  Future<void> _applyHighPerformanceSettings() async {
    try {
      // تقليل حجم كاش الصور أكثر في وضع الأداء العالي
      final imageCache = PaintingBinding.instance.imageCache;
      imageCache.maximumSize = 50; // تقليل إلى 50 صورة
      imageCache.maximumSizeBytes = 25 * 1024 * 1024; // تقليل إلى 25MB

      // مسح الكاش الحالي
      imageCache.clear();
      imageCache.clearLiveImages();

      // مسح كاش الشبكة
      _networkOptimizer.clearCache();
    } catch (e) {
      if (kDebugMode) {
        log('[PerformanceManager] Error applying high performance settings: $e');
      }
    }
  }

  /// تحسين طلب الصور للغرف عالية الكثافة
  String optimizeImageForRoom(String imageUrl, {bool isAvatar = false}) {
    // تحديد الأبعاد المناسبة حسب نوع الصورة
    int? width, height;

    if (isAvatar) {
      // صور المستخدمين - أبعاد صغيرة
      width = _isHighPerformanceMode ? 64 : 128;
      height = _isHighPerformanceMode ? 64 : 128;
    } else {
      // صور أخرى - أبعاد متوسطة
      width = _isHighPerformanceMode ? 200 : 400;
      height = _isHighPerformanceMode ? 200 : 400;
    }

    return _networkOptimizer.optimizeImageUrl(
      imageUrl,
      width: width,
      height: height,
    );
  }

  /// تجميع تحديثات المستخدمين
  void batchUserUpdate(String userId, Function updateFunction) {
    _networkOptimizer.batchUserUpdate(userId, updateFunction);
  }

  /// تجميع تحديثات الرسائل
  void batchMessageUpdate(String roomId, Function updateFunction) {
    _networkOptimizer.batchMessageUpdate(roomId, updateFunction);
  }

  /// تجميع تحديثات الصوت
  void batchAudioUpdate(String streamId, Function updateFunction) {
    _networkOptimizer.batchAudioUpdate(streamId, updateFunction);
  }

  /// طلب محسّن مع تخزين مؤقت
  Future<T> optimizedRequest<T>(
    String cacheKey,
    Future<T> Function() requestFunction,
  ) {
    return _networkOptimizer.optimizedRequest(cacheKey, requestFunction);
  }

  /// تنظيف الذاكرة يدوياً
  Future<void> cleanupMemory() async {
    await _memoryManager.forceMemoryCleanup();
  }

  /// إيقاف مدير الأداء
  void dispose() {
    try {
      if (kDebugMode) {
        log('[PerformanceManager] Disposing performance manager...');
      }

      _memoryManager.stopMemoryManagement();
      _networkOptimizer.dispose();

      _isInitialized = false;
      _isHighPerformanceMode = false;

      if (kDebugMode) {
        log('[PerformanceManager] Performance manager disposed');
      }
    } catch (e) {
      if (kDebugMode) {
        log('[PerformanceManager] Error disposing performance manager: $e');
      }
    }
  }

  /// الحصول على تقرير الأداء الشامل
  Map<String, dynamic> getPerformanceReport() {
    return {
      'isInitialized': _isInitialized,
      'isHighPerformanceMode': _isHighPerformanceMode,
      'memoryStats': _memoryManager.getPerformanceStats(),
      'networkStats': _networkOptimizer.getStats(),
      'timestamp': DateTime.now().toIso8601String(),
    };
  }

  /// طباعة تقرير الأداء
  void printPerformanceReport() {
    if (!kDebugMode) return;

    final report = getPerformanceReport();
    log('=== Performance Report ===');
    log('Initialized: ${report['isInitialized']}');
    log('High Performance Mode: ${report['isHighPerformanceMode']}');
    log('Memory Stats: ${report['memoryStats']}');
    log('Network Stats: ${report['networkStats']}');
    log('========================');
  }

  // Getters للوصول إلى المديرين الفرعيين
  MemoryManager get memoryManager => _memoryManager;
  NetworkOptimizer get networkOptimizer => _networkOptimizer;
  bool get isInitialized => _isInitialized;
  bool get isHighPerformanceMode => _isHighPerformanceMode;
}
