import 'dart:async';
import 'dart:collection';
import 'dart:developer' as dev;
import 'dart:math' as math;

import 'package:lklk/features/room/presentation/views/widgets/gift_animation_data.dart';

/// 🎯 مدير هدايا الحظ الاحترافي المحسّن
/// يدعم: أولويات ذكية، معالجة سريعة، تأثيرات combo، أداء عالي
class EnhancedLuckyGiftManager {
  static final EnhancedLuckyGiftManager _instance =
      EnhancedLuckyGiftManager._internal();
  factory EnhancedLuckyGiftManager() => _instance;
  EnhancedLuckyGiftManager._internal();

  // ==================== الإعدادات الاحترافية ====================

  /// سرعة المعالجة الفائقة - 100ms فقط لحركة سلسة
  static const Duration processingInterval = Duration(milliseconds: 100);

  /// الحد الأقصى للهدايا المتزامنة - مُحسّن للأداء
  static const int maxConcurrentGifts = 5;

  /// مدة انتظار combo - للهدايا المتتالية
  static const Duration comboDuration = Duration(seconds: 3);

  /// عامل تسريع combo
  static const double comboSpeedMultiplier = 1.5;

  // ==================== هياكل البيانات المتقدمة ====================

  /// رتل الأولويات - PriorityQueue للترتيب الذكي
  final SplayTreeSet<PriorityGiftItem> _priorityQueue =
      SplayTreeSet<PriorityGiftItem>(
    (a, b) {
      // ترتيب حسب الأولوية ثم الوقت
      if (a.priority != b.priority) {
        return b.priority.compareTo(a.priority); // أولوية أعلى أولاً
      }
      return a.timestamp.compareTo(b.timestamp); // الأقدم أولاً
    },
  );

  /// الهدايا قيد العرض
  final Map<String, DisplayingGift> _displayingGifts = {};

  /// نظام Combo للهدايا المتتالية
  final Map<String, ComboInfo> _comboTracker = {};

  /// مؤقتات المعالجة
  Timer? _processingTimer;
  Timer? _comboCleanupTimer;

  /// مراقب الأداء
  final PerformanceMonitor _performanceMonitor = PerformanceMonitor();

  /// callbacks
  final List<Function(PriorityGiftItem)> _onGiftDisplayCallbacks = [];
  final List<Function(String)> _onGiftCompleteCallbacks = [];
  final List<Function(ComboInfo)> _onComboCallbacks = [];

  // ==================== الوظائف الأساسية المحسّنة ====================

  /// إضافة هدية بنظام الأولويات الذكي
  void addEnhancedLuckyGift({
    required String giftId,
    required String senderId,
    required String senderName,
    required String receiverId,
    required String receiverName,
    required String imageUrl,
    required int count,
    required GiftAnimationData animationData,
    bool isVip = false,
    String? specialEffect,
    Map<String, dynamic>? metadata,
  }) {
    // حساب الأولوية الذكية
    final priority = _calculatePriority(
      count: count,
      isVip: isVip,
      hasSpecialEffect: specialEffect != null,
      senderId: senderId,
    );

    // التحقق من combo
    final comboLevel = _updateCombo(senderId, senderName);

    // إنشاء عنصر الهدية بالأولوية
    final queueItem = PriorityGiftItem(
      id: '${giftId}_${DateTime.now().millisecondsSinceEpoch}_${math.Random().nextInt(1000)}',
      giftId: giftId,
      senderId: senderId,
      senderName: senderName,
      receiverId: receiverId,
      receiverName: receiverName,
      imageUrl: imageUrl,
      count: count,
      animationData: animationData,
      timestamp: DateTime.now(),
      priority: priority,
      comboLevel: comboLevel,
      specialEffect: specialEffect,
      metadata: metadata ?? {},
    );

    _priorityQueue.add(queueItem);

    dev.log(
        '🎯 [ENHANCED] Added gift with priority: $priority, combo: $comboLevel',
        name: 'EnhancedLucky');
    dev.log('📊 [ENHANCED] Queue size: ${_priorityQueue.length}',
        name: 'EnhancedLucky');

    // بدء المعالجة السريعة
    _startFastProcessing();
  }

  /// حساب الأولوية الذكية
  int _calculatePriority({
    required int count,
    required bool isVip,
    required bool hasSpecialEffect,
    required String senderId,
  }) {
    int priority = 0;

    // أولوية VIP
    if (isVip) priority += 1000;

    // أولوية حسب العدد
    if (count >= 999) {
      priority += 500;
    } else if (count >= 99) {
      priority += 300;
    } else if (count >= 9) {
      priority += 100;
    }

    // أولوية التأثيرات الخاصة
    if (hasSpecialEffect) priority += 200;

    // أولوية combo
    if (_comboTracker.containsKey(senderId)) {
      priority += _comboTracker[senderId]!.level * 50;
    }

    return priority;
  }

