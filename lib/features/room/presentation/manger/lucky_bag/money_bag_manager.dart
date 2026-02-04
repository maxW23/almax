// file: presentation/manger/lucky_bag/money_bag_manager.dart
import 'package:lklk/core/utils/logger.dart';

import 'package:lklk/features/room/presentation/manger/lucky_bag/bag_session.dart';

class MoneyBagManager {
  static final MoneyBagManager _instance = MoneyBagManager._internal();
  factory MoneyBagManager() => _instance;
  MoneyBagManager._internal();

  final Set<String> displayedBagIds = {};
  final Map<String, List<BagSession>> roomBags = {};

  /// العثور على جلسة - يعيد null إن لم توجد
  BagSession? findSession(String? roomId, String bagId) {
    final sessions = roomBags[roomId];
    if (sessions == null || sessions.isEmpty) return null;
    try {
      return sessions.firstWhere((session) => session.bagID == bagId);
    } catch (e) {
      return null;
    }
  }

  /// إضافة جلسة جديدة (تزيل أي جلسة بنفس الـ bagId أولاً)
  void addSession(String roomId, BagSession newSession) {
    // تأكد أن هناك قائمة قبل أي شيء
    roomBags[roomId] ??= [];

    // إزالة الجلسة القديمة
    removeSession(roomId, newSession.bagID);

    // بعد الإزالة، تأكد أن القائمة موجودة
    roomBags[roomId] ??= [];

    // أضف الجلسة الجديدة
    roomBags[roomId]!.add(newSession);
  }

  /// إزالة جلسة محددة وتنظيفها
  void removeSession(String roomId, String bagId) {
    final sessions = roomBags[roomId];
    if (sessions != null && sessions.isNotEmpty) {
      // قبل الإزالة، نلغي الـ timer
      for (final s in sessions.where((s) => s.bagID == bagId)) {
        s.dispose();
      }

      final updated = sessions.where((s) => s.bagID != bagId).toList();
      if (updated.isEmpty) {
        roomBags.remove(roomId);
      } else {
        roomBags[roomId] = updated;
      }

      log('Removed session $bagId from room $roomId. Remaining sessions: ${updated.length}');
    }
  }

  /// مساعدة Debug
  void debugPrintAll() {
    roomBags.forEach((roomId, sessions) {
      AppLogger.debug(
          'MoneyBagManager - Room $roomId: ${sessions.map((s) => s.bagID).toList()}');
    });
  }
}
