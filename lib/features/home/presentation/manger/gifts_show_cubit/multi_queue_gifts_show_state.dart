// multi_queue_gifts_show_state.dart
part of 'multi_queue_gifts_show_cubit.dart';

/// الحالات الأساسية لمدير الرتل المتعدد
abstract class MultiQueueGiftsShowState extends Equatable {
  const MultiQueueGiftsShowState();

  @override
  List<Object?> get props => [];
}

/// الحالة الأولية - لا توجد هدايا معروضة
class MultiQueueGiftsShowInitial extends MultiQueueGiftsShowState {}

/// حالة عرض هدية مع معلومات النوع والرتل
class MultiQueueGiftShow extends MultiQueueGiftsShowState {
  final GiftEntity gift;
  final List<String> targetId;
  final String giftType;
  final MultiQueueStatus queueStatus;

  const MultiQueueGiftShow({
    required this.gift,
    required this.targetId,
    required this.giftType,
    required this.queueStatus,
  });

  @override
  List<Object?> get props => [gift, targetId, giftType, queueStatus];

  @override
  String toString() {
    return 'MultiQueueGiftShow(type: $giftType, gift: ${gift.giftId}, '
        'user: ${gift.userName}, targets: ${targetId.length})';
  }
}

/// حالة خطأ في معالجة الهدايا
class MultiQueueGiftsShowError extends MultiQueueGiftsShowState {
  final String message;
  final String? giftType;

  const MultiQueueGiftsShowError({
    required this.message,
    this.giftType,
  });

  @override
  List<Object?> get props => [message, giftType];

  @override
  String toString() {
    return 'MultiQueueGiftsShowError(message: $message, type: $giftType)';
  }
}
