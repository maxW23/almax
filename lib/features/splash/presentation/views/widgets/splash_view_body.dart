import 'package:flutter/material.dart';
import 'dart:async';
import 'package:flutter/services.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:lklk/core/animations/custom_page_transition.dart';
import 'package:lklk/core/animations/shimmer_widget.dart';
import 'package:lklk/core/constants/app_colors.dart';
import 'package:lklk/core/services/auth_result.dart';
import 'package:lklk/core/services/auth_service.dart';
import 'package:lklk/core/services/zego_service_login.dart';
import 'package:lklk/core/services/svga_seeder.dart';
import 'package:lklk/core/utils/text_direection.dart';
import 'package:lklk/features/auth/domain/entities/user_entity.dart';
import 'package:lklk/features/auth/presentation/view/auth_view.dart';
import 'package:lklk/features/home/presentation/manger/language/language_cubit.dart';
import 'package:lklk/features/home/presentation/manger/room_cubit/room_cubit_cubit.dart';
import 'package:lklk/features/profile_users/presentaion/manger/user_cubit/user_cubit_cubit.dart';
import 'package:lklk/main.dart';
import '../../../../../core/constants/assets.dart';
import 'sliding_text.dart';
// lib/features/auth/presentation/view/splash_viewbody.dart
import 'package:url_launcher/url_launcher.dart';

class SplashViewbody extends StatefulWidget {
  const SplashViewbody({
    super.key,
    required this.userCubit,
    required this.roomCubit,
  });
  final UserCubit userCubit;
  final RoomCubit roomCubit;
  @override
  State<SplashViewbody> createState() => _SplashViewbodyState();
}

