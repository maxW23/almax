import 'dart:developer' as dev;
import 'package:flutter/material.dart';

/// مدير مواضع المقاعد للحصول على الموضع الفعلي لصور المستخدمين
class SeatPositionManager {
  static final SeatPositionManager _instance = SeatPositionManager._internal();
  factory SeatPositionManager() => _instance;
  SeatPositionManager._internal();

  // خريطة لحفظ مواضع المستخدمين الفعلية
  final Map<String, Offset> _userPositions = {};

  // خريطة لحفظ مراجع المقاعد
  final Map<int, GlobalKey> _seatKeys = {};

  /// تسجيل موضع مستخدم
  void registerUserPosition(String userId, Offset position) {
    _userPositions[userId] = position;
    // dev.log('📍 Registered position for user $userId: $position', name: 'SeatPositionManager');
  }

  /// الحصول على موضع مستخدم
  Offset? getUserPosition(String userId) {
    final position = _userPositions[userId];
    if (position != null) {
      dev.log('📍 Found position for user $userId: $position',
          name: 'SeatPositionManager');
    } else {
      dev.log('❌ No position found for user $userId',
          name: 'SeatPositionManager');
    }
    return position;
  }

  /// تسجيل مفتاح مقعد
  void registerSeatKey(int seatIndex, GlobalKey key) {
    _seatKeys[seatIndex] = key;
  }

  /// الحصول على موضع مقعد بناءً على الفهرس
  Offset? getSeatPosition(int seatIndex) {
    try {
      final key = _seatKeys[seatIndex];
      if (key?.currentContext != null) {
        final RenderBox? renderBox =
            key!.currentContext!.findRenderObject() as RenderBox?;
        if (renderBox != null && renderBox.hasSize) {
          final position = renderBox.localToGlobal(Offset.zero);
          final size = renderBox.size;
          // إرجاع موضع منتصف المقعد
          final centerPosition = Offset(
            position.dx + (size.width / 2),
            position.dy + (size.height / 2),
          );
          dev.log(
              '📍 Found seat position for index $seatIndex: $centerPosition',
              name: 'SeatPositionManager');
          return centerPosition;
        }
      }
    } catch (e) {
      dev.log('❌ Error getting seat position for index $seatIndex: $e',
          name: 'SeatPositionManager');
    }
    return null;
  }

  /// إزالة موضع مستخدم
  void removeUserPosition(String userId) {
    _userPositions.remove(userId);
    dev.log('🗑️ Removed position for user $userId',
        name: 'SeatPositionManager');
  }

  /// تنظيف جميع المواضع
  void clearAllPositions() {
    _userPositions.clear();
    _seatKeys.clear();
    dev.log('🧹 Cleared all positions', name: 'SeatPositionManager');
  }

  /// الحصول على عدد المواضع المسجلة
  int get registeredUsersCount => _userPositions.length;
  int get registeredSeatsCount => _seatKeys.length;
}
