import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:lklk/live_audio_room_manager.dart';

/// كائن بسيط يحمل أبعاد الشبكة والدردشة
class SeatChatLayout {
  final double gridHeight;
  final double chatHeight;
  final int columns;
  final int rows;
  final double seatWidth;
  final double seatHeight;

  const SeatChatLayout({
    required this.gridHeight,
    required this.chatHeight,
    required this.columns,
    required this.rows,
    required this.seatWidth,
    required this.seatHeight,
  });

  @override
  String toString() {
    return 'SeatChatLayout(gridHeight: $gridHeight, chatHeight: $chatHeight, '
        'columns: $columns, rows: $rows, seatWidth: $seatWidth, seatHeight: $seatHeight)';
  }
}

/// حاسبة التخطيط للغرفة الصوتية
class LayoutCalculator {
  static const double _defaultSeatWidth = 72.0;
  static const double _defaultSeatHeight = 90.0;
  static const double _defaultMinChatHeight = 180.0;
  static const double _defaultFixedOverhead =
      148.0; // AppBar + RoomInfoRow + RoomButtonsRow + margins

  /// حساب أبعاد الشبكة والدردشة
  ///
  /// يأخذ في الاعتبار:
  /// - حجم عنصر المقعد من `ZegoSeatItemView` (عرض 72.w وارتفاع 90.h)
  /// - عدد المقاعد `microphoneNumber`
  /// - عرض الشاشة لحساب عدد الأعمدة
  /// - حجز حد أدنى لارتفاع الدردشة لضمان سهولة الاستخدام
  static SeatChatLayout computeSeatAndChatHeights(
    BuildContext context,
    int microphoneNumber,
  ) {
    final media = MediaQuery.of(context);
    final screenWidth = media.size.width;
    final screenHeight = media.size.height;

    // المساحة المتاحة للشبكة + الدردشة ضمن العمود الحالي
    double available = screenHeight - _defaultFixedOverhead;
    if (available <= 0) {
      // fallback آمن
      return SeatChatLayout(
        gridHeight: screenHeight * 0.4,
        chatHeight: screenHeight * 0.2,
        columns: 1,
        rows: 1,
        seatWidth: _defaultSeatWidth,
        seatHeight: _defaultSeatHeight,
      );
    }

    // أبعاد عنصر المقعد وفق ما هو مستخدم داخل ZegoSeatItemView (مع حماية)
    final double seatWidth = _safeScale(72.w, _defaultSeatWidth);
    final double seatHeight = _safeScale(90.h, _defaultSeatHeight);
    final double rowExtraPadding = _safeScale(8.h, 8.0);

    // استخدم العدد الفعلي الفعال (الأقل بين المطلوب والمتاح حالياً) لتفادي الوميض
    final int availableSeats = ZegoLiveAudioRoomManager().seatList.length;
    final int effectiveSeats =
        (availableSeats < microphoneNumber) ? availableSeats : microphoneNumber;

    // في حال لم تتوفر مقاعد فعّالة، اجعل الشبكة صفر والـ Chat تأخذ كل المتاح
    if (effectiveSeats <= 0) {
      final double minChatHeight = _safeScale(180.h, _defaultMinChatHeight);
      final chat = available > minChatHeight ? available : minChatHeight;
      return SeatChatLayout(
        gridHeight: 0,
        chatHeight: chat,
        columns: 0,
        rows: 0,
        seatWidth: seatWidth,
        seatHeight: seatHeight,
      );
    }

    // حساب عدد الأعمدة المتاحة بناء على عرض الشاشة (مع حماية من القسمة على صفر)
    int columns = seatWidth > 0
        ? (screenWidth / seatWidth).floor()
        : (screenWidth / _defaultSeatWidth).floor();
    if (columns < 1) columns = 1;
    if (columns > effectiveSeats) columns = effectiveSeats;

    // حساب عدد الصفوف
    final int rows = (effectiveSeats / columns).ceil();

    // الارتفاع النظري للشبكة
    double gridHeight = rows * seatHeight + (rows - 1) * 0 + rowExtraPadding;

    // احجز حد أدنى لارتفاع الدردشة (مع حماية)
    final double minChatHeight = _safeScale(180.h, _defaultMinChatHeight);
    if (available - gridHeight < minChatHeight) {
      gridHeight = available - minChatHeight;
      if (gridHeight < seatHeight) {
        // لا تقل عن ارتفاع صف واحد على الأقل
        gridHeight = seatHeight;
      }
    }

    // الآن احسب ارتفاع الدردشة كالمتبقي
    double chatHeight = available - gridHeight;
    if (chatHeight < minChatHeight) chatHeight = minChatHeight;

    // حماية إضافية: لا تتجاوز القيم المساحة المتاحة
    if (gridHeight + chatHeight > available) {
      chatHeight = available - gridHeight;
      if (chatHeight < minChatHeight) {
        chatHeight = minChatHeight;
        gridHeight = available - chatHeight;
      }
    }

    return SeatChatLayout(
      gridHeight: gridHeight,
      chatHeight: chatHeight,
      columns: columns,
      rows: rows,
      seatWidth: seatWidth,
      seatHeight: seatHeight,
    );
  }

