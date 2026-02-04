// gifts_show_cubit.dart
import 'dart:async';
import 'dart:developer' as dev;

import 'package:equatable/equatable.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:lklk/features/room/domain/entities/gift_entity.dart';
import 'package:lklk/core/room_visibility_manager.dart';

part 'gifts_show_state.dart';

/// مدير رتل الهدايا المحسن مع دعم SVGA
class GiftsShowCubit extends Cubit<GiftsShowState> {
  GiftsShowCubit() : super(GiftsShowInitial());

  final List<_GiftQueueItem> _giftQueue = [];
  bool _isPlaying = false;
  Timer? _queueProcessingTimer;
  // Prevent duplicate entry shows within a short window per user
  final Set<String> _recentEntryKeys = <String>{};
  final Map<String, Timer> _recentEntryTimers = <String, Timer>{};

  // إعدادات الرتل
  static const int maxConcurrentGifts = 1; // هدية واحدة في كل مرة
  static const Duration processingInterval = Duration(milliseconds: 500);

  void showGiftAnimation(GiftEntity gift, List<String> targetId) {
    // Global guard: skip gifts received while app was minimized (based on last resume)
    final lastResumeMs = RoomVisibilityManager().currentRoomLastResumeAtMs;
    int giftTs = gift.timestamp;
    if (giftTs > 0 && giftTs < 1000000000000) {
      giftTs *= 1000; // normalize seconds to ms if needed
    }
    if (lastResumeMs > 0 && giftTs > 0 && giftTs < lastResumeMs) {
      dev.log(
          "⏭️ [GIFTS_CUBIT] Skipping gift older than resume: giftTs=$giftTs < resume=$lastResumeMs",
          name: 'GiftsCubit');
      return;
    }

    dev.log(
        "🎁 [GIFTS_CUBIT] showGiftAnimation called - "
        "GiftType: ${gift.giftType}, "
        "GiftID: ${gift.giftId}, "
        "User: ${gift.userName}, "
        "TargetIDs: ${targetId.length}",
        name: 'GiftsCubit');

    dev.log(
        "🎁 [GIFTS_CUBIT] Gift details: "
        "Timer: ${gift.timer}s, "
        "Count: ${gift.giftCount}, "
        "Points: ${gift.giftPoints}",
        name: 'GiftsCubit');

    // Entry-specific deduplication: ensure showing once per user in ~8s window
    final String giftTypeLower = gift.giftType.toLowerCase();
    final bool isEntryGift = giftTypeLower == 'entry' || giftTypeLower.contains('entry');
    if (isEntryGift) {
      final String userKey = 'entry_${gift.userId}';
      if (_recentEntryKeys.contains(userKey)) {
        dev.log("🚫 [GIFTS_CUBIT] Skipping duplicate entry for user ${gift.userId}", name: 'GiftsCubit');
        return;
      }
      _recentEntryKeys.add(userKey);
      _recentEntryTimers[userKey]?.cancel();
      _recentEntryTimers[userKey] = Timer(const Duration(seconds: 8), () {
        _recentEntryKeys.remove(userKey);
        _recentEntryTimers.remove(userKey);
        dev.log("🧹 [GIFTS_CUBIT] Entry dedup window expired for $userKey", name: 'GiftsCubit');
      });
    }

    // Lucky: أرسل مباشرة (بدون رتل) كي يلتقطها giftImageBloc، ولا توقف بقية الأنواع
    if (_isLuckyType(gift.giftType)) {
      dev.log(
          "🎀 [GIFTS_CUBIT] Lucky gift detected - emitting directly (no queue)",
          name: 'GiftsCubit');
      emit(GiftShow(gift, targetId));
      return;
    }

    // الأنواع الأخرى: الاستمرار باستخدام نظام الرتل الحالي
    int giftCount = (gift.giftType.toLowerCase() == "entry")
        ? 1
        : ((gift.giftCount > 0) ? gift.giftCount : 1);
    if (gift.giftType.toLowerCase() == "entry") {
      dev.log("🎀 [GIFTS_CUBIT] Entry gift - forcing count to 1",
          name: 'GiftsCubit');
    } else {
      dev.log("🎁 [GIFTS_CUBIT] Regular gift - using count: $giftCount",
          name: 'GiftsCubit');
    }

    // إضافة كل هدية كعنصر منفصل في الرتل
    for (int i = 0; i < giftCount; i++) {
      final queueItem = _GiftQueueItem(
        gift: gift,
        targetId: targetId,
        sequenceNumber: i + 1,
        totalCount: giftCount,
        uniqueId: '${gift.giftId}_${DateTime.now().millisecondsSinceEpoch}_$i',
      );

      _giftQueue.add(queueItem);
      dev.log("Queue length: ${_giftQueue.length}", name: 'GiftsCubit');
    }

    _startQueueProcessing();
  }

