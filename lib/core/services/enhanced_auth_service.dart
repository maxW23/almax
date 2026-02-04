import 'dart:io';
import 'package:flutter/material.dart';
import 'package:lklk/core/services/auth_service.dart';
import 'package:lklk/core/services/auth_debug_helper.dart';
import 'package:lklk/core/services/zego_service_login.dart';
import 'package:lklk/core/utils/functions/snackbar_helper.dart';
import 'package:lklk/features/auth/domain/entities/user_entity.dart';
import 'package:lklk/features/home/presentation/manger/room_cubit/room_cubit_cubit.dart';
import 'package:lklk/features/profile_users/presentaion/manger/user_cubit/user_cubit_cubit.dart';
import 'dart:developer' as dev;

/// نتيجة عملية تسجيل الدخول المحسنة
class EnhancedAuthResult {
  final bool isSuccess;
  final String? errorMessage;
  final String? errorLocation;
  final AuthErrorType errorType;
  final UserEntity? user;
  final String? token;

  const EnhancedAuthResult({
    required this.isSuccess,
    this.errorMessage,
    this.errorLocation,
    this.errorType = AuthErrorType.unknown,
    this.user,
    this.token,
  });

  factory EnhancedAuthResult.success({
    required UserEntity user,
    required String token,
  }) {
    return EnhancedAuthResult(
      isSuccess: true,
      user: user,
      token: token,
    );
  }

  factory EnhancedAuthResult.failure({
    required String errorMessage,
    required String errorLocation,
    required AuthErrorType errorType,
  }) {
    return EnhancedAuthResult(
      isSuccess: false,
      errorMessage: errorMessage,
      errorLocation: errorLocation,
      errorType: errorType,
    );
  }
}

/// أنواع أخطاء المصادقة
enum AuthErrorType {
  noInternet, // لا يوجد إنترنت
  weakInternet, // إنترنت ضعيف
  vpnDetected, // استخدام VPN
  googleDataFailed, // فشل في الحصول على بيانات جوجل
  serverError, // خطأ في الخادم
  userBanned, // المستخدم محظور
  invalidCredentials, // بيانات اعتماد خاطئة
  zegoConnectionFailed, // فشل في الاتصال بـ Zego
  unknown, // خطأ غير معروف
}

/// خدمة تسجيل الدخول المحسنة
class EnhancedAuthService {
  static const String _logTag = 'EnhancedAuthService';

