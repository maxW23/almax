import 'dart:convert';
import 'package:lklk/core/utils/logger.dart';

import 'package:flutter/material.dart';
import 'package:lklk/core/constants/app_colors.dart';
import 'package:lklk/core/services/auth_service.dart';
import 'package:lklk/features/room/domain/entities/room_entity.dart';
import 'package:lklk/zego_sdk_manager.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:emoji_picker_flutter/emoji_picker_flutter.dart';

class CustomTextFieldWidget extends StatefulWidget {
  final TextEditingController controller;
  final RoomEntity room;
  final void Function(ZIMMessage) onSend;

  const CustomTextFieldWidget({
    super.key,
    required this.controller,
    required this.room,
    required this.onSend,
  });

  @override
  State<CustomTextFieldWidget> createState() => _CustomTextFieldWidgetState();
}

class _CustomTextFieldWidgetState extends State<CustomTextFieldWidget> {
  bool _isSending = false;
  late FocusNode _focusNode;
  bool _showEmoji = false;

  @override
  void initState() {
    super.initState();
    _focusNode = FocusNode();
    // افتح الكيبورد فوراً عند ظهور الشيت + تأكيد بعد انتهاء أنيميشن الشيت
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (!mounted) return;
      // طلب تركيز مباشر
      FocusScope.of(context).requestFocus(_focusNode);
      // تأكيد إضافي بعد 150ms لتجاوز أنيميشن الـ bottom sheet
      Future.delayed(const Duration(milliseconds: 150), () {
        if (mounted) {
          FocusScope.of(context).requestFocus(_focusNode);
        }
      });
    });
  }

  void sendMessage(String roomId) async {
    final text = widget.controller.text.trim();
    if (text.isEmpty || _isSending) return;

    setState(() => _isSending = true);

    try {
      final userAuth = await AuthService.getUserFromSharedPreferences();

      final msg = ZIMBarrageMessage(message: text);
      final customData = {
        "UserImage": "${userAuth?.img}",
        "UserVipLevel": int.tryParse(userAuth?.vip.toString() ?? '0'),
        "UserName": "${userAuth?.name}",
        "UserID": "${userAuth?.id}",
      };

      msg.extendedData = jsonEncode(customData);
      log("Send to RoomID: $roomId");
      final result = await ZIM.getInstance()!.sendMessage(
            msg,
            roomId,
            ZIMConversationType.room,
            ZIMMessageSendConfig(),
          );
      log("Send result: $result --- ${result.message} --- ${result.message.extendedData}");
      widget.onSend(result.message);
      widget.controller.clear();
      // Keep keyboard open for consecutive messages
      FocusScope.of(context).requestFocus(_focusNode);
    } catch (e) {
      log("Send error: $e");
    } finally {
      setState(() => _isSending = false);
    }
  }

  @override
  void dispose() {
    _focusNode.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final isRtl = Directionality.of(context) == TextDirection.rtl;

    Widget emojiButton() => IconButton(
          padding: EdgeInsets.symmetric(horizontal: 8),
          constraints: const BoxConstraints(minWidth: 36, minHeight: 36),
          onPressed: () {
            setState(() => _showEmoji = !_showEmoji);
            if (_showEmoji) {
              FocusScope.of(context).unfocus();
            } else {
              FocusScope.of(context).requestFocus(_focusNode);
            }
          },
          icon: SvgPicture.asset(
            'assets/icons/room_btn/emoji_textfield_icon.svg',
            width: 22,
            height: 22,
            // جرب استخدام color بدلاً من colorFilter
            color: AppColors.grey,
            // أظهر بديل في حال فشل التحميل لتشخيص الخطأ
            placeholderBuilder: (context) => const SizedBox(
              width: 22,
              height: 22,
              child: Center(
                child: Icon(
                  Icons.emoji_emotions_outlined,
                  size: 22,
                  color: AppColors.grey,
                ),
              ),
            ),
          ),
        );

    final pillTextField = Container(
      decoration: BoxDecoration(
        color: AppColors.white,
        borderRadius: BorderRadius.circular(28),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.08),
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      constraints: const BoxConstraints(minHeight: 48),
      padding: const EdgeInsets.symmetric(horizontal: 14),
      child: Row(
        children: [
          if (!isRtl) emojiButton(),
          Expanded(
            child: TextField(
              controller: widget.controller,
              focusNode: _focusNode,
              autofocus: true,
              cursorColor: AppColors.secondColor,
              textAlign: isRtl ? TextAlign.right : TextAlign.left,
              decoration: InputDecoration(
                hintText: isRtl ? 'ادخل رسالة' : 'Type a message ...',
                hintStyle: TextStyle(
                  color: Colors.grey.shade400,
                  fontWeight: FontWeight.w500,
                ),
                border: InputBorder.none,
                isDense: true,
              ),
              style: const TextStyle(color: Colors.black),
              textInputAction: TextInputAction.send,
              keyboardType: TextInputType.multiline,
              minLines: 1,
              maxLines: 4,
              // Prevent default behavior that unfocuses the field on submit
              onEditingComplete: () {
                // Keep focus so the keyboard stays visible
                FocusScope.of(context).requestFocus(_focusNode);
              },
              onSubmitted: (text) => sendMessage(widget.room.id.toString()),
            ),
          ),
          if (isRtl) emojiButton(),
        ],
      ),
    );

    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        Padding(
          padding: const EdgeInsets.symmetric(vertical: 2),
          child: SizedBox(
            width: double.infinity,
            child: pillTextField,
          ),
        ),
        Offstage(
          offstage: !_showEmoji,
          child: SizedBox(
            height: 280,
            child: EmojiPicker(
              onEmojiSelected: (category, emoji) {},
              textEditingController: widget.controller,
            ),
          ),
        ),
      ],
    );
  }
}
