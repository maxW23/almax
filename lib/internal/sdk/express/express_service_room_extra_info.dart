part of 'express_service.dart';

extension ExpressServiceRoomExtraInfo on ExpressService {
  // todo refactor me
  Future<ZegoRoomSetRoomExtraInfoResult> setRoomExtraInfo(
      String key, String value) async {
    AppLogger.debug(
        'LockLogs - ZegoRoomSetRoomExtraInfoResult currentRoomID $currentRoomID key $key value $value',
        tag: 'ExpressService');

    final result = await ZegoExpressEngine.instance
        .setRoomExtraInfo(currentRoomID, key, value);
    return result;
  }

  void onRoomExtraInfoUpdate(
      String roomID, List<ZegoRoomExtraInfo> roomExtraInfoList) {
    roomExtraInfoUpdateCtrl.add(ZegoRoomExtraInfoEvent(roomExtraInfoList));
  }
}
