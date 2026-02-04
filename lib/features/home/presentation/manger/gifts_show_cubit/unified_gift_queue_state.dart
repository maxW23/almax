// unified_gift_queue_state.dart
part of 'unified_gift_queue_manager.dart';

/// الحالات الأساسية للمدير الموحد
abstract class UnifiedGiftQueueState extends Equatable {
  const UnifiedGiftQueueState();

  @override
  List<Object?> get props => [];
}

/// الحالة الأولية - لا توجد هدايا معروضة
class UnifiedGiftQueueInitial extends UnifiedGiftQueueState {}

/// حالة عرض هدية مع معلومات شاملة
class UnifiedGiftShow extends UnifiedGiftQueueState {
  final GiftEntity gift;
  final List<String> targetIds;
  final GiftType giftType;
  final QueueStatus queueStatus;

  const UnifiedGiftShow({
    required this.gift,
    required this.targetIds,
    required this.giftType,
    required this.queueStatus,
  });

  @override
  List<Object?> get props => [gift, targetIds, giftType, queueStatus];

  @override
  String toString() {
    return 'UnifiedGiftShow(type: ${giftType.name}, gift: ${gift.giftId}, '
        'user: ${gift.userName}, targets: ${targetIds.length})';
  }
}

/// حالة تحديث الأنيميشن
class UnifiedAnimationUpdate extends UnifiedGiftQueueState {
  final List<GiftAnimationData> activeAnimations;
  final int queuedCount;

  const UnifiedAnimationUpdate({
    required this.activeAnimations,
    required this.queuedCount,
  });

  @override
  List<Object?> get props => [activeAnimations, queuedCount];

  @override
  String toString() {
    return 'UnifiedAnimationUpdate(active: ${activeAnimations.length}, '
        'queued: $queuedCount)';
  }
}

/// حالة خطأ في المعالجة
class UnifiedGiftQueueError extends UnifiedGiftQueueState {
  final String message;
  final GiftType? giftType;
  final String? giftId;

  const UnifiedGiftQueueError({
    required this.message,
    this.giftType,
    this.giftId,
  });

  @override
  List<Object?> get props => [message, giftType, giftId];

  @override
  String toString() {
    return 'UnifiedGiftQueueError(message: $message, '
        'type: ${giftType?.name}, giftId: $giftId)';
  }
}
