import 'dart:developer' as dev;
import 'package:flutter/foundation.dart';

/// مساعد تشخيص مشاكل تسجيل الدخول
class AuthDebugHelper {
  static const String _logTag = 'AuthDebugHelper';

  /// تسجيل تفاصيل مشكلة تسجيل الدخول
  static void logAuthIssue({
    required String issue,
    required String location,
    Map<String, dynamic>? additionalData,
  }) {
    if (kDebugMode) {
      dev.log("🔍 [AUTH_DEBUG] مشكلة: $issue", name: _logTag);
      dev.log("📍 [AUTH_DEBUG] الموقع: $location", name: _logTag);

      if (additionalData != null && additionalData.isNotEmpty) {
        dev.log("📊 [AUTH_DEBUG] بيانات إضافية:", name: _logTag);
        additionalData.forEach((key, value) {
          dev.log("   $key: $value", name: _logTag);
        });
      }

      dev.log("=" * 50, name: _logTag);
    }
  }

  /// تسجيل خطوات تسجيل الدخول
  static void logAuthStep({
    required String step,
    required String status,
    String? details,
  }) {
    if (kDebugMode) {
      String emoji = status == 'success'
          ? '✅'
          : status == 'error'
              ? '❌'
              : status == 'warning'
                  ? '⚠️'
                  : '🔄';

      dev.log("$emoji [AUTH_STEP] $step", name: _logTag);
      if (details != null) {
        dev.log("   التفاصيل: $details", name: _logTag);
      }
    }
  }

  /// تسجيل حالة الشبكة
  static void logNetworkStatus({
    required bool isConnected,
    String? connectionType,
    String? errorDetails,
  }) {
    if (kDebugMode) {
      String emoji = isConnected ? '🌐' : '📵';
      dev.log("$emoji [NETWORK] الاتصال: ${isConnected ? 'متصل' : 'منقطع'}",
          name: _logTag);

      if (connectionType != null) {
        dev.log("   نوع الاتصال: $connectionType", name: _logTag);
      }

      if (errorDetails != null) {
        dev.log("   تفاصيل الخطأ: $errorDetails", name: _logTag);
      }
    }
  }

  /// تسجيل حالة Google Sign In
  static void logGoogleSignInStatus({
    required String status,
    String? userEmail,
    String? errorCode,
    String? errorMessage,
  }) {
    if (kDebugMode) {
      dev.log("🔐 [GOOGLE_AUTH] الحالة: $status", name: _logTag);

      if (userEmail != null) {
        dev.log("   البريد الإلكتروني: $userEmail", name: _logTag);
      }

      if (errorCode != null) {
        dev.log("   رمز الخطأ: $errorCode", name: _logTag);
      }

      if (errorMessage != null) {
        dev.log("   رسالة الخطأ: $errorMessage", name: _logTag);
      }
    }
  }

  /// تسجيل حالة API
  static void logApiStatus({
    required String endpoint,
    required String method,
    required int statusCode,
    String? responseBody,
    String? errorMessage,
  }) {
    if (kDebugMode) {
      String emoji = statusCode >= 200 && statusCode < 300 ? '✅' : '❌';
      dev.log("$emoji [API] $method $endpoint - Status: $statusCode",
          name: _logTag);

      if (errorMessage != null) {
        dev.log("   خطأ: $errorMessage", name: _logTag);
      }

      if (responseBody != null && responseBody.length < 500) {
        dev.log("   الاستجابة: $responseBody", name: _logTag);
      }
    }
  }

  /// تسجيل حالة Zego
  static void logZegoStatus({
    required String operation,
    required bool success,
    String? errorCode,
    String? errorMessage,
  }) {
    if (kDebugMode) {
      String emoji = success ? '✅' : '❌';
      dev.log("$emoji [ZEGO] $operation", name: _logTag);

      if (!success) {
        if (errorCode != null) {
          dev.log("   رمز الخطأ: $errorCode", name: _logTag);
        }

        if (errorMessage != null) {
          dev.log("   رسالة الخطأ: $errorMessage", name: _logTag);
        }
      }
    }
  }

  /// نصائح لحل مشاكل تسجيل الدخول الشائعة
  static List<String> getCommonSolutions(String errorType) {
    switch (errorType.toLowerCase()) {
      case 'network':
        return [
          'تأكد من الاتصال بالإنترنت',
          'جرب إعادة تشغيل الـ WiFi',
          'تحقق من إعدادات الشبكة',
          'جرب استخدام بيانات الهاتف بدلاً من WiFi',
        ];

      case 'google':
        return [
          'تأكد من تسجيل الدخول في حساب Google',
          'تحقق من إعدادات Google Play Services',
          'امسح cache التطبيق',
          'جرب إعادة تسجيل الدخول في Google',
        ];

      case 'server':
        return [
          'الخادم قد يكون مشغولاً، جرب لاحقاً',
          'تحقق من حالة الخادم',
          'جرب إعادة تشغيل التطبيق',
          'تأكد من أن التطبيق محدث',
        ];

      case 'zego':
        return [
          'تحقق من صلاحيات الميكروفون',
          'جرب إعادة تشغيل التطبيق',
          'تأكد من الاتصال بالإنترنت',
          'تحقق من إعدادات الصوت',
        ];

      default:
        return [
          'جرب إعادة تشغيل التطبيق',
          'تأكد من الاتصال بالإنترنت',
          'امسح cache التطبيق',
          'تواصل مع الدعم الفني إذا استمرت المشكلة',
        ];
    }
  }

  /// عرض تقرير تشخيصي شامل
  static void generateDiagnosticReport() {
    if (kDebugMode) {
      dev.log("📋 [DIAGNOSTIC] تقرير تشخيصي شامل", name: _logTag);
      dev.log("=" * 60, name: _logTag);

      // معلومات النظام
      dev.log("🔧 معلومات النظام:", name: _logTag);
      dev.log("   المنصة: ${defaultTargetPlatform.name}", name: _logTag);
      dev.log("   وضع التطوير: ${kDebugMode ? 'نعم' : 'لا'}", name: _logTag);

      // نصائح عامة
      dev.log("💡 نصائح لحل المشاكل:", name: _logTag);
      final solutions = getCommonSolutions('general');
      for (int i = 0; i < solutions.length; i++) {
        dev.log("   ${i + 1}. ${solutions[i]}", name: _logTag);
      }

      dev.log("=" * 60, name: _logTag);
    }
  }
}
