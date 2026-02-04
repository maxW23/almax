import 'dart:collection';
import 'package:flutter/foundation.dart';
import 'package:lklk/live_audio_room_manager.dart';

/// ChangeNotifier لإدارة رسائل الغرفة بكفاءة.
/// يفصل تحديثات الدردشة عن باقي واجهة المستخدم، مما يمنع إعادة البناء غير الضرورية.
class RoomMessagesStore extends ChangeNotifier {
  String? _currentRoomId;
  List<ZIMMessage> _messages = [];
  static const int _maxMessages =
      30; // الحد الأقصى للرسائل لتحسين الأداء وتوفير الذاكرة

  // تتبع آخر تحديث لتجنب التحديثات المتكررة غير الضرورية
  DateTime? _lastNotifyTime;
  static const Duration _minNotifyInterval = Duration(milliseconds: 100);

  // Singleton pattern for easy access
  RoomMessagesStore._privateConstructor();
  static final RoomMessagesStore _instance =
      RoomMessagesStore._privateConstructor();
  static RoomMessagesStore get instance => _instance;

  /// استرجاع رسائل الروم الحالية كقائمة غير قابلة للتعديل.
  UnmodifiableListView<ZIMMessage> get messages =>
      UnmodifiableListView(_messages);

  /// الحصول على عدد الرسائل الحالي
  int get messageCount => _messages.length;

  /// التحقق من وجود رسائل
  bool get hasMessages => _messages.isNotEmpty;

  /// تهيئة أو تبديل الغرفة مع تنظيف فوري للذاكرة.
  void initializeForRoom(String roomId) {
    if (_currentRoomId != roomId) {
      // تنظيف فوري للذاكرة من الغرفة السابقة
      _messages.clear();
      _currentRoomId = roomId;
      _lastNotifyTime = null;
      // لا نُعلم المستمعين هنا، لأن الواجهة ستُبنى لأول مرة على أي حال
    }
  }

  /// مسح الرسائل عند الخروج من الروم مع تحرير الذاكرة.
  void clearMessages() {
    if (_messages.isNotEmpty) {
      _messages.clear();
      _notifyListenersThrottled();
    }
    _currentRoomId = null;
    _lastNotifyTime = null;
  }

  /// إضافة رسالة واحدة مع الالتزام الصارم بالحد الأقصى.
  void addMessage(String roomId, ZIMMessage message) {
    if (_currentRoomId != roomId) return; // تجاهل الرسائل من غرف أخرى

    _messages.insert(0, message);

    // إزالة الرسائل الزائدة فوراً لتوفير الذاكرة
    _enforceMessageLimit();

    _notifyListenersThrottled();
  }

  /// إضافة مجموعة رسائل مع الالتزام الصارم بالحد الأقصى.
  void addMessages(String roomId, List<ZIMMessage> newMessages) {
    if (newMessages.isEmpty || _currentRoomId != roomId) return;

    _messages.insertAll(0, newMessages);

    // إزالة الرسائل الزائدة فوراً لتوفير الذاكرة
    _enforceMessageLimit();

    _notifyListenersThrottled();
  }

  /// إزالة رسالة محددة بالمعرف
  void removeMessage(int messageId) {
    final initialLength = _messages.length;
    _messages.removeWhere((msg) => msg.messageID == messageId);

    if (_messages.length != initialLength) {
      _notifyListenersThrottled();
    }
  }

  /// فرض الحد الأقصى للرسائل وتحرير الذاكرة
  void _enforceMessageLimit() {
    if (_messages.length > _maxMessages) {
      // إزالة الرسائل الزائدة من النهاية (الأقدم)
      _messages.removeRange(_maxMessages, _messages.length);
    }
  }

  /// إشعار المستمعين مع تقييد التكرار لتحسين الأداء
  void _notifyListenersThrottled() {
    final now = DateTime.now();
    if (_lastNotifyTime == null ||
        now.difference(_lastNotifyTime!) >= _minNotifyInterval) {
      _lastNotifyTime = now;
      notifyListeners();
    }
  }

  /// تنظيف الذاكرة يدوياً (يمكن استدعاؤها عند الحاجة)
  void forceCleanup() {
    if (_messages.length > _maxMessages ~/ 2) {
      // احتفظ بنصف الحد الأقصى من الرسائل الأحدث فقط
      _messages = _messages.take(_maxMessages ~/ 2).toList();
      _notifyListenersThrottled();
    }
  }

  @override
  void dispose() {
    _messages.clear();
    _currentRoomId = null;
    _lastNotifyTime = null;
    super.dispose();
  }
}
