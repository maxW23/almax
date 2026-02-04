import 'dart:async';
import 'dart:convert';

import 'package:lklk/core/utils/logger.dart';
import 'package:lklk/live_audio_room_manager.dart';
import 'package:lklk/zego_sdk_manager.dart';

class MicInviteService {
  static const String typeInvite = 'invite_to_mic';
  static const String typeInviteResponse = 'invite_to_mic_response';

  /// إرسال دعوة لمستخدم لأخذ المايك على مقعد محدد (حتى لو كان مقفول)
  static Future<void> sendInvite({
    required String roomId,
    required String receiverId,
    required int seatIndex,
    required String inviterRole,
  }) async {
    try {
      final inviterId = ZEGOSDKManager().currentUser!.iduser;
      final cmd = {
        'type': typeInvite,
        'room_id': roomId,
        'receiver_id': receiverId,
        'inviter_id': inviterId,
        'inviter_role': inviterRole,
        'seat_index': seatIndex,
        'timestamp': DateTime.now().millisecondsSinceEpoch,
      };
      await ZEGOSDKManager().zimService.sendRoomCommand(jsonEncode(cmd));
      log('🎤 Invite sent -> user:$receiverId seat:$seatIndex role:$inviterRole');
    } catch (e) {
      log('❌ sendInvite error: $e');
    }
  }

  /// إرسال رد على الدعوة (accepted / rejected)
  static Future<void> sendInviteResponse({
    required String roomId,
    required String toInviterId,
    required int seatIndex,
    required String response, // 'accepted' | 'rejected'
  }) async {
    try {
      final myId = ZEGOSDKManager().currentUser!.iduser;
      final cmd = {
        'type': typeInviteResponse,
        'room_id': roomId,
        'to': toInviterId,
        'from': myId,
        'seat_index': seatIndex,
        'response': response,
        'timestamp': DateTime.now().millisecondsSinceEpoch,
      };
      await ZEGOSDKManager().zimService.sendRoomCommand(jsonEncode(cmd));
      log('📩 Invite response sent -> to:$toInviterId response:$response');
    } catch (e) {
      log('❌ sendInviteResponse error: $e');
    }
  }

  /// تنفيذ منطق القبول: محاولة الجلوس بالقوة ثم فتح المايك
  static Future<void> acceptInviteAndTakeSeat({
    required String roomId,
    required int seatIndex,
  }) async {
    try {
      // محاولة الجلوس بالقوة حتى لو المقعد مقفول
      final result = await ZegoLiveAudioRoomManager()
          .roomSeatService
          ?.takeSeat(seatIndex, isForce: true);

      // إذا نجحت العملية، افتح المايك وابدأ البث
      if (result != null && !result.errorKeys.contains(seatIndex.toString())) {
        // تأكيد أننا فعلاً على المقعد ثم نشر البث
        ZegoLiveAudioRoomManager().openMicAndStartPublishStream();
      } else {
        // في حال فشل المقعد المطلوب، حاول أقرب مقعد فارغ بالقوة
        for (final seat in ZegoLiveAudioRoomManager().seatList) {
          if (seat.currentUser.value == null) {
            final r = await ZegoLiveAudioRoomManager()
                .roomSeatService
                ?.takeSeat(seat.seatIndex, isForce: true);
            if (r != null && !r.errorKeys.contains(seat.seatIndex.toString())) {
              ZegoLiveAudioRoomManager().openMicAndStartPublishStream();
              break;
            }
          }
        }
      }
    } catch (e) {
      log('❌ acceptInviteAndTakeSeat error: $e');
    }
  }
}
