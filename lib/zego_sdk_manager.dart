import 'package:lklk/core/utils/logger.dart';
import 'package:lklk/features/auth/domain/entities/user_entity.dart';

import 'internal/internal.dart';

export 'internal/internal.dart';

class ZEGOSDKManager {
  ZEGOSDKManager._internal();
  factory ZEGOSDKManager() => instance;
  static final ZEGOSDKManager instance = ZEGOSDKManager._internal();

  ExpressService expressService = ExpressService();
  ZIMService zimService = ZIMService();

  Future<void> init(int appID, String? appSign,
      {ZegoScenario scenario = ZegoScenario.Default}) async {
    await expressService.init(appID: appID, appSign: appSign);
    await zimService.init(appID: appID, appSign: appSign);
  }

  Future<void> connectUser(UserEntity user, {String? token}) async {
    await expressService.connectUser(user, token: token);
    await zimService.connectUser(user.iduser, user.name!, token: token);
  }

  Future<void> disconnectUser() async {
    await logoutRoom();
    await expressService.disconnectUser();
    await zimService.disconnectUser();
  }

  Future<void> uploadLog() async {
    await Future.wait([
      expressService.uploadLog(),
      zimService.uploadLog(),
    ]);
    return;
  }

  Future<ZegoRoomLoginResult> loginRoom(String roomID, ZegoScenario scenario,
      {String? token}) async {
    // await these two methods
    await expressService.setRoomScenario(scenario);
    final expressResult = await expressService.loginRoom(roomID, token: token);
    if (expressResult.errorCode != 0) {
      return expressResult;
    }
    final zimResult = await zimService.loginRoom(roomID);

    // rollback if one of them failed
    if (zimResult.errorCode != 0) {
      expressService.logoutRoom();
    }
    return zimResult;
  }

  Future<void> logoutRoom() async {
    debugAppLogger.debug('sdk manager, logoutRoom');

    await expressService.logoutRoom();
    await zimService.logoutRoom();
  }

  UserEntity? get currentUser => expressService.currentUser;
  UserEntity? getUser(String userID) {
    for (final user in expressService.userInfoList) {
      if (userID == user.iduser) {
        // log('frameZego user found: ${user.iduser}');
        return user;
      }
    }
    return null;
  }
}
