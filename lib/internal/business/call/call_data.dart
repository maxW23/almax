import 'call_user_info.dart';

enum ZegoCallUserState {
  inviting,
  accepted,
  rejected,
  cancelled,
  offline,
  received,
}

enum ZegoCallType {
  voice,
  video,
}

const voiceCall = 10001;
const videoCall = 10000;
// ignore: constant_identifier_names
const VOICE_Call = voiceCall;
// ignore: constant_identifier_names
const VIDEO_Call = videoCall;

class ZegoCallData {
  late CallUserInfo inviter;
  late int callType;
  late String callID;
  List<CallUserInfo> callUserList = [];
  bool get isGroupCall => callUserList.length > 2;
}
