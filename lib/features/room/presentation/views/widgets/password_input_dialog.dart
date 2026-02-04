import 'dart:async';
import 'package:lklk/core/utils/logger.dart';
import 'package:flutter/material.dart';
import 'package:auto_size_text/auto_size_text.dart';
import 'package:lklk/generated/l10n.dart';
import '../../../../../core/constants/app_colors.dart';
import 'package:pin_code_fields/pin_code_fields.dart';

class PasswordSetupDialog extends StatefulWidget {
  const PasswordSetupDialog({super.key});

  @override
  State<PasswordSetupDialog> createState() => _PasswordSetupDialogState();
}

class _PasswordSetupDialogState extends State<PasswordSetupDialog> {
  TextEditingController textEditingController = TextEditingController();
  StreamController<ErrorAnimationType>? errorController;
  bool hasError = false;

  @override
  void initState() {
    errorController = StreamController<ErrorAnimationType>();
    super.initState();
  }

  @override
  void dispose() {
    errorController!.close();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Dialog(
      insetPadding: const EdgeInsets.symmetric(horizontal: 20.0),
      child: ConstrainedBox(
        constraints: const BoxConstraints(
          maxWidth: 300,
          maxHeight: 300,
        ),
        child: Padding(
          padding: const EdgeInsets.all(20.0),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Center(child: AutoSizeText(S.of(context).password)),
              const SizedBox(height: 24),
              SizedBox(
                width: double.infinity,
                child: PinCodeTextField(
                  appContext: context,
                  length: 4,
                  obscureText: false,
                  animationType: AnimationType.fade,
                  pinTheme: PinTheme(
                    shape: PinCodeFieldShape.box,
                    borderRadius: BorderRadius.circular(5),
                    fieldHeight: 50,
                    fieldWidth: 40,
                    activeFillColor: AppColors.white,
                    disabledColor: AppColors.danger,
                    inactiveColor: AppColors.black,
                    activeColor: AppColors.primary,
                    selectedColor: AppColors.success,
                    errorBorderColor: AppColors.danger,
                    inactiveFillColor: AppColors.white,
                    selectedFillColor: AppColors.white,
                  ),
                  animationDuration: const Duration(milliseconds: 300),
                  enableActiveFill: true,
                  errorAnimationController: errorController,
                  controller: textEditingController,
                  onChanged: (value) {
                    setState(() => hasError = false);
                  },
                ),
              ),
              const SizedBox(height: 24),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceAround,
                children: [
                  TextButton(
                    onPressed: () => Navigator.of(context).pop(),
                    child: AutoSizeText(
                      S.of(context).cancel,
                      style: const TextStyle(color: AppColors.black),
                    ),
                  ),
                  TextButton(
                    onPressed: () {
                      if (textEditingController.text.isNotEmpty) {
                        Navigator.of(context).pop(textEditingController.text);
                        log("room pass : ${textEditingController.text}");
                      } else {
                        setState(() => hasError = true);
                      }
                    },
                    child: AutoSizeText(
                      S.of(context).ok,
                      style: const TextStyle(color: AppColors.black),
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
