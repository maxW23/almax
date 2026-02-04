import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:lklk/core/config/feature_flags.dart';

/// Helper for showing debug information in Snackbars (for production builds where logs aren't visible)
class DebugSnackbarHelper {
  static final List<String> _debugSteps = [];

  static void addStep(String step) {
    _debugSteps.add(step);
  }

  static void clearSteps() {
    _debugSteps.clear();
  }

  static String getAllSteps() {
    return _debugSteps.join('\n');
  }

  static void showDebugSnackbar(BuildContext context, String title,
      {bool isError = false}) {
    // Respect feature flag: do not show debug snackbar in production
    if (!FeatureFlags.kEnableDebugSnackbars) {
      return;
    }
    final allSteps = getAllSteps();
    final message = '$title\n\n$allSteps';

    // Auto-copy to clipboard immediately (if enabled)
    if (FeatureFlags.kAutoCopyDebugToClipboard) {
      Clipboard.setData(ClipboardData(text: message));
    }

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: InkWell(
          onTap: () async {
            await Clipboard.setData(ClipboardData(text: message));
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(
                content: const Text('✅ Copied again!',
                    style: TextStyle(color: Colors.white)),
                duration: const Duration(milliseconds: 800),
                backgroundColor: Colors.green.shade700,
              ),
            );
          },
          child: Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: isError ? const Color(0xFFB71C1C) : Colors.blue.shade900,
              borderRadius: BorderRadius.circular(8),
            ),
            constraints: const BoxConstraints(maxHeight: 500),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Icon(
                      isError ? Icons.error_outline : Icons.info_outline,
                      color: Colors.white,
                      size: 20,
                    ),
                    const SizedBox(width: 8),
                    Expanded(
                      child: Text(
                        title,
                        style: const TextStyle(
                          color: Colors.white,
                          fontSize: 14,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                    const Icon(Icons.copy, color: Colors.white70, size: 16),
                  ],
                ),
                const SizedBox(height: 8),
                const Divider(color: Colors.white30, height: 1),
                const SizedBox(height: 8),
                Flexible(
                  child: SingleChildScrollView(
                    child: SelectableText(
                      allSteps,
                      style: const TextStyle(
                        color: Colors.white,
                        fontSize: 11,
                        fontFamily: 'monospace',
                        height: 1.4,
                      ),
                    ),
                  ),
                ),
                const SizedBox(height: 8),
                Container(
                  padding:
                      const EdgeInsets.symmetric(vertical: 4, horizontal: 8),
                  decoration: BoxDecoration(
                    color: Colors.white.withOpacity(0.1),
                    borderRadius: BorderRadius.circular(4),
                  ),
                  child: const Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Icon(Icons.check_circle,
                          color: Colors.greenAccent, size: 14),
                      SizedBox(width: 4),
                      Text(
                        'Auto-copied to clipboard',
                        style: TextStyle(
                          color: Colors.white70,
                          fontSize: 10,
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ),
        backgroundColor: Colors.transparent,
        elevation: 0,
        duration: const Duration(seconds: 20),
        behavior: SnackBarBehavior.floating,
        margin: const EdgeInsets.all(16),
      ),
    );
  }
}
