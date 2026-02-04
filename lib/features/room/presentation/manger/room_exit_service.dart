// room_exit_service.dart - باستخدام Service Locator
import 'package:flutter/material.dart';
import 'package:lklk/core/foreground_service_manager.dart';
import 'package:lklk/core/service_locator.dart';
import 'package:lklk/core/utils/logger.dart';
import 'package:lklk/features/home/presentation/manger/room_cubit/room_cubit_cubit.dart';
import 'package:lklk/features/home/presentation/views/home_view.dart';
import 'package:lklk/features/profile_users/presentaion/manger/user_cubit/user_cubit_cubit.dart';
import 'package:lklk/features/room/presentation/manger/lucky_bag/luck_bag_cubit.dart';
import 'package:lklk/core/widgets/overlay/defines.dart';
import 'package:lklk/live_audio_room_manager.dart';

class RoomExitService {
  static bool _isExiting = false;
  static bool get isExiting => _isExiting;
  static Future<void> exitRoom({
    required BuildContext context,
    required UserCubit userCubit,
    required RoomCubit roomCubit,
    Duration delayDuration = Duration.zero,
  }) async {
    if (_isExiting) {
      AppLogger.debug('[RoomExitService] Exit suppressed: already in progress');
      return;
    }
    _isExiting = true;
    AppLogger.debug('[RoomExitService] Starting exit flow');
    // أخفِ فقاعة الـ Overlay إن كانت معروضة لتفادي تعارض التنقل
    try { audioRoomOverlayController.hide(); } catch (_) {}
    await ForegroundServiceManager.stopService(context);
    await ZegoLiveAudioRoomManager().logoutRoom();

    // استخدام Service Locator للوصول إلى LuckBagCubit
    final luckBagCubit = sl<LuckBagCubit>();
    resetLuckBagCubit();
    roomCubit.backInitial();

    await luckBagCubit.close();

    // تأخير الانتقال إذا كانت المدة أكبر من صفر
    if (delayDuration > Duration.zero) {
      await Future.delayed(delayDuration);
    }

    // حاول الانتقال فوراً بدون الاعتماد على postFrame لتفادي التعليق داخل حوارات/Overlays
    try {
      if (!context.mounted) {
        AppLogger.debug('[RoomExitService] Context not mounted at nav time, skipping navigation');
      } else {
        AppLogger.debug('[RoomExitService] Navigating to Home (rootNavigator=true)');
        final navigator = Navigator.of(context, rootNavigator: true);
        navigator.pushAndRemoveUntil(
          MaterialPageRoute(
            builder: (ctx) => HomeView(
              userCubit: userCubit,
              roomCubit: roomCubit,
            ),
          ),
          (Route<dynamic> route) => false,
        );
      }
    } catch (e, st) {
      AppLogger.error('[RoomExitService] Direct navigation failed, trying fallback: $e', error: e, stackTrace: st);
      // محاولة بديلة بدون rootNavigator
      try {
        if (context.mounted) {
          final navigator = Navigator.of(context, rootNavigator: false);
          navigator.pushAndRemoveUntil(
            MaterialPageRoute(
              builder: (ctx) => HomeView(
                userCubit: userCubit,
                roomCubit: roomCubit,
              ),
            ),
            (Route<dynamic> route) => false,
          );
        }
      } catch (e2, st2) {
        AppLogger.error('[RoomExitService] Fallback navigation also failed: $e2', error: e2, stackTrace: st2);
      }
    } finally {
      // ضمان إعادة التفعيل حتى في حال فشل/عدم استدعاء أي callbacks
      Future.delayed(const Duration(seconds: 2), () {
        _isExiting = false;
      });
    }
  }
}
