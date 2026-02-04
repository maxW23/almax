import 'package:flutter/material.dart';
import 'dart:developer' as dev;

/// مُحسِّن أداء الدردشة - تحسينات بسيطة وآمنة
class ChatPerformanceOptimizer {
  static const String _logTag = 'ChatPerformanceOptimizer';

  // إعدادات التحسين
  static const int maxVisibleMessages = 50; // عدد الرسائل المرئية
  static const int maxCachedMessages = 100; // عدد الرسائل المخزنة
  static const Duration messageDebounce =
      Duration(milliseconds: 100); // تأخير الرسائل

  /// قائمة الرسائل المحسنة
  static Widget optimizedMessagesList<T>({
    required List<T> messages,
    required Widget Function(BuildContext, T, int) itemBuilder,
    ScrollController? controller,
    bool reverse = true,
    EdgeInsetsGeometry? padding,
    Widget? emptyWidget,
  }) {
    dev.log(
        '🚀 Creating optimized messages list with ${messages.length} messages',
        name: _logTag);

    if (messages.isEmpty) {
      return emptyWidget ??
          const Center(
            child: Text('لا توجد رسائل'),
          );
    }

    // تحديد الرسائل المرئية فقط
    final visibleMessages = messages.length > maxVisibleMessages
        ? messages.sublist(messages.length - maxVisibleMessages)
        : messages;

    return ListView.builder(
      controller: controller,
      reverse: reverse,
      padding: padding,
      cacheExtent: 300.0, // تحسين cache
      itemCount: visibleMessages.length,
      itemBuilder: (context, index) {
        return RepaintBoundary(
          key: ValueKey('message_${visibleMessages.length - index}'),
          child: itemBuilder(context, visibleMessages[index], index),
        );
      },
    );
  }
}

/// معالج الرسائل مع debouncing
class MessageHandler<T> {
  static const String _logTag = 'MessageHandler';

  final List<T> _messages = [];
  final List<T> _pendingMessages = [];
  DateTime? _lastUpdate;

  /// إضافة رسالة جديدة
  void addMessage(T message) {
    _pendingMessages.add(message);
    _scheduleUpdate();
  }

  /// إضافة عدة رسائل
  void addMessages(List<T> messages) {
    _pendingMessages.addAll(messages);
    _scheduleUpdate();
  }

  /// جدولة التحديث
  void _scheduleUpdate() {
    final now = DateTime.now();
    if (_lastUpdate == null ||
        now.difference(_lastUpdate!) >
            ChatPerformanceOptimizer.messageDebounce) {
      _processMessages();
    } else {
      Future.delayed(
          ChatPerformanceOptimizer.messageDebounce, _processMessages);
    }
  }

  /// معالجة الرسائل المعلقة
  void _processMessages() {
    if (_pendingMessages.isEmpty) return;

    _messages.addAll(_pendingMessages);
    _pendingMessages.clear();
    _lastUpdate = DateTime.now();

    // تنظيف الرسائل القديمة
    if (_messages.length > ChatPerformanceOptimizer.maxCachedMessages) {
      final removeCount =
          _messages.length - ChatPerformanceOptimizer.maxCachedMessages;
      _messages.removeRange(0, removeCount);
      dev.log('🧹 Removed $removeCount old messages', name: _logTag);
    }

    dev.log('📝 Processed messages, total: ${_messages.length}', name: _logTag);
  }

  /// الحصول على الرسائل
  List<T> get messages => List.unmodifiable(_messages);

  /// مسح الرسائل
  void clear() {
    _messages.clear();
    _pendingMessages.clear();
    _lastUpdate = null;
    dev.log('🗑️ Messages cleared', name: _logTag);
  }

  /// إحصائيات
  Map<String, int> get stats => {
        'totalMessages': _messages.length,
        'pendingMessages': _pendingMessages.length,
        'maxVisible': ChatPerformanceOptimizer.maxVisibleMessages,
        'maxCached': ChatPerformanceOptimizer.maxCachedMessages,
      };
}

/// Widget محسن لرسالة واحدة
class OptimizedMessageWidget extends StatelessWidget {
  final String message;
  final String? senderName;
  final DateTime? timestamp;
  final bool isOwnMessage;
  final VoidCallback? onTap;

  const OptimizedMessageWidget({
    super.key,
    required this.message,
    this.senderName,
    this.timestamp,
    this.isOwnMessage = false,
    this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        margin: const EdgeInsets.symmetric(vertical: 2, horizontal: 8),
        padding: const EdgeInsets.all(8),
        decoration: BoxDecoration(
          color: isOwnMessage ? Colors.blue[100] : Colors.grey[100],
          borderRadius: BorderRadius.circular(8),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          mainAxisSize: MainAxisSize.min,
          children: [
            if (senderName != null) ...[
              Text(
                senderName!,
                style: const TextStyle(
                  fontWeight: FontWeight.bold,
                  fontSize: 12,
                ),
              ),
              const SizedBox(height: 4),
            ],
            Text(
              message,
              style: const TextStyle(fontSize: 14),
            ),
            if (timestamp != null) ...[
              const SizedBox(height: 4),
              Text(
                _formatTime(timestamp!),
                style: TextStyle(
                  fontSize: 10,
                  color: Colors.grey[600],
                ),
              ),
            ],
          ],
        ),
      ),
    );
  }

  String _formatTime(DateTime time) {
    final now = DateTime.now();
    final diff = now.difference(time);

    if (diff.inMinutes < 1) {
      return 'الآن';
    } else if (diff.inHours < 1) {
      return '${diff.inMinutes} د';
    } else if (diff.inDays < 1) {
      return '${diff.inHours} س';
    } else {
      return '${time.day}/${time.month}';
    }
  }
}

/// ScrollController محسن للدردشة
class ChatScrollController extends ScrollController {
  static const String _logTag = 'ChatScrollController';

  bool _autoScroll = true;

  /// تفعيل/إلغاء التمرير التلقائي
  void setAutoScroll(bool enabled) {
    _autoScroll = enabled;
    dev.log('🔄 Auto scroll ${enabled ? 'enabled' : 'disabled'}',
        name: _logTag);
  }

  /// التمرير لأسفل (أحدث رسالة)
  Future<void> scrollToBottom({
    Duration duration = const Duration(milliseconds: 300),
    Curve curve = Curves.easeOut,
  }) async {
    if (!hasClients || !_autoScroll) return;

    try {
      await animateTo(
        0.0, // في الدردشة المعكوسة، 0 هو الأسفل
        duration: duration,
        curve: curve,
      );
      dev.log('✅ Scrolled to bottom', name: _logTag);
    } catch (e) {
      dev.log('❌ Failed to scroll to bottom: $e', name: _logTag);
    }
  }

  /// التحقق من وجود رسائل جديدة
  bool get isAtBottom => hasClients && offset <= 50.0;

  /// التمرير التلقائي عند وصول رسالة جديدة
  void onNewMessage() {
    if (_autoScroll && isAtBottom) {
      scrollToBottom();
    }
  }
}
