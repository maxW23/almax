import 'package:flutter/cupertino.dart';
import 'package:lklk/core/widgets/overlay/widget.dart';
import 'package:lklk/features/home/presentation/manger/room_cubit/room_cubit_cubit.dart';
import 'package:lklk/features/profile_users/presentaion/manger/user_cubit/user_cubit_cubit.dart';
import 'package:lklk/features/room/presentation/views/widgets/room_view_bloc.dart';
import 'package:x_overlay/x_overlay.dart';

import 'defines.dart';

class AudioRoomOverlayPage extends StatefulWidget {
  const AudioRoomOverlayPage({
    super.key,
    required this.navigatorKey,
    required this.userCubit,
    required this.roomCubit,
  });

  final UserCubit userCubit;
  final RoomCubit roomCubit;
  final GlobalKey<NavigatorState> navigatorKey;

  @override
  State<AudioRoomOverlayPage> createState() => AudioRoomOverlayPageState();
}

class AudioRoomOverlayPageState extends State<AudioRoomOverlayPage> {
  @override
  Widget build(BuildContext context) {
    return XOverlayPage(
      // roomCubit: widget.roomCubit,
      // userCubit: widget.userCubit,
      navigatorWithSafeArea: false,
      supportClickZoom: true,
      size: const Size(70, 70),
      controller: audioRoomOverlayController,
      contextQuery: _getNavigatorContext,
      restoreWidgetQuery: _restoreRoomView,
      builder: _buildOverlayWidget,
    );
  }

  BuildContext _getNavigatorContext() {
    return widget.navigatorKey.currentState!.context;
  }

  Widget _restoreRoomView(XOverlayData data) {
    final audioRoomOverlayData = data as AudioRoomOverlayData;

    return RoomViewBloc(
      roomCubit: widget.roomCubit,
      roomId: int.parse(audioRoomOverlayData.roomID),
      userCubit: widget.userCubit,
      pass: audioRoomOverlayData.roomPass,
      backgroundImage: audioRoomOverlayData.backgroundImage,
      fromOverlay: true,
      isForce: false,
    );
  }

  Widget _buildOverlayWidget(XOverlayData data) {
    final audioRoomOverlayData = data as AudioRoomOverlayData;

    return AudioRoomOverlayPageWidget(
      navigatorKey: widget.navigatorKey,
      overlayData: audioRoomOverlayData,
    );
  }
}
