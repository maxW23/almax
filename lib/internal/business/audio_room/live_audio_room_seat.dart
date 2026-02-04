import 'package:flutter/material.dart';
import 'package:lklk/features/auth/domain/entities/user_entity.dart';

// import '../../sdk/express/express_service.dart';

class ZegoLiveAudioRoomSeat {
  int seatIndex = 0;
  ValueNotifier<UserEntity?> lastUser = ValueNotifier(null);
  ValueNotifier<UserEntity?> currentUser = ValueNotifier(null);

  ZegoLiveAudioRoomSeat(this.seatIndex);
}