  /// حساب التخطيط المتجاوب للمقاعد
  static GridLayoutInfo calculateGridLayout(
    BuildContext context,
    int totalSeats, {
    double? customSeatWidth,
    double? customSeatHeight,
  }) {
    final screenWidth = MediaQuery.of(context).size.width;
    final seatWidth = customSeatWidth ?? _safeScale(72.w, _defaultSeatWidth);

    int columns = seatWidth > 0
        ? (screenWidth / seatWidth).floor()
        : (screenWidth / _defaultSeatWidth).floor();

    if (columns < 1) columns = 1;
    if (columns > totalSeats) columns = totalSeats;

    final int rows = totalSeats > 0 ? (totalSeats / columns).ceil() : 0;

    return GridLayoutInfo(
      columns: columns,
      rows: rows,
      totalSeats: totalSeats,
      seatWidth: seatWidth,
      seatHeight: customSeatHeight ?? _safeScale(90.h, _defaultSeatHeight),
    );
  }

  /// حساب الأبعاد المثلى للدردشة
  static ChatLayoutInfo calculateChatLayout(
    BuildContext context, {
    double? reservedHeight,
    double? minHeight,
  }) {
    final screenHeight = MediaQuery.of(context).size.height;
    final reserved = reservedHeight ?? _defaultFixedOverhead;
    final minChatHeight = minHeight ?? _safeScale(180.h, _defaultMinChatHeight);

    double availableHeight = screenHeight - reserved;
    if (availableHeight < minChatHeight) {
      availableHeight = minChatHeight;
    }

    return ChatLayoutInfo(
      height: availableHeight,
      minHeight: minChatHeight,
      maxHeight: screenHeight * 0.6, // حد أقصى 60% من الشاشة
    );
  }

  /// دوال مساعدة لتفادي قيم NaN/Infinity أو الصفر عند استخدام ScreenUtil على بعض المحاكيات
  static double _safeScale(double scaled, double fallback) {
    if (scaled.isNaN || scaled.isInfinite || scaled <= 0) return fallback;
    return scaled;
  }
}

/// معلومات تخطيط الشبكة
class GridLayoutInfo {
  final int columns;
  final int rows;
  final int totalSeats;
  final double seatWidth;
  final double seatHeight;

  const GridLayoutInfo({
    required this.columns,
    required this.rows,
    required this.totalSeats,
    required this.seatWidth,
    required this.seatHeight,
  });

  double get totalWidth => columns * seatWidth;
  double get totalHeight => rows * seatHeight;

  @override
  String toString() {
    return 'GridLayoutInfo(columns: $columns, rows: $rows, totalSeats: $totalSeats, '
        'seatWidth: $seatWidth, seatHeight: $seatHeight)';
  }
}

/// معلومات تخطيط الدردشة
class ChatLayoutInfo {
  final double height;
  final double minHeight;
  final double maxHeight;

  const ChatLayoutInfo({
    required this.height,
    required this.minHeight,
    required this.maxHeight,
  });

  bool get isAtMinHeight => height <= minHeight;
  bool get isAtMaxHeight => height >= maxHeight;

  @override
  String toString() {
    return 'ChatLayoutInfo(height: $height, minHeight: $minHeight, maxHeight: $maxHeight)';
  }
}
