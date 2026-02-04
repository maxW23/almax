import 'package:x_overlay/x_overlay.dart';

import '../../../internal/business/business_define.dart';

final audioRoomOverlayController = XOverlayController();

class AudioRoomOverlayData extends XOverlayData {
  final String roomID;
  final String? roomPass;
  final String? backgroundImage;
  final ZegoLiveAudioRoomRole role;
  final String roomImg;
  AudioRoomOverlayData({
    required this.roomID,
    required this.role,
    required this.roomPass,
    required this.roomImg,
    required this.backgroundImage,
  });
}
