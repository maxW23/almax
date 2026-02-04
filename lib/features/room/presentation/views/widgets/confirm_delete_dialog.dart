import 'package:flutter/material.dart';
import 'package:auto_size_text/auto_size_text.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:lklk/core/constants/app_colors.dart';
import 'package:lklk/core/utils/functions/is_arabic.dart';
import 'package:lklk/features/home/presentation/manger/language/language_cubit.dart';
import 'package:lklk/generated/l10n.dart';
import 'package:lklk/internal/business/business_define.dart';

class DeleteChatConfirmationDialog extends StatelessWidget {
  final ZegoLiveAudioRoomRole role;
  final Function() onConfirm;

  const DeleteChatConfirmationDialog({
    super.key,
    required this.role,
    required this.onConfirm,
  });

  @override
  Widget build(BuildContext context) {
    final languageCubit = context.read<LanguageCubit>();
    final selectedLanguage = languageCubit.state.languageCode;

    return Directionality(
      textDirection: getTextDirection(selectedLanguage),
      child: Dialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        elevation: 10,
        backgroundColor: AppColors.white,
        child: Padding(
          padding: const EdgeInsets.all(20.0),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              AutoSizeText(
                S.of(context).deleteChat,
                style: const TextStyle(
                  fontSize: 22,
                  fontWeight: FontWeight.bold,
                  color: Colors.black87,
                ),
              ),
              const SizedBox(height: 16),
              AutoSizeText(
                role == ZegoLiveAudioRoomRole.host
                    ? S.of(context).deleteAllMessagesConfirmationHost
                    : S.of(context).deleteAllMessagesConfirmation,
                style: TextStyle(
                  fontSize: 16,
                  color: Colors.grey.shade700,
                ),
              ),
              const SizedBox(height: 24),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                children: [
                  TextButton(
                    onPressed: () => Navigator.of(context).pop(false),
                    child: AutoSizeText(
                      S.of(context).cancel,
                      style: const TextStyle(
                          color:  Color(0xFFFF0000,),
                          fontSize: 16,
                          fontWeight: FontWeight.w500),
                    ),
                  ),
                  const SizedBox(width: 10),
                  Container(
                    decoration: BoxDecoration(
                      gradient: const LinearGradient(
                        colors: [AppColors.primary, AppColors.secondColor],
                        begin: Alignment.topLeft,
                        end: Alignment.bottomRight,
                      ),
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: InkWell(
                      onTap: () {
                        onConfirm();
                        Navigator.of(context).pop(true);
                      },
                      child: Padding(
                        padding: const EdgeInsets.symmetric(
                            horizontal: 24, vertical: 12),
                        child: AutoSizeText(
                          S.of(context).confirm,
                          style: const TextStyle(
                              fontSize: 16,
                              color: AppColors.white,
                              fontWeight: FontWeight.w500),
                        ),
                      ),
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
}
