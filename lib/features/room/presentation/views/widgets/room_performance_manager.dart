import 'dart:async';
import 'dart:collection';
import 'dart:developer' as dev;
import 'package:flutter/material.dart';
import 'package:flutter/scheduler.dart';

/// مدير أداء الغرفة المحسن لـ 500+ مستخدم
class RoomPerformanceManager {
  static final RoomPerformanceManager _instance =
      RoomPerformanceManager._internal();
  factory RoomPerformanceManager() => _instance;
  RoomPerformanceManager._internal();

  // إعدادات الأداء المثلى
  static const int maxConcurrentGifts = 10; // حد أقصى للهدايا المتزامنة
  static const int maxVisibleMessages = 100; // حد أقصى للرسائل المرئية
  static const int maxCachedMessages = 200; // حد أقصى للرسائل المخزنة
  static const int maxConcurrentAudioStreams = 20; // حد أقصى للصوتيات المتزامنة
  static const int maxUsersInMemory = 100; // حد أقصى للمستخدمين في الذاكرة
  static const int batchUpdateInterval = 100; // فترة التحديث بالميلي ثانية

  // مؤشرات الأداء
  final PerformanceMetrics metrics = PerformanceMetrics();

  // مدير التحديثات المجمعة
  final BatchUpdateManager batchManager = BatchUpdateManager();

  // مدير ذاكرة التخزين المؤقت
  final MemoryCacheManager cacheManager = MemoryCacheManager();

  // مدير معدل الإطارات
  final FrameRateOptimizer frameOptimizer = FrameRateOptimizer();

  /// تهيئة مدير الأداء عند دخول الغرفة
  void initializeForRoom(int userCount) {
    // ضبط إعدادات الأداء بناءً على عدد المستخدمين
    if (userCount > 300) {
      enableHighDensityMode();
    } else if (userCount > 100) {
      enableMediumDensityMode();
    } else {
      enableNormalMode();
    }

    // بدء مراقبة الأداء
    metrics.startMonitoring();
    batchManager.start();
    frameOptimizer.optimize();
  }

  /// وضع الكثافة العالية (300+ مستخدم)
  void enableHighDensityMode() {
    dev.log('🚀 Enabling High Density Mode for 300+ users',
        name: 'RoomPerformanceManager');

    // تقليل معدل التحديث
    batchManager.updateInterval = 200;

    // تقليل الحد الأقصى للعناصر المرئية - آخر 25 رسالة فقط
    cacheManager.maxVisibleItems = 25;

    // تعطيل التأثيرات غير الضرورية
    frameOptimizer.disableComplexAnimations = true;
  }

  /// وضع الكثافة المتوسطة (100-300 مستخدم)
  void enableMediumDensityMode() {
    dev.log('⚡ Enabling Medium Density Mode for 100-300 users',
        name: 'RoomPerformanceManager');

    batchManager.updateInterval = 150;
    cacheManager.maxVisibleItems = 25; // آخر 25 رسالة
    frameOptimizer.disableComplexAnimations = false;
  }

  /// الوضع العادي (<100 مستخدم)
  void enableNormalMode() {
    dev.log('✨ Enabling Normal Mode for <100 users',
        name: 'RoomPerformanceManager');

    batchManager.updateInterval = 100;
    cacheManager.maxVisibleItems = 25; // آخر 25 رسالة
    frameOptimizer.disableComplexAnimations = false;
  }

  /// تنظيف عند الخروج من الغرفة
  void dispose() {
    metrics.stopMonitoring();
    batchManager.stop();
    cacheManager.clear();
  }
}

/// مدير التحديثات المجمعة
class BatchUpdateManager {
  Timer? _updateTimer;
  final Queue<VoidCallback> _pendingUpdates = Queue();
  int updateInterval = 100;
  bool _isProcessing = false;

  void start() {
    _updateTimer?.cancel();
    _updateTimer = Timer.periodic(
      Duration(milliseconds: updateInterval),
      (_) => _processBatch(),
    );
  }

  void stop() {
    _updateTimer?.cancel();
    _pendingUpdates.clear();
  }

  void addUpdate(VoidCallback update) {
    if (_pendingUpdates.length < 100) {
      _pendingUpdates.add(update);
    }
  }

