import 'package:flutter/material.dart';

import 'package:lklk/core/constants/assets.dart';

import 'package:lklk/features/room/presentation/views/widgets/room_buttons_row.dart';
import 'package:lklk/features/room/presentation/views/widgets/show_custom_text_field_modal.dart';
import 'package:lklk/zego_sdk_manager.dart';
import 'package:flutter_svg/flutter_svg.dart';

class SendMessageButton extends StatelessWidget {
  const SendMessageButton({
    super.key,
    required this.widget,
    required this.onSend,
  });

  final RoomButtonsRow widget;
  final void Function(ZIMMessage) onSend;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () => RoomChatTextSheet.showBasicModalBottomSheet(
          context, widget.room, onSend),
      child: SvgPicture.asset(
        AssetsData.sendMessageBtnIconSvg,
        width: MediaQuery.of(context).size.width * 0.10,
        height: MediaQuery.of(context).size.width * 0.10,
      ),
    );
  }
}
