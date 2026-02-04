import 'dart:async';
import 'dart:collection';
import 'dart:developer' as dev;
import 'package:lklk/features/room/presentation/views/widgets/gift_animation_data.dart';

/// مدير رتل هدايا الحظ الاحترافي
class LuckyGiftQueueManager {
  static final LuckyGiftQueueManager _instance =
      LuckyGiftQueueManager._internal();
  factory LuckyGiftQueueManager() => _instance;
  LuckyGiftQueueManager._internal();

  // رتل الهدايا المنتظرة
  final Queue<LuckyGiftQueueItem> _giftQueue = Queue<LuckyGiftQueueItem>();

  // الهدايا المعروضة حالياً
  final Set<String> _displayingGifts = <String>{};

  // مؤقت معالجة الرتل
  Timer? _processingTimer;

  // حد أقصى للهدايا المعروضة في نفس الوقت (قابل للتعديل)
  int _maxConcurrentGifts = 1; // اجعلها 1 لتسلسل العرض ومنع التداخل
  int get maxConcurrentGifts => _maxConcurrentGifts;
  void setMaxConcurrentGifts(int value) {
    _maxConcurrentGifts = value < 1 ? 1 : value;
    dev.log('⚙️ [LUCKY_QUEUE] Set maxConcurrentGifts=$_maxConcurrentGifts',
        name: 'LuckyGiftQueue');
  }

  // فترة المعالجة (كل 500ms)
  static const Duration processingInterval = Duration(milliseconds: 500);
  // مهلة تبريد قصيرة بين الهدايا للسماح بإزالة الودجت السابق من الشجرة
  static const Duration displayCooldown = Duration(milliseconds: 180);

  // مهلة قصوى لعرض الهدية الواحدة لمنع التعليق (أطول من مدة الودجت)
  static const Duration giftDisplayTimeout = Duration(milliseconds: 5200);

  // مراقبات مهلة لكل هدية معروضة حاليًا
  final Map<String, Timer> _displayTimeouts = {};

  // آخر وقت أكملت فيه هدية
  DateTime _lastCompleteAt = DateTime.fromMillisecondsSinceEpoch(0);

  // callbacks للإشعارات
  final List<Function(LuckyGiftQueueItem)> _onGiftDisplayCallbacks = [];
  final List<Function(String)> _onGiftCompleteCallbacks = [];

