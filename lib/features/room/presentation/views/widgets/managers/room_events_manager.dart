import 'dart:async';
import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:lklk/core/utils/logger.dart';
import 'package:lklk/core/utils/functions/snackbar_helper.dart';
import 'package:lklk/features/home/presentation/manger/room_cubit/room_cubit_cubit.dart';
// Home navigation is centralized via RoomExitService
import 'package:lklk/features/profile_users/presentaion/manger/user_cubit/user_cubit_cubit.dart';
import 'package:lklk/features/room/presentation/manger/room_exit_service.dart';
import 'package:lklk/live_audio_room_manager.dart';
import 'package:lklk/core/room_switch_guard.dart';
import 'package:lklk/features/livekit_audio/presentation/cubit/livekit_audio_cubit.dart';

/// مدير الأحداث والاتصالات للغرفة الصوتية
class RoomEventsManager {
  final BuildContext context;
  final UserCubit userCubit;
  final RoomCubit roomCubit;
  final String roomId;

  final List<StreamSubscription> _subscriptions = [];

  RoomEventsManager({
    required this.context,
    required this.userCubit,
    required this.roomCubit,
    required this.roomId,
  });

  /// تهيئة جميع الاشتراكات والمستمعين
  void initialize() {
    _initSubscriptions();
  }

  /// تنظيف الموارد
  void dispose() {
    for (var subscription in _subscriptions) {
      subscription.cancel();
    }
    _subscriptions.clear();
  }

  /// تهيئة الاشتراكات
  void _initSubscriptions() {
    final zimService = ZEGOSDKManager().zimService;
    final expressService = ZEGOSDKManager().expressService;

    _subscriptions.addAll([
      expressService.roomStateChangedStreamCtrl.stream.listen(
        onExpressRoomStateChanged,
      ),
      zimService.roomStateChangedStreamCtrl.stream.listen(
        onZIMRoomStateChanged,
      ),
      zimService.connectionStateStreamCtrl.stream.listen(
        onZIMConnectionStateChanged,
      ),
      zimService.onInComingRoomRequestStreamCtrl.stream.listen(
        onIncomingRoomRequestReceived,
      ),
      zimService.onOutgoingRoomRequestAcceptedStreamCtrl.stream.listen(
        onOutgoingRoomRequestAccepted,
      ),
      zimService.onOutgoingRoomRequestRejectedStreamCtrl.stream.listen(
        onOutgoingRoomRequestRejected,
      ),
      zimService.onRoomCommandReceivedEventStreamCtrl.stream.listen(
        (event) => onRoomCommandReceived(event, userCubit, roomCubit),
      ),
    ]);
  }

  /// معالجة تغيير حالة Express Room
  void onExpressRoomStateChanged(ZegoRoomStateEvent event) {
    debugAppLogger.debug('RoomEventsManager:onExpressRoomStateChanged: $event');
    if (RoomSwitchGuard.isSwitching) {
      return;
    }

    if (event.errorCode != 0) {
      debugAppLogger
          .debug('Room state error: ${event.errorCode} - ${event.reason}');
      SnackbarHelper.showMessage(
          context, 'Connection error: ${event.errorCode}');
    }

    if (_shouldNavigateToHome(event.reason)) {
      _navigateToHome();
    }
  }

  /// معالجة تغيير حالة ZIM Room
  void onZIMRoomStateChanged(ZIMServiceRoomStateChangedEvent event) {
    debugAppLogger.debug('RoomEventsManager:onZIMRoomStateChanged: $event');
    if (RoomSwitchGuard.isSwitching) {
      return;
    }

    if (event.state == ZIMRoomState.disconnected) {
      _navigateToHome();
    }
  }