  void _processBatch() {
    if (_isProcessing || _pendingUpdates.isEmpty) return;

    _isProcessing = true;

    // معالجة دفعة من التحديثات
    SchedulerBinding.instance.scheduleFrameCallback((_) {
      final batch = <VoidCallback>[];
      for (int i = 0; i < 10 && _pendingUpdates.isNotEmpty; i++) {
        batch.add(_pendingUpdates.removeFirst());
      }

      for (final update in batch) {
        try {
          update();
        } catch (e) {
          dev.log('Batch update error: $e', name: 'BatchManager');
        }
      }

      _isProcessing = false;
    });
  }
}

/// مدير ذاكرة التخزين المؤقت
class MemoryCacheManager {
  int maxVisibleItems = 100;
  final Map<String, dynamic> _cache = {};
  final Queue<String> _cacheOrder = Queue();

  void add(String key, dynamic value) {
    if (_cache.length >= maxVisibleItems) {
      final oldKey = _cacheOrder.removeFirst();
      _cache.remove(oldKey);
    }

    _cache[key] = value;
    _cacheOrder.add(key);
  }

  dynamic get(String key) => _cache[key];

  void clear() {
    _cache.clear();
    _cacheOrder.clear();
  }

  int get size => _cache.length;
}

/// محسن معدل الإطارات
class FrameRateOptimizer {
  bool disableComplexAnimations = false;
  int _frameCount = 0;
  DateTime _lastCheck = DateTime.now();

  void optimize() {
    SchedulerBinding.instance.addPersistentFrameCallback((_) {
      _frameCount++;
      final now = DateTime.now();
      final elapsed = now.difference(_lastCheck).inMilliseconds;

      if (elapsed >= 1000) {
        final fps = (_frameCount * 1000 / elapsed).round();

        // تعديل الإعدادات بناءً على معدل الإطارات
        if (fps < 30) {
          disableComplexAnimations = true;
          dev.log('⚠️ Low FPS detected: $fps - Disabling animations',
              name: 'PerformanceMonitor');
        } else if (fps > 50) {
          disableComplexAnimations = false;
        }

        _frameCount = 0;
        _lastCheck = now;
      }
    });
  }
}

/// مقاييس الأداء
class PerformanceMetrics {
  int messageCount = 0;
  int giftCount = 0;
  int userCount = 0;
  int memoryUsage = 0;
  DateTime _startTime = DateTime.now();
  Timer? _metricsTimer;

  void startMonitoring() {
    _startTime = DateTime.now();
    _metricsTimer = Timer.periodic(const Duration(seconds: 10), (_) {
      _printMetrics();
    });
  }

  void stopMonitoring() {
    _metricsTimer?.cancel();
  }

  void _printMetrics() {
    final uptime = DateTime.now().difference(_startTime);
    dev.log('''
📊 Room Performance Metrics:
├─ Uptime: ${uptime.inMinutes} minutes
├─ Messages: $messageCount
├─ Gifts: $giftCount
├─ Users: $userCount
└─ Memory: ${(memoryUsage / 1024 / 1024).toStringAsFixed(2)} MB
    ''');
  }

  void recordMessage() => messageCount++;
  void recordGift() => giftCount++;
  void updateUserCount(int count) => userCount = count;
}

/// Pool للهدايا لإعادة الاستخدام
class GiftAnimationPool {
  static const int poolSize = 20;
  final List<Widget> _availableAnimations = [];
  final List<Widget> _activeAnimations = [];

  GiftAnimationPool() {
    // إنشاء pool مسبق
    for (int i = 0; i < poolSize; i++) {
      _availableAnimations.add(_createGiftAnimation());
    }
  }

  Widget getAnimation() {
    if (_availableAnimations.isEmpty) {
      return _createGiftAnimation();
    }

    final animation = _availableAnimations.removeLast();
    _activeAnimations.add(animation);
    return animation;
  }

  void releaseAnimation(Widget animation) {
    _activeAnimations.remove(animation);
    if (_availableAnimations.length < poolSize) {
      _availableAnimations.add(animation);
    }
  }

  Widget _createGiftAnimation() {
    // إنشاء widget هدية قابل لإعادة الاستخدام
    return const SizedBox(); // سيتم استبدالها بـ GiftAnimationWidget الفعلي
  }

  void dispose() {
    _availableAnimations.clear();
    _activeAnimations.clear();
  }
}
