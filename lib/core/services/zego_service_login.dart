// lib/utils/zego_util.dart
import 'dart:async';
import 'package:lklk/core/utils/logger.dart';
import 'package:flutter/material.dart';
import 'package:lklk/core/animations/custom_page_transition.dart';
import 'package:lklk/features/auth/presentation/view/auth_view.dart';
import 'package:lklk/generated/l10n.dart';
import 'package:flutter/foundation.dart';
import 'package:lklk/core/services/auth_service.dart';
import 'package:lklk/features/home/presentation/manger/room_cubit/room_cubit_cubit.dart';
import 'package:lklk/features/home/presentation/views/home_view.dart';
import 'package:lklk/pages/call/call_controller.dart';
import 'package:lklk/zego_call_manager.dart';
import 'package:lklk/zego_sdk_key_center.dart';
import 'package:lklk/features/profile_users/presentaion/manger/user_cubit/user_cubit_cubit.dart';
import 'package:lklk/features/home/domain/entities/avatar_data_zego.dart';

Future<void> zegoLoginService(
  BuildContext context, {
  required UserCubit userCubit,
  required RoomCubit roomCubit,
}) async {
  // Capture UI helpers before any awaits to avoid using BuildContext across async gaps
  final navigator = Navigator.of(context);
  final messenger = ScaffoldMessenger.of(context);
  final l10n = S.of(context);
  Future<bool> tryWithErrorHandling(
      Future<void> Function() func, String action) async {
    try {
      await func();
      return true;
    } catch (error, stackTrace) {
      log('$action failed: $error', stackTrace: stackTrace);
      messenger.showSnackBar(
        SnackBar(
            content: Text('${l10n.failedToInitializeZego} ($action): $error')),
      );
      return false;
    }
  }

  bool success;

  success = await tryWithErrorHandling(() async {
    await ZEGOSDKManager()
        .init(SDKKeyCenter.appID, kIsWeb ? null : SDKKeyCenter.appSign);
  }, 'init');
  if (!success) return;

  success = await tryWithErrorHandling(() async {
    ZegoCallManager().addListener();
  }, 'addListener');
  if (!success) return;

  success = await tryWithErrorHandling(() async {
    ZegoCallController().initService();
  }, 'initService');
  if (!success) return;

  String? token;
  final userAuth = await AuthService.getUserFromSharedPreferences();
  final user = userCubit.user ?? userAuth;

  if (user == null) {
    navigator.pushReplacement(
      MaterialPageRoute(
        builder: (context) =>
            AuthView(roomCubit: roomCubit, userCubit: userCubit),
      ),
    );
    return;
  }

  if (kIsWeb) {
    success = await tryWithErrorHandling(() async {
      token = await AuthService.getTokenFromSharedPreferences();
    }, 'getToken');
    if (!success) return;
  }

  success = await tryWithErrorHandling(() async {
    await ZEGOSDKManager().connectUser(user, token: token);
  }, 'connectUser');
  if (!success) return;

  success = await tryWithErrorHandling(() async {
    final imgUser = updateUserImagePath(user.img);
    final avatarData = AvatarData(
      imageUrl: imgUser,
      frameId: user.elementFrame?.elamentId,
      frameLink: user.elementFrame?.linkPath,
      vipLevel: user.vip,
      entryID: user.entryID,
      entryTimer: user.entryTimer,
      entryLink: user.entrylink,
      totalSocre: user.totalSocre,
      level1: user.level1,
      level2: user.level2,
      newlevel3: user.newlevel3, // pass displayed level instead of points
      ownerIds: user.ownerIds,
      adminRoomIds: user.adminRoomIds,
      svgaSquareUrls: [
        user.ws1,
        user.ws2,
        user.ws3,
        user.ws4,
        user.ws5,
      ]
          .whereType<String>()
          .map((e) => e.trim())
          .where((t) => t.isNotEmpty && t != 'null')
          .toList(),
      svgaRectUrls: [
        user.ic1,
        user.ic2,
        user.ic3,
        user.ic4,
        user.ic5,
        user.ic6,
        user.ic7,
        user.ic8,
        user.ic9,
        user.ic10,
        user.ic11,
        user.ic12,
        user.ic13,
        user.ic14,
        user.ic15,
      ]
          .whereType<String>()
          .map((e) => e.trim())
          .where((t) => t.isNotEmpty && t != 'null')
          .toList(),
    );
    final encoded = avatarData.toEncodedString();
    // Keep avatarUrl a real image URL; publish rich AvatarData via extendedData
    await ZEGOSDKManager().zimService.updateUserAvatarUrl(imgUser ?? '');
    try {
      await ZEGOSDKManager().zimService.updateUserExtendedData(encoded);
    } catch (_) {}
  }, 'updateUserAvatarUrl');
  if (!success) return;

  success = await tryWithErrorHandling(() async {
    await ZEGOSDKManager().zimService.updateUserName(user.name!);
  }, 'updateUserName');
  if (!success) return;

  try {
    log("HomeView zegoServices ");
    userCubit.getProfileUser("zegoservice");
    navigator.pushReplacement(
      CustomPageTransition.gentleTransition(
        HomeView(roomCubit: roomCubit, userCubit: userCubit),
      ),
    );
  } catch (error, stackTrace) {
    log('navigateHomeView failed: $error', stackTrace: stackTrace);
    messenger.showSnackBar(
      SnackBar(
          content: Text(
              '${l10n.failedToInitializeZego} (navigateHomeView): $error')),
    );
  }
}

String? updateUserImagePath(String? path) {
  if (path == null) {
    return null;
  } else if (path.contains('https://lh3.googleusercontent.com')) {
    return path;
  } else if (path.contains('https://lklklive.com')) {
    return path;
  } else if (path.contains('https://')) {
    return path;
  } else {
    return 'https://lklklive.com/imguser/$path';
  }
}