  /// تسجيل الدخول الشامل مع معالجة شاملة للأخطاء
  static Future<EnhancedAuthResult> performCompleteLogin({
    required UserCubit userCubit,
    required RoomCubit roomCubit,
    required BuildContext context,
  }) async {
    // Capture local reference to context before any awaits to avoid using it across async gaps
    final ctx = context;
    // Pre-build phases as local functions (preferred over assigning closures)
    Future<EnhancedAuthResult> authPhase() {
      return _performUserAuthentication(
        userCubit: userCubit,
        roomCubit: roomCubit,
        context: ctx,
      );
    }

    Future<EnhancedAuthResult> zegoPhase() {
      return _performZegoLogin(
        userCubit: userCubit,
        roomCubit: roomCubit,
        context: ctx,
      );
    }

    dev.log("🚀 [ENHANCED_AUTH] بدء عملية تسجيل الدخول الشاملة", name: _logTag);
    AuthDebugHelper.logAuthStep(
      step: "بدء تسجيل الدخول الشامل",
      status: "info",
      details: "تشغيل جميع مراحل المصادقة",
    );

    try {
      // المرحلة 1: التحقق من الاتصال بالإنترنت (اختياري - لا يوقف العملية)
      AuthDebugHelper.logAuthStep(
        step: "فحص الاتصال بالإنترنت",
        status: "info",
      );
      // Optional connectivity check; do not await to avoid blocking and context lints
      // ignore: discarded_futures
      _checkInternetConnection();

      // المرحلة 2: تسجيل الدخول عبر UserCubit
      AuthDebugHelper.logAuthStep(
        step: "تسجيل الدخول عبر UserCubit",
        status: "info",
      );
      final userAuthResult = await authPhase();

      if (!userAuthResult.isSuccess) {
        AuthDebugHelper.logAuthIssue(
          issue: "فشل في مصادقة المستخدم",
          location: "performCompleteLogin",
          additionalData: {
            'errorType': userAuthResult.errorType.toString(),
            'errorMessage': userAuthResult.errorMessage,
            'errorLocation': userAuthResult.errorLocation,
          },
        );
        return userAuthResult;
      }

      // المرحلة 3: تسجيل الدخول في Zego
      AuthDebugHelper.logAuthStep(
        step: "تسجيل الدخول في Zego",
        status: "info",
      );
      final zegoResult = await zegoPhase();

      if (!zegoResult.isSuccess) {
        AuthDebugHelper.logAuthIssue(
          issue: "فشل في تسجيل الدخول في Zego",
          location: "performCompleteLogin",
          additionalData: {
            'errorType': zegoResult.errorType.toString(),
            'errorMessage': zegoResult.errorMessage,
            'errorLocation': zegoResult.errorLocation,
          },
        );
        return zegoResult;
      }

      dev.log("✅ [ENHANCED_AUTH] تم تسجيل الدخول بنجاح", name: _logTag);
      AuthDebugHelper.logAuthStep(
        step: "تسجيل الدخول مكتمل",
        status: "success",
        details: "تم تسجيل الدخول بنجاح في جميع الخدمات",
      );

      return EnhancedAuthResult.success(
        user: userCubit.user!,
        token: userAuthResult.token!,
      );
    } catch (e) {
      dev.log("❌ [ENHANCED_AUTH] خطأ غير متوقع: $e", name: _logTag);
      AuthDebugHelper.logAuthIssue(
        issue: "خطأ غير متوقع في تسجيل الدخول",
        location: "performCompleteLogin",
        additionalData: {
          'exception': e.toString(),
          'stackTrace': StackTrace.current.toString(),
        },
      );

      return EnhancedAuthResult.failure(
        errorMessage: "حدث خطأ غير متوقع أثناء تسجيل الدخول",
        errorLocation: "EnhancedAuthService.performCompleteLogin",
        errorType: AuthErrorType.unknown,
      );
    }
  }

  /// التحقق من الاتصال بالإنترنت (فحص اختياري)
  static Future<void> _checkInternetConnection() async {
    dev.log("🌐 [ENHANCED_AUTH] فحص الاتصال بالإنترنت", name: _logTag);

    try {
      // محاولة سريعة للاتصال بخادم التطبيق
      final result = await InternetAddress.lookup('api.lklklive.com')
          .timeout(const Duration(seconds: 2));

      if (result.isNotEmpty && result[0].rawAddress.isNotEmpty) {
        dev.log("✅ [ENHANCED_AUTH] الاتصال بالإنترنت متاح", name: _logTag);
        return;
      }
    } catch (e) {
      dev.log(
          "⚠️ [ENHANCED_AUTH] تحذير: فحص الإنترنت فشل، لكن سنحاول المتابعة: $e",
          name: _logTag);
      // لا نوقف العملية، فقط نسجل التحذير
    }
  }

