// multi_queue_gifts_show_cubit.dart
import 'dart:async';
import 'dart:developer' as dev;

import 'package:equatable/equatable.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:lklk/features/room/domain/entities/gift_entity.dart';

part 'multi_queue_gifts_show_state.dart';

/// مدير رتل الهدايا المتعدد مع دعم رتل منفصل لكل نوع هدية
class MultiQueueGiftsShowCubit extends Cubit<MultiQueueGiftsShowState> {
  MultiQueueGiftsShowCubit() : super(MultiQueueGiftsShowInitial());

  // رتل منفصل لكل نوع هدية
  final Map<String, List<_GiftQueueItem>> _giftQueues = {
    'entry': [],
    'lucky': [],
    'popular': [],
    'normal': [], // للهدايا العادية
  };

  // حالة المعالجة لكل نوع
  final Map<String, bool> _isProcessing = {
    'entry': false,
    'lucky': false,
    'popular': false,
    'normal': false,
  };

  // الهدايا المعروضة حالياً لكل نوع
  final Map<String, _GiftQueueItem?> _currentlyDisplaying = {
    'entry': null,
    'lucky': null,
    'popular': null,
    'normal': null,
  };

  void showGiftAnimation(GiftEntity gift, List<String> targetId) {
    final giftType = _normalizeGiftType(gift.giftType);

    dev.log(
        "🎁 [MULTI_QUEUE] showGiftAnimation called - "
        "GiftType: $giftType (original: ${gift.giftType}), "
        "GiftID: ${gift.giftId}, "
        "User: ${gift.userName}",
        name: 'MultiQueueGifts');

    // تحديد عدد الهدايا
    int giftCount;
    if (giftType == "lucky" || giftType == "entry") {
      giftCount = 1; // هدايا الحظ والدخول تُعرض مرة واحدة
    } else {
      giftCount = (gift.giftCount > 0) ? gift.giftCount : 1;
    }

    // إضافة الهدايا إلى الرتل المناسب
    for (int i = 0; i < giftCount; i++) {
      final queueItem = _GiftQueueItem(
        gift: gift,
        targetId: targetId,
        sequenceNumber: i + 1,
        totalCount: giftCount,
        uniqueId: '${gift.giftId}_${DateTime.now().millisecondsSinceEpoch}_$i',
        giftType: giftType,
      );

      _giftQueues[giftType]!.add(queueItem);
      dev.log(
          "🎁 [MULTI_QUEUE] Added $giftType gift ${i + 1}/$giftCount to queue. "
          "Queue length: ${_giftQueues[giftType]!.length}",
          name: 'MultiQueueGifts');
    }

    _startProcessingForType(giftType);
  }

  /// تطبيع نوع الهدية
  String _normalizeGiftType(String giftType) {
    final normalized = giftType.toLowerCase();
    if (_giftQueues.containsKey(normalized)) {
      return normalized;
    }
    return 'normal'; // افتراضي للأنواع غير المعروفة
  }

  /// بدء معالجة نوع معين من الهدايا
  void _startProcessingForType(String giftType) {
    if (_isProcessing[giftType]!) {
      dev.log("⚠️ [MULTI_QUEUE] $giftType already processing",
          name: 'MultiQueueGifts');
      return;
    }

    if (_giftQueues[giftType]!.isEmpty) {
      dev.log("⚠️ [MULTI_QUEUE] $giftType queue is empty",
          name: 'MultiQueueGifts');
      return;
    }

    // تحقق من الأولوية: إذا كان popular يعمل، أوقف entry
    if (giftType == 'entry' && _isProcessing['popular']!) {
      dev.log("⏸️ [MULTI_QUEUE] Entry paused - popular is running",
          name: 'MultiQueueGifts');
      return;
    }

    dev.log(
        "🚀 [MULTI_QUEUE] Starting $giftType processing with ${_giftQueues[giftType]!.length} gifts",
        name: 'MultiQueueGifts');

    _processNextGiftForType(giftType);
  }

  /// معالجة الهدية التالية لنوع معين
  void _processNextGiftForType(String giftType) async {
    if (_giftQueues[giftType]!.isEmpty) {
      dev.log("🏁 [MULTI_QUEUE] $giftType queue is empty",
          name: 'MultiQueueGifts');
      return;
    }

    if (_isProcessing[giftType]!) {
      dev.log("⏳ [MULTI_QUEUE] $giftType already processing",
          name: 'MultiQueueGifts');
      return;
    }

    // تحقق من الأولوية مرة أخرى
    if (giftType == 'entry' && _isProcessing['popular']!) {
      dev.log("⏸️ [MULTI_QUEUE] Entry processing blocked by popular",
          name: 'MultiQueueGifts');
      return;
    }

    // إذا بدأ popular، أوقف entry
    if (giftType == 'popular' && _isProcessing['entry']!) {
      dev.log("🛑 [MULTI_QUEUE] Popular starting - pausing entry",
          name: 'MultiQueueGifts');
      // لا نوقف entry فوراً، بل ننتظر انتهاء الهدية الحالية
    }

    final current = _giftQueues[giftType]!.removeAt(0);
    _isProcessing[giftType] = true;
    _currentlyDisplaying[giftType] = current;

    dev.log(
        "🎬 [MULTI_QUEUE] Processing $giftType gift ${current.sequenceNumber}/${current.totalCount}",
        name: 'MultiQueueGifts');

    try {
      await _displayGift(current);
      dev.log(
          "✅ [MULTI_QUEUE] $giftType gift completed. Remaining: ${_giftQueues[giftType]!.length}",
          name: 'MultiQueueGifts');
    } finally {
      _isProcessing[giftType] = false;
      _currentlyDisplaying[giftType] = null;

      // إذا انتهى popular، أعد تشغيل entry إذا كان متوقفاً
      if (giftType == 'popular' &&
          _giftQueues['entry']!.isNotEmpty &&
          !_isProcessing['entry']!) {
        dev.log("🔄 [MULTI_QUEUE] Popular finished - resuming entry",
            name: 'MultiQueueGifts');
        Future.microtask(() => _startProcessingForType('entry'));
      }

      // تابع معالجة نفس النوع إذا كان هناك المزيد
      if (_giftQueues[giftType]!.isNotEmpty) {
        Future.microtask(() => _processNextGiftForType(giftType));
      }
    }
  }

