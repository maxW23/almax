import 'package:flutter/material.dart';
import 'package:lklk/generated/l10n.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:lklk/core/services/enhanced_auth_service.dart';
import 'package:lklk/features/profile_users/presentaion/manger/user_cubit/user_cubit_cubit.dart';
import 'package:progress_state_button/iconed_button.dart';
import 'package:progress_state_button/progress_button.dart';
import 'package:lklk/core/constants/app_colors.dart';
import 'package:lklk/features/home/presentation/manger/room_cubit/room_cubit_cubit.dart';
import 'dart:developer' as dev;

class ProgressButtonWidget extends StatefulWidget {
  final UserCubit userCubit;
  final RoomCubit roomCubit;
  final bool enabled;
  const ProgressButtonWidget({
    super.key,
    required this.userCubit,
    required this.roomCubit,
    required this.enabled,
  });

  @override
  State<ProgressButtonWidget> createState() => _ProgressButtonWidgetState();
}

class _ProgressButtonWidgetState extends State<ProgressButtonWidget> {
  ButtonState buttonState = ButtonState.idle;
  bool _isProcessing = false; // prevent double taps / concurrent logins

  @override
  void initState() {
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return ProgressButton.icon(
      iconedButtons: {
        ButtonState.idle: IconedButton(
          color: AppColors.purpleColor,
          text: S.of(context).signGoogle,
          icon: const Icon(
            FontAwesomeIcons.google,
            color: AppColors.white,
          ),
        ),
        ButtonState.loading: IconedButton(
          text: S.of(context).loading,
          color: AppColors.secondColorDark,
        ),
        ButtonState.fail: IconedButton(
          text: S.of(context).fail,
          icon: const Icon(Icons.cancel, color: Colors.white),
          color: AppColors.danger,
        ),
        ButtonState.success: IconedButton(
          text: S.of(context).success,
          icon: const Icon(
            Icons.check_circle,
            color: Colors.white,
          ),
          color: Colors.green.shade400,
        )
      },
      onPressed: () {
        if (!widget.enabled) {
          final messenger = ScaffoldMessenger.of(context);
          messenger.showSnackBar(
            SnackBar(content: Text(S.of(context).pleaseAgreeToPrivacyPolicy)),
          );
          return;
        }
        // Guard against double taps or rapid re-press
        if (_isProcessing || buttonState == ButtonState.loading) {
          return;
        }
        onPressedButton(widget.userCubit, widget.roomCubit);
      },
      state: buttonState,
    );
  }

  /// تنفيذ عملية تسجيل الدخول المحسنة
  void onPressedButton(UserCubit userCubit, RoomCubit roomCubit) async {
    final messenger = ScaffoldMessenger.of(context);
    if (_isProcessing) return;
    _isProcessing = true;
    setState(() {
      buttonState = ButtonState.loading;
    });

    dev.log("🚀 [PROGRESS_BUTTON] بدء عملية تسجيل الدخول",
        name: 'ProgressButton');

    try {
      // استخدام الخدمة المحسنة لتسجيل الدخول
      final result = await EnhancedAuthService.performCompleteLogin(
        userCubit: userCubit,
        roomCubit: roomCubit,
        context: context,
      );

      if (!mounted) {
        _isProcessing = false;
        return;
      }
      if (result.isSuccess) {
        dev.log("✅ [PROGRESS_BUTTON] تم تسجيل الدخول بنجاح",
            name: 'ProgressButton');
        setState(() {
          buttonState = ButtonState.success;
        });
        _isProcessing = false;
      } else {
        dev.log("❌ [PROGRESS_BUTTON] فشل تسجيل الدخول: ${result.errorMessage}",
            name: 'ProgressButton');
        dev.log("📍 [PROGRESS_BUTTON] موقع الخطأ: ${result.errorLocation}",
            name: 'ProgressButton');

        setState(() {
          buttonState = ButtonState.fail;
        });

        // عرض رسالة الخطأ للمستخدم
        EnhancedAuthService.showErrorToUser(context, result);

        // إعادة تعيين الزر بعد 3 ثوان
        Future.delayed(const Duration(seconds: 3), () {
          if (mounted) {
            setState(() {
              buttonState = ButtonState.idle;
            });
          }
          _isProcessing = false;
        });
      }
    } catch (error) {
      dev.log("❌ [PROGRESS_BUTTON] خطأ غير متوقع: $error",
          name: 'ProgressButton');

      setState(() {
        buttonState = ButtonState.fail;
      });

      // عرض رسالة خطأ عامة
      messenger.showSnackBar(
        const SnackBar(
            content: Text("حدث خطأ غير متوقع. يرجى المحاولة مرة أخرى.")),
      );

      // إعادة تعيين الزر بعد 3 ثوان
      Future.delayed(const Duration(seconds: 3), () {
        if (mounted) {
          setState(() {
            buttonState = ButtonState.idle;
          });
        }
        _isProcessing = false;
      });
    }
  }
}
