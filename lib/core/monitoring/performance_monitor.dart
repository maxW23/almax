import 'dart:async';
import 'dart:developer' as dev;
import 'package:flutter/scheduler.dart';

/// مراقب أداء احترافي للتطبيق
class PerformanceMonitor {
  static final PerformanceMonitor _instance = PerformanceMonitor._internal();
  factory PerformanceMonitor() => _instance;
  PerformanceMonitor._internal();

  // عتبات الأداء
  static const int _targetFPS = 60;
  static const int _warningFPS = 45;
  static const int _criticalFPS = 30;
  static const int _maxMemoryMB = 300;
  static const int _warningMemoryMB = 200;

  // متغيرات المراقبة
  final Map<String, Stopwatch> _timers = {};
  final Map<String, List<int>> _metrics = {};
  Timer? _memoryMonitorTimer;
  int _frameCount = 0;
  DateTime _lastFPSCheck = DateTime.now();

  /// بدء مراقبة الأداء
  void startMonitoring() {
    // مراقبة FPS
    SchedulerBinding.instance.addPersistentFrameCallback(_onFrame);

    // مراقبة الذاكرة كل 5 ثواني
    _memoryMonitorTimer = Timer.periodic(const Duration(seconds: 5), (_) {
      _checkMemoryUsage();
    });

    dev.log('🚀 Performance monitoring started', name: 'PerformanceMonitor');
  }

  /// إيقاف المراقبة
  void stopMonitoring() {
    _memoryMonitorTimer?.cancel();
    _memoryMonitorTimer = null;
    dev.log('🛑 Performance monitoring stopped', name: 'PerformanceMonitor');
  }

  /// بدء قياس عملية
  void startMeasure(String operation) {
    _timers[operation] = Stopwatch()..start();
  }

  /// إنهاء قياس عملية
  Duration? endMeasure(String operation) {
    final stopwatch = _timers.remove(operation);
    if (stopwatch == null) return null;

    stopwatch.stop();
    final duration = stopwatch.elapsed;

    // حفظ المتريك
    _metrics[operation] ??= [];
    _metrics[operation]!.add(duration.inMilliseconds);

    // تحذير إذا كانت العملية بطيئة
    if (duration.inMilliseconds > 100) {
      dev.log(
        '⚠️ Slow operation: $operation took ${duration.inMilliseconds}ms',
        name: 'PerformanceMonitor',
      );
    }

    return duration;
  }

  /// قياس FPS
  void _onFrame(Duration timestamp) {
    _frameCount++;

    final now = DateTime.now();
    final elapsed = now.difference(_lastFPSCheck);

    if (elapsed.inSeconds >= 1) {
      final fps = (_frameCount / elapsed.inSeconds).round();
      _frameCount = 0;
      _lastFPSCheck = now;

      _checkFPS(fps);
    }
  }

  /// فحص معدل الإطارات
  void _checkFPS(int fps) {
    if (fps < _criticalFPS) {
      dev.log(
        '🔴 CRITICAL: FPS dropped to $fps (target: $_targetFPS)',
        name: 'PerformanceMonitor',
      );
      _onPerformanceIssue(PerformanceIssue.criticalFPS, fps);
    } else if (fps < _warningFPS) {
      dev.log(
        '🟡 WARNING: FPS at $fps (target: $_targetFPS)',
        name: 'PerformanceMonitor',
      );
    }
  }

  /// فحص استخدام الذاكرة
  void _checkMemoryUsage() {
    // في الإنتاج، استخدم platform channels للحصول على معلومات الذاكرة الحقيقية
    // هنا مثال مبسط
    final memoryInfo = _getMemoryInfo();

    if (memoryInfo.usedMB > _maxMemoryMB) {
      dev.log(
        '🔴 CRITICAL: Memory usage ${memoryInfo.usedMB}MB exceeds limit $_maxMemoryMB MB',
        name: 'PerformanceMonitor',
      );
      _onPerformanceIssue(PerformanceIssue.highMemory, memoryInfo.usedMB);
    } else if (memoryInfo.usedMB > _warningMemoryMB) {
      dev.log(
        '🟡 WARNING: Memory usage ${memoryInfo.usedMB}MB approaching limit',
        name: 'PerformanceMonitor',
      );
    }
  }

  /// الحصول على معلومات الذاكرة
  MemoryInfo _getMemoryInfo() {
    // في الإنتاج، استخدم:
    // - iOS: os_proc_available_memory
    // - Android: ActivityManager.getMemoryInfo

    // مثال مبسط للتطوير
    return MemoryInfo(
      usedMB: 150, // قيمة وهمية
      totalMB: 512,
    );
  }

  /// معالجة مشاكل الأداء
  void _onPerformanceIssue(PerformanceIssue issue, int value) {
    switch (issue) {
      case PerformanceIssue.criticalFPS:
        // تقليل جودة الأنيميشن تلقائياً
        _reduceAnimationQuality();
        break;
      case PerformanceIssue.highMemory:
        // تنظيف الكاش وتحرير الذاكرة
        _clearCaches();
        break;
    }
  }

  void _reduceAnimationQuality() {
    // تقليل معدل الأنيميشن
    // تقليل عدد الهدايا المتزامنة
    // تعطيل التأثيرات غير الضرورية
    dev.log('📉 Reducing animation quality to improve performance',
        name: 'PerformanceMonitor');
  }

  void _clearCaches() {
    // تنظيف كاش الصور
    // تنظيف البيانات القديمة
    // استدعاء garbage collector
    dev.log('🧹 Clearing caches to free memory', name: 'PerformanceMonitor');
  }

  /// الحصول على تقرير الأداء
  Map<String, dynamic> getPerformanceReport() {
    final report = <String, dynamic>{};

    // حساب متوسطات العمليات
    _metrics.forEach((operation, durations) {
      if (durations.isNotEmpty) {
        final average = durations.reduce((a, b) => a + b) / durations.length;
        final max = durations.reduce((a, b) => a > b ? a : b);
        final min = durations.reduce((a, b) => a < b ? a : b);

        report[operation] = {
          'average': average.round(),
          'max': max,
          'min': min,
          'count': durations.length,
        };
      }
    });

    return report;
  }

  /// طباعة تقرير الأداء
  void printReport() {
    final report = getPerformanceReport();

    dev.log('📊 === Performance Report ===', name: 'PerformanceMonitor');
    report.forEach((operation, metrics) {
      dev.log(
        '  $operation: avg=${metrics['average']}ms, '
        'max=${metrics['max']}ms, count=${metrics['count']}',
        name: 'PerformanceMonitor',
      );
    });
  }
}

/// معلومات الذاكرة
class MemoryInfo {
  final int usedMB;
  final int totalMB;

  MemoryInfo({required this.usedMB, required this.totalMB});

  double get usagePercentage => (usedMB / totalMB) * 100;
}

/// أنواع مشاكل الأداء
enum PerformanceIssue {
  criticalFPS,
  highMemory,
}
