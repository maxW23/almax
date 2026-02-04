import 'dart:math' as math;
import 'package:flutter/material.dart';

/// Service منفصل لحساب مواضع الهدايا (فصل المنطق عن UI)
class GiftPositionService {
  static final GiftPositionService _instance = GiftPositionService._internal();
  factory GiftPositionService() => _instance;
  GiftPositionService._internal();

  /// حساب موضع المقعد بدقة عالية
  Offset calculateSeatPosition({
    required int seatIndex,
    required int microphoneNumber,
    required double gridHeight,
    required BuildContext context,
  }) {
    final columns = _getColumnsForMicCount(microphoneNumber);
    final row = seatIndex ~/ columns;
    final column = seatIndex % columns;

    final screenWidth = MediaQuery.of(context).size.width;
    final seatWidth = screenWidth / columns;
    final rowsCount = (microphoneNumber / columns).ceil();
    final seatHeight = gridHeight / rowsCount;

    // حسابات دقيقة مع مراعاة كل العوامل
    const double appBarHeight = kToolbarHeight;
    final statusBarHeight = MediaQuery.of(context).padding.top;
    const double infoRowHeight = 60.0;

    final x = column * seatWidth + (seatWidth / 2);
    final y = appBarHeight +
        statusBarHeight +
        infoRowHeight +
        (row * seatHeight) +
        (seatHeight / 2);

    return Offset(x, y);
  }

  /// حساب نقطة المركز للشاشة
  Offset calculateCenterPoint(BuildContext context) {
    final size = MediaQuery.of(context).size;
    return Offset(size.width / 2, size.height / 2);
  }

  /// حساب مسار محسن للهدية
  List<Offset> calculateOptimizedPath({
    required Offset start,
    required Offset end,
    Offset? midPoint,
    int curvePoints = 20,
  }) {
    final points = <Offset>[];
    final mid = midPoint ??
        Offset(
          (start.dx + end.dx) / 2,
          (start.dy + end.dy) / 2 - 50, // ارتفاع طفيف للمنحنى
        );

    // Bezier curve calculation
    for (int i = 0; i <= curvePoints; i++) {
      final t = i / curvePoints;
      final x = math.pow(1 - t, 2) * start.dx +
          2 * (1 - t) * t * mid.dx +
          math.pow(t, 2) * end.dx;
      final y = math.pow(1 - t, 2) * start.dy +
          2 * (1 - t) * t * mid.dy +
          math.pow(t, 2) * end.dy;
      points.add(Offset(x.toDouble(), y.toDouble()));
    }

    return points;
  }

  /// توزيع الهدايا على مستلمين متعددين بذكاء
  Map<String, Offset> distributeGiftsToReceivers({
    required List<String> receiverIds,
    required Map<String, int> seatMapping,
    required int microphoneNumber,
    required double gridHeight,
    required BuildContext context,
  }) {
    final positions = <String, Offset>{};

    for (final receiverId in receiverIds) {
      final seatIndex = seatMapping[receiverId];
      if (seatIndex != null) {
        positions[receiverId] = calculateSeatPosition(
          seatIndex: seatIndex,
          microphoneNumber: microphoneNumber,
          gridHeight: gridHeight,
          context: context,
        );
      }
    }

    return positions;
  }

  /// حساب التأخير الأمثل بين الهدايا
  Duration calculateOptimalDelay(int giftCount) {
    if (giftCount <= 3) return Duration.zero;
    if (giftCount <= 6) return const Duration(milliseconds: 100);
    if (giftCount <= 10) return const Duration(milliseconds: 150);
    return const Duration(milliseconds: 200);
  }

  int _getColumnsForMicCount(int micCount) {
    if (micCount <= 4) return 2;
    if (micCount <= 9) return 3;
    if (micCount <= 16) return 4;
    return 5;
  }
}
