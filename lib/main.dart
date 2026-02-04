// ignore_for_file: depend_on_referenced_packages
import 'dart:async';
import 'dart:ui' show PlatformDispatcher;
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:lklk/core/initialization/app_initializer.dart';
import 'package:lklk/core/service_locator.dart';
import 'package:lklk/features/home/presentation/manger/gifts_show_cubit/gifts_show_cubit.dart';
import 'package:lklk/features/room/presentation/manger/gifts/gifts_cubit.dart';
import 'package:lklk/features/room/presentation/manger/player/playback_cubit.dart';
import 'package:lklk/features/room/presentation/manger/player/playlist_cubit.dart';
import 'package:lklk/features/room/presentation/manger/player/bottom_sheet_cubit.dart';
import 'package:lklk/features/room/presentation/manger/lucky_bag/luck_bag_cubit.dart';
import 'package:lklk/generated/l10n.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:lklk/core/widgets/overlay/page.dart';
import 'package:lklk/features/home/presentation/manger/alert_cubit/alert_cubit.dart';
import 'package:lklk/features/home/presentation/manger/language/language_cubit.dart';
import 'package:lklk/features/home/presentation/manger/rooms_cubit/rooms_cubit.dart';
import 'package:lklk/features/profile_users/presentaion/manger/fetch_elements_cubit/fetch_elements_cubit.dart';
import 'package:lklk/features/profile_users/presentaion/manger/user_cubit/user_cubit_cubit.dart';
import 'package:lklk/features/splash/presentation/views/splash_view.dart';
import 'package:nested/nested.dart';
import 'core/constants/assets.dart';
import 'core/utils/simple_bloc_observer.dart';
import 'core/utils/performance_logger.dart';
import 'core/utils/logger.dart';
import 'core/zego_delegate.dart';
import 'features/home/presentation/manger/room_cubit/room_cubit_cubit.dart';
import 'core/constants/app_colors.dart';
import 'package:get_it/get_it.dart';
import 'package:lklk/features/livekit_audio/presentation/cubit/livekit_audio_cubit.dart';

final GlobalKey<NavigatorState> navigatorKey = GlobalKey<NavigatorState>();
final GetIt getIt = GetIt.instance;

// Global notification plugin instance for backward compatibility
final flutterLocalNotificationsPlugin = AppInitializer.notificationsPlugin;

Future<void> main() async {
  // Run inside guarded zone to capture uncaught errors without affecting UX
  await runZonedGuarded(() async {
    // Initialize all app services and configurations
    await AppInitializer.initialize();

    // Global crash handlers (Flutter/UI and platform)
    FlutterError.onError = (FlutterErrorDetails details) {
      FlutterError.presentError(details);
      log('[FlutterError] ${details.exceptionAsString()}',
          stackTrace: details.stack);
    };
    PlatformDispatcher.instance.onError = (Object error, StackTrace stack) {
      log('[PlatformDispatcher] $error', stackTrace: stack);
      return true; // prevent default crash in release
    };

    // Global edge-to-edge configuration with consistent system UI styling.
    try {
      await SystemChrome.setEnabledSystemUIMode(SystemUiMode.edgeToEdge);
      SystemChrome.setSystemUIOverlayStyle(const SystemUiOverlayStyle(
        systemNavigationBarColor: Colors.black,
        systemNavigationBarIconBrightness: Brightness.dark,
        systemNavigationBarDividerColor: Colors.black,
        statusBarColor: Colors.transparent,
        statusBarIconBrightness: Brightness.dark,
      ));
    } catch (_) {}

    // Set Bloc observer for debugging
    Bloc.observer = ComprehensiveBlocObserver();

    // Create language cubit for localization
    final languageCubit = LanguageCubit();

    // Run the app
    runApp(MyApp(languageCubit: languageCubit));

    // Defer non-critical initializations to after first frame
    WidgetsBinding.instance.addPostFrameCallback((_) {
      AppInitializer.initializeAds();
      AppInitializer.initializeDownloads();
      // Enable lightweight performance logs in debug/profile only
      // Uncomment to activate when needed
      // PerformanceLogger.instance.start();
    });
  }, (Object error, StackTrace stack) {
    // Fallback for any uncaught error in the zone
    log('[UncaughtZoneError] $error', stackTrace: stack);
  });
}

class MyApp extends StatelessWidget {
  const MyApp({super.key, required this.languageCubit});
  final LanguageCubit languageCubit;
  @override
  Widget build(BuildContext context) {
    return MultiBlocProvider(
      providers: providersMultiBlocProvider,
      child: Builder(builder: (context) {
        final UserCubit userCubit = sl<UserCubit>();
        final RoomCubit roomCubit = BlocProvider.of<RoomCubit>(context);

        return BlocBuilder<LanguageCubit, Locale>(
          builder: (context, locale) {
            return ScreenUtilInit(
              designSize: const Size(360, 756.0),
              minTextAdapt: true,
              splitScreenMode: true,
              builder: (context, child) {
                return Builder(
                  builder: (context) {
                    return materialAppLkLk(locale, userCubit, roomCubit, child);
                  },
                );
              },
              child: SplashView(userCubit: userCubit, roomCubit: roomCubit),
            );
          },
        );
      }),
    );
  }