  // كشف مرن لنوع Lucky (إنجليزي/عربي)
  bool _isLuckyType(String? type) {
    if (type == null) return false;
    final t = type.toLowerCase();
    return t.contains('lucky') || t.contains('حظ');
  }

  /// بدء معالجة الرتل
  void _startQueueProcessing() {
    if (_isPlaying) {
      dev.log("⚠️ [GIFTS_CUBIT] Cannot start - already processing a gift",
          name: 'GiftsCubit');
      return;
    }

    if (_giftQueue.isEmpty) {
      dev.log("⚠️ [GIFTS_CUBIT] Cannot start processing - queue is empty",
          name: 'GiftsCubit');
      return;
    }

    dev.log(
        "🚀 [GIFTS_CUBIT] Starting queue processing with ${_giftQueue.length} gifts",
        name: 'GiftsCubit');

    // معالجة فورية بدلاً من Timer
    _processNextGift();
  }

  /// معالجة الهدية التالية في الرتل
  void _processNextGift() async {
    // إيقاف المعالجة إذا كان الرتل فارغ
    if (_giftQueue.isEmpty) {
      dev.log("🏁 [GIFTS_CUBIT] Queue is empty - stopping processing",
          name: 'GiftsCubit');
      return;
    }

    // إيقاف المعالجة إذا كان هناك هدية تُعرض حالياً
    if (_isPlaying) {
      dev.log("⏳ [GIFTS_CUBIT] Already processing a gift - skipping",
          name: 'GiftsCubit');
      return;
    }

    // أخذ الهدية التالية من الرتل
    final current = _giftQueue.removeAt(0);
    _isPlaying = true;

    dev.log(
        "🎬 [GIFTS_CUBIT] Processing gift ${current.sequenceNumber}/${current.totalCount}: "
        "${current.gift.giftType} from ${current.gift.userName}",
        name: 'GiftsCubit');
    dev.log("🎬 [GIFTS_CUBIT] Queue remaining: ${_giftQueue.length}",
        name: 'GiftsCubit');

    try {
      // انتظار انتهاء عرض الهدية قبل المتابعة
      await _displayGift(current);

      // لوغ انتهاء عرض الهدية
      dev.log(
          "✅ [GIFTS_CUBIT] Gift ${current.sequenceNumber}/${current.totalCount} completed. Remaining: ${_giftQueue.length}",
          name: 'GiftsCubit');
    } finally {
      _isPlaying = false;

      // إذا كان هناك هدايا أخرى، تابع المعالجة فوراً
      if (_giftQueue.isNotEmpty) {
        dev.log("🔄 [GIFTS_CUBIT] Processing next gift immediately",
            name: 'GiftsCubit');
        // استدعاء فوري للهدية التالية
        Future.microtask(() => _processNextGift());
      } else {
        dev.log("🏁 [GIFTS_CUBIT] All gifts processed successfully",
            name: 'GiftsCubit');
      }
    }
  }

