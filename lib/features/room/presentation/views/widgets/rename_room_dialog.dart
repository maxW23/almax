import 'package:flutter/material.dart';
import 'package:auto_size_text/auto_size_text.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:lklk/core/constants/app_colors.dart';
import 'package:lklk/core/utils/functions/is_arabic.dart';
import 'package:lklk/features/home/presentation/manger/language/language_cubit.dart';
import 'package:lklk/generated/l10n.dart';

class RenameNameDialog extends StatefulWidget {
  const RenameNameDialog({super.key});

  @override
  State<RenameNameDialog> createState() => _RenameNameDialogState();
}

class _RenameNameDialogState extends State<RenameNameDialog> {
  late TextEditingController _controller;
  late String _selectedLanguage;

  @override
  void initState() {
    super.initState();
    _controller = TextEditingController();
    final languageCubit = context.read<LanguageCubit>();
    _selectedLanguage = languageCubit.state.languageCode;
  }

  @override
  Widget build(BuildContext context) {
    return Directionality(
      textDirection: getTextDirection(_selectedLanguage),
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
                S.of(context).rename,
                style: const TextStyle(
                  fontSize: 22,
                  fontWeight: FontWeight.bold,
                  color: Colors.black87,
                ),
              ),
              const SizedBox(height: 16),
              TextField(
                controller: _controller,
                decoration: InputDecoration(
                  focusColor: AppColors.primary, // استخدام لون ثابت
                  hintText: S.of(context).enterNewName,
                  contentPadding:
                      const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                    borderSide: BorderSide(color: Colors.grey.shade300),
                  ),
                  focusedBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                    borderSide: const BorderSide(
                        color: AppColors.secondColorDark, // استخدام لون ثابت
                        width: 1.5),
                  ),
                ),
              ),
              const SizedBox(height: 24),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                children: [
                  TextButton(
                    onPressed: () => Navigator.of(context).pop(),
                    child: AutoSizeText(
                      S.of(context).cancel,
                      style: const TextStyle(
                          color: const Color(0xFFFF0000),
                          fontSize: 16,
                          fontWeight: FontWeight.w500),
                    ),
                  ),
                  const SizedBox(width: 10),
                  // استبدال ElevatedButton ب Container مع InkWell
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
                        final newName = _controller.text.trim();
                        if (newName.isNotEmpty) {
                          Navigator.of(context).pop(newName);
                        }
                      },
                      child: Padding(
                        padding: const EdgeInsets.symmetric(
                            horizontal: 24, vertical: 12),
                        child: AutoSizeText(
                          S.of(context).rename,
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