  /// تسجيل الدخول عبر UserCubit
  static Future<EnhancedAuthResult> _performUserAuthentication({
    required UserCubit userCubit,
    required RoomCubit roomCubit,
    required BuildContext context,
  }) async {
    dev.log("👤 [ENHANCED_AUTH] بدء مصادقة المستخدم", name: _logTag);

    try {
      await userCubit.signIn(roomCubit, context);

      // انتظار قصير للتأكد من تحديث الحالة
      await Future.delayed(const Duration(milliseconds: 500));

      final userState = userCubit.state;
      dev.log("📊 [ENHANCED_AUTH] حالة المستخدم: ${userState.status}",
          name: _logTag);

      switch (userState.status) {
        case UserCubitStatus.authenticated:
          if (userCubit.user != null) {
            dev.log("✅ [ENHANCED_AUTH] تم تسجيل الدخول بنجاح", name: _logTag);

            // جلب التوكن من التخزين
            final token = await AuthService.getTokenFromSharedPreferences();

            return EnhancedAuthResult.success(
              user: userCubit.user!,
              token: token ?? '',
            );
          } else {
            dev.log("❌ [ENHANCED_AUTH] بيانات المستخدم فارغة رغم نجاح المصادقة",
                name: _logTag);
            return EnhancedAuthResult.failure(
              errorMessage: "فشل في الحصول على بيانات المستخدم من الخادم.",
              errorLocation: "_performUserAuthentication - user data null",
              errorType: AuthErrorType.serverError,
            );
          }

        case UserCubitStatus.error:
          final rawMessage =
              (userState.message?.toString().trim().isNotEmpty ?? false)
                  ? userState.message!.toString().trim()
                  : "حدث خطأ في تسجيل الدخول";
          dev.log("❌ [ENHANCED_AUTH] خطأ في المصادقة: $rawMessage",
              name: _logTag);

          // تحليل نوع الخطأ من الرسالة الفعلية
          final errorType = _analyzeErrorType(rawMessage);
          final localized = _getLocalizedErrorMessage(errorType, rawMessage);

          return EnhancedAuthResult.failure(
            errorMessage: localized,
            errorLocation: "_performUserAuthentication - UserCubit error",
            errorType: errorType,
          );

        case UserCubitStatus.loading:
          dev.log("⏳ [ENHANCED_AUTH] لا يزال في حالة تحميل", name: _logTag);
          return EnhancedAuthResult.failure(
            errorMessage: "انتهت مهلة تسجيل الدخول. يرجى المحاولة مرة أخرى.",
            errorLocation: "_performUserAuthentication - timeout",
            errorType: AuthErrorType.weakInternet,
          );

        default:
          dev.log("❌ [ENHANCED_AUTH] حالة غير متوقعة: ${userState.status}",
              name: _logTag);
          return EnhancedAuthResult.failure(
            errorMessage: "حدث خطأ غير متوقع أثناء تسجيل الدخول.",
            errorLocation: "_performUserAuthentication - unexpected state",
            errorType: AuthErrorType.unknown,
          );
      }
    } catch (e) {
      dev.log("❌ [ENHANCED_AUTH] استثناء في مصادقة المستخدم: $e",
          name: _logTag);
      return EnhancedAuthResult.failure(
        errorMessage: "حدث خطأ أثناء الاتصال بخادم المصادقة.",
        errorLocation: "_performUserAuthentication - exception: $e",
        errorType: AuthErrorType.serverError,
      );
    }
  }

  /// تسجيل الدخول في Zego
  static Future<EnhancedAuthResult> _performZegoLogin({
    required UserCubit userCubit,
    required RoomCubit roomCubit,
    required BuildContext context,
  }) async {
    dev.log("🎮 [ENHANCED_AUTH] بدء تسجيل الدخول في Zego", name: _logTag);

    try {
      await zegoLoginService(
        context,
        userCubit: userCubit,
        roomCubit: roomCubit,
      );

      dev.log("✅ [ENHANCED_AUTH] تم تسجيل الدخول في Zego بنجاح", name: _logTag);
      return const EnhancedAuthResult(isSuccess: true);
    } catch (e) {
      dev.log("❌ [ENHANCED_AUTH] فشل في تسجيل الدخول في Zego: $e",
          name: _logTag);

      String errorMessage = "فشل في الاتصال بخدمة الدردشة الصوتية.";

      // تحليل خطأ Zego
      if (e.toString().contains("network") ||
          e.toString().contains("timeout")) {
        errorMessage = "فشل في الاتصال بخدمة الدردشة بسبب ضعف الإنترنت.";
      } else if (e.toString().contains("permission")) {
        errorMessage = "يرجى السماح بصلاحيات الميكروفون للتطبيق.";
      }

      return EnhancedAuthResult.failure(
        errorMessage: errorMessage,
        errorLocation: "_performZegoLogin - exception: $e",
        errorType: AuthErrorType.zegoConnectionFailed,
      );
    }
  }

