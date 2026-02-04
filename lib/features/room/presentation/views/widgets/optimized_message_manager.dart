import 'dart:async';
import 'dart:collection';
import 'package:flutter/widgets.dart';
import 'package:lklk/live_audio_room_manager.dart';

/// مدير محسن للرسائل والهدايا للغرف عالية الكثافة (500+ مستخدم)
class OptimizedMessageManager extends ChangeNotifier {
  static const int _maxMessages = 25; // احتفظ بآخر 25 رسالة فقط
  static const int _maxGifts = 10; // حد أقصى للهدايا المعروضة
  static const Duration _batchDelay = Duration(
    milliseconds: 140,
  ); // تجميع التحديثات (أسرع)

  final Queue<ZIMMessage> _messageQueue = Queue<ZIMMessage>();
  final Queue<Map<String, dynamic>> _giftQueue = Queue<Map<String, dynamic>>();

  Timer? _batchTimer;
  bool _isProcessing = false;

  List<ZIMMessage> messagess = [];
  List<Map<String, dynamic>> activeGiftss = [];

  // تتبع الرسائل التي تمت إضافتها بالفعل لمنع التكرار
  final Set<String> _seenMessageKeys = <String>{};

  String? _currentRoomId;

  // Singleton
  static final OptimizedMessageManager _instance = OptimizedMessageManager._();
  static OptimizedMessageManager get instance => _instance;
  OptimizedMessageManager._();

  UnmodifiableListView<ZIMMessage> get messages =>
      UnmodifiableListView(messagess);
  UnmodifiableListView<Map<String, dynamic>> get activeGifts =>
      UnmodifiableListView(activeGiftss);

  void initializeForRoom(String roomId) {
    if (_currentRoomId != roomId) {
      _currentRoomId = roomId;
      _clearAll();
    }
  }

  /// إضافة رسالة مع تجميع التحديثات
  void addMessage(String roomId, ZIMMessage message) {
    if (_currentRoomId != roomId) return;
    // منع التكرار باستخدام مفتاحين: مفتاح هوية ومفتاح محتوى (لتغطية حالة echo المحلي برسالة id=0 ثم وصول نفس الرسالة مع id>0)
    final String idKey = _uniqueKey(message);
    final String contentKey = _contentKey(message);
    if (_seenMessageKeys.contains(idKey) || _seenMessageKeys.contains(contentKey)) {
      return; // تمّت إضافتها مسبقاً
    }
    // علّم كلا المفتاحين لتفادي تكرار قادم بأي شكل
    _seenMessageKeys.add(idKey);
    _seenMessageKeys.add(contentKey);

    _messageQueue.add(message);
    _scheduleBatchUpdate();
  }

  /// إضافة هدية مع تجميع التحديثات
  void addGift(String roomId, Map<String, dynamic> gift) {
    if (_currentRoomId != roomId) return;

    _giftQueue.add(gift);
    _scheduleBatchUpdate();
  }

  /// جدولة تحديث مجمع لتقليل إعادة البناء
  void _scheduleBatchUpdate() {
    _batchTimer?.cancel();
    _batchTimer = Timer(_batchDelay, _processBatch);
  }

  /// معالجة مجمعة للرسائل والهدايا
  void _processBatch() {
    if (_isProcessing) return;
    _isProcessing = true;

    bool hasChanges = false;

    // معالجة الرسائل: أدخل كل الرسائل الجديدة ثم قلّم القائمة للإبقاء على آخر _maxMessages عنصر
    while (_messageQueue.isNotEmpty) {
      messagess.insert(0, _messageQueue.removeFirst());
      hasChanges = true;
    }

    // إزالة الرسائل الزائدة: احتفظ بالأحدث فقط
    if (messagess.length > _maxMessages) {
      messagess.removeRange(_maxMessages, messagess.length);
      hasChanges = true;
    }

    // معالجة الهدايا
    while (_giftQueue.isNotEmpty && activeGiftss.length < _maxGifts) {
      activeGiftss.add(_giftQueue.removeFirst());
      hasChanges = true;
    }

    // إزالة الهدايا الزائدة
    if (activeGiftss.length > _maxGifts) {
      activeGiftss.removeRange(_maxGifts, activeGiftss.length);
      hasChanges = true;
    }

    _isProcessing = false;

    if (hasChanges) {
      // تأخير الإشعار لتجنب مشكلة setState أثناء البناء
      WidgetsBinding.instance.addPostFrameCallback((_) {
        notifyListeners();
      });
    }
  }

  void removeGift(Map<String, dynamic> gift) {
    activeGiftss.remove(gift);
    // تأخير الإشعار لتجنب مشكلة setState أثناء البناء
    WidgetsBinding.instance.addPostFrameCallback((_) {
      notifyListeners();
    });
  }

  void _clearAll() {
    _messageQueue.clear();
    _giftQueue.clear();
    messagess.clear();
    activeGiftss.clear();
    _seenMessageKeys.clear();
    _batchTimer?.cancel();
    _isProcessing = false;
  }

  /// Clear messages safely (delays notification to avoid build-time issues)
  void clearMessages() {
    _messageQueue.clear();
    if (messagess.isNotEmpty) {
      messagess.clear();
      // إعادة تعيين حالة منع التكرار لجلسة جديدة (دخول جديد للغرفة)
      _seenMessageKeys.clear();
      // تأخير الإشعار لتجنب مشكلة setState أثناء البناء
      WidgetsBinding.instance.addPostFrameCallback((_) {
        notifyListeners();
      });
    }
  }

  /// Clear messages immediately without notification (for internal use)
  void clearMessagesImmediate() {
    _messageQueue.clear();
    messagess.clear();
    _seenMessageKeys.clear();
  }

  // مفتاح فريد للرسالة لضمان عدم التكرار حتى عندما يكون messageID == 0
  String _uniqueKey(ZIMMessage m) {
    if (m.messageID != 0) return 'id:${m.messageID}';
    if (m is ZIMBarrageMessage) {
      return 'id0:${m.extendedData.hashCode}:${m.message.hashCode}';
    }
    return 'hash:${m.hashCode}';
  }

  // مفتاح محتوى مستقل عن الهوية (بدون الاعتماد على messageID) لمنع تكرار echo
  String _contentKey(ZIMMessage m) {
    if (m is ZIMBarrageMessage) {
      return 'content:${m.extendedData.hashCode}:${m.message.hashCode}';
    }
    return 'content:${m.hashCode}:${m.messageID}:${m.timestamp}';
  }

  @override
  void dispose() {
    _batchTimer?.cancel();
    _clearAll();
    super.dispose();
  }
}