class _SplashViewbodyState extends State<SplashViewbody>
    with SingleTickerProviderStateMixin {
  late AnimationController animationController;
  late Animation<Offset> slidingAnimation;
  String selectedLanguage = 'en';

  @override
  void initState() {
    super.initState();
    initSlidingAnimation();
    _checkAuth();
    final languageCubit = context.read<LanguageCubit>();
    selectedLanguage = languageCubit.state.languageCode;
  }

  Future<void> _checkAuth() async {
    // تهيئة ملفات SVGA محلياً عند أول تشغيل (تنفّذ في الخلفية ولا تحجب الـ UI)
    unawaited(SvgaSeeder.seedIfNeeded());

    final UserEntity? userAuth =
        await AuthService.getUserFromSharedPreferences();
    final userType = await AuthService.getUserTypeFromSharedPreferences();
    final userEmail = await AuthService.getEmailFromSharedPreferences();
    final userPassword = await AuthService.getPasswordFromSharedPreferences();

    final versionInfo = await widget.userCubit.getVertionNumber();
    final versionApp = await DeviceInfoHelper.getAppVersion();

    if (!mounted) return;

    // في حالة عدم توفر معلومات الإصدار (غالباً لانقطاع الإنترنت)
    if (versionInfo == null) {
      Future.delayed(
        const Duration(seconds: 1),
        () {
          if (!mounted) return;
          final navigator = Navigator.of(context);
          navigator.pushReplacement(
            CustomPageTransition.gentleTransition(
              AuthView(
                roomCubit: widget.roomCubit,
                userCubit: widget.userCubit,
              ),
            ),
          );
        },
      );
      return; // إيقاف الدالة لمنع استخدام versionInfo لاحقاً
    }

    // تحقق من التحديثات
    if (versionInfo.version > versionApp) {
      // تحديث إجباري
      final navigator = Navigator.of(context);
      WidgetsBinding.instance.addPostFrameCallback((_) {
        showForceUpdateDialog(navigator.context, versionInfo.response);
      });
      return; // منع الدخول لأي مكان
    } else if (versionInfo.numb > versionApp) {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        showOptionalUpdateNotification(versionInfo.response);
      });
    }

    // الدخول العادي
    if (userAuth != null && versionInfo.version <= versionApp) {
      final navigator = Navigator.of(context);
      userType == "email"
          ? await widget.userCubit.signIn(widget.roomCubit, context,
              email: userEmail, password: userPassword, isGoogle: false)
          : await widget.userCubit
              .signIn(widget.roomCubit, context, isGoogle: true);

      if (!mounted) return;

      if (widget.userCubit.state.status == UserCubitStatus.authenticated) {
        await zegoLoginService(
          navigator.context,
          userCubit: widget.userCubit,
          roomCubit: widget.roomCubit,
        );
      }
    } else if (versionInfo.version <= versionApp) {
      Future.delayed(
        const Duration(seconds: 1),
        () {
          if (!mounted) return;
          final navigator = Navigator.of(context);
          navigator.pushReplacement(
            CustomPageTransition.gentleTransition(
              AuthView(
                roomCubit: widget.roomCubit,
                userCubit: widget.userCubit,
              ),
            ),
          );
        },
      );
    }
  }

  @override
  void dispose() {
    animationController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      mainAxisAlignment: MainAxisAlignment.center,
      crossAxisAlignment: CrossAxisAlignment.center,
      children: [
        ShimmerWidget(
          gradient: LinearGradient(
            colors: [
              Colors.transparent,
              Colors.black.withValues(alpha: .4),
              Colors.transparent,
            ],
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
          ),
          period: Duration(seconds: 4),
          child: Padding(
            padding: const EdgeInsets.all(30),
            child: Image.asset(
              AssetsData.logoWhite,
              fit: BoxFit.cover,
              alignment: Alignment.center,
            ),
          ),
        ),
        const SizedBox(
          height: 4,
        ),
        SlidingText(slidingAnimation: slidingAnimation),
      ],
    );
  }

  void initSlidingAnimation() {
    animationController = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 2),
    );

    slidingAnimation =
        Tween<Offset>(begin: const Offset(0, 6), end: Offset.zero)
            .animate(animationController);

    animationController.forward();
  }

  Future<void> openGooglePlay() async {
    const url =
        'https://play.google.com/store/apps/details?id=com.bwmatbw.lklklivechatapp';
    if (await canLaunchUrl(Uri.parse(url))) {
      await launchUrl(Uri.parse(url), mode: LaunchMode.externalApplication);
    }
  }

  void showForceUpdateDialog(BuildContext context, String message) {
    final languageCubit = context.read<LanguageCubit>();
    final selectedLanguage = languageCubit.state.languageCode;

    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) {
        return Directionality(
          textDirection: getTextDirection(selectedLanguage),
          child: Dialog(
            shape:
                RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
            elevation: 10,
            backgroundColor: AppColors.white,
            child: Padding(
              padding: const EdgeInsets.all(20.0),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  // العنوان
                  const Text(
                    'تحديث مطلوب',
                    textAlign: TextAlign.center,
                    style: TextStyle(
                      fontSize: 22,
                      fontWeight: FontWeight.bold,
                      color: Colors.black87,
                    ),
                  ),
                  const SizedBox(height: 16),

                  // الرسالة
                  Text(
                    message,
                    textAlign: TextAlign.center,
                    style: const TextStyle(
                      fontSize: 16,
                      color: Colors.black54,
                    ),
                  ),
                  const SizedBox(height: 24),

                  // الأزرار
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                    children: [
                      // زر إلغاء
                      TextButton(
                        onPressed: () async {
                          await AuthService.clearUserData();
                          SystemNavigator.pop();
                        },
                        child: const Text(
                          'إلغاء',
                          style: TextStyle(
                            color: const Color(0xFFFF0000),
                            fontSize: 16,
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                      ),

                      // زر تحديث
                      Container(
                        decoration: BoxDecoration(
                          gradient: const LinearGradient(
                            colors: [AppColors.primary, AppColors.secondColor],
                            begin: Alignment.topLeft,
                            end: Alignment.bottomRight,
                          ),
                          borderRadius: BorderRadius.circular(12),
                        ),
                        child: InkWell(
                          onTap: () async {
                            await openGooglePlay();
                          },
                          child: const Padding(
                            padding: EdgeInsets.symmetric(
                                horizontal: 24, vertical: 12),
                            child: Text(
                              'تحديث',
                              style: TextStyle(
                                fontSize: 16,
                                color: AppColors.white,
                                fontWeight: FontWeight.w500,
                              ),
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ),
        );
      },
    );
  }

  Future<void> showOptionalUpdateNotification(String message) async {
    const AndroidNotificationDetails androidPlatformChannelSpecifics =
        AndroidNotificationDetails(
      'update_channel',
      'App Updates',
      channelDescription: 'Optional app update notifications',
      importance: Importance.max,
      priority: Priority.high,
      ticker: 'ticker',
    );

    const NotificationDetails platformChannelSpecifics =
        NotificationDetails(android: androidPlatformChannelSpecifics);

    await flutterLocalNotificationsPlugin.show(
      0,
      'تحديث جديد متاح',
      message,
      platformChannelSpecifics,
      payload: 'update_app',
    );
  }
}
