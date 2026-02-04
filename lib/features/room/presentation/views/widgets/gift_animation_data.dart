import 'package:flutter/material.dart';

class GiftAnimationData {
  final String imageUrl;
  final Offset targetOffset;
  final Offset senderOffset;
  final String? giftsMany;
  final Duration delay;
  final Offset centerOffset;
  final double centerDiameter;
  // إزاحة اختيارية لمحور Y عن centerOffset لضبط موضع المركز ديناميكياً
  final double? centerYOffset;

  // خصائص إضافية للتحسينات
  final String? giftId;
  final String? senderId;
  final String? receiverId;
  // دعم عدة مستلمين لهدايا الحظ
  final List<String>? receiverIds;
  final List<Offset>? receiverOffsets;
  int count;
  final DateTime timestamp;
  final String? microphoneNumber; // عدد الميكروفونات للحساب الدقيق
  final int? giftTimer; // مدة الهدية من الخادم (بالثواني)
  final String? giftType; // نوع الهدية (lucky, normal, etc.)
  // إذا لم يكن المرسل على المايك، ابدأ من المركز بدلاً من البحث عن موضعه
  final bool startFromCenterIfSenderMissing;

  // مدة الأنيميشن - قابلة للتعديل لنظام combo
  Duration duration;

  GiftAnimationData({
    required this.imageUrl,
    required this.targetOffset,
    required this.senderOffset,
    this.giftsMany,
    this.delay = Duration.zero,
    required this.centerOffset,
    this.centerDiameter = 110,
    this.centerYOffset,
    this.giftId,
    this.senderId,
    this.receiverId,
    this.receiverIds,
    this.receiverOffsets,
    this.count = 1,
    DateTime? timestamp,
    this.microphoneNumber,
    this.giftTimer,
    this.giftType,
    this.startFromCenterIfSenderMissing = false,
    Duration? duration,
  })  : timestamp = timestamp ?? DateTime.now(),
        duration = duration ??
            Duration(
                milliseconds: (giftTimer != null && giftTimer > 0)
                    ? giftTimer * 1000
                    : 2200);
}
