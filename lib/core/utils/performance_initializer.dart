import 'package:flutter/material.dart';
import 'package:lklk/core/utils/image_cache_optimizer.dart';
import 'package:lklk/core/utils/memory_optimizer.dart';
import 'dart:developer' as dev;

/// مُهيئ الأداء - تهيئة جميع التحسينات
class PerformanceInitializer {
  static const String _logTag = 'PerformanceInitializer';
  static bool _isInitialized = false;

  /// تهيئة جميع تحسينات الأداء
  static Future<void> initialize() async {
    if (_isInitialized) {
      dev.log('⚠️ Performance already initialized', name: _logTag);
      return;
    }

    try {
      dev.log('🚀 Initializing performance optimizations...', name: _logTag);

      // تحسين كاش الصور
      ImageCacheOptimizer.optimizeImageCache();

      // بدء مراقبة الذاكرة
      MemoryMonitor.checkMemoryUsage();

      // تحسين إعدادات Flutter العامة
      _optimizeFlutterSettings();

      _isInitialized = true;
      dev.log('✅ Performance optimizations initialized successfully',
          name: _logTag);
    } catch (e) {
      dev.log('❌ Failed to initialize performance optimizations: $e',
          name: _logTag);
      rethrow;
    }
  }

  /// تحسين إعدادات Flutter العامة
  static void _optimizeFlutterSettings() {
    try {
      // تحسين إعدادات الرسم
      WidgetsBinding.instance.addPostFrameCallback((_) {
        // تحسين أداء الرسم
        WidgetsBinding.instance.buildOwner?.focusManager.highlightStrategy =
            FocusHighlightStrategy.alwaysTraditional;
      });

      dev.log('⚙️ Flutter settings optimized', name: _logTag);
    } catch (e) {
      dev.log('❌ Failed to optimize Flutter settings: $e', name: _logTag);
    }
  }

  /// تنظيف دوري للذاكرة
  static void startPeriodicCleanup() {
    if (!_isInitialized) {
      dev.log('⚠️ Performance not initialized, skipping periodic cleanup',
          name: _logTag);
      return;
    }

    // تنظيف كل 5 دقائق
    Stream.periodic(const Duration(minutes: 5)).listen((_) {
      dev.log('🧹 Starting periodic cleanup...', name: _logTag);
      MemoryOptimizer.cleanupMemory();
    });
  }

  /// إحصائيات الأداء
  static Map<String, dynamic> getPerformanceStats() {
    if (!_isInitialized) {
      return {'initialized': false};
    }

    return {
      'initialized': true,
      'imageCache': ImageCacheOptimizer.getCacheStats(),
      'timestamp': DateTime.now().toIso8601String(),
    };
  }

  /// إعادة تعيين التحسينات
  static Future<void> reset() async {
    try {
      dev.log('🔄 Resetting performance optimizations...', name: _logTag);

      // مسح كاش الصور
      ImageCacheOptimizer.clearImageCache();

      // تنظيف الذاكرة
      await MemoryOptimizer.cleanupMemory();

      _isInitialized = false;
      dev.log('✅ Performance optimizations reset', name: _logTag);
    } catch (e) {
      dev.log('❌ Failed to reset performance optimizations: $e', name: _logTag);
    }
  }
}

/// Widget مُحسن للأداء العام
class PerformanceOptimizedApp extends StatelessWidget {
  final Widget child;
  final bool enablePeriodicCleanup;

  const PerformanceOptimizedApp({
    super.key,
    required this.child,
    this.enablePeriodicCleanup = true,
  });

  @override
  Widget build(BuildContext context) {
    // بدء التنظيف الدوري إذا كان مفعلاً
    if (enablePeriodicCleanup) {
      PerformanceInitializer.startPeriodicCleanup();
    }

    return child;
  }
}

/// مساعد لتحسين الأداء في الصفحات
class PagePerformanceHelper {
  static const String _logTag = 'PagePerformanceHelper';

  /// تحسين صفحة معينة
  static Widget optimizePage({
    required Widget child,
    String? pageName,
    bool addRepaintBoundary = true,
    bool enableMemoryMonitoring = true,
  }) {
    if (pageName != null) {
      dev.log('🎯 Optimizing page: $pageName', name: _logTag);
    }

    Widget optimized = child;

    if (addRepaintBoundary) {
      optimized = RepaintBoundary(child: optimized);
    }

    if (enableMemoryMonitoring) {
      optimized = _MemoryMonitoringWidget(child: optimized);
    }

    return optimized;
  }
}

/// Widget لمراقبة الذاكرة
class _MemoryMonitoringWidget extends StatefulWidget {
  final Widget child;

  const _MemoryMonitoringWidget({required this.child});

  @override
  State<_MemoryMonitoringWidget> createState() =>
      _MemoryMonitoringWidgetState();
}

class _MemoryMonitoringWidgetState extends State<_MemoryMonitoringWidget>
    with MemoryOptimizedStateMixin {
  @override
  Widget build(BuildContext context) {
    return widget.child;
  }
}
