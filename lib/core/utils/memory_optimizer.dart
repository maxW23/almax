import 'package:flutter/material.dart';
import 'dart:developer' as dev;
import 'package:lklk/core/utils/image_cache_optimizer.dart';

/// مُحسِّن الذاكرة - تحسينات بسيطة وآمنة
class MemoryOptimizer {
  static const String _logTag = 'MemoryOptimizer';

  /// تنظيف الذاكرة العام
  static Future<void> cleanupMemory() async {
    try {
      dev.log('🧹 Starting memory cleanup...', name: _logTag);

      // تنظيف كاش الصور
      PaintingBinding.instance.imageCache.clear();
      PaintingBinding.instance.imageCache.clearLiveImages();

      // إجبار garbage collection
      await _forceGarbageCollection();

      dev.log('✅ Memory cleanup completed', name: _logTag);
    } catch (e) {
      dev.log('❌ Memory cleanup failed: $e', name: _logTag);
    }
  }

  /// إجبار garbage collection
  static Future<void> _forceGarbageCollection() async {
    try {
      // محاولة إجبار GC عبر إنشاء وحذف كائنات
      for (int i = 0; i < 3; i++) {
        final temp = List.generate(1000, (index) => index);
        temp.clear();
        await Future.delayed(const Duration(milliseconds: 10));
      }
      dev.log('🗑️ Forced garbage collection', name: _logTag);
    } catch (e) {
      dev.log('❌ Failed to force GC: $e', name: _logTag);
    }
  }

  /// تحسين Widget للذاكرة
  static Widget memoryOptimizedWidget({
    required Widget child,
    bool addRepaintBoundary = true,
    bool addAutomaticKeepAlive = false,
  }) {
    Widget optimized = child;

    if (addRepaintBoundary) {
      optimized = RepaintBoundary(child: optimized);
    }

    if (addAutomaticKeepAlive) {
      optimized = AutomaticKeepAlive(child: optimized);
    }

    return optimized;
  }

  /// تحسين القوائم الطويلة
  static Widget memoryOptimizedList({
    required int itemCount,
    required IndexedWidgetBuilder itemBuilder,
    ScrollController? controller,
    Axis scrollDirection = Axis.vertical,
    bool shrinkWrap = false,
    EdgeInsetsGeometry? padding,
  }) {
    return ListView.builder(
      controller: controller,
      scrollDirection: scrollDirection,
      shrinkWrap: shrinkWrap,
      padding: padding,
      cacheExtent: 200.0, // تقليل cache extent لتوفير الذاكرة
      itemCount: itemCount,
      itemBuilder: (context, index) {
        return memoryOptimizedWidget(
          child: itemBuilder(context, index),
          addRepaintBoundary: true,
        );
      },
    );
  }

  /// تحسين الصور للذاكرة
  static Widget memoryOptimizedImage({
    required String imageUrl,
    double? width,
    double? height,
    BoxFit fit = BoxFit.cover,
    Widget? placeholder,
    Widget? errorWidget,
  }) {
    return ImageCacheOptimizer.optimizedImage(
      imageUrl: imageUrl,
      width: width,
      height: height,
      fit: fit,
      placeholder: placeholder,
      errorWidget: errorWidget,
    );
  }
}

/// مراقب استهلاك الذاكرة
class MemoryMonitor {
  static const String _logTag = 'MemoryMonitor';
  static DateTime? _lastCheck;
  static const Duration _checkInterval = Duration(seconds: 30);

  /// فحص استهلاك الذاكرة
  static void checkMemoryUsage() {
    final now = DateTime.now();
    if (_lastCheck != null && now.difference(_lastCheck!) < _checkInterval) {
      return;
    }

    _lastCheck = now;

    try {
      final imageCache = PaintingBinding.instance.imageCache;
      final stats = {
        'imageCache_size': imageCache.currentSize,
        'imageCache_bytes': imageCache.currentSizeBytes,
        'imageCache_live': imageCache.liveImageCount,
        'imageCache_pending': imageCache.pendingImageCount,
      };

      dev.log('📊 Memory stats: $stats', name: _logTag);

      // تنظيف تلقائي إذا تجاوز الحد
      if (imageCache.currentSizeBytes > (30 << 20)) {
        // 30 MB
        dev.log('⚠️ High memory usage detected, cleaning up...', name: _logTag);
        MemoryOptimizer.cleanupMemory();
      }
    } catch (e) {
      dev.log('❌ Failed to check memory: $e', name: _logTag);
    }
  }
}

/// Mixin لتحسين الذاكرة في StatefulWidget
mixin MemoryOptimizedStateMixin<T extends StatefulWidget> on State<T> {
  @override
  void initState() {
    super.initState();
    MemoryMonitor.checkMemoryUsage();
  }

  @override
  void dispose() {
    // تنظيف الموارد عند التخلص من الـ Widget
    super.dispose();
  }

  /// تنظيف مخصص للـ Widget
  void cleanupResources() {
    // يمكن للـ Widget المحدد تنفيذ تنظيف مخصص هنا
  }
}

/// ScrollController محسن للذاكرة
class MemoryOptimizedScrollController extends ScrollController {
  static const String _logTag = 'MemoryOptimizedScrollController';

  DateTime? _lastMemoryCheck;
  static const Duration _memoryCheckInterval = Duration(seconds: 10);

  @override
  void addListener(VoidCallback listener) {
    super.addListener(() {
      listener();
      _checkMemoryPeriodically();
    });
  }

  void _checkMemoryPeriodically() {
    final now = DateTime.now();
    if (_lastMemoryCheck == null ||
        now.difference(_lastMemoryCheck!) > _memoryCheckInterval) {
      _lastMemoryCheck = now;
      MemoryMonitor.checkMemoryUsage();
    }
  }

  @override
  void dispose() {
    dev.log('🗑️ Disposing MemoryOptimizedScrollController', name: _logTag);
    super.dispose();
  }
}