  /// تحديث نظام Combo
  int _updateCombo(String senderId, String senderName) {
    final now = DateTime.now();

    if (_comboTracker.containsKey(senderId)) {
      final combo = _comboTracker[senderId]!;

      // التحقق من انتهاء وقت combo
      if (now.difference(combo.lastGiftTime) <= comboDuration) {
        // زيادة مستوى combo
        combo.level++;
        combo.lastGiftTime = now;
        combo.totalGifts++;

        // إشعار بـ combo
        if (combo.level >= 3) {
          _notifyCombo(combo);
        }

        dev.log('🔥 [COMBO] Level ${combo.level} for $senderName!',
            name: 'EnhancedLucky');

        return combo.level;
      }
    }

    // بدء combo جديد
    _comboTracker[senderId] = ComboInfo(
      senderId: senderId,
      senderName: senderName,
      level: 1,
      lastGiftTime: now,
      totalGifts: 1,
    );

    // تنظيف combos القديمة
    _scheduleComboCleanup();

    return 1;
  }

  /// معالجة سريعة ومحسّنة للرتل
  void _startFastProcessing() {
    if (_processingTimer?.isActive == true) return;

    dev.log('⚡ [ENHANCED] Starting FAST processing', name: 'EnhancedLucky');

    _processingTimer = Timer.periodic(processingInterval, (timer) {
      _processFastQueue();
    });
  }

  /// معالجة الرتل بسرعة فائقة
  void _processFastQueue() {
    // مراقبة الأداء
    _performanceMonitor.startFrame();

    // إذا كان الرتل فارغ، أوقف المعالجة
    if (_priorityQueue.isEmpty) {
      _stopProcessing();
      _performanceMonitor.endFrame();
      return;
    }

    // معالجة متعددة في نفس الإطار إذا أمكن
    int processed = 0;
    final maxPerFrame = _performanceMonitor.canProcessMore() ? 2 : 1;

    while (processed < maxPerFrame &&
        _displayingGifts.length < maxConcurrentGifts &&
        _priorityQueue.isNotEmpty) {
      final nextGift = _priorityQueue.first;
      _priorityQueue.remove(nextGift);

      // تطبيق تسريع combo
      if (nextGift.comboLevel > 1) {
        nextGift.animationData.duration = Duration(
            milliseconds: (nextGift.animationData.duration.inMilliseconds /
                    (1 + (nextGift.comboLevel * 0.2)))
                .round());
      }

      _displayingGifts[nextGift.id] = DisplayingGift(
        item: nextGift,
        startTime: DateTime.now(),
      );

      dev.log('⚡ [ENHANCED] Displaying priority gift: ${nextGift.priority}',
          name: 'EnhancedLucky');

      _notifyDisplay(nextGift);
      processed++;
    }

    _performanceMonitor.endFrame();

    // تحذير إذا انخفض الأداء
    if (_performanceMonitor.fps < 30) {
      dev.log('⚠️ [PERFORMANCE] Low FPS: ${_performanceMonitor.fps}',
          name: 'EnhancedLucky');
    }
  }

  /// إكمال عرض هدية
  void completeGift(String giftId) {
    if (_displayingGifts.remove(giftId) != null) {
      dev.log('✅ [ENHANCED] Completed gift: $giftId', name: 'EnhancedLucky');

      _notifyComplete(giftId);

      // معالجة فورية للتالي
      if (_priorityQueue.isNotEmpty) {
        _processFastQueue();
      }
    }
  }

  // ==================== نظام الإشعارات ====================

  void _notifyDisplay(PriorityGiftItem item) {
    for (final callback in _onGiftDisplayCallbacks) {
      try {
        callback(item);
      } catch (e) {
        dev.log('❌ [ENHANCED] Display callback error: $e',
            name: 'EnhancedLucky');
      }
    }
  }

  void _notifyComplete(String giftId) {
    for (final callback in _onGiftCompleteCallbacks) {
      try {
        callback(giftId);
      } catch (e) {
        dev.log('❌ [ENHANCED] Complete callback error: $e',
            name: 'EnhancedLucky');
      }
    }
  }

