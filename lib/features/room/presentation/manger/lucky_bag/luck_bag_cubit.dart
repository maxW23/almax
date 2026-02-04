import 'dart:async';
import 'package:lklk/core/utils/logger.dart';

import 'package:bloc/bloc.dart';
import 'package:equatable/equatable.dart';
import 'package:lklk/features/room/domain/entities/luck_bag_entity.dart';
import 'package:lklk/features/room/domain/use_cases/get_bag_result_use_case.dart';
import 'package:lklk/features/room/presentation/manger/lucky_bag/bag_session.dart';
import 'package:lklk/features/room/presentation/manger/lucky_bag/money_bag_manager.dart';

part 'luck_bag_state.dart';

class LuckBagCubit extends Cubit<LuckBagState> {
  final GetBagResultUseCase getBagResultUseCase;
  final PurchaseBagUseCase purchaseBagUseCase;
  final SendUltraMessageUseCase sendUltraMessageUseCase;
  final CompletePurchaseFlowUseCase completePurchaseFlowUseCase;

  bool _isClosing = false;
  final MoneyBagManager manager = MoneyBagManager();
  LuckBagCubit({
    required this.getBagResultUseCase,
    required this.purchaseBagUseCase,
    required this.sendUltraMessageUseCase,
    required this.completePurchaseFlowUseCase,
  }) : super(LuckBagState.initial()) {
    log('[LuckBagCubit] ✅ Cubit initialized with hashCode: $hashCode');
  }
  final Map<String, Set<String>> _processedBags = {};

  bool _isAlreadyProcessed(String bagId, String userId) {
    if (!_processedBags.containsKey(bagId)) {
      _processedBags[bagId] = {};
    }

    if (_processedBags[bagId]!.contains(userId)) {
      return true;
    } else {
      _processedBags[bagId]!.add(userId);
      return false;
    }
  }

  void _safeEmit(LuckBagState state) {
    if (!_isClosing && !isClosed) {
      log('[LuckBagCubit] 🟢 Emitting state: ${state.status}');
      emit(state);
    } else {
      log('[LuckBagCubit] ⚠️ Cannot emit - Cubit is closing or closed');
    }
  }

  bool isUserAlreadyInBag(String roomId, String userId) {
    log('[LuckBagCubit] 🔍 Checking if user $userId is already in any bag in room $roomId');
    final sessions = manager.roomBags[roomId];
    if (sessions == null) {
      log('[LuckBagCubit] ℹ️ No sessions found for room $roomId');
      return false;
    }

    for (final session in sessions) {
      if (session.collectedUsers.contains(userId)) {
        log('[LuckBagCubit] ✅ User $userId found in bag ${session.bagID}');
        return true;
      }
    }

    log('[LuckBagCubit] ❌ User $userId not found in any bag in room $roomId');
    return false;
  }

  Future<void> purchaseBag(LuckBagEntity luckBag) async {
    if (_isClosing || isClosed) {
      log('[LuckBagCubit] ⚠️ Cannot purchase bag - Cubit is closing or closed');
      return;
    }

    log('🛒 [LuckBagCubit] PURCHASE BAG - Cubit Instance: $hashCode');
    _emitPurchasingState('تنفيذ عملية الشراء');

    try {
      log('[LuckBagCubit] 📤 Sending purchase request for room: ${luckBag.roomID}');
      final result = await purchaseBagUseCase.execute(luckBag);

      if (_isClosing || isClosed) {
        log('[LuckBagCubit] ⚠️ Purchase completed but cubit is already closed');
        return;
      }

      log('[LuckBagCubit] ✅ Purchase successful: $result');
      _safeEmit(state.copyWith(
        status: BagStatus.success,
        purchaseMessage: result,
        activeBagsCount: _getActiveBagsCount(),
      ));
    } catch (e) {
      log('[LuckBagCubit] ❌ Purchase failed: $e', error: e);
      _emitErrorState('فشل في عملية الشراء: $e');
    }
  }

