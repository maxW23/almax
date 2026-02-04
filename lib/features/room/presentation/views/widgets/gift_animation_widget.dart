import 'dart:async';
import 'dart:developer' as dev;
import 'dart:math' as math;

import 'package:flutter/material.dart';
import 'package:flutter/foundation.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:lklk/core/constants/app_colors.dart';
import 'package:lklk/core/utils/gradient_text.dart';
import 'package:lklk/features/room/presentation/views/widgets/gift_animation_data.dart';
import 'package:lklk/features/room/presentation/views/widgets/seat_position_manager.dart';
// تم إزالة نظام الرتل - الآن الهدايا تعرض في Stack
// Removed gradient/count overlay: keep animation image-only

class GiftAnimationWidget extends StatefulWidget {
  final GiftAnimationData giftData;
  final VoidCallback onAnimationComplete;
  final String? giftId; // معرف فريد للهدية (للتمييز في Stack)

  const GiftAnimationWidget({
    super.key,
    required this.giftData,
    required this.onAnimationComplete,
    this.giftId,
  });

  @override
  State<GiftAnimationWidget> createState() => _GiftAnimationWidgetState();
}

class _GiftAnimationWidgetState extends State<GiftAnimationWidget>
    with TickerProviderStateMixin {
  // المتحكم الرئيسي للحركة كلها. زيادة المدة تجعل الهدية تبقى أطول على الشاشة، وتقليلها يجعل الحركة أسرع وأقصر.
  late AnimationController _controller;
  // الحركة الموحدة الجديدة (استبدلنا الحركة القديمة بحركة موحدة)
  late Animation<double> _scaleAnimation; // ستبقى لتطبيق التكبير
  // نقطة المنتصف التي تتجه إليها الهدية سريعاً قبل انطلاق صور الانفجار.
  Offset? midPoint;
  // متحكم خاص لمرحلة التكبير في المركز (1 ثانية) مع تلاشي قبل بدء الانفجارات
  late AnimationController _centerScaleController;
  late Animation<double> _centerScaleAnimation;
  late Animation<double> _centerOpacityAnimation;
  bool _centerScaleStarted = false;
  bool _centerGone = false;
  // مؤقت إزالة إجباري في حال علقت الحركة لأي سبب. تقليل المدة يزيل الهدية أسرع، وزيادتها تُبقيها أطول.
  Timer? _forceRemovalTimer;
  // تم إزالة نظام الرتل - الآن يعرض الهدايا في Stack فوق بعض
  // لا يوجد عداد مرئي: الهدية صورة فقط لتقليل التعقيد وتحسين الأداء.

  // Shared provider to prevent flicker and reloads across center/bursts
  // نجعلها قابلة لإعادة الضبط لضمان العزل بين الهدايا المتتابعة
  late ImageProvider _imageProvider;

  // Burst animation system
  final List<AnimationController> _burstControllers = [];
  final List<Animation<Offset>> _burstAnimations = [];
  final List<Animation<double>> _burstOpacities = [];
  final List<Animation<double>> _burstScales = [];
  bool _burstStarted = false;
  // إخفاء ذاتي بعد الإنهاء لضمان عدم بقاء أي أثر بصري حتى لو لم يزل الوالد الودجت فوراً
  bool _hidden = false;
  // معرف جلسة للتأكد من عزل النداءات غير المتزامنة بين الهدايا المتتابعة
  int _sessionId = 0;
  // مفتاح الحدث الحالي لضمان عدم تشغيل نفس الهدية مرتين
  String? _currentEventKey;
  // هذا الودجت قد يكون Proxy إذا وُجد ويدجت أساسي لنفس المرسل/الهدية
  bool _isProxy = false;

  // ===== نظام العداد التراكمي المحترف =====
  static final Map<String, _ProfessionalGiftAccumulator> _globalAccumulators =
      {};
  String? _accumulatorKey;
  Timer? _persistentTimer;
  int _totalAccumulated = 0;
  // ignore: unused_field
  bool _isActivelyAccumulating = false;
  DateTime? _lastGiftTime;

  String _computeEventKey(GiftAnimationData d) {
    // استخدم معرف الهدية إن وُجد، وإلا timestamp، وإلا تجميعة ثابتة
    return d.giftId ??
        widget.giftId ??
        // اجعل المفتاح ثابتاً عبر إعادة البناء لنفس الحدث لتفادي تشغيله مرتين
        '${d.imageUrl}|${d.senderOffset.dx.toStringAsFixed(1)},${d.senderOffset.dy.toStringAsFixed(1)}|${d.targetOffset.dx.toStringAsFixed(1)},${d.targetOffset.dy.toStringAsFixed(1)}|${d.count}';
  }

  // مشغل الصوت لتشغيل صوت بدء/أثناء الهدية وإيقافه عند الانتهاء
  // تم تعطيل الصوت: لا نستخدم أي مشغل صوت الآن

  // حراسة الإنهاء لمنع تكرار onAnimationComplete/queue complete
  bool _completionFired = false;
  Future<void> _completeOnce() async {
    if (_completionFired) return;
    _completionFired = true;
    dev.log('✅ [COMPLETE_ONCE] Triggered. Starting aggressive cleanup.',
        name: 'GiftAnimation');

    // إيقاف الصوت والتخلص من المشغل
    await _stopAndDisposeAudio();

    // أوقف المؤقت الإجباري
    try {
      _forceRemovalTimer?.cancel();
    } catch (_) {}

    // أوقف المتحكم الرئيسي
    try {
      if (_controller.isAnimating) _controller.stop();
    } catch (_) {}

    // أوقف وألغِ جميع انفجارات الصور وأزلها
    for (final wd in _burstWatchdogs.values) {
      try {
        wd.cancel();
      } catch (_) {}
    }
    _burstWatchdogs.clear();
    for (final c in List<AnimationController>.from(_burstControllers)) {
      try {
        c.stop();
      } catch (_) {}
      try {
        c.dispose();
      } catch (_) {}
    }
    _burstControllers.clear();
    _burstAnimations.clear();
    _burstOpacities.clear();
    _burstScales.clear();

    // ألغِ مؤقتات مراحل العداد وأوقف محرك مقياس الشارة
    for (final t in _countStageTimers) {
      try {
        t.cancel();
      } catch (_) {}
    }
    _countStageTimers.clear();
    try {
      if (_badgeScaleController.isAnimating) {
        _badgeScaleController.stop();
      }
    } catch (_) {}

    // إخفاء الودجت بصرياً فوراً حتى لو لم يُزل من الشجرة بعد
    if (mounted) {
      setState(() {
        _hidden = true;
      });
    }

    // تم إزالة نظام الرتل - الهدايا تعرض مباشرة في Stack

    // إشعار الوالد لإزالته من الشجرة
    try {
      widget.onAnimationComplete();
    } catch (e) {
      dev.log('❌ [COMPLETE_ONCE] onAnimationComplete error: $e',
          name: 'GiftAnimation');
    }
  }

  // مراقبات لكل انفجار لضمان تنظيفه حتى لو لم يصل لحدث الحالة
  final Map<AnimationController, Timer> _burstWatchdogs = {};

  // Staged counter state for badge near center image
  List<int> _countStages = [];
  final List<Timer> _countStageTimers = [];
  bool _countStagingStarted = false;
  int _currentStageIndex = -1;
  int _displayedCount = 0;
  late final AnimationController _badgeScaleController;
  late final Animation<double> _badgeScaleAnimation;

  // أوزان المراحل في الحركة الموحدة + نقاط التبديل المحسوبة
  double _w1 = 25.0; // من المرسل إلى المركز
  double _w2 = 10.0; // توقف قصير في المركز
  double _w3 = 65.0; // من المركز إلى المستلم الأساسي
  double _breakCenter = 0.25; // نسبة الوصول للمركز
  double _breakBurst = 0.35; // نسبة بدء الانطلاق للمستلمين
  int _centerStageMs = 0; // المدة الفعلية لمرحلة المركز بالميللي ثانية
  // إظهار شارة العداد في المنتصف حتى اكتمال جميع المراحل
  bool _centerBadgeVisible = false;
  Timer? _centerBadgeHideTimer;

  // =============================
  // ثوابت لضبط القيم بسهولة
  // =============================
  static const int _kMainDurationMs = 2200; // مدة الحركة الموحدة الكاملة (أسرع)
  static const int _kBurstDurationMs = 450; // مدة طيران صورة الانفجار (أسرع)
  static const int _kForceRemovalMs =
      3600; // مهلة الإزالة الإجبارية (متوافقة مع الزيادة)
  static const int _kCenterScaleMs =
      900; // تقليل مدة التكبير قليلاً لفتح نافذة عدّ أسرع

  // توقيت عرض مراحل العداد (أسرع وبمظهر احترافي)
  static const int _kCountSwitchAnimMs =
      140; // انتقال أسرع للـ AnimatedSwitcher (Fade+Scale)
  static const int _kCenterBadgeHoldMs =
      220; // إبقاء الشارة زمناً أقصر بعد آخر قيمة
  static const int _kMinCountStageIntervalMs = 70; // فاصل أدنى أسرع بين القيم
  static const int _kMaxCountStageIntervalMs =
      130; // فاصل أقصى أقصر لضمان سرعة وجمالية

  static const double _kCenterImgSize = 64; // حجم صورة المركز (أكبر)
  static const double _kBurstImgSize = 56; // حجم صور الانفجار (أكبر قليلاً)
  static const double _kDecodeScale =
      1.25; // زيادة بسيطة لدقة الديكود لتحسين الحِدّة
  static const double _kCenterAlignDx = -10; // محاذاة مركز الصورة أفقياً
  static const double _kCenterAlignDy = -25; // محاذاة مركز الصورة عمودياً
  static const double _kBurstAlignDx =
      -10; // محاذاة صورة الانفجار أفقياً (مطابقة لمركز الصورة)
  static const double _kBurstAlignDy =
      -25; // محاذاة صورة الانفجار عمودياً (مطابقة لمركز الصورة)
  static const double _kSenderDeltaX = 10; // إزاحة المرسل يميناً
  static const double _kSenderDeltaY = 20; // إزاحة المرسل للأسفل
  static const double _kReceiverDeltaX = 10; // إزاحة المستلم يميناً
  static const double _kReceiverDeltaY = 20; // إزاحة المستلم للأسفل
  static const double _kUnderMicDeltaX = -5; // إزاحة أسفل المايك يساراً 5px
  static const double _kUnderMicDeltaY = 50; // إزاحة أسفل المايك للأسفل 50px
  // شبكة المقاعد والقيود العامة
  static const int _kGridColumns = 5; // عدد الأعمدة في الشبكة
  static const double _kSeatChildAspectRatio =
      0.8; // نسبة عرض/ارتفاع عنصر المقعد
  static const double _kInfoRowHeight = 60.0; // ارتفاع صف المعلومات أعلى الشبكة
  static const double _kClampPadding = 100.0; // هامش التثبيت خارج الشاشة
  // حذفنا الثوابت غير المستخدمة للنظام الجديد

  // نظام الحركة الموحدة الجديد
  late Animation<Offset> _unifiedPathAnimation; // الحركة الموحدة الكاملة
  bool _unifiedAnimationsReady = false;

  /// تحديث العداد المحترف (يتم استدعاؤها من _ProfessionalGiftAccumulator)
  void _updateProfessionalCounter(int totalCount) {
    if (!mounted) return;

    // إذا كان هذا أول تحديث أو العداد الجديد أكبر، قم بالتحديث
    if (_totalAccumulated != totalCount) {
      final previousCount = _totalAccumulated;
      _totalAccumulated = totalCount;
      _isActivelyAccumulating = true;
      _lastGiftTime = DateTime.now();

      // تحديث العداد المعروض في الشارة - يجب أن يعكس المجموع التراكمي
      _displayedCount = totalCount;

      // إظهار الشارة إذا لم تكن مرئية
      if (!_centerBadgeVisible) {
        _centerBadgeVisible = true;
      }

      dev.log(
          '🔄 [PROFESSIONAL] Updated counter: $previousCount → $totalCount (accumulated)',
          name: 'GiftAnimation');

      setState(() {});
    }
  }

  /// إخفاء العداد المحترف بعد انتهاء فترة الإرسال
  // ignore: unused_element
  void _hideProfessionalCounter() {
    if (!mounted) return;

    _isActivelyAccumulating = false;

    dev.log('⏹️ [PROFESSIONAL] Hiding counter. Final total: $_totalAccumulated',
        name: 'GiftAnimation');

    // إخفاء العداد تدريجياً
    Timer(const Duration(milliseconds: 300), () {
      if (mounted) {
        _centerBadgeVisible = false;
        setState(() {});

        // إزالة هذا الويدجت من المجمع العام (لكن احتفظ بالقيمة المتراكمة)
        if (_accumulatorKey != null) {
          final accumulator = _globalAccumulators[_accumulatorKey!];
          if (accumulator != null) {
            accumulator.removeWidget(this);
            // الاحتفاظ بالقيمة المتراكمة للاستخدام المستقبلي
            dev.log(
                '💾 [PROFESSIONAL] Preserved accumulated total: ${accumulator.totalGifts}',
                name: 'GiftAnimation');
          }
        }

        // إنهاء الأنيميشن
        Timer(const Duration(milliseconds: 200), () {
          if (mounted) {
            _completeOnce();
          }
        });
      }
    });
  }

  /// بدء النظام المحترف للتجميع
  void _startProfessionalAccumulation() {
    // إنشاء مفتاح فريد مبني على المرسل ونوع الهدية لضمان عدّاد واحد لكل مرسل
    final senderPos = widget.giftData.senderOffset;
    final targetPos = widget.giftData.targetOffset;
    final imageUrl = widget.giftData.imageUrl;
    // imageUrl غير قابلة لأن تكون null
    final giftKey = imageUrl;
    final giftType = widget.giftData.giftType?.toLowerCase();
    final bool isLucky = (giftType?.contains('lucky') ?? false) ||
        (giftType?.contains('حظ') ?? false);
    if (widget.giftData.senderId != null) {
      if (isLucky) {
        // عداد واحد لكل مرسل في هدايا الحظ
        _accumulatorKey = 'sender:${widget.giftData.senderId}|lucky';
      } else {
        _accumulatorKey = 'sender:${widget.giftData.senderId}|gift:$giftKey';
      }
    } else {
      // fallback بالإحداثيات إذا لم يتوفر senderId
      if (isLucky) {
        // ميز أيضاً حسب المستلم بالاعتماد على targetPos
        _accumulatorKey =
            'pos:${senderPos.dx.toInt()}_${senderPos.dy.toInt()}_${targetPos.dx.toInt()}_${targetPos.dy.toInt()}|lucky';
      } else {
        _accumulatorKey =
            'pos:${senderPos.dx.toInt()}_${senderPos.dy.toInt()}_${targetPos.dx.toInt()}_${targetPos.dy.toInt()}|gift:$giftKey';
      }
    }

    // إنشاء أو الحصول على المجمع العام
    if (!_globalAccumulators.containsKey(_accumulatorKey!)) {
      _globalAccumulators[_accumulatorKey!] = _ProfessionalGiftAccumulator();
      dev.log(
          '🆕 [PROFESSIONAL] Created new accumulator for key: $_accumulatorKey',
          name: 'GiftAnimation');
    }

    final accumulator = _globalAccumulators[_accumulatorKey!]!;

    // إن وُجد ويدجت أساسي (primary) لهذا المرسل/الهدية، اجعل هذا الودجت Proxy فقط
    if (accumulator.primaryWidget != null &&
        accumulator.primaryWidget!.mounted) {
      _isProxy = true;
      // مرّر هذه الهدية إلى الودجت الأساسي مباشرة
      accumulator.addGift(widget.giftData.count, accumulator.primaryWidget!);
      // أخفِ هذا الودجت ولا تعرض شيئاً
      _hidden = true;
      WidgetsBinding.instance.addPostFrameCallback((_) {
        if (mounted) {
          _completeOnce();
        }
      });
      dev.log(
          '🧭 [PROFESSIONAL] Proxy widget: forwarded count=${widget.giftData.count} to primary. key=$_accumulatorKey',
          name: 'GiftAnimation');
      return;
    }

    // عيّن هذا الودجت كودجت أساسي لهذا المفتاح
    accumulator.primaryWidget = this;

    // إذا كان هناك ويدجتات نشطة مسبقاً (حالات انتقالية)، أعد الضبط البصري
    if (accumulator.activeWidgets.isNotEmpty && accumulator.isDisplaying) {
      dev.log(
          '🔄 [PROFESSIONAL] Found existing active widgets (${accumulator.activeWidgets.length}), merging...',
          name: 'GiftAnimation');
      _totalAccumulated = accumulator.totalGifts;
      _displayedCount = accumulator.totalGifts;
      dev.log(
          '📊 [PROFESSIONAL] Starting from accumulated total: ${accumulator.totalGifts}',
          name: 'GiftAnimation');
    }

    // إضافة هذه الهدية إلى المجمع
    accumulator.addGift(widget.giftData.count, this);

    dev.log(
        '🎯 [PROFESSIONAL] Started accumulation for key: $_accumulatorKey, count: ${widget.giftData.count}',
        name: 'GiftAnimation');
  }

  @override
  // تنظيف كافة الموارد والمتحكمات لتجنب تسريب الذاكرة عند انتهاء الأنيميشن.
  // ملاحظة: إذا كان لديك مؤقتات إضافية وزدت عددها، احرص على إلغائها هنا.
  void dispose() {
    dev.log('🗑️ [DISPOSE] Disposing GiftAnimationWidget',
        name: 'GiftAnimation');

    // تأكد من إيقاف الصوت وتحرير المشغل
    _stopAndDisposeAudio();

    // إلغاء جميع المؤقتات
    _forceRemovalTimer?.cancel();
    _centerBadgeHideTimer?.cancel();

    _hidden = true;
    // إيقاف الأنيميشن وتنظيف الموارد
    if (_controller.isAnimating) {
      _controller.stop();
      dev.log('🚫 [DISPOSE] Stopped running animation', name: 'GiftAnimation');
    }
    _controller.dispose();

    // Dispose burst controllers
    for (final controller in _burstControllers) {
      try {
        controller.stop();
      } catch (_) {}
      controller.dispose();
    }

    // إلغاء جميع مراقبي الانفجارات
    for (final t in _burstWatchdogs.values) {
      t.cancel();
    }
    _burstWatchdogs.clear();

    // Cancel staged counter timers
    for (final t in _countStageTimers) {
      t.cancel();
    }
    // Dispose badge scale controller
    _badgeScaleController.dispose();
    // Dispose center scale controller
    try {
      _centerScaleController.dispose();
    } catch (_) {}
    // Dispose main controller
    try {
      _controller.dispose();
    } catch (_) {}

    // إزالة هذا الويدجت من المجمع العام
    if (_accumulatorKey != null) {
      _globalAccumulators[_accumulatorKey!]?.removeWidget(this);
    }

    // إلغاء مؤقت التجميع المحترف
    _persistentTimer?.cancel();

    super.dispose();
  }

  // Removed staged count display method (no on-screen counter)

  // إنشاء صور الانفجار التي تنطلق من نقطة المنتصف إلى مواقع المستلمين.
  // زيادة مدة الانطلاق تجعل الرحلة أطول وأهدأ، تقليلها يجعلها أسرع.
  void _createBurstAnimations() {
    // ابدأ الانفجارات من المركز حتى لو كان العداد = 1
    if (_burstStarted || midPoint == null) return;
    _burstStarted = true;

    // إنشاء انفجار باتجاه كل مستلم متاح
    final receiverPositions = _getAllReceiverPositions();

    // إذا لم يتم إيجاد أي مستقبلين، لا تنشئ انفجارات وتخرج
    if (receiverPositions.isEmpty) {
      if (kDebugMode) {
        dev.log('⚠️ [BURST] No receiver positions resolved. Skipping burst.',
            name: 'GiftAnimation');
      }
      return;
    }

    dev.log(
        '🎆 [BURST] Creating ${receiverPositions.length} burst(s) from center',
        name: 'GiftAnimation');

    for (final targetPosition in receiverPositions) {
      final controller = AnimationController(
        duration: const Duration(milliseconds: _kBurstDurationMs),
        vsync: this,
      );

      final animation = TweenSequence<Offset>([
        TweenSequenceItem(
          tween: Tween<Offset>(begin: midPoint!, end: targetPosition)
              .chain(CurveTween(curve: Curves.easeOutCubic)),
          weight: 100,
        ),
      ]).animate(controller);

      final opacityAnimation = Tween<double>(begin: 1.0, end: 0.0).animate(
        CurvedAnimation(parent: controller, curve: const Interval(0.85, 1.0)),
      );

      final scaleAnimation = Tween<double>(begin: 0.92, end: 1.0).animate(
        CurvedAnimation(
          parent: controller,
          curve: const Interval(0.0, 0.25, curve: Curves.easeOutBack),
        ),
      );

      _burstControllers.add(controller);
      _burstAnimations.add(animation);
      _burstOpacities.add(opacityAnimation);
      _burstScales.add(scaleAnimation);

      controller.addStatusListener((status) {
        if (status == AnimationStatus.completed ||
            status == AnimationStatus.dismissed) {
          if (!mounted) return;
          final wd = _burstWatchdogs.remove(controller);
          wd?.cancel();
          setState(() {
            final idx = _burstControllers.indexOf(controller);
            if (idx != -1) {
              _burstControllers.removeAt(idx);
              _burstAnimations.removeAt(idx);
              _burstOpacities.removeAt(idx);
              if (idx < _burstScales.length) {
                _burstScales.removeAt(idx);
              }
            }
            controller.dispose();
          });
          dev.log('🧹 [BURST] Controller cleaned via status: $status',
              name: 'GiftAnimation');

          // أكمل الهدية فقط عند انتهاء جميع الانفجارات
          if (_burstControllers.isEmpty) {
            try {
              _forceRemovalTimer?.cancel();
            } catch (_) {}
            try {
              if (_controller.isAnimating) {
                _controller.stop();
              }
            } catch (_) {}
            dev.log('🏁 [BURST_DONE] All bursts completed — completing gift',
                name: 'GiftAnimation');
            _completeOnce();
          }
        }
      });

      final watchdogDelayMs = _kBurstDurationMs + 300;
      final watchdog = Timer(Duration(milliseconds: watchdogDelayMs), () {
        if (!mounted) return;
        final idx = _burstControllers.indexOf(controller);
        if (idx != -1) {
          try {
            controller.stop();
          } catch (_) {}
          setState(() {
            _burstControllers.removeAt(idx);
            _burstAnimations.removeAt(idx);
            _burstOpacities.removeAt(idx);
            if (idx < _burstScales.length) {
              _burstScales.removeAt(idx);
            }
          });
          controller.dispose();
        }
        _burstWatchdogs.remove(controller);
        dev.log('⏱️ [BURST] Watchdog cleaned controller',
            name: 'GiftAnimation');

        // أكمل الهدية عند انتهاء جميع الانفجارات
        if (_burstControllers.isEmpty) {
          try {
            _forceRemovalTimer?.cancel();
          } catch (_) {}
          try {
            if (_controller.isAnimating) {
              _controller.stop();
            }
          } catch (_) {}
          dev.log('🏁 [BURST_DONE][WD] All bursts completed — completing gift',
              name: 'GiftAnimation');
          _completeOnce();
        }
      });

      _burstWatchdogs[controller] = watchdog;

      // بدء فوري للانفجار لكل مستلم
      dev.log(
          '🚀 [BURST] Starting burst to ${targetPosition.dx.toInt()},${targetPosition.dy.toInt()}',
          name: 'GiftAnimation');
      controller.forward();
    }

    // إعادة البناء لإظهار عناصر الانفجار الجديدة في الواجهة
    if (mounted) {
      setState(() {});
      dev.log(
          '🎨 [BURST_UI] Rebuilt with ${receiverPositions.length} burst item(s)',
          name: 'GiftAnimation');
    }
  }

  // تحديد جميع مواقع المستلمين:
  // 1) إذا تم تمرير إزاحات جاهزة receiverOffsets سيتم استخدامها مباشرة (أدق شيء).
  // 2) إن لم توجد، نحاول حلها بواسطة معرفات المستلمين عبر SeatPositionManager (دقة جيدة).
  // 3) إن فشل كل ذلك، نستخدم الهدف المفرد targetOffset كخطة أخيرة.
  // ملاحظة: زيادة عدد المستلمين يزيد عدد صور الانفجار والحمل على الواجهة.
  List<Offset> _getAllReceiverPositions() {
    // الأولوية لقائمة الإزاحات الجاهزة
    if (widget.giftData.receiverOffsets != null &&
        widget.giftData.receiverOffsets!.isNotEmpty) {
      // استخدم الإزاحات الموفرة كما هي دون تصحيح إضافي لتجنب انحراف الصفوف
      final list = widget.giftData.receiverOffsets!.toList();
      dev.log('🎯 [BURST] Using provided receiverOffsets as-is: ${list.length}',
          name: 'GiftAnimation');
      return list;
    }

    // ثم نحاول عبر معرفات المستلمين
    if (widget.giftData.receiverIds != null &&
        widget.giftData.receiverIds!.isNotEmpty) {
      final list = <Offset>[];
      for (final id in widget.giftData.receiverIds!) {
        final p = SeatPositionManager().getUserPosition(id);
        if (p != null) {
          // إضافة إزاحة تحت المايك لتحسين دقة الوصول أسفل صورة المستخدم
          list.add(Offset(
            p.dx + _kReceiverDeltaX + _kUnderMicDeltaX,
            p.dy + _kReceiverDeltaY + _kUnderMicDeltaY,
          ));
        }
      }
      if (list.isNotEmpty) {
        dev.log('🎯 [BURST] Resolved ${list.length} receiverIds to positions',
            name: 'GiftAnimation');
        return list;
      }
    }

    // fallback: الموضع التقليدي المفرد
    final mainTarget =
        _validateAndCorrectSeatPosition(widget.giftData.targetOffset, false);
    dev.log('🎯 [BURST] Fallback single target', name: 'GiftAnimation');
    return [mainTarget];
  }

  /// حساب عدد المقاعد الفعلي (مطابق لـ RoomViewBody)
  // تحديد العدد الفعلي للمقاعد للاعتماد عليه في الحسابات. استخدام قيمة أكبر يؤثر على ارتفاع الشبكة وتوزيع الصفوف.
  int _calculateActualSeatCount() {
    try {
      // استخدام نفس المصدر المستخدم في RoomViewBody
      final micNumber = widget.giftData.microphoneNumber ?? "20";
      return int.parse(micNumber);
    } catch (e) {
      return 20; // نفس القيمة الافتراضية في RoomViewBody
    }
  }

  /// حساب ارتفاع الشبكة (مطابق تماماً لـ RoomViewBody._calculateGridHeight)
  // حساب ارتفاع شبكة المقاعد بناءً على عدد المايكات.
  // تغيير هذه القيم الثلاث سيؤثر مباشرة على موضع الصور بالنسبة للشبكة.
  double _calculateGridHeight(int micNumber) {
    return micNumber == 20
        ? 340.0
        : micNumber == 15
            ? 250.0
            : 170.0;
  }

  /// حساب موضع مقعد محدد (محسن لمطابقة GridView الفعلي في RoomViewBody)
  // حساب موضع مقعد محدد داخل شبكة 5 أعمدة.
  // columns=5: زيادتها تعني أعمدة أكثر ومقاعد أضيق؛ تقليلها يعرض أعمدة أقل ومقاعد أعرض.
  // childAspectRatio=0.8: تغييرها يغير نسبة عرض/ارتفاع المقعد، وبالتالي يؤثر على حساب y النهائي.
  Offset _calculateSeatPosition(
      int seatIndex, Size screenSize, double gridHeight) {
    const columns = _kGridColumns;
    final row = seatIndex ~/ columns;
    final column = seatIndex % columns;

    final screenWidth = screenSize.width;
    final micNumber = _calculateActualSeatCount();
    final rowsCount = (micNumber / columns).ceil();

    // حساب أبعاد المقعد الفعلية مع مراعاة childAspectRatio
    // childAspectRatio = width / height = 72.0 / 90.0 = 0.8
    const double childAspectRatio =
        _kSeatChildAspectRatio; // رفعها يقلل الارتفاع لكل مقعد، خفضها يزيد الارتفاع
    final double seatWidth = screenWidth / columns;
    final double seatHeight =
        seatWidth / childAspectRatio; // الارتفاع الفعلي للمقعد

    // حساب الارتفاع الفعلي للمقعد
    final double actualSeatHeight = gridHeight / rowsCount;

    // استخدام الارتفاع الأصغر للدقة (مقارنة بين النسبة المحسوبة والفعلية)
    final double finalSeatHeight = math.min(seatHeight, actualSeatHeight);

    const appBarHeight = kToolbarHeight;
    final statusBarHeight = MediaQuery.of(context).padding.top;
    const double infoRowHeight = _kInfoRowHeight; // ارتفاع صف المعلومات

    // حساب الإحداثيات مع مراعاة الأبعاد الفعلية
    final x = column * seatWidth + (seatWidth / 2);
    final y = appBarHeight +
        statusBarHeight +
        infoRowHeight +
        (row * finalSeatHeight) +
        (finalSeatHeight / 2);

    dev.log('🎯 Seat Position Calculation:', name: 'GiftAnimation');
    dev.log('Seat Index: $seatIndex (Row: $row, Col: $column)',
        name: 'GiftAnimation');
    dev.log('Screen: ${screenSize.width}x${screenSize.height}',
        name: 'GiftAnimation');
    dev.log('Grid Height: $gridHeight, Rows: $rowsCount',
        name: 'GiftAnimation');
    dev.log('Seat Size: ${seatWidth}x$finalSeatHeight', name: 'GiftAnimation');
    dev.log('Final Position: ($x, $y)', name: 'GiftAnimation');

    return Offset(x, y);
  }

  // تم حذف _getActualUserImagePosition لأنها غير مستخدمة
  // نستخدم SeatPositionManager.getUserPosition() مباشرة في _validateAndCorrectSeatPosition()

  // تم حذف _calculateFallbackPosition و _findSeatItemViewByIndex لأنها غير مستخدمة
  // نستخدم SeatPositionManager بدلاً منها

  /// الحصول على موضع المرسل الفعلي مع تعديل الموضع
  // الحصول على موضع المرسل الحقيقي من SeatPositionManager (أدق من الحساب الثابت)
  // الإزاحة +10 يمين +20 أسفل: زيادة هذه القيم تُحرّك الصورة بعيداً عن مركز المايك؛ تقليلها يقربها.
  Offset? _getSenderPosition() {
    if (widget.giftData.senderId != null) {
      dev.log('🔍 Looking for sender ID: ${widget.giftData.senderId}',
          name: 'GiftAnimation');
      final senderPosition =
          SeatPositionManager().getUserPosition(widget.giftData.senderId!);
      if (senderPosition != null) {
        // تعديل الموضع: +10 يمين، +20 أسفل
        final adjustedPosition = Offset(
          senderPosition.dx + _kSenderDeltaX,
          senderPosition.dy + _kSenderDeltaY,
        );
        dev.log(
            '✅ Found sender position from SeatPositionManager: $senderPosition',
            name: 'GiftAnimation');
        dev.log('🎯 Adjusted sender position: $adjustedPosition',
            name: 'GiftAnimation');
        return adjustedPosition;
      } else {
        dev.log(
            '❌ Sender position NOT found in SeatPositionManager for ID: ${widget.giftData.senderId}',
            name: 'GiftAnimation');
      }
    } else {
      dev.log('⚠️ No senderId provided in giftData', name: 'GiftAnimation');
    }
    return null;
  }

  /// الحصول على موضع المستلم الفعلي مع تعديل الموضع
  // الحصول على موضع المستلم الحقيقي بنفس منطق المرسل مع نفس الإزاحات.
  Offset? _getReceiverPosition() {
    if (widget.giftData.receiverId != null) {
      dev.log('🔍 Looking for receiver ID: ${widget.giftData.receiverId}',
          name: 'GiftAnimation');
      final receiverPosition =
          SeatPositionManager().getUserPosition(widget.giftData.receiverId!);
      if (receiverPosition != null) {
        // تعديل الموضع: +10 يمين، +20 أسفل
        final adjustedPosition = Offset(
          receiverPosition.dx + _kReceiverDeltaX,
          receiverPosition.dy + _kReceiverDeltaY,
        );
        dev.log(
            '✅ Found receiver position from SeatPositionManager: $receiverPosition',
            name: 'GiftAnimation');
        dev.log('🎯 Adjusted receiver position: $adjustedPosition',
            name: 'GiftAnimation');
        return adjustedPosition;
      } else {
        dev.log(
            '❌ Receiver position NOT found in SeatPositionManager for ID: ${widget.giftData.receiverId}',
            name: 'GiftAnimation');
      }
    } else {
      dev.log('⚠️ No receiverId provided in giftData', name: 'GiftAnimation');
    }
    return null;
  }

  /// التحقق من صحة موضع المقعد وتصحيحه إذا لزم الأمر
  // التحقق من موضع المقعد:
  // - أولاً نحاول إرجاع موضع فعلي من SeatPositionManager إن وُجد (أفضل دقة).
  // - إن لم يوجد، نحسب المقعد الأقرب حسابياً من الإحداثيات ونعيد موضعه الصحيح.
  // - ثم نضيف إزاحة أسفل المايك لتجنب تغطية الصورة.
  Offset _validateAndCorrectSeatPosition(
      Offset originalPosition, bool isSender) {
    dev.log(
        '🔧 Validating ${isSender ? "sender" : "receiver"} position: $originalPosition',
        name: 'GiftAnimation');

    // محاولة الحصول على الموضع الفعلي من SeatPositionManager
    final actualPosition =
        isSender ? _getSenderPosition() : _getReceiverPosition();
    if (actualPosition != null) {
      // تطبيق إزاحة تحت المايك مباشرة باستخدام الثوابت المضبوطة
      final adjusted = Offset(
        actualPosition.dx + _kUnderMicDeltaX, // يسار/يمين حسب القيمة
        actualPosition.dy +
            _kUnderMicDeltaY, // أسفل/أعلى حسب القيمة (حالياً 50px للأسفل)
      );
      dev.log('🎯 Final adjusted actual position (bottom of mic): $adjusted',
          name: 'GiftAnimation');
      return adjusted;
    }

    // استخدام الحساب التقليدي كحل احتياطي
    Offset base = _fallbackCorrectedPosition(originalPosition);

    // إذا كان المرسل غير موجود على المايك ونريد البدء من المركز، استخدم centerOffset
    if (isSender && actualPosition == null) {
      final bool fromCenter = widget.giftData.startFromCenterIfSenderMissing;
      if (fromCenter) {
        base = widget.giftData.centerOffset;
        dev.log('🎯 Using center as sender base (sender not on mic)',
            name: 'GiftAnimation');
      }
    }
    // تطبيق نفس إزاحة تحت المايك باستخدام الثوابت
    final adjusted = Offset(
      base.dx + _kUnderMicDeltaX,
      base.dy + _kUnderMicDeltaY,
    );
    dev.log('🎯 Final adjusted fallback position (bottom of mic): $adjusted',
        name: 'GiftAnimation');
    return adjusted;
  }

  // الحساب الاحتياطي لتصحيح الموضع عندما لا تتوفر إحداثيات فعلية من SeatPositionManager
  Offset _fallbackCorrectedPosition(Offset originalPosition) {
    dev.log('⚠️ No actual position found, using calculation fallback',
        name: 'GiftAnimation');

    final screenSize = MediaQuery.of(context).size;
    final seatCount = _calculateActualSeatCount();
    final gridHeight = _calculateGridHeight(seatCount);

    // حساب أي مقعد يقع في هذا الموضع تقريباً
    const int columns = _kGridColumns;
    final double seatWidth = screenSize.width / columns;
    final int column =
        (originalPosition.dx / seatWidth).round().clamp(0, columns - 1);

    // حساب الصف بناءً على الموضع العمودي
    const double appBarHeight = kToolbarHeight;
    final double statusBarHeight = MediaQuery.of(context).padding.top;
    const double infoRowHeight = _kInfoRowHeight;
    final double gridStartY = appBarHeight + statusBarHeight + infoRowHeight;

    final double relativeY = originalPosition.dy - gridStartY;
    final int rowsCount = (seatCount / columns).ceil();
    final double seatHeight = gridHeight / rowsCount;
    final int row = (relativeY / seatHeight).round().clamp(0, rowsCount - 1);

    final int estimatedSeatIndex = (row * columns) + column;
    final int finalSeatIndex = estimatedSeatIndex.clamp(0, seatCount - 1);

    dev.log('🎯 Estimated seat: $finalSeatIndex (row: $row, col: $column)',
        name: 'GiftAnimation');
    dev.log('Grid start Y: $gridStartY, Relative Y: $relativeY',
        name: 'GiftAnimation');
    dev.log('Seat height: $seatHeight, Rows: $rowsCount',
        name: 'GiftAnimation');

    // احسب الموضع الصحيح لهذا المقعد
    final correctPosition =
        _calculateSeatPosition(finalSeatIndex, screenSize, gridHeight);

    dev.log('🎯 Base seat position (before under-mic offset): $correctPosition',
        name: 'GiftAnimation');
    // نعيد الموضع الأساسي فقط، وسيُطبَّق تعويض أسفل المايك في الدالة الرئيسية
    return correctPosition;
  }

  @override
  // تهيئة المتحكمات والمتحركات ومؤقت الإزالة.
  // duration=2200ms: زيادتها تبقي الهدية على الشاشة مدة أطول (ومزامنة أطول للانفجارات)، تقليلها يسرّع كل شيء.
  void initState() {
    super.initState();

    // فحص نوع الهدية - يجب أن تكون lucky فقط
    final giftType = widget.giftData.giftType?.toLowerCase();
    if (giftType != null && giftType != 'lucky') {
      dev.log(
          '❌ [INIT] GiftAnimationWidget مخصص لهدايا الحظ (lucky) فقط! تم استقبال: $giftType',
          name: 'GiftAnimation');
      dev.log(
          '⚠️ [INIT] يجب استخدام OptimizedGiftAnimationWidget أو widget آخر للهدايا العادية',
          name: 'GiftAnimation');
      // إنهاء فوري للهدايا غير المناسبة
      WidgetsBinding.instance.addPostFrameCallback((_) {
        if (mounted) {
          widget.onAnimationComplete();
        }
      });
      return;
    }

    if (kDebugMode) {
      dev.log(
          '🚀 [INIT] GiftAnimationWidget init for LUCKY gift. giftId=${widget.giftId}',
          name: 'GiftAnimation');
    }

    // بدء النظام المحترف للتجميع
    _startProfessionalAccumulation();

    // تأكد من أن العداد يعكس القيمة المتراكمة الحالية
    if (_totalAccumulated > 0) {
      _displayedCount = _totalAccumulated;
      dev.log(
          '🔢 [INIT] Set displayed count to accumulated: $_totalAccumulated',
          name: 'GiftAnimation');
    }

    // ابدأ جلسة جديدة لهذا التشغيل
    _sessionId++;
    final int session = _sessionId;
    _controller = AnimationController(
      duration: const Duration(milliseconds: _kMainDurationMs),
      vsync: this,
    );
    // سجل مفتاح الحدث الحالي لمنع التكرار
    _currentEventKey = _computeEventKey(widget.giftData);

    // Initialize badge scale controller/animation early to avoid late init errors
    _badgeScaleController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 180), // نبضة أسرع
      reverseDuration: const Duration(milliseconds: 120),
    );
    _badgeScaleAnimation = Tween<double>(begin: 1.0, end: 1.22)
        .chain(CurveTween(curve: Curves.easeOutBack))
        .animate(_badgeScaleController);

    // إضافة listener لتتبع حالة الحركة
    // مراقبة حالة الحركة لأغراض التصحيح فقط.
    _controller.addStatusListener((status) {
      if (kDebugMode) {
        dev.log('🎬 Animation status: $status', name: 'GiftAnimation');
        if (status == AnimationStatus.completed) {
          dev.log('🎯 Animation reached target position',
              name: 'GiftAnimation');
        }
      }
    });

    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (!mounted || session != _sessionId) return;
      setState(() {
        // Prepare a single cached provider and warm it up once
        _imageProvider = CachedNetworkImageProvider(
            widget.giftData.imageUrl); // مصدر الصورة الموحد لتجنب وميض التحميل
        // Precaching avoids visible blanks when many burst images start
        try {
          precacheImage(_imageProvider,
              context); // التخزين المسبق يقلل التأخير والوميض عند بدء الانفجارات
        } catch (_) {}
        // استخدام centerOffset مع إزاحة Y اختيارية من GiftAnimationData (افتراضياً 70px)
        final originalCenter = widget.giftData.centerOffset;
        final dy = widget.giftData.centerYOffset ?? 70;
        midPoint = originalCenter + Offset(0, dy);
        if (kDebugMode) {
          dev.log(
              '📍 [CENTER] Shifted center by +$dy on Y: $originalCenter -> $midPoint',
              name: 'GiftAnimation');
        }

        _initializeAnimations();
        if (kDebugMode) {
          dev.log(
              '🧭 [INIT] Animations initialized. sender=${widget.giftData.senderOffset} target=${widget.giftData.targetOffset} mid=$midPoint',
              name: 'GiftAnimation');
        }

        // Removed staged counter setup

        // إعداد مستمعي الحركة: عند الوصول للمركز، نفّذ مرحلة التكبير ثم ابدأ الانفجار
        _controller.addListener(() {
          if (session != _sessionId) return; // تجاهل إشارات جلسة قديمة
          final progress = _controller.value;

          // عند الوصول للمركز: ابدأ العداد
          if (progress >= _breakCenter && !_countStagingStarted) {
            _startCountStaging();
            dev.log('🎯 [CENTER] Reached center, starting count staging',
                name: 'GiftAnimation');
          }

          // ابدأ مرحلة التكبير في المركز مرة واحدة فقط
          if (progress >= _breakCenter && !_centerScaleStarted) {
            _centerScaleStarted = true;
            try {
              _centerScaleController.forward();
            } catch (_) {}
            // ابدأ الانفجارات فور بدء التكبير (بدلاً من الانتظار للنهاية)
            if (!_burstStarted) {
              _createBurstAnimations();
              dev.log('💥 [CENTER] Launched burst animations at scale start',
                  name: 'GiftAnimation');
            }
            dev.log('🔍 [CENTER] Starting center scale animation (1s)',
                name: 'GiftAnimation');
          }
        });
        _unifiedAnimationsReady = true;
        dev.log('✅ [UNIFIED] All animations initialized successfully',
            name: 'GiftAnimation');

        // مؤقت إجباري لضمان الإزالة حتى لو تعلقت الحركة
        // اجعل المدة آمنة: على الأقل _kForceRemovalMs أو (_kMainDurationMs + (is77?2000:0) + 600ms)
        final bool is77 = widget.giftData.count == 77;
        final int forceMs = math.max(
          _kForceRemovalMs,
          _kMainDurationMs + (is77 ? 2000 : 0) + 600,
        );
        // Removed multiple CachedNetworkImage resolves and replaced with a single shared ImageProvider
        // for all instances, precached once, to avoid flicker and reloads.
        // مؤقت إزالة إجباري: 2400ms بعد بدء الحركة
        // زيادته قد يبقي ودجت عالق أطول في حالات نادرة؛ تقليله قد يزيل قبل اكتمال بعض الانفجارات.
        _forceRemovalTimer = Timer(Duration(milliseconds: forceMs), () {
          if (mounted) {
            if (kDebugMode) {
              dev.log(
                  '🚨 [FORCE_REMOVAL] Removing stuck gift animation after 2.4s',
                  name: 'GiftAnimation');
            }

            _completeOnce();
          }
        });

        // بدء الحركة الرئيسية ثم الانتظار لفترة تسمح للانفجارات بإكمال حركتها قبل التنظيف.
        _controller.forward().then((_) {
          if (session != _sessionId) return; // تجاهل إكمال جلسة قديمة
          // Wait briefly for burst animations to complete
          Future.delayed(Duration(milliseconds: forceMs), () {
            if (session != _sessionId) return; // تجاهل تأخير جلسة قديمة
            // وقت انتظار إضافي للانفجارات
            // إلغاء المؤقت الإجباري إذا انتهت الحركة بشكل طبيعي
            _forceRemovalTimer?.cancel();

            if (kDebugMode) {
              dev.log(
                  '✅ [ANIMATION_COMPLETE] Gift animation completed normally',
                  name: 'GiftAnimation');
            }

            // استدعاء إنهاء موحّد مرة واحدة فقط
            Future.delayed(const Duration(milliseconds: 100), () {
              if (session != _sessionId) return;
              if (!mounted) return;
              if (kDebugMode) {
                dev.log('🧹 [CLEANUP] Removing gift animation from UI',
                    name: 'GiftAnimation');
              }
              _completeOnce();
            });
          });
        }).catchError((error) {
          // معالجة الأخطاء في الأنيميشن
          if (kDebugMode) {
            dev.log('❌ [ANIMATION_ERROR] Animation failed: $error',
                name: 'GiftAnimation');
          }
          _forceRemovalTimer?.cancel();

          if (mounted) {
            _completeOnce();
          }
        });
      });

      // تشغيل صوت الهدية (Fire-and-forget)
      _startGiftSound();
    });
  }

  @override
  void didUpdateWidget(covariant GiftAnimationWidget oldWidget) {
    super.didUpdateWidget(oldWidget);
    final newKey = _computeEventKey(widget.giftData);
    if (newKey != _currentEventKey) {
      _currentEventKey = newKey;
      dev.log('♻️ [UPDATE] Gift changed, restarting animation flow',
          name: 'GiftAnimation');
      _restartForNewGift();
    } else {
      if (kDebugMode) {
        dev.log(
            '🔁 [UPDATE] Same event key detected, ignoring update (no double play).',
            name: 'GiftAnimation');
      }
    }
  }

  // إعادة بدء الودجت بهدية جديدة بنفس حالة الشجرة بدون تسرب حالة من السابقة
  Future<void> _restartForNewGift() async {
    // ابدأ جلسة جديدة لهذه الهدية
    _sessionId++;
    final int session = _sessionId;
    // أوقف الصوت وألغِ المؤقتات الحالية
    await _stopAndDisposeAudio();
    try {
      _forceRemovalTimer?.cancel();
    } catch (_) {}
    try {
      _centerBadgeHideTimer?.cancel();
    } catch (_) {}

    // أوقف وحرر جميع انفجارات الصور ومراقباتها
    for (final wd in _burstWatchdogs.values) {
      try {
        wd.cancel();
      } catch (_) {}
    }
    _burstWatchdogs.clear();
    for (final c in List<AnimationController>.from(_burstControllers)) {
      try {
        c.stop();
      } catch (_) {}
      try {
        c.dispose();
      } catch (_) {}
    }
    _burstControllers.clear();
    _burstAnimations.clear();
    _burstOpacities.clear();
    _burstScales.clear();

    // ألغِ مؤقتات مراحل العداد
    for (final t in _countStageTimers) {
      try {
        t.cancel();
      } catch (_) {}
    }
    _countStageTimers.clear();

    // أوقف وتخلص من المتحكمات الرئيسية وأعد إنشاءها
    try {
      _controller.stop();
    } catch (_) {}
    try {
      _controller.dispose();
    } catch (_) {}
    try {
      _centerScaleController.dispose();
    } catch (_) {}

    // إعادة ضبط الحالات
    _completionFired = false;
    _burstStarted = false;
    _centerScaleStarted = false;
    _centerGone = false;
    _hidden = false;
    _unifiedAnimationsReady = false;
    _countStagingStarted = false;
    _currentStageIndex = -1;
    // لا تعيد تعيين _displayedCount هنا - سيتم تعيينه في _updateProfessionalCounter
    midPoint = null;

    // احفظ مفتاح الحدث الجديد كالمفعل حالياً
    _currentEventKey = _computeEventKey(widget.giftData);

    // إنشاء المتحكمات من جديد
    _controller = AnimationController(
      duration: const Duration(milliseconds: _kMainDurationMs),
      vsync: this,
    );
    _centerScaleController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: _kCenterScaleMs),
    );

    // أعِد تهيئة الصورة وتهيئة الحركة والبدء
    _imageProvider = CachedNetworkImageProvider(widget.giftData.imageUrl);
    try {
      precacheImage(_imageProvider, context);
    } catch (_) {}

    // حساب مركز جديد بحسب البيانات
    final originalCenter = widget.giftData.centerOffset;
    final dy = widget.giftData.centerYOffset ?? 70;
    midPoint = originalCenter + Offset(0, dy);

    _initializeAnimations();

    // إعادة ربط مستمع الوصول للمركز لبدء التكبير والانفجار
    _controller.addListener(() {
      if (session != _sessionId) return; // تجاهل إشارات جلسة قديمة
      final progress = _controller.value;
      if (progress >= _breakCenter && !_countStagingStarted) {
        _startCountStaging();
      }
      if (progress >= _breakCenter && !_centerScaleStarted) {
        _centerScaleStarted = true;
        try {
          _centerScaleController.forward();
        } catch (_) {}
        if (!_burstStarted) {
          _createBurstAnimations();
        }
      }
    });

    _unifiedAnimationsReady = true;

    // مؤقت إزالة إجباري للحالة الجديدة
    final bool is77 = widget.giftData.count == 77;
    final int forceMs = math.max(
      _kForceRemovalMs,
      _kMainDurationMs + (is77 ? 2000 : 0) + 600,
    );
    _forceRemovalTimer = Timer(Duration(milliseconds: forceMs), () {
      if (session != _sessionId) return; // تجاهل مؤقت جلسة قديمة
      if (mounted) {
        if (kDebugMode) {
          dev.log('🚨 [FORCE_REMOVAL][RESTART] Removing stuck gift animation',
              name: 'GiftAnimation');
        }
        _completeOnce();
      }
    });

    // ابدأ الحركة من جديد مع سلسلة إكمال مماثلة
    _controller.forward().then((_) {
      if (session != _sessionId) return; // تجاهل إكمال جلسة قديمة
      Future.delayed(Duration(milliseconds: forceMs), () {
        if (session != _sessionId) return; // تجاهل تأخير جلسة قديمة
        _forceRemovalTimer?.cancel();
        if (kDebugMode) {
          dev.log('✅ [ANIMATION_COMPLETE][RESTART] Completed normally',
              name: 'GiftAnimation');
        }
        Future.delayed(const Duration(milliseconds: 100), () {
          if (session != _sessionId) return;
          if (!mounted) return;
          _completeOnce();
        });
      });
    }).catchError((_) {
      _forceRemovalTimer?.cancel();
      if (mounted) _completeOnce();
    });
  }

  /// تشغيل صوت الهدية عند البداية (معطل)
  Future<void> _startGiftSound() async {
    // الصوت معطل: لا تفعل شيئاً
    return;
  }

  /// إيقاف الصوت والتخلص من المشغل بأمان (معطل)
  Future<void> _stopAndDisposeAudio() async {
    // الصوت معطل: لا تفعل شيئاً
    return;
  }

  /// إعداد الحركة:
  /// المرحلة 1: من المرسل إلى المركز
  /// المرحلة 2: تثبيت في المركز بينما يجري تكبير الصورة (1s) ثم تختفي، وبعدها تنطلق الانفجارات إلى المستلمين
  void _initializeAnimations() {
    if (midPoint == null) return;

    // Remove unused variable

    // تصحيح مواضع المقاعد إذا كانت خاطئة
    final correctedSenderOffset =
        _validateAndCorrectSeatPosition(widget.giftData.senderOffset, true);
    final correctedTargetOffset =
        _validateAndCorrectSeatPosition(widget.giftData.targetOffset, false);

    // تسجيل معلومات التصحيح
    dev.log('🎁 Gift Animation Positions:', name: 'GiftAnimation');
    dev.log('Original Sender: ${widget.giftData.senderOffset}',
        name: 'GiftAnimation');
    dev.log('Corrected Sender: $correctedSenderOffset', name: 'GiftAnimation');
    dev.log('Original Target: ${widget.giftData.targetOffset}',
        name: 'GiftAnimation');
    dev.log('Corrected Target: $correctedTargetOffset', name: 'GiftAnimation');
    dev.log('Mid Point: $midPoint', name: 'GiftAnimation');

    // إضافة logs إضافية لفهم المشكلة
    dev.log('🔍 Debug Info:', name: 'GiftAnimation');
    dev.log('Mic Number: ${widget.giftData.microphoneNumber}',
        name: 'GiftAnimation');
    dev.log('Seat Count: ${_calculateActualSeatCount()}',
        name: 'GiftAnimation');
    dev.log('Grid Height: ${_calculateGridHeight(_calculateActualSeatCount())}',
        name: 'GiftAnimation');

    // لم نعد نحتاج هدفاً أساسياً للصورة المركزية؛ سيتم الانفجار بعد التكبير مباشرة

    // أوزان ثابتة: وصول للمركز ثم تثبيت هناك (لا مرحلة انتقال إلى المستلم بالصورة المركزية)
    const double totalWeight = 100.0;
    _w1 = 15.0; // وصول سريع ولكن ليس مبالغاً (~15%)
    _w2 = 85.0; // الباقي تثبيت في المركز
    _w3 = 0.0; // إزالة مرحلة الانتقال للمستلم بالصورة المركزية

    // نقاط التبديل (كنسب تقدم من 0..1)
    _breakCenter = _w1 / totalWeight;
    _breakBurst = _breakCenter; // لم نعد نستخدم مرحلة طيران للصورة المركزية
    // احسب مدة مرحلة المركز فعلياً بالميلي ثانية لاستخدامها في جدولة العداد (قد تتجاوز 1s)
    _centerStageMs = ((_w2 / totalWeight) * _kMainDurationMs).round();

    dev.log(
        '🧮 [UNIFIED_WEIGHTS] w1=$_w1, w2=$_w2, w3=$_w3, breakCenter=$_breakCenter, breakBurst=$_breakBurst',
        name: 'GiftAnimation');

    // إنشاء الحركة الموحدة الكاملة بالأوزان المحسوبة
    _unifiedPathAnimation = TweenSequence<Offset>([
      // المرحلة 1: من المرسل إلى المركز (سريع)
      TweenSequenceItem(
        tween: Tween<Offset>(
          begin: correctedSenderOffset,
          end: midPoint!,
        ).chain(CurveTween(
            curve: Curves
                .linearToEaseOut)), // منحنى سريع في البداية ثم يهدأ للوصول للمركز
        weight: _w1,
      ),
      // المرحلة 2: توقف قصير في المركز
      TweenSequenceItem(
        tween: Tween<Offset>(
          begin: midPoint!,
          end: midPoint!,
        ),
        weight: _w2,
      ),
      // لا توجد مرحلة ثالثة: بعد التثبيت بالمركز، يتم التكبير ثم الانفجار فقط
    ]).animate(_controller);

    // لا نحتاج الحركة القديمة بعد الآن - نستخدم _unifiedPathAnimation فقط

    // حجم ثابت: جميع الصور (المركزية والانفجارية) بنفس الحجم الثابت
    _scaleAnimation = Tween<double>(
      begin: 1.0,
      end: 1.0, // الأساس سيبقى 1.0؛ التكبير سيتم عبر _centerScaleAnimation
    ).animate(_controller);

    // تهيئة متحكم التكبير في المركز والشفافية (1 ثانية)
    _centerScaleController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: _kCenterScaleMs),
    );
    _centerScaleAnimation = Tween<double>(begin: 1.0, end: 2.2)
        .chain(CurveTween(curve: Curves.easeOutBack))
        .animate(_centerScaleController);
    _centerOpacityAnimation = Tween<double>(begin: 1.0, end: 0.0).animate(
      CurvedAnimation(
        parent: _centerScaleController,
        curve: const Interval(0.75, 1.0, curve: Curves.easeOut),
      ),
    );

    _centerScaleController.addStatusListener((status) {
      if (status == AnimationStatus.completed) {
        // أخفِ الصورة المركزية بعد اكتمال التكبير
        if (mounted) {
          setState(() {
            _centerGone = true;
          });
        }
      }
    });
    _centerScaleController.addListener(() {
      if (mounted) setState(() {});
    });

    // حذفنا الحركات غير المستخدمة (الدوران والاهتزاز) للنظام المبسط

    // Prepare staged count sequence based on gift count
    _countStages = _computeCountStages(widget.giftData.count);

    // بدء العداد من القيمة المتراكمة الحالية إن وجدت
    if (_totalAccumulated > 0) {
      _displayedCount = _totalAccumulated;
      dev.log('🔢 [INIT_STATE] Using accumulated count: $_totalAccumulated',
          name: 'GiftAnimation');
    } else {
      _displayedCount =
          _countStages.isNotEmpty ? _countStages.first : widget.giftData.count;
      dev.log('🔢 [INIT_STATE] Using stage count: $_displayedCount',
          name: 'GiftAnimation');
    }
  }

  // Compute staged sequence for the badge
  List<int> _computeCountStages(int count) {
    if (count <= 1) return [count];
    switch (count) {
      case 7:
        return [3, 5, 7];
      case 17:
        return [7, 10, 17];
      case 77:
        return [33, 66, 77];
      default:
        return [count];
    }
  }

  // Start staged display when the center is reached
  void _startCountStaging() {
    if (_countStagingStarted) return;
    _countStagingStarted = true;
    if (_countStages.isEmpty) return;

    // Immediately show first stage
    _currentStageIndex = 0;

    // استخدم القيمة المتراكمة إذا كانت متوفرة، وإلا استخدم المرحلة الأولى
    if (_totalAccumulated > 0) {
      _displayedCount = _totalAccumulated;
    } else {
      _displayedCount = _countStages[_currentStageIndex];
    }

    // أظهر الشارة في المنتصف فوراً
    _centerBadgeHideTimer?.cancel();
    _centerBadgeVisible = true;
    if (mounted) setState(() {});

    // إذا كان العداد مرحلة واحدة (count == 1): اعرض الشارة لمدة ثانية فقط ثم أخفها
    if (_countStages.length == 1) {
      _centerBadgeHideTimer?.cancel();
      _centerBadgeHideTimer = Timer(const Duration(milliseconds: 1000), () {
        if (!mounted) return;
        _centerBadgeVisible = false;
        setState(() {});
      });
      return;
    }

    // جدولة باقي المراحل. إذا كانت نافذة المركز قصيرة، استمر بعرض الشارة حتى بعد بدء الطيران
    final totalStages = _countStages.length;
    if (totalStages > 1) {
      final remaining = totalStages - 1; // عدد التبديلات المطلوبة
      // زمن متاح داخل المركز بهامش أمان (تقليل الهامش لتبديلات أسرع)
      final safeMargin = 60; // ms
      final availableInCenter = (_centerStageMs - safeMargin)
          .clamp(_kMinCountStageIntervalMs, _centerStageMs);
      // احسب الفاصل الزمني بين القيم مع تقييده بحدين دنيا/عليا
      final int raw = (availableInCenter / remaining).floor();
      final int interval = math.min(
        _kMaxCountStageIntervalMs,
        math.max(_kMinCountStageIntervalMs, raw),
      );
      for (int i = 1; i < totalStages; i++) {
        final delayMs = interval * i;
        final timer = Timer(Duration(milliseconds: delayMs), () {
          if (!mounted) return;
          _currentStageIndex = i;

          // استخدم القيمة المتراكمة إذا كانت متوفرة، وإلا استخدم المرحلة
          if (_totalAccumulated > 0) {
            _displayedCount = _totalAccumulated;
          } else {
            _displayedCount = _countStages[i];
          }

          setState(() {});

          // bump بسيط عند الوصول إلى المرحلة الأخيرة
          if (i == totalStages - 1) {
            try {
              _badgeScaleController.forward().then((_) {
                if (mounted) _badgeScaleController.reverse();
              });
            } catch (_) {}
            // إخفِ الشارة بعد آخر قيمة بهامش صغير حتى لو بدأت الحركة
            _centerBadgeHideTimer?.cancel();
            _centerBadgeHideTimer = Timer(
              const Duration(milliseconds: _kCenterBadgeHoldMs),
              () {
                if (!mounted) return;
                _centerBadgeVisible = false;
                setState(() {});
              },
            );
          }
        });
        _countStageTimers.add(timer);
      }
    }
  }

  @override
  // بناء واجهة الهدية:
  // الطبقات: أولاً صور الانفجار (خلفية)، ثم الصورة المركزية (أعلى) لضمان عدم اختفائها.
  Widget build(BuildContext context) {
    if (_hidden || _isProxy) {
      return const SizedBox.shrink();
    }

    // فحص إضافي في build() لضمان عدم عرض هدايا غير مناسبة
    final giftType = widget.giftData.giftType?.toLowerCase();
    final isLucky = (giftType?.contains('lucky') ?? false) ||
        (giftType?.contains('حظ') ?? false);
    if (giftType != null && !isLucky) {
      return const SizedBox.shrink(); // لا تعرض شيئاً للهدايا غير المناسبة
    }
    if (midPoint == null || !_unifiedAnimationsReady) {
      return Container();
    }

    // التحكم في حالة الـ ticker
    final tickerEnabled = TickerMode.of(context);
    if (!tickerEnabled) {
      if (_controller.isAnimating) _controller.stop();
      for (final c in _burstControllers) {
        if (c.isAnimating) c.stop();
      }
    }

    return Stack(
      children: [
        _buildBurstLayer(),
        _buildUnifiedCenterImage(),
        _buildCenterBadgeLayer(),
      ],
    );
  }

  // طبقة صور الانفجار في الخلف (تظهر فقط بعد بدء تحركها من المركز)
  Widget _buildBurstLayer() {
    return Stack(
      children: _burstAnimations.asMap().entries.map((entry) {
        final index = entry.key;
        final animation = entry.value;
        final controller = _burstControllers[index];
        final opacity = _burstOpacities[index];
        return AnimatedBuilder(
          animation: controller,
          builder: (context, child) {
            final position = animation.value;

            // عرض الصورة الانفجارية فقط بعد بدء تحركها (بعد انطلاق المتحرك)
            if (controller.value == 0.0) {
              return Container(); // مخفية حتى تبدأ بالتحرك
            }
            final double opacityValue = opacity.value.clamp(0.0, 1.0);
            final double scaleValue =
                (index < _burstScales.length ? _burstScales[index].value : 1.0)
                    .clamp(0.5, 1.2);
            final double dpr = MediaQuery.of(context).devicePixelRatio;
            final int burstDecode =
                (_kBurstImgSize * dpr * _kDecodeScale).round();

            return Positioned(
              left: position.dx + _kBurstAlignDx,
              top: position.dy + _kBurstAlignDy,
              child: Opacity(
                opacity: opacityValue,
                child: Transform.scale(
                  scale: scaleValue,
                  child: SizedBox(
                    width: _kBurstImgSize,
                    height: _kBurstImgSize,
                    child: RepaintBoundary(
                      child: Image(
                        image: ResizeImage(
                          _imageProvider,
                          width: burstDecode,
                          height: burstDecode,
                        ),
                        width: _kBurstImgSize,
                        height: _kBurstImgSize,
                        fit: BoxFit.cover,
                        gaplessPlayback: true,
                        filterQuality: FilterQuality.medium,
                      ),
                    ),
                  ),
                ),
              ),
            );
          },
        );
      }).toList(),
    );
  }

  /// الصورة المركزية بالتسلسل الجديد
  /// تتحرك من المرسل → المركز، ثم تكبر لمدة 1s وتختفي، وبعدها تنطلق الانفجارات
  Widget _buildUnifiedCenterImage() {
    return AnimatedBuilder(
      animation: _controller,
      builder: (context, child) {
        if (_centerGone) {
          return const SizedBox.shrink();
        }

        // استخدام الحركة الموحدة الجديدة
        final currentPosition = _unifiedPathAnimation.value;
        // حجم نهائي = أساس (1.0) * تكبير المركز (1.0 -> 1.75)
        final double centerScale =
            (_centerScaleAnimation.value).clamp(1.0, 2.5);
        final currentScale =
            (_scaleAnimation.value * centerScale).clamp(0.5, 3.0);

        // الشفافية يتحكم بها متحكم التكبير (تتلاشى في نهاية الثانية)
        double opacity = (_centerOpacityAnimation.value).clamp(0.0, 1.0);

        // التحقق من صحة الموضع
        if (currentPosition.dx.isNaN ||
            currentPosition.dy.isNaN ||
            currentPosition.dx.isInfinite ||
            currentPosition.dy.isInfinite) {
          return const SizedBox.shrink();
        }

        // ضبط حجم الديكود للصورة المركزية مع زيادة بسيطة للدقة
        final double dpr = MediaQuery.of(context).devicePixelRatio;
        final int centerDecode =
            (_kCenterImgSize * dpr * _kDecodeScale).round();

        return Positioned(
          left: (currentPosition.dx + _kCenterAlignDx)
              .clamp(-_kClampPadding,
                  MediaQuery.of(context).size.width + _kClampPadding)
              .toDouble(),
          top: (currentPosition.dy + _kCenterAlignDy)
              .clamp(-_kClampPadding,
                  MediaQuery.of(context).size.height + _kClampPadding)
              .toDouble(),
          child: RepaintBoundary(
            child: Opacity(
              opacity: opacity,
              child: Stack(
                clipBehavior: Clip.none,
                children: [
                  // صورة الحركة الموحدة
                  Transform.scale(
                    alignment: Alignment.center,
                    scale: currentScale,
                    child: SizedBox(
                      width: _kCenterImgSize,
                      height: _kCenterImgSize,
                      child: Image(
                        image: ResizeImage(
                          _imageProvider,
                          width: centerDecode,
                          height: centerDecode,
                        ),
                        width: _kCenterImgSize,
                        height: _kCenterImgSize,
                        fit: BoxFit.cover,
                        gaplessPlayback: true,
                        filterQuality: FilterQuality.medium,
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
        );
      },
    );
  }

  // طبقة شارة العداد المثبتة في مركز الواجهة (حول midPoint)
  Widget _buildCenterBadgeLayer() {
    if (!_centerBadgeVisible || midPoint == null) {
      return const SizedBox.shrink();
    }
    // ضع الشارة بجانب المركز مباشرة مع تعويض بسيط يميناً
    final Offset center = midPoint!;
    return Positioned(
      left: (center.dx + _kCenterAlignDx + (_kCenterImgSize / 2) + 50)
          .clamp(-_kClampPadding,
              MediaQuery.of(context).size.width + _kClampPadding)
          .toDouble(),
      top: (center.dy + _kCenterAlignDy)
          .clamp(-_kClampPadding,
              MediaQuery.of(context).size.height + _kClampPadding)
          .toDouble(),
      child: RepaintBoundary(
        child: Align(
          alignment: Alignment.center,
          child: ScaleTransition(
            scale: _badgeScaleAnimation,
            child: _buildGiftCountBadge(_displayedCount),
          ),
        ),
      ),
    );
  }

  // ===== عرض العداد =====
  // شارة عداد الهدايا بجانب الصورة المركزية
  Widget _buildGiftCountBadge(int count) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      decoration: BoxDecoration(
        boxShadow: const [
          BoxShadow(color: Colors.black12, blurRadius: 6, offset: Offset(0, 2)),
        ],
        // border: Border.all(color: Colors.white, width: 1),
      ),
      child: AnimatedSwitcher(
        duration: const Duration(milliseconds: _kCountSwitchAnimMs),
        // استخدم منحنى خطي لتفادي تمرير قيم تتجاوز 1.0 إلى transitionBuilder
        // مما قد يسبب أخطاء في Curves.transform
        switchInCurve: Curves.linear,
        switchOutCurve: Curves.linear,
        layoutBuilder: (currentChild, previousChildren) => Stack(
          alignment: Alignment.center,
          children: <Widget>[
            ...previousChildren,
            if (currentChild != null) currentChild,
          ],
        ),
        transitionBuilder: (child, animation) {
          // استخدم نفس animation مباشرة للـ Fade لمنع تمرير قيم خارج [0,1]
          final fade = animation;
          // نبضة: صغر -> يكبر فوق الطبيعي قليلاً -> يستقر على الطبيعي
          final scale = TweenSequence<double>([
            TweenSequenceItem(tween: Tween(begin: 0.90, end: 1.12), weight: 60),
            TweenSequenceItem(tween: Tween(begin: 1.12, end: 1.00), weight: 40),
          ]).animate(animation);
          return FadeTransition(
            opacity: fade,
            child: ScaleTransition(scale: scale, child: child),
          );
        },
        child: GradientText(
          'x$count',
          key: ValueKey<int>(count),
          style: const TextStyle(
            color: Colors.white,
            fontSize: 30,
            fontWeight: FontWeight.bold,
          ),
          gradient: LinearGradient(colors: [
            AppColors.goldenhad1,
            AppColors.goldenhad2,
          ]),
        ),
      ),
    );
  }
}

/// نظام تجميع الهدايا المحترف المتقدم - أداء عالي للكميات الهائلة
class _ProfessionalGiftAccumulator {
  int totalGifts = 0;
  Timer? continuousTimer;
  Timer? batchUpdateTimer;
  final Set<_GiftAnimationWidgetState> activeWidgets = {};
  DateTime lastActivity = DateTime.now();
  bool isDisplaying = false;
  // ويدجت أساسي وحيد لعرض العدّاد لهذا المفتاح (مرسل+هدية)
  _GiftAnimationWidgetState? primaryWidget;

  // نظام الـ Batching المتقدم
  int _pendingGifts = 0;
  bool _isProcessingBatch = false;
  static const int _batchSize = 10; // معالجة 10 هدايا في المرة الواحدة
  static const Duration _batchDelay =
      Duration(milliseconds: 50); // تأخير قصير بين الدفعات

  // نظام مراقبة الأداء والتحسين التلقائي
  int _performanceLevel = 1; // 1=عادي، 2=متوسط، 3=عالي الأداء
  DateTime _lastPerformanceCheck = DateTime.now();
  int _giftsProcessedInLastSecond = 0;
  Timer? _performanceMonitor;

  /// إضافة هدية جديدة مع نظام Batching متقدم للأداء العالي
  void addGift(int count, _GiftAnimationWidgetState widget) {
    totalGifts += count;
    _pendingGifts += count;
    _giftsProcessedInLastSecond += count;

    // إضافة الويدجت فقط إذا لم يكن موجوداً
    if (!activeWidgets.contains(widget)) {
      activeWidgets.add(widget);
    }

    lastActivity = DateTime.now();
    isDisplaying = true;

    // بدء مراقبة الأداء إذا لم تكن نشطة
    _startPerformanceMonitoring();

    // إعادة تشغيل مؤقت العرض المستمر
    _resetContinuousTimer();

    // معالجة بنظام Batching لتحسين الأداء
    _processBatchedUpdates();

    dev.log(
        '🎁 [HIGH-PERFORMANCE] Added gift: +$count, Total: $totalGifts, Pending: $_pendingGifts, Level: $_performanceLevel',
        name: 'GiftAccumulator');
  }

  /// بدء نظام مراقبة الأداء والتحسين التلقائي
  void _startPerformanceMonitoring() {
    _performanceMonitor?.cancel();
    _performanceMonitor = Timer.periodic(const Duration(seconds: 1), (timer) {
      final now = DateTime.now();
      final timeSinceLastCheck =
          now.difference(_lastPerformanceCheck).inMilliseconds;

      if (timeSinceLastCheck >= 1000) {
        // تحليل الأداء وتعديل المستوى
        if (_giftsProcessedInLastSecond > 50) {
          _performanceLevel = 3; // أداء عالي - تقليل التحديثات
          dev.log(
              '🚀 [PERFORMANCE] High load detected ($_giftsProcessedInLastSecond gifts/sec), switching to level 3',
              name: 'GiftAccumulator');
        } else if (_giftsProcessedInLastSecond > 20) {
          _performanceLevel = 2; // أداء متوسط
          dev.log(
              '⚡ [PERFORMANCE] Medium load detected ($_giftsProcessedInLastSecond gifts/sec), switching to level 2',
              name: 'GiftAccumulator');
        } else {
          _performanceLevel = 1; // أداء عادي
        }

        _giftsProcessedInLastSecond = 0;
        _lastPerformanceCheck = now;
      }

      // إيقاف المراقبة إذا لم تعد هناك أنشطة
      if (activeWidgets.isEmpty && _pendingGifts == 0) {
        timer.cancel();
        _performanceMonitor = null;
      }
    });
  }

  /// معالجة التحديثات بنظام Batching لتجنب التعليق
  void _processBatchedUpdates() {
    if (_isProcessingBatch) return;

    _isProcessingBatch = true;

    // إلغاء المؤقت السابق إن وجد
    batchUpdateTimer?.cancel();

    // تعديل التأخير حسب مستوى الأداء
    Duration adaptiveDelay = _batchDelay;
    int adaptiveBatchSize = _batchSize;

    switch (_performanceLevel) {
      case 3: // أداء عالي - تأخير أكبر ودفعات أكبر
        adaptiveDelay = const Duration(milliseconds: 100);
        adaptiveBatchSize = 25;
        break;
      case 2: // أداء متوسط
        adaptiveDelay = const Duration(milliseconds: 75);
        adaptiveBatchSize = 15;
        break;
      default: // أداء عادي
        adaptiveDelay = _batchDelay;
        adaptiveBatchSize = _batchSize;
    }

    batchUpdateTimer = Timer(adaptiveDelay, () {
      if (_pendingGifts > 0) {
        // تحديث فوري للعداد
        _updateAllActiveWidgets();

        // إذا كان هناك هدايا معلقة كثيرة، قسمها على دفعات
        if (_pendingGifts > adaptiveBatchSize) {
          _pendingGifts = 0;
          // جدولة الدفعة التالية
          _isProcessingBatch = false;
          _processBatchedUpdates();
        } else {
          _pendingGifts = 0;
          _isProcessingBatch = false;
        }
      } else {
        _isProcessingBatch = false;
      }
    });
  }

  /// إعادة تشغيل مؤقت العرض المستمر مع فحص ذكي للهدايا الجديدة
  void _resetContinuousTimer() {
    continuousTimer?.cancel();
    continuousTimer = Timer(const Duration(seconds: 4), () {
      // فحص ذكي: هل هناك هدايا جديدة في الطريق؟
      final timeSinceLastActivity =
          DateTime.now().difference(lastActivity).inSeconds;

      if (timeSinceLastActivity < 4 && _pendingGifts > 0) {
        // هناك هدايا معلقة، أعد تشغيل المؤقت
        dev.log('🔄 [SMART-TIMER] Pending gifts detected, extending timer...',
            name: 'GiftAccumulator');
        _resetContinuousTimer();
        return;
      }

      // فحص إضافي: هل هناك ويدجتات جديدة تم إنشاؤها مؤخراً؟
      bool hasRecentActivity = false;
      for (final widget in activeWidgets) {
        if (widget.mounted && widget._lastGiftTime != null) {
          final timeSinceGift =
              DateTime.now().difference(widget._lastGiftTime!).inSeconds;
          if (timeSinceGift < 4) {
            hasRecentActivity = true;
            break;
          }
        }
      }

      if (hasRecentActivity) {
        dev.log('🔄 [SMART-TIMER] Recent activity detected, extending timer...',
            name: 'GiftAccumulator');
        _resetContinuousTimer();
        return;
      }

      dev.log(
          '⏰ [SMART-TIMER] 4 seconds passed with no activity, hiding counter. Total shown: $totalGifts',
          name: 'GiftAccumulator');
      _hideAllWidgets();
    });
  }

  /// تحديث جميع الويدجتات النشطة مع نظام Throttling متقدم
  void _updateAllActiveWidgets() {
    if (activeWidgets.isEmpty) return;

    // استخدام microtask لتجنب حجب UI thread
    scheduleMicrotask(() {
      final widgetsToRemove = <_GiftAnimationWidgetState>[];

      for (final widget in activeWidgets) {
        if (widget.mounted) {
          // تحديث فقط إذا كان العداد مختلف
          if (widget._totalAccumulated != totalGifts) {
            // استخدام addPostFrameCallback لضمان السلاسة
            WidgetsBinding.instance.addPostFrameCallback((_) {
              if (widget.mounted) {
                widget._updateProfessionalCounter(totalGifts);
              }
            });
          }
        } else {
          widgetsToRemove.add(widget);
        }
      }

      // إزالة الويدجتات غير المثبتة
      for (final widget in widgetsToRemove) {
        activeWidgets.remove(widget);
      }
    });
  }

  /// إخفاء جميع الويدجتات بعد 4 ثوانٍ
  void _hideAllWidgets() {
    isDisplaying = false;
    for (final widget in Set.from(activeWidgets)) {
      if (widget.mounted) {
        widget._hideProfessionalCounter();
      }
    }
    // بعد أمر الإخفاء، قم بإلغاء تعيين الودجت الأساسي
    primaryWidget = null;
    _cleanup();
  }

  /// تنظيف شامل للموارد مع إلغاء جميع المؤقتات
  void _cleanup() {
    activeWidgets.clear();
    totalGifts = 0;
    _pendingGifts = 0;
    _isProcessingBatch = false;
    _giftsProcessedInLastSecond = 0;
    _performanceLevel = 1;
    primaryWidget = null;

    // إلغاء جميع المؤقتات
    continuousTimer?.cancel();
    continuousTimer = null;
    batchUpdateTimer?.cancel();
    batchUpdateTimer = null;
    _performanceMonitor?.cancel();
    _performanceMonitor = null;

    dev.log(
        '🧹 [HIGH-PERFORMANCE] Cleaned up accumulator with all timers and performance monitor',
        name: 'GiftAccumulator');
  }

  /// إزالة ويدجت معين
  void removeWidget(_GiftAnimationWidgetState widget) {
    activeWidgets.remove(widget);
    if (identical(widget, primaryWidget)) {
      primaryWidget = null;
    }

    // لا تنظف المجمع فوراً - اتركه للاستخدام المستقبلي
    // سيتم التنظيف فقط بعد فترة طويلة من عدم النشاط
    if (activeWidgets.isEmpty && !isDisplaying) {
      // انتظر 10 ثواني إضافية قبل التنظيف النهائي
      Timer(const Duration(seconds: 10), () {
        if (activeWidgets.isEmpty && !isDisplaying) {
          _cleanup();
        }
      });
    }
  }
}