  /// تحليل نوع الخطأ من رسالة الخطأ
  static AuthErrorType _analyzeErrorType(String errorMessage) {
    final message = errorMessage.toLowerCase();

    if (message.contains("محظور") || message.contains("banned")) {
      return AuthErrorType.userBanned;
    } else if (message.contains("network_") ||
        message.contains("network error") ||
        message.contains("network") ||
        message.contains("شبكة")) {
      return AuthErrorType.noInternet;
    } else if (message.contains("timeout") ||
        message.contains("انتهت المهلة")) {
      return AuthErrorType.weakInternet;
    } else if (message.contains("apiexception: 7") ||
        message.contains(" 7:") ||
        message.contains("code 7")) {
      // Google Play Services NETWORK_ERROR
      return AuthErrorType.weakInternet;
    } else if (message.contains("vpn")) {
      return AuthErrorType.vpnDetected;
    } else if (message.contains("google") ||
        message.contains("جوجل") ||
        message.contains("play services")) {
      return AuthErrorType.googleDataFailed;
    } else if (message.contains("server") || message.contains("خادم")) {
      return AuthErrorType.serverError;
    } else if (message.contains("credentials") ||
        message.contains("بيانات اعتماد")) {
      return AuthErrorType.invalidCredentials;
    }

    return AuthErrorType.unknown;
  }

  /// الحصول على رسالة خطأ محلية
  static String _getLocalizedErrorMessage(
      AuthErrorType errorType, String originalMessage) {
    switch (errorType) {
      case AuthErrorType.noInternet:
        return "لا يوجد اتصال بالإنترنت. يرجى التحقق من الاتصال والمحاولة مرة أخرى.";

      case AuthErrorType.weakInternet:
        return "الاتصال بالإنترنت ضعيف. يرجى التحقق من قوة الإشارة والمحاولة مرة أخرى.";

      case AuthErrorType.vpnDetected:
        return "يرجى إيقاف تشغيل VPN والمحاولة مرة أخرى.";

      case AuthErrorType.googleDataFailed:
        return "فشل في الحصول على بيانات جوجل. يرجى المحاولة مرة أخرى أو استخدام طريقة تسجيل دخول أخرى.";

      case AuthErrorType.serverError:
        return "خطأ في الخادم. يرجى المحاولة مرة أخرى لاحقاً.";

      case AuthErrorType.userBanned:
        return "تم حظر حسابك من التطبيق. يرجى التواصل مع الدعم الفني.";

      case AuthErrorType.invalidCredentials:
        return "بيانات تسجيل الدخول غير صحيحة. يرجى المحاولة مرة أخرى.";

      case AuthErrorType.zegoConnectionFailed:
        return "فشل في الاتصال بخدمة الدردشة الصوتية. يرجى التحقق من الاتصال والمحاولة مرة أخرى.";

      case AuthErrorType.unknown:
      default:
        return originalMessage.isNotEmpty
            ? originalMessage
            : "حدث خطأ غير متوقع. يرجى المحاولة مرة أخرى.";
    }
  }

  /// عرض رسالة الخطأ للمستخدم
  static void showErrorToUser(BuildContext context, EnhancedAuthResult result) {
    if (!result.isSuccess && result.errorMessage != null) {
      dev.log("📱 [ENHANCED_AUTH] عرض رسالة خطأ: ${result.errorMessage}",
          name: _logTag);
      dev.log("📍 [ENHANCED_AUTH] موقع الخطأ: ${result.errorLocation}",
          name: _logTag);

      SnackbarHelper.showMessage(
        context,
        result.errorMessage!,
      );
    }
  }
}