  /// إضافة هدية حظ للرتل
  void addLuckyGift({
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
    final queueItem = LuckyGiftQueueItem(
      id: '${giftId}_${DateTime.now().millisecondsSinceEpoch}',
      giftId: giftId,
      senderId: senderId,
      senderName: senderName,
      receiverId: receiverId,
      receiverName: receiverName,
      imageUrl: imageUrl,
      count: count,
      animationData: animationData,
      timestamp: DateTime.now(),
      metadata: metadata ?? {},
    );

    _giftQueue.add(queueItem);

    dev.log('🎁 [LUCKY_QUEUE] Added gift to queue: ${queueItem.id}',
        name: 'LuckyGiftQueue');
    dev.log('🎁 [LUCKY_QUEUE] Queue size: ${_giftQueue.length}',
        name: 'LuckyGiftQueue');

    // بدء معالجة الرتل إذا لم تكن بدأت
    _startProcessing();
  }

  /// بدء معالجة الرتل
  void _startProcessing() {
    if (_processingTimer?.isActive == true) return;

    dev.log('🚀 [LUCKY_QUEUE] Starting queue processing',
        name: 'LuckyGiftQueue');

    _processingTimer = Timer.periodic(processingInterval, (timer) {
      _processQueue();
    });
  }

  /// هل يمكن عرض هدية جديدة الآن؟ (لم نتجاوز الحد)
  bool _canDisplayMore() => _displayingGifts.length < _maxConcurrentGifts;

  /// إرسال إشعار العرض لكل المستمعين بأمان
  void _notifyDisplay(LuckyGiftQueueItem item) {
    for (final callback in _onGiftDisplayCallbacks) {
      try {
        callback(item);
      } catch (e) {
        dev.log('❌ [LUCKY_QUEUE] Error in display callback: $e',
            name: 'LuckyGiftQueue');
      }
    }
  }

  /// إرسال إشعار الإكمال لكل المستمعين بأمان
  void _notifyComplete(String giftId) {
    for (final callback in _onGiftCompleteCallbacks) {
      try {
        callback(giftId);
      } catch (e) {
        dev.log('❌ [LUCKY_QUEUE] Error in complete callback: $e',
            name: 'LuckyGiftQueue');
      }
    }
  }

  /// معالجة الرتل
  void _processQueue() {
    // إذا كان الرتل فارغ، أوقف المعالجة
    if (_giftQueue.isEmpty) {
      _stopProcessing();
      return;
    }

    // تحقق من مهلة التبريد بين العروض
    final sinceLast = DateTime.now().difference(_lastCompleteAt);
    if (sinceLast < displayCooldown) {
      dev.log(
          '🧊 [LUCKY_QUEUE] Cooling down ${displayCooldown.inMilliseconds - sinceLast.inMilliseconds}ms before showing next gift',
          name: 'LuckyGiftQueue');
      return;
    }

    // إذا وصلنا للحد الأقصى من الهدايا المعروضة، انتظر
    if (!_canDisplayMore()) {
      dev.log(
          '⏳ [LUCKY_QUEUE] Max concurrent gifts reached (${_displayingGifts.length}/$_maxConcurrentGifts)',
          name: 'LuckyGiftQueue');
      return;
    }

    // أخذ الهدية التالية من الرتل
    final nextGift = _giftQueue.removeFirst();
    _displayingGifts.add(nextGift.id);

    dev.log('🎬 [LUCKY_QUEUE] Displaying gift: ${nextGift.id}',
        name: 'LuckyGiftQueue');
    dev.log('🎬 [LUCKY_QUEUE] Queue remaining: ${_giftQueue.length}',
        name: 'LuckyGiftQueue');
    dev.log('🎬 [LUCKY_QUEUE] Currently displaying: ${_displayingGifts.length}',
        name: 'LuckyGiftQueue');

    // إشعار المستمعين بعرض الهدية
    _notifyDisplay(nextGift);

    // بدء مؤقت مهلة لضمان عدم بقاء الهدية معلقة ومنع توقف الرتل
    _displayTimeouts[nextGift.id]?.cancel();
    _displayTimeouts[nextGift.id] = Timer(giftDisplayTimeout, () {
      if (_displayingGifts.contains(nextGift.id)) {
        dev.log(
            '⏱️ [LUCKY_QUEUE] Gift timeout reached. Auto-completing: ${nextGift.id}',
            name: 'LuckyGiftQueue');
        completeGift(nextGift.id);
      }
    });
  }

  /// إنهاء عرض هدية
  void completeGift(String giftId) {
    if (_displayingGifts.remove(giftId)) {
      // إلغاء مهلة العرض لهذه الهدية
      _displayTimeouts.remove(giftId)?.cancel();
      _lastCompleteAt = DateTime.now();
      dev.log('✅ [LUCKY_QUEUE] Completed gift: $giftId',
          name: 'LuckyGiftQueue');
      dev.log(
          '✅ [LUCKY_QUEUE] Currently displaying: ${_displayingGifts.length}',
          name: 'LuckyGiftQueue');

      // إشعار المستمعين بإنهاء الهدية
      _notifyComplete(giftId);

      // إذا كان هناك هدايا في الانتظار، تابع المعالجة
      if (_giftQueue.isNotEmpty && _processingTimer?.isActive != true) {
        _startProcessing();
      }
    }
  }

  /// إيقاف معالجة الرتل
  void _stopProcessing() {
    _processingTimer?.cancel();
    _processingTimer = null;
    dev.log('⏹️ [LUCKY_QUEUE] Stopped queue processing',
        name: 'LuckyGiftQueue');
  }

  /// إضافة مستمع لعرض الهدايا
  void addDisplayListener(Function(LuckyGiftQueueItem) callback) {
    _onGiftDisplayCallbacks.add(callback);
  }

  /// إزالة مستمع عرض الهدايا
  void removeDisplayListener(Function(LuckyGiftQueueItem) callback) {
    _onGiftDisplayCallbacks.remove(callback);
  }

  /// إضافة مستمع لإنهاء الهدايا
  void addCompleteListener(Function(String) callback) {
    _onGiftCompleteCallbacks.add(callback);
  }

  /// إزالة مستمع إنهاء الهدايا
  void removeCompleteListener(Function(String) callback) {
    _onGiftCompleteCallbacks.remove(callback);
  }

  /// الحصول على حالة الرتل
  LuckyGiftQueueStatus getStatus() {
    return LuckyGiftQueueStatus(
      queueSize: _giftQueue.length,
      displayingCount: _displayingGifts.length,
      isProcessing: _processingTimer?.isActive == true,
      nextGifts: _giftQueue.take(5).toList(), // أول 5 هدايا في الرتل
    );
  }

  /// مسح الرتل (للطوارئ)
  void clearQueue() {
    _giftQueue.clear();
    _displayingGifts.clear();
    for (final t in _displayTimeouts.values) {
      t.cancel();
    }
    _displayTimeouts.clear();
    _stopProcessing();
    dev.log('🗑️ [LUCKY_QUEUE] Queue cleared', name: 'LuckyGiftQueue');
  }

  /// تنظيف الموارد
  void dispose() {
    _stopProcessing();
    _giftQueue.clear();
    _displayingGifts.clear();
    for (final t in _displayTimeouts.values) {
      t.cancel();
    }
    _displayTimeouts.clear();
    _onGiftDisplayCallbacks.clear();
    _onGiftCompleteCallbacks.clear();
    dev.log('🗑️ [LUCKY_QUEUE] Manager disposed', name: 'LuckyGiftQueue');
  }
}

/// عنصر في رتل هدايا الحظ
class LuckyGiftQueueItem {
  final String id;
  final String giftId;
  final String senderId;
  final String senderName;
  final String receiverId;
  final String receiverName;
  final String imageUrl;
  final int count;
  final GiftAnimationData animationData;
  final DateTime timestamp;
  final Map<String, dynamic> metadata;

  const LuckyGiftQueueItem({
    required this.id,
    required this.giftId,
    required this.senderId,
    required this.senderName,
    required this.receiverId,
    required this.receiverName,
    required this.imageUrl,
    required this.count,
    required this.animationData,
    required this.timestamp,
    required this.metadata,
  });

  @override
  String toString() {
    return 'LuckyGiftQueueItem(id: $id, giftId: $giftId, sender: $senderName, receiver: $receiverName, count: $count)';
  }
}

/// حالة رتل هدايا الحظ
class LuckyGiftQueueStatus {
  final int queueSize;
  final int displayingCount;
  final bool isProcessing;
  final List<LuckyGiftQueueItem> nextGifts;

  const LuckyGiftQueueStatus({
    required this.queueSize,
    required this.displayingCount,
    required this.isProcessing,
    required this.nextGifts,
  });

  @override
  String toString() {
    return 'LuckyGiftQueueStatus(queue: $queueSize, displaying: $displayingCount, processing: $isProcessing)';
  }
}
