import 'dart:async';
import 'package:flutter/material.dart';
import 'package:lklk/core/utils/logger.dart';
import 'package:lklk/core/zego_delegate.dart';
import 'package:lklk/features/room/domain/entities/room_entity.dart';
import 'package:lklk/features/room/presentation/views/widgets/room_messages_store.dart';
import 'package:lklk/live_audio_room_manager.dart';

/// مدير الغرفة الصوتية
class RoomManager {
  final BuildContext context;
  final RoomEntity room;
  final ZegoDelegate zegoDelegate;
  final bool fromOverlay;

  bool _isInitialized = false;
  bool _isLoggedIn = false;

  // Getters للحالة
  bool get isInitialized => _isInitialized;
  bool get isLoggedIn => _isLoggedIn;

  RoomManager({
    required this.context,
    required this.room,
    required this.zegoDelegate,
    this.fromOverlay = false,
  });

  /// تهيئة مدير الغرفة
  Future<void> initialize() async {
    if (_isInitialized) return;

    try {
      await _createEngineAndLoginRoom();
      _isInitialized = true;
      log('Room manager initialized successfully', name: 'RoomManager');
    } catch (e) {
      log('Error initializing room manager: $e', name: 'RoomManager');
      rethrow;
    }
  }

  /// تنظيف الموارد
  Future<void> dispose() async {
    try {
      await _logoutRoom();
      await _destroyEngine();
      _isInitialized = false;
      _isLoggedIn = false;
      log('Room manager disposed successfully', name: 'RoomManager');
    } catch (e) {
      log('Error disposing room manager: $e', name: 'RoomManager');
    }
  }

  /// إنشاء المحرك وتسجيل الدخول للغرفة
  Future<void> _createEngineAndLoginRoom() async {
    await zegoDelegate.createEngine();

    if (!fromOverlay) {
      await loginRoom();
    }
  }

  /// تسجيل الدخول للغرفة
  Future<void> loginRoom() async {
    if (_isLoggedIn) {
      log('Already logged in to room', name: 'RoomManager');
      return;
    }

    try {
      final roomID = room.id.toString();
      // استخدام ZegoLiveAudioRoomManager بدلاً من ZEGOSDKManager مباشرة
      final result = await ZegoLiveAudioRoomManager().loginRoom(
        roomID,
        ZegoLiveAudioRoomRole.audience, // يمكن تخصيص هذا حسب الحاجة
      );

      if (result.errorCode == 0) {
        _isLoggedIn = true;
        log('Successfully logged in to room: $roomID', name: 'RoomManager');
      } else {
        throw Exception('Login failed with error code: ${result.errorCode}');
      }
    } catch (e) {
      log('Error logging in to room: $e', name: 'RoomManager');
      _handleLoginFailure();
      rethrow;
    }
  }

  /// تسجيل الخروج من الغرفة
  Future<void> _logoutRoom() async {
    if (!_isLoggedIn) return;

    try {
      ZegoLiveAudioRoomManager().unInit();
      _isLoggedIn = false;
      log('Successfully logged out from room', name: 'RoomManager');
    } catch (e) {
      log('Error logging out from room: $e', name: 'RoomManager');
    }
  }

  /// تدمير المحرك
  Future<void> _destroyEngine() async {
    try {
      zegoDelegate.destroyEngine();
      log('Engine destroyed successfully', name: 'RoomManager');
    } catch (e) {
      log('Error destroying engine: $e', name: 'RoomManager');
    }
  }

  /// معالجة فشل تسجيل الدخول
  void _handleLoginFailure() {
    // يمكن إضافة منطق معالجة فشل تسجيل الدخول هنا
    // مثل إظهار رسالة خطأ أو إعادة المحاولة
    log('Login failure handled', name: 'RoomManager');
  }

  /// إعادة الاتصال بالغرفة
  Future<void> reconnectRoom() async {
    try {
      if (_isLoggedIn) {
        await _logoutRoom();
      }

      await Future.delayed(const Duration(seconds: 1));
      await loginRoom();

      log('Successfully reconnected to room', name: 'RoomManager');
    } catch (e) {
      log('Error reconnecting to room: $e', name: 'RoomManager');
      rethrow;
    }
  }

  /// فحص حالة الاتصال
  bool isConnected() {
    return _isInitialized && _isLoggedIn;
  }

  /// الحصول على معلومات الغرفة
  Map<String, dynamic> getRoomInfo() {
    return {
      'id': room.id,
      'name': room.name,
      'isInitialized': _isInitialized,
      'isLoggedIn': _isLoggedIn,
      'fromOverlay': fromOverlay,
    };
  }

  /// إرسال رسالة للغرفة
  Future<void> sendMessage(String message) async {
    if (!_isLoggedIn) {
      throw Exception('Not logged in to room');
    }

    try {
      // استخدام sendRoomCommand بدلاً من sendRoomMessage
      await ZEGOSDKManager().zimService.sendRoomCommand(message);
      log('Message sent successfully: $message', name: 'RoomManager');
    } catch (e) {
      log('Error sending message: $e', name: 'RoomManager');
      rethrow;
    }
  }

  /// إرسال أمر للغرفة
  void sendRoomCommand(Map<String, dynamic> command) {
    if (!_isLoggedIn) {
      throw Exception('Not logged in to room');
    }

    try {
      final commandString = command.toString();
      ZEGOSDKManager().zimService.sendRoomCommand(commandString);
      log('Room command sent successfully: $commandString',
          name: 'RoomManager');
    } catch (e) {
      log('Error sending room command: $e', name: 'RoomManager');
      rethrow;
    }
  }

  /// الحصول على قائمة المستخدمين في الغرفة
  List<dynamic> getRoomUsers() {
    return ZegoLiveAudioRoomManager().seatList;
  }

  /// فحص ما إذا كان المستخدم مضيف الغرفة
  bool isRoomHost(String userID) {
    return room.owner == userID;
  }

  /// فحص ما إذا كان المستخدم مشرف في الغرفة
  bool isRoomAdmin(String userID) {
    // يمكن تحسين هذا بناءً على بنية البيانات الفعلية
    return false; // placeholder
  }

  /// الحصول على إحصائيات الغرفة
  Map<String, dynamic> getRoomStatistics() {
    final users = getRoomUsers();
    return {
      'totalUsers': users.length,
      'activeUsers': users.where((user) => user != null).length,
      'roomId': room.id,
      'roomName': room.name,
      'connectionStatus': isConnected() ? 'connected' : 'disconnected',
    };
  }

  /// تنظيف رسائل الغرفة
  void clearRoomMessages() {
    RoomMessagesStore.instance.clearMessages();
    log('Room messages cleared', name: 'RoomManager');
  }
}
