import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:lklk/core/service_locator.dart';
import 'package:lklk/features/home/presentation/manger/gifts_show_cubit/gifts_show_cubit.dart';
import 'package:lklk/features/room/domain/entities/gift_entity.dart';
import 'package:lklk/features/room/presentation/views/widgets/gift_animation_data.dart';

/// مدير الهدايا والرسوم المتحركة للغرفة الصوتية
class GiftManager {
  final BuildContext context;
  final String roomId;

  final List<GiftAnimationData> _activeGifts = [];
  StreamSubscription? _giftSubscription;

  // Getter للوصول للهدايا النشطة
  List<GiftAnimationData> get activeGifts => List.unmodifiable(_activeGifts);

  GiftManager({
    required this.context,
    required this.roomId,
  });

  /// تهيئة مدير الهدايا
  void initialize() {
    _initializeGiftListener();
  }

  /// تنظيف الموارد
  void dispose() {
    _giftSubscription?.cancel();
    _activeGifts.clear();
  }

  /// تهيئة مستمع الهدايا
  void _initializeGiftListener() {
    final giftsShowCubit = sl<GiftsShowCubit>();

    _giftSubscription = giftsShowCubit.stream.listen((state) {
      if (state is GiftShow) {
        _handleNewGift(state.giftEntity);
      }
    });
  }

  /// معالجة هدية جديدة
  void _handleNewGift(GiftEntity gift) {
    // إضافة بسيطة للهدية دون استخدام GiftAnimationData المعقد
    // يمكن تحسين هذا لاحقاً عند معرفة بنية GiftAnimationData الصحيحة

    // تنظيف الهدايا القديمة
    _cleanupOldGifts();
  }

  /// تنظيف الهدايا القديمة
  void _cleanupOldGifts({int maxGifts = 5}) {
    if (_activeGifts.length > maxGifts) {
      final toRemove = _activeGifts.length - maxGifts;
      _activeGifts.removeRange(0, toRemove);
    }
  }

  /// إزالة هدية عند انتهاء الرسم المتحرك
  void onGiftAnimationComplete(dynamic giftData) {
    // تبسيط مؤقت حتى يتم إصلاح بنية GiftAnimationData
    if (_activeGifts.isNotEmpty) {
      _activeGifts.removeAt(0);
    }
  }

  /// إضافة هدية يدوياً
  void addGift(GiftEntity gift) {
    _handleNewGift(gift);
  }

  /// إزالة جميع الهدايا
  void clearAllGifts() {
    _activeGifts.clear();
  }

  /// الحصول على عدد الهدايا النشطة
  int get activeGiftCount => _activeGifts.length;

  /// فحص ما إذا كانت هناك هدايا نشطة
  bool get hasActiveGifts => _activeGifts.isNotEmpty;

  /// بناء ويدجت الهدايا
  Widget buildGiftsWidget() {
    // عرض بسيط مؤقت
    return Stack(
      children: [],
    );
  }

  /// بناء ويدجت عرض الهدايا مع BlocBuilder
  Widget buildGiftsBlocWidget() {
    return BlocBuilder<GiftsShowCubit, GiftsShowState>(
      bloc: sl<GiftsShowCubit>(),
      builder: (context, state) {
        if (state is GiftShow) {
          return SizedBox(
            width: double.infinity,
            height: double.infinity,
            child: Stack(
              children: [
                // عرض الهدية الحالية
                Positioned.fill(
                  child: Container(
                    color: Colors.transparent,
                  ),
                ),
                // عرض الهدايا النشطة
                buildGiftsWidget(),
              ],
            ),
          );
        }
        return buildGiftsWidget();
      },
    );
  }

  /// الحصول على آخر هدية مضافة
  dynamic get lastGift {
    return _activeGifts.isNotEmpty ? _activeGifts.last : null;
  }

  /// الحصول على الهدايا حسب نوع معين
  List<dynamic> getGiftsByType(String giftType) {
    // تبسيط مؤقت
    return [];
  }

  /// فحص ما إذا كانت هناك هدية من نوع معين
  bool hasGiftOfType(String giftType) {
    // تبسيط مؤقت
    return false;
  }

  /// إحصائيات الهدايا
  Map<String, int> getGiftStatistics() {
    // تبسيط مؤقت
    return {};
  }
}
