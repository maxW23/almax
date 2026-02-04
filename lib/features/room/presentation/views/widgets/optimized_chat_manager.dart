import 'dart:async';
import 'dart:collection';
import 'dart:developer' as dev;
import 'package:zego_zim/zego_zim.dart';

/// مدير الدردشة المحسن للأداء العالي
class OptimizedChatManager {
  static final OptimizedChatManager _instance =
      OptimizedChatManager._internal();
  factory OptimizedChatManager() => _instance;
  OptimizedChatManager._internal();

  // حدود الرسائل - تم تقليلها لعرض آخر 25 رسالة فقط
  static const int maxVisibleMessages = 25;
  static const int maxCachedMessages = 50;
  static const int batchSize = 10;
  static const int updateDebounce = 50;

  // قوائم الرسائل
  final Queue<ZIMMessage> _messageQueue = Queue();
  final List<ZIMMessage> _visibleMessages = [];
  final StreamController<List<ZIMMessage>> _messagesStreamController =
      StreamController<List<ZIMMessage>>.broadcast();

  // مؤقتات وأعلام
  Timer? _debounceTimer;
  bool _isProcessing = false;
  int _totalMessagesReceived = 0;
  int _droppedMessages = 0;

  Stream<List<ZIMMessage>> get messagesStream =>
      _messagesStreamController.stream;
  int get totalMessages => _totalMessagesReceived;
  int get droppedMessages => _droppedMessages;
  int get visibleMessages => _visibleMessages.length;

  /// إضافة رسالة جديدة بطريقة محسنة
  void addMessage(ZIMMessage message) {
    _totalMessagesReceived++;

    _messageQueue.add(message);

    while (_messageQueue.length > maxCachedMessages) {
      _messageQueue.removeFirst();
      _droppedMessages++;
    }

    _scheduleProcessing();
  }

  /// جدولة معالجة الرسائل مع debouncing
  void _scheduleProcessing() {
    _debounceTimer?.cancel();
    _debounceTimer = Timer(
      Duration(milliseconds: updateDebounce),
      _processMessages,
    );
  }

  /// معالجة الرسائل من الطابور
  void _processMessages() {
    if (_isProcessing) return;
    _isProcessing = true;

    try {
      int processed = 0;
      while (_messageQueue.isNotEmpty && processed < batchSize) {
        final message = _messageQueue.removeFirst();
        _visibleMessages.add(message);
        processed++;
      }

      while (_visibleMessages.length > maxVisibleMessages) {
        _visibleMessages.removeAt(0);
      }

      _messagesStreamController.add(List.from(_visibleMessages));
    } finally {
      _isProcessing = false;
    }
  }

  /// مسح الرسائل
  void clearMessages() {
    _messageQueue.clear();
    _visibleMessages.clear();
    _messagesStreamController.add([]);
  }

  /// تنظيف الموارد
  void dispose() {
    _debounceTimer?.cancel();
    _messagesStreamController.close();
    clearMessages();
  }

  /// طباعة الإحصائيات
  void printStats() {
    dev.log('''
📊 Chat Performance Stats:
├─ Total Messages: $_totalMessagesReceived
├─ Visible Messages: ${_visibleMessages.length}
├─ Cached Messages: ${_messageQueue.length}
└─ Dropped Messages: $_droppedMessages
    ''');
  }
}
