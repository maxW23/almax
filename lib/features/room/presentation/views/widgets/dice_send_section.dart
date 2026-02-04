import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:lklk/features/home/presentation/manger/room_messages_cubit/room_messages_cubit.dart';
import 'package:flutter_svg/flutter_svg.dart';

class DiceSendSection extends StatelessWidget {
  const DiceSendSection({
    super.key,
    required this.roomId,
  });
  final int roomId;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () async {
        final cubit =
            BlocProvider.of<RoomMessagesCubit>(context, listen: false);
        final navigator = Navigator.of(context);
        final messenger = ScaffoldMessenger.of(context);
        try {
          await cubit.sendDiceMessage(roomId);
          navigator.pop();
        } catch (e) {
          messenger.showSnackBar(
            SnackBar(content: Text('فشل في إرسال النرد: $e')),
          );
        }
      },
      child: SvgPicture.asset(
        'assets/icons/room_btn/dice_icon_btn.svg',
        width: 45,
        height: 45,
      ),
    );
  }
}

class PsrSendSection extends StatelessWidget {
  const PsrSendSection({
    super.key,
    required this.roomId,
  });
  final int roomId;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () async {
        final cubit =
            BlocProvider.of<RoomMessagesCubit>(context, listen: false);
        final navigator = Navigator.of(context);
        final messenger = ScaffoldMessenger.of(context);
        try {
          await cubit.sendPsrMessage(roomId);
          navigator.pop();
        } catch (e) {
          messenger.showSnackBar(
            SnackBar(content: Text('فشل في إرسال psr: $e')),
          );
        }
      },
      child: SvgPicture.asset(
        'assets/icons/room_btn/psr_icon_btn.svg',
        width: 45,
        height: 45,
      ),
    );
  }
}

class SeventySendSection extends StatelessWidget {
  const SeventySendSection({
    super.key,
    required this.roomId,
  });
  final int roomId;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () async {
        final cubit =
            BlocProvider.of<RoomMessagesCubit>(context, listen: false);
        final navigator = Navigator.of(context);
        final messenger = ScaffoldMessenger.of(context);
        try {
          await cubit.sendSeventyMessage(roomId);
          navigator.pop();
        } catch (e) {
          messenger.showSnackBar(
            SnackBar(content: Text('فشل في إرسال 777: $e')),
          );
        }
      },
      child: SvgPicture.asset(
        'assets/icons/room_btn/seventy_icon_btn.svg',
        width: 45,
        height: 45,
      ),
    );
  }
}
