import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:auto_size_text/auto_size_text.dart';

import '../../zego_call_manager.dart';

class ZegoCallAddUserButton extends StatefulWidget {
  const ZegoCallAddUserButton({super.key});

  @override
  State<ZegoCallAddUserButton> createState() => _ZegoCallAddUserButtonState();
}

class _ZegoCallAddUserButtonState extends State<ZegoCallAddUserButton> {
  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: sendCallInvite,
      child: Container(
        width: 96,
        height: 96,
        decoration: BoxDecoration(
          color: const Color.fromARGB(255, 51, 52, 56).withValues(alpha: 0.6),
          shape: BoxShape.circle,
        ),
        child: SizedBox.fromSize(
          size: const Size(56, 56),
          child: const Icon(Icons.add, color: Colors.white),
        ),
      ),
    );
  }

  void sendCallInvite() {
    final editingController1 = TextEditingController();
    showCupertinoDialog(
      context: context,
      barrierDismissible: true,
      builder: (context) {
        return CupertinoAlertDialog(
          title: const AutoSizeText('Input a user id'),
          content: CupertinoTextField(controller: editingController1),
          actions: [
            CupertinoDialogAction(
              onPressed: Navigator.of(context).pop,
              child: const AutoSizeText('Cancel'),
            ),
            CupertinoDialogAction(
              onPressed: () {
                ZegoCallManager().inviteUserToJoinCall([
                  if (editingController1.text.isNotEmpty)
                    editingController1.text
                ]);
                Navigator.of(context).pop();
              },
              child: const AutoSizeText('OK'),
            ),
          ],
        );
      },
    );
  }
}
