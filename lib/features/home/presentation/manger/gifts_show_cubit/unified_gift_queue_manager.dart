// unified_gift_queue_manager.dart
import 'dart:async';
import 'dart:developer' as dev;

import 'package:equatable/equatable.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:lklk/features/room/domain/entities/gift_entity.dart';
import 'package:lklk/features/room/presentation/views/widgets/gift_animation_data.dart';

part 'unified_gift_queue_state.dart';

/// مدير رتل الهدايا الموحد - يجمع كل الوظائف في مكان واحد
class UnifiedGiftQueueManager extends Cubit<UnifiedGiftQueueState> {
  UnifiedGiftQueueManager() : super(UnifiedGiftQueueInitial());

  // ===== الرتل المنفصلة لكل نوع هدية =====
  final Map<GiftType, List<GiftQueueItem>> _typeQueues = {
    GiftType.entry: [],
    GiftType.lucky: [],
    GiftType.popular: [],
    GiftType.normal: [],
  };

  // ===== رتل الأنيميشن الطائر =====
  final List<GiftAnimationData> _activeAnimations = [];
  final List<GiftAnimationData> _animationQueue = [];

  // ===== حالة المعالجة =====
  final Map<GiftType, bool> _isProcessing = {
    GiftType.entry: false,
    GiftType.lucky: false,
    GiftType.popular: false,
    GiftType.normal: false,
  };

  // ===== الإعدادات =====
  static const int maxConcurrentAnimations = 6;
  static const Map<GiftType, int> typePriority = {
    GiftType.popular: 1, // أعلى أولوية
    GiftType.lucky: 2,
    GiftType.entry: 3,
    GiftType.normal: 4, // أقل أولوية
  };

  // ===== الدالة الرئيسية لإضافة الهدايا =====
  void addGift({
    required GiftEntity gift,
    required List<String> targetIds,
    GiftAnimationData? animationData,
  }) {
    final giftType = _getGiftType(gift.giftType);

    // Lucky: تخطّي الرتل بالكامل للسماح بالتكديس المتوازي
    if (giftType == GiftType.lucky) {
      dev.log(
          "🎁 [UNIFIED_QUEUE] (bypass) Lucky gift received: ${gift.giftId} from ${gift.userName}",
          name: 'UnifiedGiftQueue');
      if (animationData != null) {
        // ضف مباشرة إلى الأنيميشن النشطة بدون رتل
        _activeAnimations.add(animationData);
        emit(UnifiedGiftQueueInitial());
        dev.log(
            "🎬 [UNIFIED_QUEUE] (bypass) Added lucky animation directly. Active: ${_activeAnimations.length}",
            name: 'UnifiedGiftQueue');
      }
      return; // لا معالجة ولا رتل لهدايا lucky
    }

    dev.log(
        "🎁 [UNIFIED_QUEUE] Adding ${giftType.name} gift: ${gift.giftId} "
        "from ${gift.userName}",
        name: 'UnifiedGiftQueue');

    // إضافة للرتل المناسب
    _addToTypeQueue(gift, targetIds, giftType);

    // إضافة للأنيميشن إذا توفر
    if (animationData != null) {
      _addToAnimationQueue(animationData);
    }

    // بدء المعالجة
    _startProcessingForType(giftType);
  }

  // ===== إضافة للرتل حسب النوع =====
  void _addToTypeQueue(
      GiftEntity gift, List<String> targetIds, GiftType giftType) {
    final giftCount = _calculateGiftCount(gift, giftType);

    for (int i = 0; i < giftCount; i++) {
      final queueItem = GiftQueueItem(
        gift: gift,
        targetIds: targetIds,
        giftType: giftType,
        sequenceNumber: i + 1,
        totalCount: giftCount,
        uniqueId: '${gift.giftId}_${DateTime.now().millisecondsSinceEpoch}_$i',
        timestamp: DateTime.now(),
      );

      _typeQueues[giftType]!.add(queueItem);
    }

    dev.log(
        "🎁 [UNIFIED_QUEUE] Added $giftCount ${giftType.name} gifts. "
        "Queue size: ${_typeQueues[giftType]!.length}",
        name: 'UnifiedGiftQueue');
  }

  // ===== إضافة للأنيميشن =====
  void _addToAnimationQueue(GiftAnimationData animationData) {
    if (_activeAnimations.length < maxConcurrentAnimations) {
      _activeAnimations.add(animationData);
      dev.log(
          "🎬 [UNIFIED_QUEUE] Added animation directly. "
          "Active: ${_activeAnimations.length}",
          name: 'UnifiedGiftQueue');
    } else {
      _animationQueue.add(animationData);
      dev.log(
          "🎬 [UNIFIED_QUEUE] Added animation to queue. "
          "Queue: ${_animationQueue.length}",
          name: 'UnifiedGiftQueue');
    }
  }