  /// معالجة تغيير حالة الاتصال
  void onZIMConnectionStateChanged(
      ZIMServiceConnectionStateChangedEvent event) {
    debugAppLogger
        .debug('RoomEventsManager:onZIMConnectionStateChanged: $event');
    if (RoomSwitchGuard.isSwitching) {
      return;
    }

    if (event.state == ZIMConnectionState.disconnected) {
      _navigateToHome();
    }
  }

  void onIncomingRoomRequestReceived(OnInComingRoomRequestReceivedEvent event) {
    // يمكن إضافة منطق معالجة الطلبات الواردة هنا
  }

  /// معالجة قبول طلب صادر
  void onOutgoingRoomRequestAccepted(OnOutgoingRoomRequestAcceptedEvent event) {
    // يمكن إضافة منطق معالجة قبول الطلبات هنا
  }

  /// معالجة رفض طلب صادر
  void onOutgoingRoomRequestRejected(OnOutgoingRoomRequestRejectedEvent event) {
    // يمكن إضافة منطق معالجة رفض الطلبات هنا
  }

  /// معالجة أوامر الغرفة المستلمة
  void onRoomCommandReceived(
    OnRoomCommandReceivedEvent event,
    UserCubit userCubit,
    RoomCubit roomCubit,
  ) {
    try {
      final Map<String, dynamic> messageMap = jsonDecode(event.command);
      log('Parsed room command: $messageMap', name: 'RoomEventsManager');

      if (messageMap.containsKey('room_command_type')) {
        final type = messageMap['room_command_type'];
        final receiverID = messageMap['receiver_id'];

        if (receiverID == ZEGOSDKManager().currentUser!.iduser) {
          _handleRoomCommand(type, userCubit, roomCubit);
        }
      }
    } catch (e) {
      log('Error parsing room command: $e', name: 'RoomEventsManager');
    }
  }

  /// معالجة أوامر الغرفة المختلفة
  void _handleRoomCommand(
      String type, UserCubit userCubit, RoomCubit roomCubit) {
    switch (type) {
      case RoomCommandType.muteSpeaker:
        log('You have been muted by the host');
        try {
          context.read<LiveKitAudioCubit>().toggleMic(false);
        } catch (_) {}
        break;
      case RoomCommandType.unMuteSpeaker:
        log('You have been unmuted by the host');
        try {
          context.read<LiveKitAudioCubit>().toggleMic(true);
        } catch (_) {}
        break;
      case RoomCommandType.kickOutRoom:
        log('You have been kicked out of the room');
        _handleKickOut(userCubit, roomCubit);
        break;
    }
  }

  /// معالجة طرد المستخدم من الغرفة
  void _handleKickOut(UserCubit userCubit, RoomCubit roomCubit) {
    if (!RoomExitService.isExiting) {
      RoomExitService.exitRoom(
        context: context,
        userCubit: userCubit,
        roomCubit: roomCubit,
      );
    }
  }

  /// معالجة إعادة الاتصال
  void _handleReconnection() {
    // يمكن إضافة منطق إعادة الاتصال هنا
    // مثل إعادة تسجيل الدخول للغرفة
  }

  /// فحص ما إذا كان يجب الانتقال للصفحة الرئيسية
  bool _shouldNavigateToHome(ZegoRoomStateChangedReason reason) {
    return reason == ZegoRoomStateChangedReason.KickOut ||
        reason == ZegoRoomStateChangedReason.ReconnectFailed ||
        reason == ZegoRoomStateChangedReason.LoginFailed;
  }

  /// الانتقال للصفحة الرئيسية
  void _navigateToHome() {
    BlocProvider.of<RoomCubit>(context).backInitial();
    if (!RoomExitService.isExiting) {
      RoomExitService.exitRoom(
        context: context,
        userCubit: userCubit,
        roomCubit: roomCubit,
      );
    }
  }
}

/// أنواع أوامر الغرفة
class RoomCommandType {
  static const String muteSpeaker = 'mute_speaker';
  static const String unMuteSpeaker = 'unmute_speaker';
  static const String kickOutRoom = 'kick_out_room';
}
