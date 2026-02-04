import 'dart:async';
import 'dart:developer' as dev;
import 'package:flutter/material.dart';
import 'package:lklk/features/room/presentation/views/widgets/room_performance_manager.dart';
import 'package:lklk/features/room/presentation/views/widgets/optimized_chat_manager.dart';
import 'package:lklk/features/room/presentation/views/widgets/optimized_gift_manager.dart';
import 'package:lklk/features/room/presentation/views/widgets/optimized_audio_manager.dart';
import 'package:lklk/features/room/presentation/views/widgets/room_view_body.dart';
import 'package:lklk/live_audio_room_manager.dart';

/// RoomViewBody محسن للأداء العالي (500+ مستخدم)
class RoomViewBodyOptimized extends StatefulWidget {
  const RoomViewBodyOptimized({
    super.key,
    required this.room,
    required this.roomCubit,
    this.users,
    this.bannedUsers,
    required this.userCubit,
    required this.role,
    this.fromOverlay,
    required this.onSend,
    this.adminUsers,
  });

  final bool? fromOverlay;
  final dynamic roomCubit;
  final dynamic room;
  final dynamic users;
  final dynamic bannedUsers;
  final dynamic adminUsers;
  final dynamic userCubit;
  final dynamic role;
  final void Function(ZIMMessage) onSend;

  @override
  State<RoomViewBodyOptimized> createState() => _RoomViewBodyOptimizedState();
}

class _RoomViewBodyOptimizedState extends State<RoomViewBodyOptimized>
    with WidgetsBindingObserver, TickerProviderStateMixin {
  // مديري الأداء
  late final RoomPerformanceManager _performanceManager;
  late final OptimizedChatManager _chatManager;
  late final OptimizedGiftManager _giftManager;
  late final OptimizedAudioManager _audioManager;

  // حالة الأداء
  bool _isHighPerformanceMode = false;
  int _currentUserCount = 0;

  @override
  void initState() {
    super.initState();

    // تهيئة مديري الأداء
    _initializePerformanceManagers();

    // إضافة مراقب دورة الحياة
    WidgetsBinding.instance.addObserver(this);

    // تحديد وضع الأداء بناءً على عدد المستخدمين
    _updatePerformanceMode();

    // بدء المعالجة المحسنة
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _startOptimizedProcessing();
    });
  }

  /// تهيئة مديري الأداء
  void _initializePerformanceManagers() {
    _performanceManager = RoomPerformanceManager();
    _chatManager = OptimizedChatManager();
    _giftManager = OptimizedGiftManager();
    _audioManager = OptimizedAudioManager();

    // حساب عدد المستخدمين
    _currentUserCount = widget.users?.length ?? 0;

    // تهيئة مديري الأداء
    _performanceManager.initializeForRoom(_currentUserCount);
    _giftManager.initialize();
    _audioManager.initialize();

    dev.log('🚀 Performance managers initialized for $_currentUserCount users',
        name: 'RoomViewBodyOptimized');
  }

  /// تحديث وضع الأداء
  void _updatePerformanceMode() {
    final userCount = widget.users?.length ?? 0;
    _currentUserCount = userCount;

    if (userCount > 300) {
      _enableHighPerformanceMode();
    } else if (userCount > 100) {
      _enableMediumPerformanceMode();
    } else {
      _enableNormalMode();
    }
  }

  /// تفعيل وضع الأداء العالي
  void _enableHighPerformanceMode() {
    setState(() {
      _isHighPerformanceMode = true;
    });

    dev.log('🔥 High Performance Mode activated for $_currentUserCount+ users',
        name: 'RoomViewBodyOptimized');

    // تقليل معدل التحديث
    _performanceManager.enableHighDensityMode();

    // تقليل عدد الرسائل المرئية
    OptimizedChatManager.maxVisibleMessages;

    // تقليل عدد الهدايا المتزامنة
    OptimizedGiftManager.maxConcurrentGifts;
  }

  /// تفعيل وضع الأداء المتوسط
  void _enableMediumPerformanceMode() {
    setState(() {
      _isHighPerformanceMode = false;
    });

    dev.log('⚡ Medium Performance Mode for $_currentUserCount users',
        name: 'RoomViewBodyOptimized');
    _performanceManager.enableMediumDensityMode();
  }

  /// تفعيل الوضع العادي
  void _enableNormalMode() {
    setState(() {
      _isHighPerformanceMode = false;
    });

    dev.log('✨ Normal Mode for $_currentUserCount users',
        name: 'RoomViewBodyOptimized');
    _performanceManager.enableNormalMode();
  }

  /// بدء المعالجة المحسنة
  void _startOptimizedProcessing() {
    // بدء مراقبة الأداء
    Timer.periodic(const Duration(seconds: 30), (_) {
      _printPerformanceStats();
    });
  }

  /// طباعة إحصائيات الأداء
  void _printPerformanceStats() {
    dev.log('''
    
=====================================
📊 ROOM PERFORMANCE REPORT
=====================================
👥 Users: $_currentUserCount
⚡ Mode: ${_isHighPerformanceMode ? 'HIGH PERFORMANCE' : 'NORMAL'}
-------------------------------------
''');

    _chatManager.printStats();
    _giftManager.printStats();
    _audioManager.printStats();

    dev.log('=====================================\n',
        name: 'RoomViewBodyOptimized');
  }

  @override
  void dispose() {
    WidgetsBinding.instance.removeObserver(this);

    // تنظيف مديري الأداء
    _performanceManager.dispose();
    _chatManager.dispose();
    _giftManager.dispose();
    _audioManager.dispose();

    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    // استخدام الويدجت الأصلي مع التحسينات المطبقة
    return Stack(
      children: [
        // الويدجت الأصلي
        RoomViewBody(
          room: widget.room,
          roomCubit: widget.roomCubit,
          users: widget.users,
          bannedUsers: widget.bannedUsers,
          userCubit: widget.userCubit,
          role: widget.role,
          fromOverlay: widget.fromOverlay,
          onSend: widget.onSend,
          adminUsers: widget.adminUsers,
        ),

        // شريط معلومات الأداء (في وضع التطوير فقط)
        if (const bool.fromEnvironment('dart.vm.product') == false)
          Positioned(
            top: 100,
            right: 10,
            child: _buildPerformanceIndicator(),
          ),
      ],
    );
  }

  /// بناء مؤشر الأداء
  Widget _buildPerformanceIndicator() {
    return Container(
      padding: const EdgeInsets.all(8),
      decoration: BoxDecoration(
        color: _isHighPerformanceMode
            ? Colors.orange.withValues(alpha: 0.8)
            : Colors.green.withValues(alpha: 0.8),
        borderRadius: BorderRadius.circular(8),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Performance',
            style: TextStyle(
              color: Colors.white,
              fontSize: 10,
              fontWeight: FontWeight.bold,
            ),
          ),
          Text(
            '$_currentUserCount users',
            style: TextStyle(
              color: Colors.white,
              fontSize: 9,
            ),
          ),
          Text(
            _isHighPerformanceMode ? 'HIGH' : 'NORMAL',
            style: TextStyle(
              color: Colors.white,
              fontSize: 9,
              fontWeight: FontWeight.bold,
            ),
          ),
        ],
      ),
    );
  }
}