  // ===== بدء المعالجة لنوع معين =====
  void _startProcessingForType(GiftType giftType) {
    if (_isProcessing[giftType]!) {
      dev.log("⚠️ [UNIFIED_QUEUE] ${giftType.name} already processing",
          name: 'UnifiedGiftQueue');
      return;
    }

    if (_typeQueues[giftType]!.isEmpty) {
      dev.log("⚠️ [UNIFIED_QUEUE] ${giftType.name} queue is empty",
          name: 'UnifiedGiftQueue');
      return;
    }

    // تحقق من الأولوية
    if (!_canProcessType(giftType)) {
      dev.log("⏸️ [UNIFIED_QUEUE] ${giftType.name} blocked by higher priority",
          name: 'UnifiedGiftQueue');
      return;
    }

    dev.log("🚀 [UNIFIED_QUEUE] Starting ${giftType.name} processing",
        name: 'UnifiedGiftQueue');

    _processNextGiftForType(giftType);
  }

  // ===== معالجة الهدية التالية =====
  void _processNextGiftForType(GiftType giftType) async {
    if (_typeQueues[giftType]!.isEmpty || _isProcessing[giftType]!) {
      return;
    }

    if (!_canProcessType(giftType)) {
      return;
    }

    final current = _typeQueues[giftType]!.removeAt(0);
    _isProcessing[giftType] = true;

    dev.log(
        "🎬 [UNIFIED_QUEUE] Processing ${giftType.name} gift "
        "${current.sequenceNumber}/${current.totalCount}",
        name: 'UnifiedGiftQueue');

    try {
      // إرسال حالة العرض
      emit(UnifiedGiftShow(
        gift: current.gift,
        targetIds: current.targetIds,
        giftType: giftType,
        queueStatus: _getQueueStatus(),
      ));

      // انتظار مدة العرض
      final displayDuration = Duration(seconds: current.gift.timer) +
          const Duration(milliseconds: 350);

      await Future.delayed(displayDuration);

      // إرسال حالة الانتهاء
      emit(UnifiedGiftQueueInitial());

      // فترة تنظيف
      await Future.delayed(const Duration(milliseconds: 300));

      dev.log("✅ [UNIFIED_QUEUE] ${giftType.name} gift completed",
          name: 'UnifiedGiftQueue');
    } catch (e) {
      dev.log("❌ [UNIFIED_QUEUE] Error processing ${giftType.name} gift: $e",
          name: 'UnifiedGiftQueue');
      emit(UnifiedGiftQueueInitial());
    } finally {
      _isProcessing[giftType] = false;

      // معالجة الأولوية بعد الانتهاء
      _handlePostProcessingPriority(giftType);

      // متابعة نفس النوع إذا كان هناك المزيد
      if (_typeQueues[giftType]!.isNotEmpty) {
        Future.microtask(() => _processNextGiftForType(giftType));
      }
    }
  }

  // ===== فحص إمكانية المعالجة حسب الأولوية =====
  bool _canProcessType(GiftType giftType) {
    // popular يمكنه المعالجة دائماً (أعلى أولوية)
    if (giftType == GiftType.popular) return true;

    // entry لا يمكنه المعالجة إذا كان popular يعمل
    if (giftType == GiftType.entry && _isProcessing[GiftType.popular]!) {
      return false;
    }

    // باقي الأنواع يمكنها المعالجة
    return true;
  }

  // ===== معالجة الأولوية بعد الانتهاء =====
  void _handlePostProcessingPriority(GiftType completedType) {
    // إذا انتهى popular، أعد تشغيل entry
    if (completedType == GiftType.popular &&
        _typeQueues[GiftType.entry]!.isNotEmpty &&
        !_isProcessing[GiftType.entry]!) {
      dev.log("🔄 [UNIFIED_QUEUE] Popular finished - resuming entry",
          name: 'UnifiedGiftQueue');
      Future.microtask(() => _startProcessingForType(GiftType.entry));
    }
  }

  // ===== إنهاء الأنيميشن =====
  void onAnimationComplete(GiftAnimationData completedAnimation) {
    _activeAnimations.remove(completedAnimation);

    if (_animationQueue.isNotEmpty) {
      final next = _animationQueue.removeAt(0);
      _activeAnimations.add(next);
    }

    dev.log(
        "🎬 [UNIFIED_QUEUE] Animation completed. "
        "Active: ${_activeAnimations.length}, Queue: ${_animationQueue.length}",
        name: 'UnifiedGiftQueue');
  }

