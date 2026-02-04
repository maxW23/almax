import 'package:flutter/foundation.dart';

/// Global feature flags to tailor UX between debug/beta and production.
/// In production (release), debug snackbars should be disabled.
class FeatureFlags {
  // Show technical debug snackbars with long logs and auto-copy.
  // Enabled by default only in debug/profile builds.
  static const bool kEnableDebugSnackbars = kReleaseMode ? false : true;

  // Show user-facing status snackbars (success/error). Disabled in prod.
  static const bool kEnableStatusSnackbars = kReleaseMode ? false : true;

  // Show progress snackbars for transient states (loading/pending/verifying).
  // Disabled in prod to reduce noise.
  static const bool kShowProgressSnackbars = kReleaseMode ? false : true;

  // Copy-to-clipboard automatically when showing debug snackbars.
  static const bool kAutoCopyDebugToClipboard = kReleaseMode ? false : true;
}
