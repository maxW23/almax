import 'package:flutter/material.dart';
import 'package:auto_size_text/auto_size_text.dart';
import 'package:lklk/core/constants/app_colors.dart';
import 'package:lklk/features/auth/presentation/view/widget/privacy_policy_dialog.dart';
import 'package:lklk/generated/l10n.dart';

class PrivacyAgreementWidget extends StatelessWidget {
  final bool agreed;
  final ValueChanged<bool> onChanged;

  const PrivacyAgreementWidget(
      {super.key, required this.agreed, required this.onChanged});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 20, horizontal: 20),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          AnimatedSwitcher(
            duration: const Duration(milliseconds: 300),
            transitionBuilder: (child, animation) {
              return ScaleTransition(scale: animation, child: child);
            },
            child: Checkbox(
              key: ValueKey<bool>(agreed),
              value: agreed,
              onChanged: (value) => onChanged(value!),
              activeColor: AppColors.primary,
              checkColor: AppColors.white,
              splashRadius: 24,
            ),
          ),
          const SizedBox(width: 10),
          InkWell(
            borderRadius: BorderRadius.circular(5),
            onTap: () => _showPrivacyPolicyDialog(context),
            splashColor: AppColors.primary.withValues(alpha: 0.3),
            child: AutoSizeText(
              S.of(context).privacypolicy,
              style: const TextStyle(
                color: AppColors.white,
                decoration: TextDecoration.underline,
                fontWeight: FontWeight.w600,
                shadows: [
                  Shadow(
                    color: Colors.black45,
                    offset: Offset(0, 1),
                    blurRadius: 1,
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  void _showPrivacyPolicyDialog(BuildContext context) {
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (BuildContext context) {
        return PrivacyPolicyDialog();
      },
    );
  }
}