  void handleMoneyBag(Map<String, dynamic> data) {
    log('[LuckBagCubit] 📨 Handling money bag message: ${data[r'$id']}');

    final roomId = _safeToString(data['room_id']);
    if (roomId.isEmpty) {
      log('[LuckBagCubit] ❌ Invalid room_id: ${data['room_id']}');
      return;
    }

    final sender = _safeToString(data['sender']);

    String bagId = '';
    if (data['type'] == 'money_bag') {
      bagId = _safeToString(data[r'$id']);
    } else if (data['type'] == 'money_bag_result') {
      bagId = _safeToString(data['gift_id']);
    }

    if (bagId.isEmpty) {
      log('[LuckBagCubit] ❌ Missing bag id in data: $data');
      return;
    }
    final userId = _safeToString(data['UserID']);
    if (_isAlreadyProcessed(bagId, userId)) {
      log('[LuckBagCubit] ⚠️ Bag $bagId for user $userId already processed recently.');
      return;
    }

    final who = _safeToString(data['selected_usr']);
    final how = _safeToString(data['gift_id']);

    int createdAt = DateTime.now().millisecondsSinceEpoch;
    final rawTs = data['timestamp'] ?? data['createdAt'];

    if (rawTs != null) {
      log('[LuckBagCubit] ⏰ Raw timestamp: $rawTs (type: ${rawTs.runtimeType})');
      if (rawTs is String) {
        final parsed = int.tryParse(rawTs) ?? 0;
        createdAt = (parsed < 100000000000) ? parsed * 1000 : parsed;
        log('[LuckBagCubit] 🔄 Converted string timestamp: $parsed → $createdAt');
      } else if (rawTs is int) {
        createdAt = (rawTs < 100000000000) ? rawTs * 1000 : rawTs;
        log('[LuckBagCubit] 🔄 Converted int timestamp: $rawTs → $createdAt');
      }
    }

    final maxUsers = int.tryParse(_safeToString(data['selected_usr'])) ?? 50;

    log('[LuckBagCubit] 🎯 Creating new bag session for bag: $bagId');
    final session = BagSession(
      bagID: bagId,
      ownerID: sender,
      displayEndAtMs: data['_displayEndAt'] is int
          ? data['_displayEndAt'] as int
          : (data['_displayEndAt'] is String
              ? int.tryParse(data['_displayEndAt'])
              : null),
      createdAt: createdAt,
      collectedUsers: [],
      maxUsers: maxUsers,
      how: how,
      who: who,
    );

    manager.addSession(roomId, session);
    log('[LuckBagCubit] 🎉 Money bag created in room $roomId by $sender. bagID: $bagId');

    // If the realtime layer provided an explicit display end timestamp,
    // schedule the session timer to fire at that exact time. Otherwise
    // fall back to the default duration (17s) from the createdAt.
    final displayEnd = session.displayEndAtMs;
    // We want to request the bag result 2 seconds BEFORE the UI timers expire.
    const leadMs = 2000;
    if (displayEnd != null && displayEnd > 0) {
      final nowMs = DateTime.now().millisecondsSinceEpoch;
      final targetMs = displayEnd - leadMs; // request 2s earlier
      final remainingMs = targetMs - nowMs;
      final delay =
          remainingMs > 0 ? Duration(milliseconds: remainingMs) : Duration.zero;
      session.timer = Timer(delay, () {
        log('[LuckBagCubit] ⏰ Scheduled pre-request timer fired for bag: $bagId (target: ${DateTime.fromMillisecondsSinceEpoch(targetMs)}, displayEnd: ${DateTime.fromMillisecondsSinceEpoch(displayEnd)})');
        _processBagResult(roomId, bagId);
      });
      log('[LuckBagCubit] ⏳ Session pre-request timer scheduled for ${DateTime.fromMillisecondsSinceEpoch(targetMs)} (display end: ${DateTime.fromMillisecondsSinceEpoch(displayEnd)}) for bag: $bagId');
    } else {
      // fallback: default duration (17s) minus lead
      final fallbackTarget =
          DateTime.now().millisecondsSinceEpoch + (17 * 1000) - leadMs;
      final delay = Duration(
          milliseconds: (fallbackTarget - DateTime.now().millisecondsSinceEpoch)
              .clamp(0, 1 << 31));
      session.timer = Timer(delay, () {
        log('[LuckBagCubit] ⏰ Fallback pre-request timer fired for bag: $bagId');
        _processBagResult(roomId, bagId);
      });
      log('[LuckBagCubit] ⏳ Session fallback pre-request timer scheduled for ${DateTime.fromMillisecondsSinceEpoch(fallbackTarget)} for bag: $bagId');
    }

    _safeEmit(state.copyWith(activeBagsCount: _getActiveBagsCount()));
  }

