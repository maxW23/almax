import 'dart:async';
import 'dart:collection';
import 'dart:developer' as dev;
import 'package:lklk/features/room/presentation/views/widgets/gift_animation_data.dart';

/// مدير الهدايا المحسن للأداء العالي
class OptimizedGiftManager {
  static final OptimizedGiftManager _instance =
      OptimizedGiftManager._internal();
  factory OptimizedGiftManager() => _instance;
  OptimizedGiftManager._internal();

  // حدود الهدايا
  static const int maxConcurrentGifts = 8; // حد أقصى للهدايا المتزامنة
  static const int giftQueueLimit = 50; // حد أقصى للطابور
  static const int batchProcessingSize = 5; // عدد الهدايا المعالجة في المرة
  static const int processInterval = 100; // فترة معالجة الهدايا بالميلي ثانية

  // قوائم الهدايا
  final Queue<GiftAnimationData> _pendingGifts = Queue();
  final List<GiftAnimationData> _activeGifts = [];
  final StreamController<List<GiftAnimationData>> _giftsStreamController =
      StreamController<List<GiftAnimationData>>.broadcast();

  // معالجة الهدايا
  Timer? _processTimer;
  bool _isProcessing = false;

  // إحصائيات
  int _totalGiftsReceived = 0;
  int _totalGiftsDropped = 0;
  int _totalGiftsProcessed = 0;

  // الحصول على Stream للهدايا النشطة
  Stream<List<GiftAnimationData>> get giftsStream =>
      _giftsStreamController.stream;

  // الحصول على الهدايا النشطة
  List<GiftAnimationData> get activeGifts => List.from(_activeGifts);

  /// تهيئة معالج الهدايا
  void initialize() {
    _startProcessing();
  }

  /// بدء معالجة الهدايا
  void _startProcessing() {
    _processTimer?.cancel();
    _processTimer = Timer.periodic(
      Duration(milliseconds: processInterval),
      (_) => _processGiftQueue(),
    );
  }

  /// إضافة هدية جديدة
  void addGift(GiftAnimationData gift) {
    _totalGiftsReceived++;

    // التحقق من حد الطابور
    if (_pendingGifts.length >= giftQueueLimit) {
      _totalGiftsDropped++;
      _removeOldestGift();
    }

    _pendingGifts.add(gift);
  }

  /// إضافة دفعة من الهدايا
  void addGiftBatch(List<GiftAnimationData> gifts) {
    for (final gift in gifts) {
      addGift(gift);
    }
  }

  /// معالجة طابور الهدايا
  void _processGiftQueue() {
    if (_isProcessing || _pendingGifts.isEmpty) return;

    _isProcessing = true;

    try {
      // التحقق من المساحة المتاحة
      final availableSlots = maxConcurrentGifts - _activeGifts.length;
      if (availableSlots <= 0) return;

      // معالجة دفعة من الهدايا
      int processed = 0;
      while (_pendingGifts.isNotEmpty &&
          processed < batchProcessingSize &&
          processed < availableSlots) {
        final gift = _pendingGifts.removeFirst();

        // تحسين: دمج الهدايا المتشابهة
        final existingGift = _findSimilarActiveGift(gift);
        if (existingGift != null) {
          _mergeGifts(existingGift, gift);
        } else {
          _activeGifts.add(gift);
          _totalGiftsProcessed++;
        }

        processed++;
      }

      // إرسال التحديث
      if (processed > 0) {
        _giftsStreamController.add(List.from(_activeGifts));
      }
    } finally {
      _isProcessing = false;
    }
  }

  /// البحث عن هدية مشابهة نشطة
  GiftAnimationData? _findSimilarActiveGift(GiftAnimationData gift) {
    try {
      return _activeGifts.firstWhere(
        (activeGift) =>
            activeGift.giftId == gift.giftId &&
            activeGift.senderId == gift.senderId &&
            activeGift.receiverId == gift.receiverId &&
            _canMergeGifts(activeGift, gift),
      );
    } catch (_) {
      return null;
    }
  }

  /// التحقق من إمكانية دمج الهدايا
  bool _canMergeGifts(GiftAnimationData gift1, GiftAnimationData gift2) {
    // دمج الهدايا إذا كانت متقاربة زمنياً (خلال ثانية واحدة)
    final timeDiff =
        gift2.timestamp.difference(gift1.timestamp).inMilliseconds.abs();
    return timeDiff < 1000;
  }

  /// دمج الهدايا المتشابهة
  void _mergeGifts(GiftAnimationData existing, GiftAnimationData newGift) {
    // زيادة عدد الهدايا المدمجة
    existing.count = existing.count + newGift.count;
    _totalGiftsProcessed++;
  }

  /// إزالة أقدم هدية من الطابور
  void _removeOldestGift() {
    if (_pendingGifts.isNotEmpty) {
      _pendingGifts.removeFirst();
    }
  }

  /// إزالة هدية منتهية
  void removeGift(GiftAnimationData gift) {
    _activeGifts.remove(gift);
    _giftsStreamController.add(List.from(_activeGifts));
  }

  /// تنظيف جميع الهدايا
  void clearAllGifts() {
    _pendingGifts.clear();
    _activeGifts.clear();
    _giftsStreamController.add([]);
  }

  /// إيقاف المعالجة
  void dispose() {
    _processTimer?.cancel();
    _giftsStreamController.close();
    clearAllGifts();
  }

  /// طباعة الإحصائيات
  void printStats() {
    dev.log('''
🎁 Gift Performance Stats:
├─ Total Received: $_totalGiftsReceived
├─ Total Processed: $_totalGiftsProcessed
├─ Total Dropped: $_totalGiftsDropped
├─ Active Gifts: ${_activeGifts.length}
└─ Pending Gifts: ${_pendingGifts.length}
    ''');
  }

  /// الحصول على معلومات الأداء
  Map<String, dynamic> getPerformanceMetrics() {
    return {
      'totalReceived': _totalGiftsReceived,
      'totalProcessed': _totalGiftsProcessed,
      'totalDropped': _totalGiftsDropped,
      'activeGifts': _activeGifts.length,
      'pendingGifts': _pendingGifts.length,
      'queueUtilization':
          '${(_pendingGifts.length / giftQueueLimit * 100).toStringAsFixed(1)}%',
      'dropRate': _totalGiftsReceived > 0
          ? '${(_totalGiftsDropped / _totalGiftsReceived * 100).toStringAsFixed(1)}%'
          : '0%',
    };
  }
}
