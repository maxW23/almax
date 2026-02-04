import 'package:flutter/foundation.dart';
import 'dart:async' show Zone;
import 'dart:developer' as dev;

/// Severity levels used by [AppLogger].
enum LogLevel { debug, info, warning, error }

/// Unified logging utility that prints only when logging is enabled (defaults to
/// debug mode). The output is formatted for easier reading and supports tags,
/// error objects, and stack traces.
class AppLogger {
  AppLogger._();

  static bool _enabled = kDebugMode;
  static final Set<String> _disabledTags = <String>{
    // Suppress all payment-related logs globally
    'purchase',
  };

  /// Enables or disables log output at runtime (useful for integration tests).
  static void setEnabled(bool enabled) {
    _enabled = enabled;
  }

  /// Returns whether logging is currently enabled.
  static bool get isEnabled => _enabled;

  /// Disable logs for a specific [tag]. Pass `null`/empty to clear all.
  static void disableTag(String tag) => _disabledTags.add(tag);

  /// Re-enable logs for a specific [tag].
  static void enableTag(String tag) => _disabledTags.remove(tag);

  /// Clears all tag-specific suppression rules.
  static void clearDisabledTags() => _disabledTags.clear();

  /// Base logging method used by the level-specific helpers below.
  static void log(
    String message, {
    LogLevel level = LogLevel.debug,
    String? tag,
    Object? error,
    StackTrace? stackTrace,
  }) {
    if (!_enabled) return;
    if (tag != null && _disabledTags.contains(tag)) return;

    final timestamp = DateTime.now().toIso8601String();
    final buffer = StringBuffer()
      ..write('[$timestamp]')
      ..write(' [${level.name.toUpperCase()}]');

    if (tag != null && tag.isNotEmpty) {
      buffer.write(' [$tag]');
    }

    buffer.write(' $message');
    final line = buffer.toString();

    switch (level) {
      case LogLevel.error:
        dev.log('❗ $line', name: tag ?? 'AppLogger');
        break;
      case LogLevel.warning:
        dev.log('⚠️ $line', name: tag ?? 'AppLogger');
        break;
      case LogLevel.info:
        dev.log('ℹ️ $line', name: tag ?? 'AppLogger');
        break;
      case LogLevel.debug:
      default:
        dev.log('🐛 $line', name: tag ?? 'AppLogger');
        break;
    }

    if (error != null) {
      dev.log('└─ error: $error', name: tag ?? 'AppLogger');
    }

    if (stackTrace != null) {
      dev.log('└─ stackTrace: $stackTrace', name: tag ?? 'AppLogger');
    }
  }

  static void debug(String? message,
      {String? tag, Object? error, StackTrace? stackTrace}) {
    log(
      message ?? 'no message',
      level: LogLevel.debug,
      tag: tag,
      error: error,
      stackTrace: stackTrace,
    );
  }

  static void info(String message,
      {String? tag, Object? error, StackTrace? stackTrace}) {
    log(
      message,
      level: LogLevel.info,
      tag: tag,
      error: error,
      stackTrace: stackTrace,
    );
  }

  static void warning(String message,
      {String? tag, Object? error, StackTrace? stackTrace}) {
    log(
      message,
      level: LogLevel.warning,
      tag: tag,
      error: error,
      stackTrace: stackTrace,
    );
  }

  static void error(String message,
      {String? tag, Object? error, StackTrace? stackTrace}) {
    log(
      message,
      level: LogLevel.error,
      tag: tag,
      error: error,
      stackTrace: stackTrace,
    );
  }
}

/// Legacy helper kept for backward compatibility. Prefer using [AppLogger].
@Deprecated('Use AppLogger.debug/info/warning/error instead.')
void dlog(String message, {Object? error, StackTrace? stackTrace}) {
  AppLogger.debug(message, error: error, stackTrace: stackTrace);
}

/// Legacy shim to maintain compatibility with existing code that calls
/// `debugAppLogger.debug('...')`. Prefer using AppLogger directly.
class _DebugAppLoggerShim {
  void debug(String message) {
    AppLogger.debug(message);
  }
}

final debugAppLogger = _DebugAppLoggerShim();

/// Drop-in replacement for dart:developer log with the same signature.
/// This forwards to [AppLogger] so all logs are unified.
void log(
  String message, {
  DateTime? time,
  int? sequenceNumber,
  int level = 0,
  String name = '',
  Zone? zone,
  Object? error,
  StackTrace? stackTrace,
}) {
  // Map numeric "level" to AppLogger.LogLevel heuristically
  // 0: debug, 500: info, 900: warning, 1000+: error (roughly similar to java.util.logging)
  LogLevel mapped;
  if (level >= 1000) {
    mapped = LogLevel.error;
  } else if (level >= 900) {
    mapped = LogLevel.warning;
  } else if (level >= 500) {
    mapped = LogLevel.info;
  } else {
    mapped = LogLevel.debug;
  }

  final tag = (name.isNotEmpty) ? name : null;
  AppLogger.log(message,
      level: mapped, tag: tag, error: error, stackTrace: stackTrace);
}
