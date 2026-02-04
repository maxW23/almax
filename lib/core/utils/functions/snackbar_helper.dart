import 'package:flutter/material.dart';
import 'package:auto_size_text/auto_size_text.dart';
import 'package:flutter/services.dart';
import 'package:lklk/core/config/feature_flags.dart';

class SnackbarHelper {
  static void showMessage(
    BuildContext context,
    String message, {
    double bottomMargin = 10,
    int durationinMilli = 2400,
    bool copyOnTap = false,
    String copyToastText = 'Copied to clipboard',
  }) {
    // Respect feature flags: do not show status snackbars in production
    if (!FeatureFlags.kEnableStatusSnackbars) {
      return;
    }
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: GestureDetector(
          onTap: copyOnTap
              ? () async {
                  await Clipboard.setData(ClipboardData(text: message));
                  // Show a small confirmation
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(
                      content: Text(copyToastText),
                      duration: const Duration(milliseconds: 1200),
                    ),
                  );
                }
              : null,
          child: Container(
            decoration: BoxDecoration(
              color: Colors.grey[800], // خلفية رمادية خلف النص
              borderRadius: BorderRadius.circular(8.0), // حواف مستديرة
            ),
            padding: const EdgeInsets.symmetric(vertical: 10, horizontal: 10),
            child: AutoSizeText(
              message,
              textAlign: TextAlign.center, // محاذاة النص إلى المنتصف
              style: const TextStyle(
                color: Colors.white, // لون النص
                fontSize: 16,
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
        ),
        backgroundColor: Colors.transparent, // خلفية شفافة
        elevation: 0, // إزالة الظل
        behavior: SnackBarBehavior.floating,
        margin: EdgeInsets.only(
            bottom: bottomMargin, left: 60, right: 60), // الهامش من الحواف
        duration: Duration(milliseconds: durationinMilli), // مدة العرض
      ),
    );
  }
}
