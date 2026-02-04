import 'dart:async';
import 'dart:convert';
import 'dart:developer' as dev;
import 'package:web_socket_channel/web_socket_channel.dart';

/// خدمة WebSocket للتحديثات الفورية بدلاً من Polling
class RealtimeService {
  static final RealtimeService _instance = RealtimeService._internal();
  factory RealtimeService() => _instance;
  RealtimeService._internal();

  WebSocketChannel? _channel;
  final _eventController = StreamController<RealtimeEvent>.broadcast();
  Timer? _heartbeatTimer;
  Timer? _reconnectTimer;

  bool _isConnected = false;
  int _reconnectAttempts = 0;
  static const int _maxReconnectAttempts = 5;

  // Streams للأحداث المختلفة
  Stream<RealtimeEvent> get events => _eventController.stream;

  Stream<GiftEvent> get giftEvents =>
      events.where((e) => e is GiftEvent).cast<GiftEvent>();

  Stream<MessageEvent> get messageEvents =>
      events.where((e) => e is MessageEvent).cast<MessageEvent>();

  Stream<UserJoinEvent> get userJoinEvents =>
      events.where((e) => e is UserJoinEvent).cast<UserJoinEvent>();

  /// الاتصال بخادم WebSocket
  Future<void> connect({
    required String url,
    required String roomId,
    required String userId,
    required String token,
  }) async {
    if (_isConnected) return;

    try {
      final wsUrl = Uri.parse('$url/ws?room=$roomId&user=$userId&token=$token');
      _channel = WebSocketChannel.connect(wsUrl);

      // الاستماع للرسائل
      _channel!.stream.listen(
        _handleMessage,
        onError: _handleError,
        onDone: _handleDisconnect,
      );

      _isConnected = true;
      _reconnectAttempts = 0;

      // بدء heartbeat
      _startHeartbeat();

      dev.log('✅ WebSocket connected to room: $roomId',
          name: 'RealtimeService');
    } catch (e) {
      dev.log('❌ WebSocket connection failed: $e', name: 'RealtimeService');
      _scheduleReconnect();
    }
  }

  /// معالجة الرسائل الواردة
  void _handleMessage(dynamic message) {
    try {
      final data = jsonDecode(message);
      final type = data['type'] as String;

      switch (type) {
        case 'gift':
          _eventController.add(GiftEvent.fromJson(data));
          break;
        case 'message':
          _eventController.add(MessageEvent.fromJson(data));
          break;
        case 'user_join':
          _eventController.add(UserJoinEvent.fromJson(data));
          break;
        case 'user_leave':
          _eventController.add(UserLeaveEvent.fromJson(data));
          break;
        case 'seat_update':
          _eventController.add(SeatUpdateEvent.fromJson(data));
          break;
        case 'pong':
          // Heartbeat response
          break;
        default:
          dev.log('Unknown event type: $type', name: 'RealtimeService');
      }
    } catch (e) {
      dev.log('Error parsing message: $e', name: 'RealtimeService');
    }
  }

  /// معالجة الأخطاء
  void _handleError(error) {
    dev.log('❌ WebSocket error: $error', name: 'RealtimeService');
    _scheduleReconnect();
  }

  /// معالجة قطع الاتصال
  void _handleDisconnect() {
    _isConnected = false;
    _heartbeatTimer?.cancel();
    dev.log('🔌 WebSocket disconnected', name: 'RealtimeService');
    _scheduleReconnect();
  }

  /// جدولة إعادة الاتصال
  void _scheduleReconnect() {
    if (_reconnectAttempts >= _maxReconnectAttempts) {
      dev.log('❌ Max reconnection attempts reached', name: 'RealtimeService');
      return;
    }

    _reconnectAttempts++;
    final delay = Duration(seconds: _reconnectAttempts * 2);

    _reconnectTimer?.cancel();
    _reconnectTimer = Timer(delay, () {
      dev.log('🔄 Attempting reconnection #$_reconnectAttempts',
          name: 'RealtimeService');
      // إعادة الاتصال بنفس البيانات السابقة
      // يجب حفظ البيانات عند أول اتصال
    });
  }

  /// بدء Heartbeat للحفاظ على الاتصال
  void _startHeartbeat() {
    _heartbeatTimer?.cancel();
    _heartbeatTimer = Timer.periodic(const Duration(seconds: 30), (_) {
      if (_isConnected) {
        sendMessage({'type': 'ping'});
      }
    });
  }

