import 'dart:developer' as dev;

import 'package:flutter/material.dart';
import 'package:lklk/features/room/presentation/views/widgets/gift_animation_data.dart';
import 'package:lklk/features/room/presentation/views/widgets/enhanced_lucky_gift_manager.dart';
import 'package:lklk/features/room/presentation/views/widgets/professional_gift_animation.dart';
import 'package:lklk/features/room/presentation/views/widgets/enhanced_lucky_gift_display.dart';

/// 🎯 نظام تكامل هدايا الحظ الاحترافي
/// يربط جميع المكونات معاً بشكل سلس
class LuckyGiftSystemIntegration {
  static final LuckyGiftSystemIntegration _instance =
      LuckyGiftSystemIntegration._internal();
  factory LuckyGiftSystemIntegration() => _instance;
  LuckyGiftSystemIntegration._internal();

  // المدير المحسّن
  final EnhancedLuckyGiftManager _manager = EnhancedLuckyGiftManager();

  // قائمة الأنيميشنز النشطة
  final List<Widget> _activeAnimations = [];

  // callback لتحديث الواجهة
  Function(List<Widget>)? _onAnimationsUpdated;

  /// تهيئة النظام
  void initialize({
    required Function(List<Widget>) onAnimationsUpdated,
  }) {
    _onAnimationsUpdated = onAnimationsUpdated;

    // الاستماع لعرض الهدايا
    _manager.addDisplayListener(_onGiftDisplay);

    // الاستماع لإكمال الهدايا
    _manager.addCompleteListener(_onGiftComplete);

    // الاستماع لـ combos
    _manager.addComboListener(_onComboTriggered);

    dev.log('🚀 [LUCKY_SYSTEM] System initialized successfully',
        name: 'LuckySystem');
  }

  /// إضافة هدية حظ للنظام
  void addLuckyGift({
    required String giftId,
    required String senderId,
    required String senderName,
    required String receiverId,
    required String receiverName,
    required String imageUrl,
    required int count,
    required Offset senderOffset,
    required Offset targetOffset,
    Offset? centerOffset,
    bool isVip = false,
    String? specialEffect,
    String? microphoneNumber,
    Map<String, dynamic>? metadata,
  }) {
    // إنشاء بيانات الأنيميشن
    final animationData = GiftAnimationData(
      imageUrl: imageUrl,
      targetOffset: targetOffset,
      senderOffset: senderOffset,
      centerOffset: centerOffset ?? _calculateCenterPoint(),
      giftId: giftId,
      senderId: senderId,
      receiverId: receiverId,
      count: count,
      microphoneNumber: microphoneNumber,
      duration: const Duration(milliseconds: 2200), // المدة الافتراضية
      giftType: 'lucky', // هذا الملف مخصص لهدايا الحظ فقط
    );

    // إضافة للمدير المحسّن
    _manager.addEnhancedLuckyGift(
      giftId: giftId,
      senderId: senderId,
      senderName: senderName,
      receiverId: receiverId,
      receiverName: receiverName,
      imageUrl: imageUrl,
      count: count,
      animationData: animationData,
      isVip: isVip,
      specialEffect: specialEffect,
      metadata: metadata,
    );

    dev.log(
        '🎁 [LUCKY_SYSTEM] Gift added: $giftId from $senderName to $receiverName',
        name: 'LuckySystem');
  }

  /// معالجة عرض الهدية
  void _onGiftDisplay(PriorityGiftItem item) {
    dev.log(
        '🎬 [LUCKY_SYSTEM] Displaying gift: ${item.id} with priority ${item.priority}',
        name: 'LuckySystem');

    // إنشاء أنيميشن احترافي
    final animation = ProfessionalGiftAnimation(
      key: ValueKey(item.id),
      giftData: item.animationData,
      comboLevel: item.comboLevel,
      specialEffect: item.specialEffect,
      queueItemId: item.id,
      onAnimationComplete: () => _removeAnimation(item.id),
    );

    _activeAnimations.add(animation);
    _notifyUpdate();
  }

  /// معالجة إكمال الهدية
  void _onGiftComplete(String giftId) {
    dev.log('✅ [LUCKY_SYSTEM] Gift completed: $giftId', name: 'LuckySystem');
    _manager.completeGift(giftId);
  }

  /// معالجة تفعيل combo
  void _onComboTriggered(ComboInfo combo) {
    dev.log(
        '🔥 [LUCKY_SYSTEM] COMBO! ${combo.senderName} - Level ${combo.level}',
        name: 'LuckySystem');

    // يمكن إضافة تأثيرات إضافية هنا
    if (combo.level >= 5) {
      dev.log('💥 [LUCKY_SYSTEM] MEGA COMBO ACHIEVED!', name: 'LuckySystem');
    }
  }