  MaterialApp materialAppLkLk(
      Locale locale, UserCubit userCubit, RoomCubit roomCubit, Widget? child) {
    return MaterialApp(
      locale: locale,
      supportedLocales: S.delegate.supportedLocales,
      navigatorKey: navigatorKey,
      home: child,
      // home: SplashView(userCubit: userCubit, roomCubit: roomCubit),
      title: AssetsData.appLKLK,
      theme: themeDataApp(),
      localizationsDelegates: [
        S.delegate,
        GlobalMaterialLocalizations.delegate,
        GlobalWidgetsLocalizations.delegate,
        GlobalCupertinoLocalizations.delegate,
      ],

      builder: (BuildContext context, Widget? child) {
        return Directionality(
          textDirection: _getTextDirection(locale.languageCode),
          child: Builder(builder: (context) {
            final baseMedia = MediaQuery.of(context).copyWith(
              textScaler: TextScaler.linear(1.sp),
              devicePixelRatio: 1.sp,
            );
            // Compute a global bottom inset that respects keyboard or system nav bar.
            final keyboardInset = baseMedia.viewInsets.bottom;
            final systemNavInset = baseMedia.viewPadding.bottom;
            // عند ظهور الكيبورد لا نضيف أي padding سفلي عام حتى لا تظهر مساحة بيضاء
            final double resolvedBottomInset =
                (keyboardInset > 0) ? 0.0 : systemNavInset;

            // Provide a MediaQuery with bottom padding removed so inner SafeAreas
            // don't double-apply bottom padding. We'll apply it once here.
            final mediaWithoutBottomPadding = baseMedia.copyWith(
              padding: baseMedia.padding.copyWith(bottom: 0),
            );

            return MediaQuery(
              data: mediaWithoutBottomPadding,
              child: AnnotatedRegion<SystemUiOverlayStyle>(
                value: const SystemUiOverlayStyle(
                  systemNavigationBarColor: Colors.black,
                  systemNavigationBarIconBrightness: Brightness.dark,
                  systemNavigationBarDividerColor: Colors.black,
                  statusBarColor: Colors.transparent,
                  statusBarIconBrightness: Brightness.dark,
                ),
                child: Material(
                  child: Padding(
                    padding: EdgeInsets.only(
                      bottom: resolvedBottomInset,
                    ),
                    child: Stack(
                      fit: StackFit.expand,
                      children: [
                        child!,
                        AudioRoomOverlayPage(
                          navigatorKey: navigatorKey,
                          userCubit: userCubit,
                          roomCubit: roomCubit,
                        ),
                      ],
                    ),
                  ),
                ),
              ),
            );
          }),
        );
      },
    );
  }

  ThemeData themeDataApp() {
    return ThemeData(
      useMaterial3: true,
      appBarTheme: const AppBarTheme(
        backgroundColor: Colors.transparent,
        elevation: 0,
        scrolledUnderElevation: 0,
        surfaceTintColor: Colors.transparent,
        shadowColor: Colors.transparent,
      ),
      textTheme: Typography.englishLike2018.apply(
        fontSizeFactor: 1.sp,
        bodyColor: AppColors.black,
        displayColor: AppColors.black,
      ),
      colorScheme: ColorScheme.fromSeed(
        seedColor: AppColors.primary,
        primary: AppColors.primary,
        background: AppColors.white,
        error: AppColors.danger,
        brightness: Brightness.light,
      ).copyWith(surface: AppColors.white),
      tabBarTheme: TabBarThemeData(
        labelColor: AppColors.golden,
        labelStyle: TextStyle(
            color: AppColors.golden, fontSize: 14, fontWeight: FontWeight.w600),
        indicator: UnderlineTabIndicator(
          borderSide: BorderSide(
            color: AppColors.golden,
            width: 2,
          ),
        ),
      ),
    );
  }

  List<SingleChildWidget> get providersMultiBlocProvider {
    return [
      BlocProvider(create: (context) => sl<UserCubit>()),
      BlocProvider(create: (context) => sl<LuckBagCubit>()),

      BlocProvider<RoomCubit>(create: (context) => RoomCubit()),
      BlocProvider<LanguageCubit>.value(value: languageCubit),
      BlocProvider(
        create: (context) => RoomsCubit(),
      ),
      BlocProvider<AlertCubit>(
        create: (context) => AlertCubit(),
        lazy: true,
      ),
      BlocProvider<GiftCubit>(
        create: (context) => GiftCubit(),
        lazy: true,
      ),

      BlocProvider<FetchElementsCubit>(
        lazy: true,
        create: (context) => FetchElementsCubit(),
      ), //EmojiCubit,
      BlocProvider<GiftsShowCubit>(
        create: (context) => GiftsShowCubit(),
        lazy: true,
      ),
      // مزودي المشغل وقائمة الأغاني وواجهة BottomSheet
      BlocProvider<PlaybackCubit>(
        create: (context) => PlaybackCubit(ZegoDelegate()),
        lazy: false, // نحتاجه دائماً للحفاظ على حالة الصوت
      ),
      BlocProvider<PlaylistCubit>(
        create: (context) {
          final playbackCubit = context.read<PlaybackCubit>();
          return PlaylistCubit(
            onSongRemoved: playbackCubit.onSongRemovedFromPlaylist,
            onPlaylistCleared: playbackCubit.onPlaylistCleared,
          );
        },
        lazy: false,
      ),
      BlocProvider<BottomSheetCubit>(
        create: (context) => BottomSheetCubit(),
        lazy: true,
      ),
      // LiveKit audio cubit provider for audio features across the app
      BlocProvider<LiveKitAudioCubit>(
        create: (context) => sl<LiveKitAudioCubit>(),
      ),
    ];
  }

  // A method to determine TextDirection based on the selected language
  TextDirection _getTextDirection(String languageCode) {
    // Keep everything Left-to-Right regardless of language
    return TextDirection.ltr;
  }
}
