import 'dart:developer' as dev;

import 'package:flutter/material.dart';
import 'package:lklk/features/room/presentation/views/widgets/gift_animation_data.dart';
import 'package:lklk/features/room/presentation/views/widgets/gift_animation_widget.dart';
// تم تعطيل نظام الرتل - الهدايا تعرض مباشرة في Stack

/// مساعد التكامل مع نظام هدايا الحظ
class LuckyGiftIntegrationHelper {
  static final LuckyGiftIntegrationHelper _instance =
      LuckyGiftIntegrationHelper._internal();
  factory LuckyGiftIntegrationHelper() => _instance;
  LuckyGiftIntegrationHelper._internal();
  // Queue system disabled: gifts are displayed directly in a Stack
  final List<Widget> _activeAnimations = [];
  Function(List<Widget>)? _onAnimationsUpdated;

  /// تهيئة المساعد
  void initialize({required Function(List<Widget>) onAnimationsUpdated}) {
    _onAnimationsUpdated = onAnimationsUpdated;

    // Queue disabled: no listeners needed. Gifts will display directly.

    dev.log('🚀 [LUCKY_INTEGRATION] Helper initialized',
        name: 'LuckyIntegration');
  }

  /// إضافة هدية (عرض مباشر بدون رتل)
  void addLuckyGift({
    required String giftType,
    required String giftId,
    required String senderId,
    required String senderName,
    required String receiverId,
    required String receiverName,
    required String imageUrl,
    required int count,
    required GiftAnimationData animationData,
    Map<String, dynamic>? metadata,
  }) {
    // التحقق من أن هذه هدية حظ
    if (giftType.toLowerCase() != 'lucky') {
      dev.log(
          '⚠️ [LUCKY_INTEGRATION] Not a lucky gift, create direct animation: $giftType',
          name: 'LuckyIntegration');
      return;
    }

    dev.log(
        '🎁 [LUCKY_INTEGRATION] Creating direct lucky gift animation (no queue)',
        name: 'LuckyIntegration');
    dev.log(
        '🎁 [LUCKY_INTEGRATION] Gift details: $giftId, $senderName → $receiverName, count: $count',
        name: 'LuckyIntegration');

    _displayGiftDirect(giftId, animationData);
  }

  /// عرض هدية مباشرة (بدون رتل)
  void _displayGiftDirect(String giftId, GiftAnimationData animationData) {
    dev.log('🎬 [LUCKY_INTEGRATION] Displaying gift directly: $giftId',
        name: 'LuckyIntegration');

    final animationWidget = GiftAnimationWidget(
      key: ValueKey(giftId),
      giftData: animationData,
      giftId: giftId,
      onAnimationComplete: () => _removeAnimation(giftId),
    );

    _activeAnimations.add(animationWidget);
    _notifyAnimationsUpdated();

    dev.log(
        '🎬 [LUCKY_INTEGRATION] Active animations count: ${_activeAnimations.length}',
        name: 'LuckyIntegration');
  }

  /// إزالة أنيميشن مكتمل
  void _removeAnimation(String giftId) {
    dev.log('🗑️ [LUCKY_INTEGRATION] Removing completed animation: $giftId',
        name: 'LuckyIntegration');

    _activeAnimations.removeWhere((widget) {
      if (widget is GiftAnimationWidget) {
        return widget.giftId == giftId;
      }
      return false;
    });

    _notifyAnimationsUpdated();
    dev.log(
        '🗑️ [LUCKY_INTEGRATION] Active animations count: ${_activeAnimations.length}',
        name: 'LuckyIntegration');
  }

  /// إشعار بتحديث الأنيميشنز
  void _notifyAnimationsUpdated() {
    _onAnimationsUpdated?.call(List.from(_activeAnimations));
  }

  /// الحصول على الأنيميشنز النشطة
  List<Widget> getActiveAnimations() {
    return List.from(_activeAnimations);
  }

  /// الحصول على عدد الهدايا النشطة (بدون رتل)
  int getActiveGiftsCount() => _activeAnimations.length;

  /// مسح جميع الهدايا المعروضة (للطوارئ)
  void clearAllGifts() {
    _activeAnimations.clear();
    _notifyAnimationsUpdated();
    dev.log('🗑️ [LUCKY_INTEGRATION] All animations cleared',
        name: 'LuckyIntegration');
  }

  /// إضافة هدية عادية (بدون رتل)
  Widget createRegularGiftAnimation({
    required GiftAnimationData animationData,
    required VoidCallback onAnimationComplete,
  }) {
    dev.log('🎁 [LUCKY_INTEGRATION] Creating regular gift animation (no queue)',
        name: 'LuckyIntegration');

    return GiftAnimationWidget(
      giftData: animationData,
      onAnimationComplete: onAnimationComplete,
      // لا يوجد queueItemId للهدايا العادية
    );
  }

  /// تنظيف الموارد
  void dispose() {
    _activeAnimations.clear();
    _onAnimationsUpdated = null;
    dev.log('🗑️ [LUCKY_INTEGRATION] Helper disposed',
        name: 'LuckyIntegration');
  }
}

/// معلومات إضافية لهدايا الحظ
class LuckyGiftMetadata {
  final String roomId;
  final DateTime timestamp;
  final String? specialEffect;
  final Map<String, dynamic> customData;

  const LuckyGiftMetadata({
    required this.roomId,
    required this.timestamp,
    this.specialEffect,
    this.customData = const {},
  });

  Map<String, dynamic> toMap() {
    return {
      'roomId': roomId,
      'timestamp': timestamp.toIso8601String(),
      'specialEffect': specialEffect,
      'customData': customData,
    };
  }

  factory LuckyGiftMetadata.fromMap(Map<String, dynamic> map) {
    return LuckyGiftMetadata(
      roomId: map['roomId'] ?? '',
      timestamp: DateTime.tryParse(map['timestamp'] ?? '') ?? DateTime.now(),
      specialEffect: map['specialEffect'],
      customData: Map<String, dynamic>.from(map['customData'] ?? {}),
    );
  }
}