  // ===== الدوال المساعدة =====
  GiftType _getGiftType(String giftTypeString) {
    switch (giftTypeString.toLowerCase()) {
      case 'entry':
        return GiftType.entry;
      case 'lucky':
        return GiftType.lucky;
      case 'popular':
        return GiftType.popular;
      default:
        return GiftType.normal;
    }
  }

  int _calculateGiftCount(GiftEntity gift, GiftType giftType) {
    if (giftType == GiftType.lucky || giftType == GiftType.entry) {
      return 1; // هدايا الحظ والدخول تُعرض مرة واحدة
    }
    return (gift.giftCount > 0) ? gift.giftCount : 1;
  }

  QueueStatus _getQueueStatus() {
    return QueueStatus(
      typeQueues: Map.fromEntries(
        _typeQueues.entries.map((entry) => MapEntry(
              entry.key,
              TypeQueueInfo(
                size: entry.value.length,
                isProcessing: _isProcessing[entry.key]!,
                nextGift: entry.value.isNotEmpty ? entry.value.first : null,
              ),
            )),
      ),
      activeAnimations: _activeAnimations.length,
      queuedAnimations: _animationQueue.length,
    );
  }

  // ===== دوال الإدارة =====
  void clearQueueForType(GiftType giftType) {
    _typeQueues[giftType]!.clear();
    _isProcessing[giftType] = false;
    dev.log("🗑️ [UNIFIED_QUEUE] Cleared ${giftType.name} queue",
        name: 'UnifiedGiftQueue');
  }

  void clearAllQueues() {
    for (final type in GiftType.values) {
      _typeQueues[type]!.clear();
      _isProcessing[type] = false;
    }
    _activeAnimations.clear();
    _animationQueue.clear();
    emit(UnifiedGiftQueueInitial());
    dev.log("🗑️ [UNIFIED_QUEUE] All queues cleared", name: 'UnifiedGiftQueue');
  }

  void forceRemoveCurrentGift(GiftType giftType) {
    _isProcessing[giftType] = false;
    emit(UnifiedGiftQueueInitial());

    if (_typeQueues[giftType]!.isNotEmpty) {
      Future.microtask(() => _processNextGiftForType(giftType));
    }

    dev.log("🚨 [UNIFIED_QUEUE] Force removed current ${giftType.name} gift",
        name: 'UnifiedGiftQueue');
  }

  // ===== Getters للمراقبة =====
  List<GiftAnimationData> get activeAnimations =>
      List.unmodifiable(_activeAnimations);
  List<GiftAnimationData> get queuedAnimations =>
      List.unmodifiable(_animationQueue);

  int getQueueSizeForType(GiftType giftType) => _typeQueues[giftType]!.length;
  bool isProcessingType(GiftType giftType) => _isProcessing[giftType]!;

  Map<GiftType, int> get allQueueSizes => Map.fromEntries(
      _typeQueues.entries.map((e) => MapEntry(e.key, e.value.length)));

  @override
  Future<void> close() {
    dev.log("🚫 [UNIFIED_QUEUE] Closing UnifiedGiftQueueManager",
        name: 'UnifiedGiftQueue');
    clearAllQueues();
    return super.close();
  }
}

// ===== أنواع الهدايا =====
enum GiftType {
  entry,
  lucky,
  popular,
  normal,
}

// ===== عنصر في الرتل =====
class GiftQueueItem {
  final GiftEntity gift;
  final List<String> targetIds;
  final GiftType giftType;
  final int sequenceNumber;
  final int totalCount;
  final String uniqueId;
  final DateTime timestamp;

  const GiftQueueItem({
    required this.gift,
    required this.targetIds,
    required this.giftType,
    required this.sequenceNumber,
    required this.totalCount,
    required this.uniqueId,
    required this.timestamp,
  });

  @override
  String toString() {
    return 'GiftQueueItem(id: $uniqueId, type: ${giftType.name}, '
        'sequence: $sequenceNumber/$totalCount, user: ${gift.userName})';
  }
}

// ===== معلومات رتل نوع واحد =====
class TypeQueueInfo {
  final int size;
  final bool isProcessing;
  final GiftQueueItem? nextGift;

  const TypeQueueInfo({
    required this.size,
    required this.isProcessing,
    this.nextGift,
  });
}

// ===== حالة جميع الرتل =====
class QueueStatus {
  final Map<GiftType, TypeQueueInfo> typeQueues;
  final int activeAnimations;
  final int queuedAnimations;

  const QueueStatus({
    required this.typeQueues,
    required this.activeAnimations,
    required this.queuedAnimations,
  });

  @override
  String toString() {
    final typeSummary = typeQueues.entries
        .map((e) => '${e.key.name}: ${e.value.size}')
        .join(', ');
    return 'QueueStatus($typeSummary, animations: $activeAnimations+$queuedAnimations)';
  }
}