  /// إزالة أنيميشن مكتمل
  void _removeAnimation(String giftId) {
    _activeAnimations.removeWhere((widget) {
      if (widget is ProfessionalGiftAnimation) {
        return widget.queueItemId == giftId;
      }
      return false;
    });

    _manager.completeGift(giftId);
    _notifyUpdate();

    dev.log('🗑️ [LUCKY_SYSTEM] Animation removed: $giftId',
        name: 'LuckySystem');
  }

  /// إشعار بالتحديث
  void _notifyUpdate() {
    _onAnimationsUpdated?.call(List.from(_activeAnimations));
  }

  /// حساب نقطة المركز
  Offset _calculateCenterPoint() {
    // يمكن تخصيص هذا حسب حجم الشاشة
    return const Offset(200, 300);
  }

  /// الحصول على الأنيميشنز النشطة
  List<Widget> getActiveAnimations() => List.from(_activeAnimations);

  /// الحصول على حالة النظام
  EnhancedQueueStatus getSystemStatus() => _manager.getStatus();

  /// بناء واجهة العرض
  Widget buildDisplay() => const EnhancedLuckyGiftDisplay();

  /// تنظيف النظام
  void dispose() {
    _activeAnimations.clear();
    _manager.dispose();
    _onAnimationsUpdated = null;
    dev.log('🗑️ [LUCKY_SYSTEM] System disposed', name: 'LuckySystem');
  }
}

/// 🎯 مثال على الاستخدام في room_view_body.dart
class LuckyGiftSystemExample extends StatefulWidget {
  const LuckyGiftSystemExample({super.key});

  @override
  State<LuckyGiftSystemExample> createState() => _LuckyGiftSystemExampleState();
}

class _LuckyGiftSystemExampleState extends State<LuckyGiftSystemExample> {
  final LuckyGiftSystemIntegration _luckySystem = LuckyGiftSystemIntegration();
  List<Widget> _giftAnimations = [];

  @override
  void initState() {
    super.initState();

    // تهيئة النظام
    _luckySystem.initialize(
      onAnimationsUpdated: (animations) {
        setState(() {
          _giftAnimations = animations;
        });
      },
    );
  }

  /// مثال على إضافة هدية
  void _sendLuckyGift() {
    _luckySystem.addLuckyGift(
      giftId: 'gift_${DateTime.now().millisecondsSinceEpoch}',
      senderId: 'user123',
      senderName: 'أحمد',
      receiverId: 'user456',
      receiverName: 'محمد',
      imageUrl: 'https://example.com/gift.png',
      count: 99,
      senderOffset: const Offset(50, 400),
      targetOffset: const Offset(300, 400),
      isVip: true,
      specialEffect: 'golden_burst',
      microphoneNumber: '20',
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Stack(
        children: [
          // محتوى الغرفة الأساسي
          Container(
            color: Colors.black,
            child: Center(
              child: ElevatedButton(
                onPressed: _sendLuckyGift,
                child: const Text('Send Lucky Gift'),
              ),
            ),
          ),

          // طبقة الأنيميشنز
          ..._giftAnimations,

          // واجهة عرض الرتل
          _luckySystem.buildDisplay(),
        ],
      ),
    );
  }

  @override
  void dispose() {
    _luckySystem.dispose();
    super.dispose();
  }
}

/// 🎯 دليل التكامل السريع
///
/// 1. في room_view_body.dart، أضف:
/// ```dart
/// final _luckySystem = LuckyGiftSystemIntegration();
/// ```
///
/// 2. في initState():
/// ```dart
/// _luckySystem.initialize(
///   onAnimationsUpdated: (animations) {
///     setState(() {
///       _giftAnimations = animations;
///     });
///   },
/// );
/// ```
///
/// 3. عند استقبال هدية من السيرفر:
/// ```dart
/// if (giftType == 'lucky') {
///   _luckySystem.addLuckyGift(
///     giftId: gift['id'],
///     senderId: gift['sender_id'],
///     senderName: gift['sender_name'],
///     receiverId: gift['receiver_id'],
///     receiverName: gift['receiver_name'],
///     imageUrl: gift['image_url'],
///     count: gift['count'],
///     senderOffset: _getSenderPosition(gift['sender_id']),
///     targetOffset: _getReceiverPosition(gift['receiver_id']),
///     isVip: gift['is_vip'] ?? false,
///   );
/// }
/// ```
///
/// 4. في build():
/// ```dart
/// Stack(
///   children: [
///     // محتوى الغرفة
///     RoomContent(),
///
///     // أنيميشنز الهدايا
///     ..._giftAnimations,
///
///     // واجهة الرتل
///     _luckySystem.buildDisplay(),
///   ],
/// )
/// ```