  void _processBagResult(String roomID, String bagId) {
    log('[LuckBagCubit] 🚀 Processing bag result for room $roomID, bag $bagId');

    final session = manager.findSession(roomID, bagId);
    if (session == null) {
      log('[LuckBagCubit] ❌ Session not found for room $roomID, bag $bagId');
      return;
    }

    if (session.isProcessing) {
      log('[LuckBagCubit] ⚠️ Bag $bagId is already being processed');
      return;
    }

    session.isProcessing = true;
    log('[LuckBagCubit] ⏰ Processing bag result for room $roomID, bag $bagId');

    if (session.collectedUsers.isEmpty) {
      log('[LuckBagCubit] ❌ No users collected for bag $bagId in room $roomID');
      debugPrintSessions();
    } else {
      final usersString = session.collectedUsers.join(',');
      log('[LuckBagCubit] ✅ Sending users to server: $usersString');

      // جهّز LuckBagEntity مع bag id من Appwrite و users
      final updatedBag =
          (session.bag ?? LuckBagEntity(roomID: roomID)).copyWith(
        user: usersString,
        id: bagId,
        who: session.who,
        how: session.how,
      );

      log('[LuckBagCubit] 📤 Sending bag result request for bag: $bagId');
      getBagResult(updatedBag);
    }

    // إضافة تأخير قبل تنظيف الجلسة لمطابقة التأخير في الواجهة
    Future.delayed(const Duration(seconds: 3), () {
      log('[LuckBagCubit] 🧹 Cleaning up session for bag: $bagId');
      session.dispose();
      manager.removeSession(roomID, bagId);
      _safeEmit(state.copyWith(activeBagsCount: _getActiveBagsCount()));
    });
  }

  Future<void> getBagResult(LuckBagEntity luckBag) async {
    if (_isClosing || isClosed) {
      log('[LuckBagCubit] ⚠️ Cannot get bag result - Cubit is closing or closed');
      return;
    }

    log('[LuckBagCubit] 📋 Getting bag result for bag: ${luckBag.id}');
    _emitLoadingState('جلب نتيجة الشراء');

    try {
      log('[LuckBagCubit] 📤 Sending getBagResult request for bag: ${luckBag.id}');
      final result = await getBagResultUseCase.execute(luckBag);

      log('[LuckBagCubit] ✅ Bag result received: $result');
      _safeEmit(state.copyWith(
        status: BagStatus.success,
        resultMessage: result,
      ));
    } catch (e) {
      log('[LuckBagCubit] ❌ Failed to get bag result: $e', error: e);
      _emitErrorState('فشل في جلب النتيجة: $e');
    }
  }

  @override
  Future<void> close() {
    log('[LuckBagCubit] 🚮 Closing cubit, cleaning up resources');
    _isClosing = true;

    int timerCount = 0;
    for (final sessions in manager.roomBags.values) {
      for (final session in sessions) {
        if (session.timer != null) {
          session.timer?.cancel();
          timerCount++;
        }
      }
    }

    log('[LuckBagCubit] 🧹 Cancelled $timerCount timers and clearing ${manager.roomBags.length} rooms');
    manager.roomBags.clear();

    return super.close();
  }

  int _getActiveBagsCount() {
    final count = manager.roomBags.values
        .fold(0, (count, sessions) => count + sessions.length);
    log('[LuckBagCubit] 📊 Active bags count: $count');
    return count;
  }

  void _emitLoadingState(String operation) {
    log('[LuckBagCubit] ⏳ Loading state: $operation');
    _safeEmit(state.copyWith(
      status: BagStatus.loading,
      currentOperation: operation,
    ));
  }

