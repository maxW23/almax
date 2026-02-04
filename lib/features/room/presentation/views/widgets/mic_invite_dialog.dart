import 'dart:async';

import 'package:auto_size_text/auto_size_text.dart';
import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:lklk/features/auth/domain/entities/user_entity.dart';

class MicInviteDialog {
  /// يعرض Bottom Sheet بسيط لقبول/رفض دعوة المايك ويختفي تلقائياً خلال [timeout]
  static Future<void> show({
    required BuildContext context,
    required String roomId,
    required int seatIndex,
    required UserEntity? inviter,
    required VoidCallback onAccept,
    required VoidCallback onReject,
    Duration timeout = const Duration(seconds: 5),
  }) async {
    bool responded = false;

    await showModalBottomSheet(
      context: context,
      isScrollControlled: false,
      backgroundColor: Theme.of(context).colorScheme.surface,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(16)),
      ),
      builder: (ctx) {
        // اغلاق تلقائي بعد [timeout]
        Timer(timeout, () {
          if (!responded && Navigator.of(ctx).canPop()) {
            Navigator.of(ctx).pop();
          }
        });

        final inviterName = inviter?.name ?? inviter?.nameUser.value ?? inviter?.iduser ?? 'مشرف';

        return SafeArea(
          top: false,
          child: Padding(
            padding: const EdgeInsets.fromLTRB(16, 12, 16, 16),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                Row(
                  children: [
                    const Icon(FontAwesomeIcons.microphone, size: 18),
                    const SizedBox(width: 8),
                    const Text(
                      'دعوة للمايك',
                      style: TextStyle(fontSize: 16, fontWeight: FontWeight.w700),
                    ),
                    const Spacer(),
                    IconButton(
                      icon: const Icon(Icons.close_rounded),
                      onPressed: () {
                        responded = true;
                        Navigator.of(ctx).pop();
                      },
                    ),
                  ],
                ),
                const SizedBox(height: 6),
                AutoSizeText(
                  'تمت دعوتك لأخذ المايك من "${inviterName}"',
                  maxLines: 2,
                  style: const TextStyle(fontSize: 14),
                ),
                const SizedBox(height: 4),
                AutoSizeText(
                  'المقعد: ${seatIndex + 1}',
                  maxLines: 1,
                  style: TextStyle(fontSize: 12, color: Theme.of(context).hintColor),
                ),
                const SizedBox(height: 12),
                Row(
                  children: [
                    Expanded(
                      child: ElevatedButton.icon(
                        style: ElevatedButton.styleFrom(backgroundColor: Colors.green),
                        onPressed: () {
                          responded = true;
                          Navigator.of(ctx).pop();
                          onAccept();
                        },
                        icon: const Icon(Icons.check_rounded, color: Colors.white),
                        label: const Text('قبول', style: TextStyle(color: Colors.white)),
                      ),
                    ),
                    const SizedBox(width: 10),
                    Expanded(
                      child: OutlinedButton.icon(
                        onPressed: () {
                          responded = true;
                          Navigator.of(ctx).pop();
                          onReject();
                        },
                        icon: const Icon(Icons.close_rounded),
                        label: const Text('رفض'),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        );
      },
    );
  }
}
