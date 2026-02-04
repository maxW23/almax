// room_move_dialog.dart
import 'package:flutter/material.dart';
import 'package:auto_size_text/auto_size_text.dart';
import 'package:lklk/features/home/presentation/manger/top_bar_room_cubit/has_message.dart';
import 'package:lklk/generated/l10n.dart';
import 'package:lklk/features/room/presentation/views/widgets/password_input_dialog.dart';

class RoomMoveDialog extends StatelessWidget {
  final BuildContext originalContext;
  final HasMessage state; // استخدام الواجهة المشتركة بدلاً من نوع محدد
  final int roomId;
  final Future<void> Function(BuildContext, HasMessage, int, String?) onConfirm;
  final bool isMoneyBag;

  const RoomMoveDialog({
    super.key,
    required this.originalContext,
    required this.state,
    required this.roomId,
    required this.onConfirm,
    this.isMoneyBag = false,
  });

  @override
  Widget build(BuildContext context) {
    final navigator = Navigator.of(context);
    final messenger = ScaffoldMessenger.of(originalContext);
    final s = S.of(originalContext);
    return Dialog(
      backgroundColor: Colors.white,
      elevation: 12,
      insetPadding: const EdgeInsets.symmetric(horizontal: 36, vertical: 24),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
      child: ConstrainedBox(
        constraints: BoxConstraints(
          maxWidth: MediaQuery.of(context).size.width * 0.75,
          minWidth: 260.0,
        ),
        child: Padding(
          padding: const EdgeInsets.fromLTRB(20, 20, 20, 16),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              AutoSizeText(
                isMoneyBag
                    ? 'حقيبة حظ في غرفة أخرى'
                    : S.of(context).moveAnotherRoom,
                style: Theme.of(context)
                    .textTheme
                    .titleMedium
                    ?.copyWith(fontWeight: FontWeight.w700),
                maxLines: 1,
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 10),
              AutoSizeText(
                isMoneyBag
                    ? 'هناك حقيبة حظ تنتظرك في غرفة أخرى. هل ترغب بالانتقال إليها؟'
                    : S.of(context).areMoveAnotherRoom,
                maxLines: 3,
                textAlign: TextAlign.center,
                style: Theme.of(context)
                    .textTheme
                    .bodyMedium
                    ?.copyWith(color: Colors.black87),
              ),
              const SizedBox(height: 20),
              Row(
                children: [
                  Expanded(
                    child: _PillButton(
                      text: S.of(context).okay,
                      textColor: Colors.white,
                      gradient: const LinearGradient(
                        begin: Alignment.topLeft,
                        end: Alignment.bottomRight,
                        colors: [
                          Color(0xFFDAB46E),
                          Color(0xFF9E6D37),
                        ],
                      ),
                      onTap: () async {
                        navigator.pop();

                        // إذا كانت الغرفة تتطلب كلمة مرور (من الرسالة)، اطلبها وتحقق منها
                        final String? requiredPass = state.message.pass;
                        String? enteredPass;
                        if (requiredPass != null && requiredPass.isNotEmpty) {
                          enteredPass = await showDialog<String>(
                            context: context,
                            builder: (context) => const PasswordSetupDialog(),
                          );

                          // إذا أغلق المستخدم الحوار بدون إدخال
                          if (enteredPass == null) {
                            return;
                          }

                          if (enteredPass != requiredPass) {
                            messenger.showSnackBar(
                              SnackBar(content: Text(s.thePasswordIsWrong)),
                            );
                            return;
                          }
                        }

                        await onConfirm(
                            originalContext, state, roomId, enteredPass);
                      },
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: _PillButton(
                      text: S.of(context).cancel,
                      backgroundColor: const Color(0xFFEDEDED),
                      textColor: Colors.black87,
                      onTap: () => navigator.pop(),
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }

  static void show({
    required BuildContext context,
    required BuildContext originalContext,
    required HasMessage state, // استخدام الواجهة المشتركة
    required int roomId,
    required Future<void> Function(BuildContext, HasMessage, int, String?)
        onConfirm,
    bool isMoneyBag = false,
  }) {
    showDialog(
      context: context,
      builder: (BuildContext context) => RoomMoveDialog(
        originalContext: originalContext,
        state: state,
        roomId: roomId,
        onConfirm: onConfirm,
        isMoneyBag: isMoneyBag,
      ),
    );
  }
}

class _PillButton extends StatelessWidget {
  final String text;
  final VoidCallback onTap;
  final Gradient? gradient;
  final Color? backgroundColor;
  final Color textColor;
  // ثابت لارتفاع الزر بشكل حبة (pill)
  static const double _kHeight = 44;

  const _PillButton({
    required this.text,
    required this.onTap,
    this.gradient,
    this.backgroundColor,
    this.textColor = Colors.white,
  });
  @override
  Widget build(BuildContext context) {
    final borderRadius = BorderRadius.circular(22);
    return Material(
      color: Colors.transparent,
      child: InkWell(
        borderRadius: borderRadius,
        onTap: onTap,
        child: Ink(
          height: _kHeight,
          decoration: BoxDecoration(
            color: backgroundColor,
            gradient: gradient,
            borderRadius: borderRadius,
          ),
          child: Center(
            child: Text(
              text,
              style: TextStyle(
                color: textColor,
                fontWeight: FontWeight.w600,
              ),
            ),
          ),
        ),
      ),
    );
  }
}