  void _notifyCombo(ComboInfo combo) {
    for (final callback in _onComboCallbacks) {
      try {
        callback(combo);
      } catch (e) {
        dev.log('❌ [ENHANCED] Combo callback error: $e', name: 'EnhancedLucky');
      }
    }
  }

  // ==================== إدارة الموارد ====================

  void _stopProcessing() {
    _processingTimer?.cancel();
    _processingTimer = null;
    dev.log('⏹️ [ENHANCED] Stopped processing', name: 'EnhancedLucky');
  }

  void _scheduleComboCleanup() {
    _comboCleanupTimer?.cancel();
    _comboCleanupTimer = Timer(const Duration(seconds: 10), () {
      final now = DateTime.now();
      _comboTracker.removeWhere(
          (_, combo) => now.difference(combo.lastGiftTime) > comboDuration);
    });
  }

  // ==================== واجهات عامة ====================

  void addDisplayListener(Function(PriorityGiftItem) callback) {
    _onGiftDisplayCallbacks.add(callback);
  }

  void addCompleteListener(Function(String) callback) {
    _onGiftCompleteCallbacks.add(callback);
  }

  void addComboListener(Function(ComboInfo) callback) {
    _onComboCallbacks.add(callback);
  }

  EnhancedQueueStatus getStatus() {
    return EnhancedQueueStatus(
      queueSize: _priorityQueue.length,
      displayingCount: _displayingGifts.length,
      isProcessing: _processingTimer?.isActive == true,
      topPriorityGifts: _priorityQueue.take(5).toList(),
      activeCombos: Map.from(_comboTracker),
      performanceFps: _performanceMonitor.fps,
    );
  }

  void dispose() {
    _stopProcessing();
    _comboCleanupTimer?.cancel();
    _priorityQueue.clear();
    _displayingGifts.clear();
    _comboTracker.clear();
    _onGiftDisplayCallbacks.clear();
    _onGiftCompleteCallbacks.clear();
    _onComboCallbacks.clear();
  }
}

// ==================== نماذج البيانات المحسّنة ====================

/// عنصر هدية بنظام الأولويات
class PriorityGiftItem {
  final String id;
  final String giftId;
  final String senderId;
  final String senderName;
  final String receiverId;
  final String receiverName;
  final String imageUrl;
  final int count;
  final GiftAnimationData animationData;
  final DateTime timestamp;
  final int priority;
  final int comboLevel;
  final String? specialEffect;
  final Map<String, dynamic> metadata;

  PriorityGiftItem({
    required this.id,
    required this.giftId,
    required this.senderId,
    required this.senderName,
    required this.receiverId,
    required this.receiverName,
    required this.imageUrl,
    required this.count,
    required this.animationData,
    required this.timestamp,
    required this.priority,
    required this.comboLevel,
    this.specialEffect,
    required this.metadata,
  });
}

/// معلومات الهدية قيد العرض
class DisplayingGift {
  final PriorityGiftItem item;
  final DateTime startTime;

  DisplayingGift({
    required this.item,
    required this.startTime,
  });
}

/// معلومات Combo
class ComboInfo {
  final String senderId;
  final String senderName;
  int level;
  DateTime lastGiftTime;
  int totalGifts;

  ComboInfo({
    required this.senderId,
    required this.senderName,
    required this.level,
    required this.lastGiftTime,
    required this.totalGifts,
  });
}

/// حالة الرتل المحسّنة
class EnhancedQueueStatus {
  final int queueSize;
  final int displayingCount;
  final bool isProcessing;
  final List<PriorityGiftItem> topPriorityGifts;
  final Map<String, ComboInfo> activeCombos;
  final double performanceFps;

  EnhancedQueueStatus({
    required this.queueSize,
    required this.displayingCount,
    required this.isProcessing,
    required this.topPriorityGifts,
    required this.activeCombos,
    required this.performanceFps,
  });
}

/// مراقب الأداء
class PerformanceMonitor {
  final List<int> _frameTimes = [];
  DateTime? _frameStart;

  double get fps {
    if (_frameTimes.isEmpty) return 60.0;
    final avg = _frameTimes.reduce((a, b) => a + b) / _frameTimes.length;
    return 1000 / avg;
  }

  void startFrame() {
    _frameStart = DateTime.now();
  }

  void endFrame() {
    if (_frameStart != null) {
      final duration = DateTime.now().difference(_frameStart!).inMilliseconds;
      _frameTimes.add(duration);
      if (_frameTimes.length > 60) _frameTimes.removeAt(0);
    }
  }

  bool canProcessMore() {
    return fps >= 50;
  }
}
