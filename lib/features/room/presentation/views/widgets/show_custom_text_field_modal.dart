import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:lklk/features/home/presentation/manger/room_messages_cubit/room_messages_cubit.dart';
import 'package:lklk/features/room/domain/entities/room_entity.dart';
import 'package:lklk/features/room/presentation/views/widgets/custom_text_field_widget.dart';
import 'package:lklk/zego_sdk_manager.dart';

class RoomChatTextSheet extends StatefulWidget {
  const RoomChatTextSheet(
      {super.key, required this.room, required this.onSend});
  final RoomEntity room;
  final void Function(ZIMMessage) onSend;

  static Future<void> showBasicModalBottomSheet(BuildContext context,
      RoomEntity room, void Function(ZIMMessage) onSend) async {
    final roomMessagesCubit = BlocProvider.of<RoomMessagesCubit>(context);
    await showGeneralDialog(
      context: context,
      barrierLabel: 'RoomChat',
      barrierDismissible: true,
      barrierColor: Colors.transparent,
      transitionDuration: const Duration(milliseconds: 0),
      pageBuilder: (ctx, anim, secAnim) {
        return BlocProvider.value(
          value: roomMessagesCubit,
          child: SafeArea(
            bottom: true,
            child: Align(
              alignment: Alignment.bottomCenter,
              child: RoomChatTextSheet(room: room, onSend: onSend),
            ),
          ),
        );
      },
    );
  }

  @override
  State<RoomChatTextSheet> createState() => _RoomChatTextSheetState();
}

class _RoomChatTextSheetState extends State<RoomChatTextSheet> {
  late TextEditingController _controller;

  @override
  void initState() {
    super.initState();
    _controller = TextEditingController();
    // إجبار ظهور لوحة المفاتيح فور فتح الـ bottom sheet
    WidgetsBinding.instance.addPostFrameCallback((_) {
      SystemChannels.textInput.invokeMethod('TextInput.show');
      Future.delayed(const Duration(milliseconds: 150), () {
        SystemChannels.textInput.invokeMethod('TextInput.show');
      });
    });
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    // احصل على قيمة الـ bottom inset قبل إزالة الـ insets من الشجرة
    final bottomInset = MediaQuery.of(context).viewInsets.bottom;
    // إزالة تفاعل الـ bottom sheet الافتراضي مع الكيبورد لمنع حركة الارتفاع
    return MediaQuery.removeViewInsets(
      removeBottom: true,
      context: context,
      child: GestureDetector(
        // إخفاء لوحة المفاتيح عند النقر خارج منطقة الإدخال
        onTap: () => FocusScope.of(context).unfocus(),
        child: Container(
          decoration: duration(),
          padding: EdgeInsets.only(
            top: 8,
            left: 8,
            right: 8,
            // تطبيق الهامش السفلي يدوياً بدون أنيميشن ليتوافق فوراً مع الكيبورد
            bottom: bottomInset + 8,
          ),
          child: CustomTextFieldWidget(
            controller: _controller,
            room: widget.room,
            onSend: widget.onSend,
          ),
        ),
      ),
    );
  }

  EdgeInsets padding(BuildContext context) {
    return EdgeInsets.only(
      top: 8,
      left: 16,
      right: 16,
      bottom: MediaQuery.of(context).viewInsets.bottom + 8,
    );
  }

  BoxDecoration duration() {
    return const BoxDecoration(
      color: Colors.transparent,
    );
  }
}