  /// عرض هدية واحدة
  Future<void> _displayGift(_GiftQueueItem queueItem) async {
    try {
      dev.log("🎭 [GIFTS_CUBIT] Displaying gift: ${queueItem.uniqueId}",
          name: 'GiftsCubit');

      // إرسال حالة عرض الهدية
      emit(GiftShow(queueItem.gift, queueItem.targetId));

      // انتظار مدة عرض الهدية + SVGA
      final displayDuration = Duration(seconds: queueItem.gift.timer) +
          const Duration(milliseconds: 350);

      dev.log(
          "⏰ [GIFTS_CUBIT] Waiting ${displayDuration.inMilliseconds}ms for gift display",
          name: 'GiftsCubit');

      await Future.delayed(displayDuration);

      dev.log(
          "🧹 [GIFTS_CUBIT] Cleaning up gift display: ${queueItem.uniqueId}",
          name: 'GiftsCubit');

      // إرسال حالة الانتهاء لإزالة الهدية من الواجهة
      emit(GiftsShowInitial());

      // فترة إضافية لضمان إزالة الهدية من الواجهة
      await Future.delayed(const Duration(milliseconds: 300));

      dev.log(
          "✅ [GIFTS_CUBIT] Gift display completed and removed: ${queueItem.uniqueId}",
          name: 'GiftsCubit');

      // فترة انتظار قصيرة بين الهدايا
      await Future.delayed(const Duration(milliseconds: 100));
    } catch (e, stackTrace) {
      dev.log("❌ [GIFTS_CUBIT] ERROR displaying gift: $e", name: 'GiftsCubit');
      dev.log("❌ [GIFTS_CUBIT] Stack trace: $stackTrace", name: 'GiftsCubit');

      // حتى لو حدث خطأ، أكمل للهدية التالية
      emit(GiftsShowInitial());
    }
  }

  /// إيقاف معالجة الرتل (لم تعد مستخدمة مع النظام الجديد)
  void _stopQueueProcessing() {
    _queueProcessingTimer?.cancel();
    _queueProcessingTimer = null;
    dev.log("⏹️ [GIFTS_CUBIT] Stopped queue processing", name: 'GiftsCubit');
  }

  /// الحصول على حالة الرتل
  GiftQueueStatus getQueueStatus() {
    return GiftQueueStatus(
      queueSize: _giftQueue.length,
      isProcessing: _isPlaying,
      currentGift:
          _isPlaying && _giftQueue.isNotEmpty ? _giftQueue.first : null,
      nextGifts: _giftQueue.take(5).toList(),
    );
  }

  /// مسح الرتل (للطوارئ)
  void clearQueue() {
    _giftQueue.clear();
    _stopQueueProcessing();
    _isPlaying = false;
    emit(GiftsShowInitial());
    dev.log("🗑️ [GIFTS_CUBIT] Queue cleared", name: 'GiftsCubit');
  }

  /// إجبار إزالة الهدية الحالية والمتابعة للتالية
  void forceRemoveCurrentGift() {
    dev.log("🚨 [FORCE_REMOVE] Forcing removal of current gift",
        name: 'GiftsCubit');

    // إرسال حالة الإزالة فوراً
    emit(GiftsShowInitial());

    // إعادة تعيين حالة المعالجة
    _isPlaying = false;

    // المتابعة للهدية التالية إذا وجدت
    if (_giftQueue.isNotEmpty) {
      dev.log("🔄 [FORCE_REMOVE] Processing next gift after forced removal",
          name: 'GiftsCubit');
      Future.microtask(() => _processNextGift());
    }
  }

  @override
  Future<void> close() {
    dev.log("🚫 [CLOSE] Closing GiftsShowCubit", name: 'GiftsCubit');

    // مسح جميع الهدايا وإيقاف المعالجة
    _giftQueue.clear();
    _stopQueueProcessing();
    _isPlaying = false;

    // إرسال حالة نهائية لإزالة أي هدايا عالقة
    emit(GiftsShowInitial());

    return super.close();
  }
}

/// عنصر في رتل الهدايا
class _GiftQueueItem {
  final GiftEntity gift;
  final List<String> targetId;
  final int sequenceNumber;
  final int totalCount;
  final String uniqueId;

  _GiftQueueItem({
    required this.gift,
    required this.targetId,
    required this.sequenceNumber,
    required this.totalCount,
    required this.uniqueId,
  });

  @override
  String toString() {
    return 'GiftQueueItem(id: $uniqueId, gift: ${gift.giftType}, '
        'sequence: $sequenceNumber/$totalCount, user: ${gift.userName})';
  }
}

/// حالة رتل الهدايا
class GiftQueueStatus {
  final int queueSize;
  final bool isProcessing;
  final _GiftQueueItem? currentGift;
  final List<_GiftQueueItem> nextGifts;

  const GiftQueueStatus({
    required this.queueSize,
    required this.isProcessing,
    this.currentGift,
    required this.nextGifts,
  });

  @override
  String toString() {
    return 'GiftQueueStatus(queue: $queueSize, processing: $isProcessing)';
  }
}