  /// عرض هدية واحدة
  Future<void> _displayGift(_GiftQueueItem queueItem) async {
    try {
      dev.log(
          "🎭 [MULTI_QUEUE] Displaying ${queueItem.giftType} gift: ${queueItem.uniqueId}",
          name: 'MultiQueueGifts');

      // إرسال حالة عرض الهدية مع نوعها
      emit(MultiQueueGiftShow(
        gift: queueItem.gift,
        targetId: queueItem.targetId,
        giftType: queueItem.giftType,
        queueStatus: _getQueueStatus(),
      ));

      // انتظار مدة عرض الهدية
      final displayDuration = Duration(seconds: queueItem.gift.timer) +
          const Duration(milliseconds: 350);

      await Future.delayed(displayDuration);

      // إرسال حالة الانتهاء
      emit(MultiQueueGiftsShowInitial());

      // فترة إضافية لضمان الإزالة
      await Future.delayed(const Duration(milliseconds: 300));

      dev.log(
          "✅ [MULTI_QUEUE] ${queueItem.giftType} gift display completed: ${queueItem.uniqueId}",
          name: 'MultiQueueGifts');
    } catch (e) {
      dev.log("❌ [MULTI_QUEUE] ERROR displaying ${queueItem.giftType} gift: $e",
          name: 'MultiQueueGifts');
      emit(MultiQueueGiftsShowInitial());
    }
  }

  /// الحصول على حالة جميع الرتل
  MultiQueueStatus _getQueueStatus() {
    return MultiQueueStatus(
      queues: Map.fromEntries(
        _giftQueues.entries.map((entry) => MapEntry(
              entry.key,
              QueueInfo(
                size: entry.value.length,
                isProcessing: _isProcessing[entry.key]!,
                currentGift: _currentlyDisplaying[entry.key],
              ),
            )),
      ),
    );
  }

  /// مسح رتل معين
  void clearQueueForType(String giftType) {
    final normalizedType = _normalizeGiftType(giftType);
    _giftQueues[normalizedType]!.clear();
    _isProcessing[normalizedType] = false;
    _currentlyDisplaying[normalizedType] = null;
    dev.log("🗑️ [MULTI_QUEUE] Cleared $normalizedType queue",
        name: 'MultiQueueGifts');
  }

  /// مسح جميع الرتل
  void clearAllQueues() {
    for (final type in _giftQueues.keys) {
      _giftQueues[type]!.clear();
      _isProcessing[type] = false;
      _currentlyDisplaying[type] = null;
    }
    emit(MultiQueueGiftsShowInitial());
    dev.log("🗑️ [MULTI_QUEUE] All queues cleared", name: 'MultiQueueGifts');
  }

  /// إجبار إزالة الهدية الحالية لنوع معين
  void forceRemoveCurrentGiftForType(String giftType) {
    final normalizedType = _normalizeGiftType(giftType);
    dev.log("🚨 [MULTI_QUEUE] Force removing current $normalizedType gift",
        name: 'MultiQueueGifts');

    _isProcessing[normalizedType] = false;
    _currentlyDisplaying[normalizedType] = null;
    emit(MultiQueueGiftsShowInitial());

    if (_giftQueues[normalizedType]!.isNotEmpty) {
      Future.microtask(() => _processNextGiftForType(normalizedType));
    }
  }

  @override
  Future<void> close() {
    dev.log("🚫 [MULTI_QUEUE] Closing MultiQueueGiftsShowCubit",
        name: 'MultiQueueGifts');
    clearAllQueues();
    return super.close();
  }
}

/// عنصر في رتل الهدايا مع نوع الهدية
class _GiftQueueItem {
  final GiftEntity gift;
  final List<String> targetId;
  final int sequenceNumber;
  final int totalCount;
  final String uniqueId;
  final String giftType;

  _GiftQueueItem({
    required this.gift,
    required this.targetId,
    required this.sequenceNumber,
    required this.totalCount,
    required this.uniqueId,
    required this.giftType,
  });

  @override
  String toString() {
    return 'GiftQueueItem(id: $uniqueId, type: $giftType, '
        'sequence: $sequenceNumber/$totalCount, user: ${gift.userName})';
  }
}

/// معلومات رتل واحد
class QueueInfo {
  final int size;
  final bool isProcessing;
  final _GiftQueueItem? currentGift;

  const QueueInfo({
    required this.size,
    required this.isProcessing,
    this.currentGift,
  });
}

/// حالة جميع الرتل
class MultiQueueStatus {
  final Map<String, QueueInfo> queues;

  const MultiQueueStatus({required this.queues});

  @override
  String toString() {
    final summary =
        queues.entries.map((e) => '${e.key}: ${e.value.size}').join(', ');
    return 'MultiQueueStatus($summary)';
  }
}