  void _emitPurchasingState(String operation) {
    log('[LuckBagCubit] 🛒 Purchasing state: $operation');
    _safeEmit(state.copyWith(
      status: BagStatus.purchasing,
      currentOperation: operation,
    ));
  }

  void _emitErrorState(String error) {
    log('[LuckBagCubit] ❌ Error state: $error');
    _safeEmit(state.copyWith(status: BagStatus.error, error: error));
  }

  Future<void> completePurchaseFlow(LuckBagEntity luckBag) async {
    if (_isClosing || isClosed) {
      log('[LuckBagCubit] ⚠️ Cannot complete purchase flow - Cubit is closing or closed');
      return;
    }

    log('[LuckBagCubit] 🔄 Completing purchase flow for bag: ${luckBag.id}');
    try {
      await completePurchaseFlowUseCase.execute(luckBag);
      log('[LuckBagCubit] ✅ Purchase flow completed successfully');
    } catch (e) {
      log('[LuckBagCubit] ❌ Purchase flow failed: $e', error: e);
      if (!_isClosing && !isClosed) {
        _emitErrorState('فشل في العملية الكاملة: ${e.toString()}');
      }
    }
  }

  Future<void> sendUltraMessage(int roomID, String message) async {
    if (_isClosing || isClosed) {
      log('[LuckBagCubit] ⚠️ Cannot send ultra message - Cubit is closing or closed');
      return;
    }

    log('[LuckBagCubit] 💬 Sending ultra message to room: $roomID');
    _emitSendingMessageState('إرسال الرسالة');

    try {
      final result = await sendUltraMessageUseCase.execute(roomID, message);
      log('[LuckBagCubit] ✅ Ultra message sent successfully: $result');
      _safeEmit(state.copyWith(
        status: BagStatus.success,
        ultraMessage: result,
        currentOperation: null,
        error: null,
      ));
    } catch (e) {
      log('[LuckBagCubit] ❌ Failed to send ultra message: $e', error: e);
      if (!_isClosing || !isClosed) {
        _emitErrorState('فشل في إرسال الرسالة: ${e.toString()}');
      }
    }
  }

  void clearError() {
    if (_isClosing || isClosed) {
      log('[LuckBagCubit] ⚠️ Cannot clear error - Cubit is closing or closed');
      return;
    }

    log('[LuckBagCubit] 🧹 Clearing error state');
    _safeEmit(state.copyWith(error: null, status: BagStatus.initial));
  }

  void _emitSendingMessageState(String operation) {
    log('[LuckBagCubit] 📤 Sending message state: $operation');
    _safeEmit(state.copyWith(
      status: BagStatus.sendingMessage,
      currentOperation: operation,
      error: null,
    ));
  }

  void debugPrintSessions() {
    log('=== [LuckBagCubit] DEBUG: Current Bag Sessions ===');
    if (manager.roomBags.isEmpty) {
      log('No active sessions found');
    } else {
      manager.roomBags.forEach((roomId, sessions) {
        log('Room $roomId:');
        for (var session in sessions) {
          log('  Bag ${session.bagID}: ${session.collectedUsers.length} users');
          log('    Users: ${session.collectedUsers.join(', ')}');
          log('    Created: ${DateTime.fromMillisecondsSinceEpoch(session.createdAt)}');
          log('    Max Users: ${session.maxUsers}');
          log('    Is Processing: ${session.isProcessing}');
        }
      });
    }
    log('==================================');
  }

  void debugPrintIncomingMessage(Map<String, dynamic> data) {
    log('=== [LuckBagCubit] DEBUG: Incoming Money Bag Message ===');
    log('Room ID: ${data['room_id']}');
    log('Bag ID: ${data[r'$id']}');
    log('Sender: ${data['sender']}');
    log('User ID: ${data['UserID']}');
    log('Message Type: ${data['type']}');
    log('Full Data: $data');
    log('==========================================');
  }

  /// يحول أي قيمة إلى String آمنة
  String _safeToString(dynamic value) {
    if (value == null) return '';
    if (value is String) return value;
    return value.toString();
  }
}