  /// إرسال رسالة
  void sendMessage(Map<String, dynamic> message) {
    if (!_isConnected || _channel == null) {
      dev.log('⚠️ Cannot send message: not connected', name: 'RealtimeService');
      return;
    }

    try {
      _channel!.sink.add(jsonEncode(message));
    } catch (e) {
      dev.log('❌ Error sending message: $e', name: 'RealtimeService');
    }
  }

  /// إرسال هدية (Optimistic UI)
  void sendGift({
    required String giftId,
    required List<String> receiverIds,
    required int count,
  }) {
    // إرسال للخادم
    sendMessage({
      'type': 'send_gift',
      'gift_id': giftId,
      'receivers': receiverIds,
      'count': count,
      'timestamp': DateTime.now().toIso8601String(),
    });

    // Optimistic UI - إضافة فورية محلياً
    _eventController.add(GiftEvent(
      giftId: giftId,
      senderId: 'current_user', // يجب الحصول عليه من السياق
      receiverIds: receiverIds,
      count: count,
      timestamp: DateTime.now(),
      isOptimistic: true,
    ));
  }

  /// قطع الاتصال
  void disconnect() {
    _isConnected = false;
    _heartbeatTimer?.cancel();
    _reconnectTimer?.cancel();
    _channel?.sink.close();
    _channel = null;
    dev.log('👋 WebSocket disconnected', name: 'RealtimeService');
  }

  /// تنظيف الموارد
  void dispose() {
    disconnect();
    _eventController.close();
  }
}

/// الأحداث الأساسية
abstract class RealtimeEvent {
  final DateTime timestamp;
  final bool isOptimistic;

  RealtimeEvent({
    required this.timestamp,
    this.isOptimistic = false,
  });
}

/// حدث هدية
class GiftEvent extends RealtimeEvent {
  final String giftId;
  final String senderId;
  final List<String> receiverIds;
  final int count;

  GiftEvent({
    required this.giftId,
    required this.senderId,
    required this.receiverIds,
    required this.count,
    required super.timestamp,
    super.isOptimistic,
  });

  factory GiftEvent.fromJson(Map<String, dynamic> json) {
    return GiftEvent(
      giftId: json['gift_id'],
      senderId: json['sender_id'],
      receiverIds: List<String>.from(json['receivers']),
      count: json['count'],
      timestamp: DateTime.parse(json['timestamp']),
    );
  }
}

/// حدث رسالة
class MessageEvent extends RealtimeEvent {
  final String messageId;
  final String userId;
  final String content;
  final String? replyTo;

  MessageEvent({
    required this.messageId,
    required this.userId,
    required this.content,
    this.replyTo,
    required super.timestamp,
    super.isOptimistic,
  });

  factory MessageEvent.fromJson(Map<String, dynamic> json) {
    return MessageEvent(
      messageId: json['message_id'],
      userId: json['user_id'],
      content: json['content'],
      replyTo: json['reply_to'],
      timestamp: DateTime.parse(json['timestamp']),
    );
  }
}

/// حدث انضمام مستخدم
class UserJoinEvent extends RealtimeEvent {
  final String userId;
  final String userName;
  final String? avatarUrl;

  UserJoinEvent({
    required this.userId,
    required this.userName,
    this.avatarUrl,
    required super.timestamp,
  });

  factory UserJoinEvent.fromJson(Map<String, dynamic> json) {
    return UserJoinEvent(
      userId: json['user_id'],
      userName: json['user_name'],
      avatarUrl: json['avatar_url'],
      timestamp: DateTime.parse(json['timestamp']),
    );
  }
}

/// حدث مغادرة مستخدم
class UserLeaveEvent extends RealtimeEvent {
  final String userId;

  UserLeaveEvent({
    required this.userId,
    required super.timestamp,
  });

  factory UserLeaveEvent.fromJson(Map<String, dynamic> json) {
    return UserLeaveEvent(
      userId: json['user_id'],
      timestamp: DateTime.parse(json['timestamp']),
    );
  }
}

/// حدث تحديث مقعد
class SeatUpdateEvent extends RealtimeEvent {
  final int seatIndex;
  final String? userId;
  final bool isLocked;

  SeatUpdateEvent({
    required this.seatIndex,
    this.userId,
    required this.isLocked,
    required super.timestamp,
  });

  factory SeatUpdateEvent.fromJson(Map<String, dynamic> json) {
    return SeatUpdateEvent(
      seatIndex: json['seat_index'],
      userId: json['user_id'],
      isLocked: json['is_locked'],
      timestamp: DateTime.parse(json['timestamp']),
    );
  }
}
