import 'dart:async';
import 'package:lklk/core/utils/logger.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

/// مدير الذاكرة المحسّن للتطبيق
/// يتولى تنظيف الذاكرة وتحسين الأداء للغرف التي تحتوي على عدد كبير من المستخدمين
class MemoryManager {
  static final MemoryManager _instance = MemoryManager._internal();
  factory MemoryManager() => _instance;
  MemoryManager._internal();

  Timer? _memoryCleanupTimer;
  Timer? _performanceMonitorTimer;

  // إحصائيات الأداء
  int _lastMemoryUsage = 0;
  int _memoryCleanupCount = 0;

  /// بدء مراقبة الذاكرة والأداء
  void startMemoryManagement() {
    if (kDebugMode) {
      log('[MemoryManager] Starting memory management');
    }

    // تنظيف دوري للذاكرة كل 30 ثانية
    _memoryCleanupTimer?.cancel();
    _memoryCleanupTimer = Timer.periodic(
      const Duration(seconds: 30),
      (_) => _performMemoryCleanup(),
    );

    // مراقبة الأداء كل 10 ثوانٍ في وضع التطوير
    if (kDebugMode) {
      _performanceMonitorTimer?.cancel();
      _performanceMonitorTimer = Timer.periodic(
        const Duration(seconds: 10),
        (_) => _monitorPerformance(),
      );
    }
  }

  /// إيقاف مراقبة الذاكرة
  void stopMemoryManagement() {
    if (kDebugMode) {
      log('[MemoryManager] Stopping memory management');
    }

    _memoryCleanupTimer?.cancel();
    _performanceMonitorTimer?.cancel();
    _memoryCleanupTimer = null;
    _performanceMonitorTimer = null;
  }

  /// تنظيف فوري للذاكرة
  Future<void> forceMemoryCleanup() async {
    await _performMemoryCleanup();
  }

  /// تنفيذ تنظيف الذاكرة
  Future<void> _performMemoryCleanup() async {
    try {
      // تنظيف garbage collection
      if (kDebugMode) {
        final beforeCleanup = await _getMemoryUsage();
        log('[MemoryManager] Memory before cleanup: ${beforeCleanup}MB');
      }

      // إجبار garbage collection
      await _forceGarbageCollection();

      // تنظيف كاش الصور إذا كان الاستهلاك عالياً
      await _cleanupImageCache();

      _memoryCleanupCount++;

      if (kDebugMode) {
        final afterCleanup = await _getMemoryUsage();
        log('[MemoryManager] Memory after cleanup: ${afterCleanup}MB (Cleanup #$_memoryCleanupCount)');
      }
    } catch (e) {
      if (kDebugMode) {
        log('[MemoryManager] Error during memory cleanup: $e');
      }
    }
  }

  /// إجبار garbage collection
  Future<void> _forceGarbageCollection() async {
    // تشغيل garbage collection عدة مرات للتأكد من التنظيف الكامل
    for (int i = 0; i < 3; i++) {
      await Future.delayed(const Duration(milliseconds: 10));
      // في Flutter، لا يمكننا إجبار GC مباشرة، لكن يمكننا تشجيعه
      List.generate(1000, (index) => index).clear();
    }
  }

  /// تنظيف كاش الصور
  Future<void> _cleanupImageCache() async {
    try {
      // تنظيف كاش الصور المدمج في Flutter
      PaintingBinding.instance.imageCache.clear();
      PaintingBinding.instance.imageCache.clearLiveImages();

      if (kDebugMode) {
        log('[MemoryManager] Image cache cleared');
      }
    } catch (e) {
      if (kDebugMode) {
        log('[MemoryManager] Error clearing image cache: $e');
      }
    }
  }

  /// مراقبة الأداء
  Future<void> _monitorPerformance() async {
    if (!kDebugMode) return;

    try {
      final currentMemory = await _getMemoryUsage();
      final memoryDiff = currentMemory - _lastMemoryUsage;

      log('[MemoryManager] Current memory: ${currentMemory}MB (${memoryDiff >= 0 ? '+' : ''}${memoryDiff}MB)');

      // تحذير إذا كان استهلاك الذاكرة عالياً
      if (currentMemory > 200) {
        log('[MemoryManager] ⚠️ High memory usage detected: ${currentMemory}MB');
        // تنظيف فوري إذا كان الاستهلاك عالياً جداً
        if (currentMemory > 300) {
          await _performMemoryCleanup();
        }
      }

      _lastMemoryUsage = currentMemory;
    } catch (e) {
      log('[MemoryManager] Error monitoring performance: $e');
    }
  }

  /// الحصول على استهلاك الذاكرة الحالي (تقريبي)
  Future<int> _getMemoryUsage() async {
    try {
      // محاولة الحصول على معلومات الذاكرة من النظام
      final info = await SystemChannels.platform
          .invokeMethod('SystemChrome.getMemoryInfo');
      if (info != null && info is Map) {
        final totalMemory = info['totalMemory'] as int?;
        final availableMemory = info['availableMemory'] as int?;
        if (totalMemory != null && availableMemory != null) {
          return ((totalMemory - availableMemory) / (1024 * 1024)).round();
        }
      }
    } catch (e) {
      // إذا فشل الحصول على معلومات النظام، نستخدم تقدير بسيط
    }

    // تقدير بسيط بناءً على عدد العناصر في الذاكرة
    return _estimateMemoryUsage();
  }

  /// تقدير استهلاك الذاكرة بناءً على العناصر المحملة
  int _estimateMemoryUsage() {
    // تقدير بسيط: 50MB كأساس + 1MB لكل 100 صورة محملة
    final imageCache = PaintingBinding.instance.imageCache;
    final cachedImages = imageCache.currentSize;
    return 50 + (cachedImages / 100).round();
  }

  /// تحسين إعدادات كاش الصور للأداء العالي
  void optimizeImageCacheSettings() {
    final imageCache = PaintingBinding.instance.imageCache;

    // تقليل حجم الكاش للحفاظ على الذاكرة
    imageCache.maximumSize = 100; // الحد الأقصى 100 صورة
    imageCache.maximumSizeBytes = 50 * 1024 * 1024; // الحد الأقصى 50MB

    if (kDebugMode) {
      log('[MemoryManager] Image cache optimized: max ${imageCache.maximumSize} images, ${imageCache.maximumSizeBytes ~/ (1024 * 1024)}MB');
    }
  }

  /// تحسين إعدادات الأداء العامة
  void optimizePerformanceSettings() {
    // تحسين إعدادات كاش الصور
    optimizeImageCacheSettings();

    if (kDebugMode) {
      log('[MemoryManager] Performance settings optimized');
    }
  }

  /// الحصول على إحصائيات الأداء
  Map<String, dynamic> getPerformanceStats() {
    return {
      'memoryCleanupCount': _memoryCleanupCount,
      'lastMemoryUsage': _lastMemoryUsage,
      'imageCacheSize': PaintingBinding.instance.imageCache.currentSize,
      'imageCacheSizeBytes':
          PaintingBinding.instance.imageCache.currentSizeBytes,
      'isMonitoring': _memoryCleanupTimer?.isActive ?? false,
    };
  }
}
