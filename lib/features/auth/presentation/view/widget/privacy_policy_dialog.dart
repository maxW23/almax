import 'package:flutter/material.dart';
import 'package:auto_size_text/auto_size_text.dart';
import 'package:lklk/core/constants/app_colors.dart';
import 'package:lklk/generated/l10n.dart';
import 'package:lklk/features/profile_users/presentaion/views/privacy_policy_page.dart';
import 'package:shared_preferences/shared_preferences.dart';

class PrivacyPolicyDialog extends StatefulWidget {
  const PrivacyPolicyDialog({super.key});

  @override
  State<PrivacyPolicyDialog> createState() => _PrivacyPolicyDialogState();
}

class _PrivacyPolicyDialogState extends State<PrivacyPolicyDialog> {
  Future<void> _savePrivacyAgreement() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool('hasAgreedToPrivacyPolicy', true);
  }

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      insetPadding: EdgeInsets.fromLTRB(
        24,
        24,
        24,
        24 + MediaQuery.of(context).viewPadding.bottom,
      ),
      backgroundColor: AppColors.white.withValues(alpha: 0.85),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(20),
      ),
      title: AutoSizeText(
        S.of(context).privacypolicy,
        textAlign: TextAlign.center,
        style: const TextStyle(
          fontWeight: FontWeight.bold,
          color: AppColors.black,
        ),
      ),
      content: SizedBox(
        height: 300,
        child: const SingleChildScrollView(
          child: PrivacyPolicyBody(),
        ),
      ),
      actions: [
        Center(
          child: FilledButton.icon(
            icon: const Icon(Icons.check_circle, color: AppColors.white),
            label: AutoSizeText(
              S.of(context).accept,
              style: const TextStyle(color: AppColors.white),
            ),
            style: FilledButton.styleFrom(
              backgroundColor: AppColors.primary,
              padding: const EdgeInsets.symmetric(horizontal: 30, vertical: 12),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(15),
              ),
              shadowColor: AppColors.primary.withValues(alpha: 0.6),
              elevation: 8,
            ),
            onPressed: () async {
              final navigator = Navigator.of(context);
              await _savePrivacyAgreement();
              navigator.pop();
            },
          ),
        ),
      ],
    );
  }
}
