import 'package:flutter/material.dart';

import 'package:lklk/core/constants/assets.dart';

import 'package:lklk/features/room/presentation/views/widgets/more_detalis_bottomsheet.dart';
import 'package:lklk/internal/business/business_define.dart';
import 'package:flutter_svg/flutter_svg.dart';

class MoreRoomSettingsButton extends StatelessWidget {
  const MoreRoomSettingsButton({
    super.key,
    required this.roomId,
    required this.deleteAllMessages,
    required this.role,
    required this.addDeleteAllMessagesMessage,
    required this.userID,
    this.fromOverlay,
  });
  final int roomId;
  final void Function() deleteAllMessages;
  final ZegoLiveAudioRoomRole role;
  final void Function() addDeleteAllMessagesMessage;
  final String userID;
  final bool? fromOverlay;
  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () {
        MoreDetailsRoomBottomSheet.show(
          context,
          roomId,
          deleteAllMessages,
          role,
          addDeleteAllMessagesMessage,
          userID,
          fromOverlay: fromOverlay,
        );
      },
      child: SvgPicture.asset(
        AssetsData.moreSettingsBtnSvg,
        width: MediaQuery.of(context).size.width * 0.10,
        height: MediaQuery.of(context).size.width * 0.10,
      ),
    );
  }
}
