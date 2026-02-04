import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'dart:ui';
import 'package:lklk/core/utils/functions/snackbar_helper.dart';
import 'package:lklk/features/profile_users/presentaion/manger/fetch_elements_cubit/fetch_elements_cubit.dart';
import 'package:lklk/features/room/presentation/manger/gifts/gifts_cubit.dart';
import 'package:lklk/core/constants/app_colors.dart';
import 'package:lklk/features/home/presentation/manger/room_cubit/room_cubit_cubit.dart';
import 'package:lklk/features/profile_users/presentaion/manger/user_cubit/user_cubit_cubit.dart';
import 'package:lklk/generated/l10n.dart';
import 'package:lklk/core/shutdown/app_shutdown.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:lklk/features/home/presentation/manger/rooms_cubit/rooms_cubit.dart';
import 'package:lklk/features/home/presentation/manger/cubit/room_me_cubit.dart';
import 'package:lklk/features/home/presentation/manger/banner_cubit/banner_cubit.dart';
import 'package:lklk/features/chat/presentation/manger/home_message_cubit/home_message_cubit.dart';
import 'package:lklk/features/profile_users/presentaion/manger/friend_cubit/freind_cubit.dart';
import '../../../chat/presentation/views/chat_view.dart';
import 'widgets/home_view_body.dart';
import '../../../profile_users/presentaion/views/pages/user_profile_view.dart';
import 'widgets/home_navigationbar.dart';
import 'package:lklk/core/utils/logger.dart';
import 'package:lklk/core/realtime/notification_realtime_service.dart';
import 'package:lklk/features/home/presentation/manger/alert_cubit/alert_cubit.dart';

class HomeView extends StatefulWidget {
  final UserCubit userCubit;
  final RoomCubit roomCubit;
  final bool isBanned;
  const HomeView({
    super.key,
    required this.userCubit,
    required this.roomCubit,
    this.isBanned = false,
  });

  @override
  State<HomeView> createState() => _HomeViewState();
}

class _HomeViewState extends State<HomeView> {
  int _currentIndex = 2;
  late final GiftCubit _giftCubit;
  late final FetchElementsCubit _fetchElementsCubit;
  late final List<Widget> _screens;
  static DateTime? _lastPrefetchAt;
  static const Duration _prefetchCooldown = Duration(seconds: 45);
  static bool _alertsFetchedThisLaunch = false;

  @override
  void initState() {
    super.initState();
    _giftCubit = GiftCubit();
    _fetchElementsCubit = FetchElementsCubit();
    _screens = [
      UserProfileView(
        userCubit: widget.userCubit,
        roomCubit: widget.roomCubit,
      ),
      ChatView(
        userCubit: widget.userCubit,
        roomCubit: widget.roomCubit,
      ),
      RoomsHome(
        roomCubit: widget.roomCubit,
        userCubit: widget.userCubit,
      ),
    ];
    // Start realtime notifications service (idempotent)
    NotificationRealtimeService.instance.init();

    // Schedule prefetch and baseline alert fetch after first frame
    WidgetsBinding.instance.addPostFrameCallback((_) async {
      // One-time baseline fetch for alerts at app start only
      if (!_alertsFetchedThisLaunch) {
        try {
          await context.read<AlertCubit>().fetchAlerts();
          _alertsFetchedThisLaunch = true;
          debugAppLogger.debug('✅ Baseline alerts fetched at app start');
        } catch (e) {
          debugAppLogger.debug('Baseline alerts fetch error: $e');
        }
      }

      // Small delay to let the navigation/overlay transition settle
      // Avoids competing with route transition and reduces jank
      await Future.delayed(const Duration(milliseconds: 400));
      await _prefetchHomeData();
      // Schedule background downloads after a short delay
      // to give priority to initial UI/rendering and room fetching.
      Future.delayed(const Duration(seconds: 2), () {
        if (!mounted) return;
        if (!kDebugMode) {
        _startDownload();
        }
      });
    });
  }

  Future<void> _prefetchHomeData() async {
    try {
      final now = DateTime.now();
      if (_lastPrefetchAt != null &&
          now.difference(_lastPrefetchAt!) < _prefetchCooldown) {
        debugAppLogger.debug('⏭️ Home prefetch skipped (cooldown active)');
        return;
      }
      _lastPrefetchAt = now;

      debugAppLogger.debug('🚀 Home prefetch start');

      // Step 1: RoomsHome data (popular rooms, my rooms, banners)
      try {
        final roomsCubit = context.read<RoomsCubit>();
        await roomsCubit.fetchRooms(1, 'HomeViewPrefetch');
      } catch (e) {
        debugAppLogger.debug('Rooms prefetch error: $e');
      }

      final roomMeCubit = RoomMeCubit();
      final bannerCubit = BannerCubit();
      try {
        await roomMeCubit.fetchRoomsMe();
      } catch (e) {
        debugAppLogger.debug('RoomMe prefetch error: $e');
      }
      try {
        await bannerCubit.fetchBanners(forceRefresh: true);
      } catch (e) {
        debugAppLogger.debug('Banners prefetch error: $e');
      }

      // Step 2: User profile (full fetch to refresh caches)
      try {
        await widget.userCubit.getProfileUser('HomeViewPrefetch');
      } catch (e) {
        debugAppLogger.debug('Profile prefetch error: $e');
      }

      // Step 3: ChatView data (home messages, friends, visitors)
      final homeMessageCubit = HomeMessageCubit();
      final freindCubit = FreindCubit();
      try {
        await homeMessageCubit.fetchLastMessages();
      } catch (e) {
        debugAppLogger.debug('Home messages prefetch error: $e');
      }
      try {
        await freindCubit.getFriendsList();
      } catch (e) {
        debugAppLogger.debug('Friends prefetch error: $e');
      }
      try {
        await freindCubit.getListOfVisitorProfiles();
      } catch (e) {
        debugAppLogger.debug('Visitors prefetch error: $e');
      }

      // Close locally created cubits
      try {
        await roomMeCubit.close();
      } catch (_) {}
      try {
        await bannerCubit.close();
      } catch (_) {}
      try {
        await homeMessageCubit.close();
      } catch (_) {}
      try {
        await freindCubit.close();
      } catch (_) {}

      debugAppLogger.debug('✅ Home prefetch completed');
    } catch (e) {
      debugAppLogger.debug('Home prefetch fatal error: $e');
    }
  }

  Future<void> _startDownload() async {
    try {
      debugAppLogger.debug('_startDownload ........' );
      _fetchElementsCubit.fetchStoreElements(download: true);
      _giftCubit.fetchGiftsElements(download: true);
    } catch (e) {
      debugAppLogger.debug('Error during download: $e');
    }
  }

  @override
  void dispose() {
    // Close locally created cubits to avoid leaks
    try {
      _giftCubit.close();
    } catch (_) {}
    try {
      _fetchElementsCubit.close();
    } catch (_) {}
    super.dispose();
  }

  void printScreenInformation(BuildContext context) {
    final mediaQuery = MediaQuery.of(context);
    log('Width: ${mediaQuery.size.width}, Height: ${mediaQuery.size.height}');
  }

  @override
  Widget build(BuildContext context) {
    if (widget.isBanned) {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        SnackbarHelper.showMessage(
          context,
          S.of(context).youAreBannedFromEnterThisRoom,
        );
      });
    }
    if (kDebugMode) {
      printScreenInformation(context);
    }
    return WillPopScope(
      onWillPop: _onWillPop,
      child: SafeArea(
        top: false,
        child: Scaffold(
          backgroundColor: AppColors.whitewhite,
          extendBodyBehindAppBar: true,
          body: IndexedStack(
            index: _currentIndex,
            children: _screens,
          ),
          bottomNavigationBar: SafeArea(
            top: false,
            child: HomeBottomNavigationBar(
              currentIndex: _currentIndex,
              onTap: (index) => setState(() => _currentIndex = index),
            ),
          ),
        ),
      ),
    );
  }

  Future<bool> _onWillPop() async {
    final confirmed = await showDialog<bool>(
      context: context,
      barrierDismissible: true,
      barrierColor: Colors.black54,
      builder: (ctx) {
        return Center(
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 24.0),
            child: ClipRRect(
              borderRadius: BorderRadius.circular(20),
              child: BackdropFilter(
                filter: ImageFilter.blur(sigmaX: 16, sigmaY: 16),
                child: Container(
                  width: double.infinity,
                  decoration: BoxDecoration(
                    color: Colors.white.withValues(alpha: 0.08),
                    borderRadius: BorderRadius.circular(20),
                    border: Border.all(color: Colors.white24, width: 1),
                    boxShadow: const [
                      BoxShadow(
                          color: Colors.black26,
                          blurRadius: 24,
                          spreadRadius: 2),
                    ],
                  ),
                  child: Padding(
                    padding: const EdgeInsets.all(16.0),
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      crossAxisAlignment: CrossAxisAlignment.center,
                      children: [
                        const SizedBox(height: 8),
                        Icon(Icons.exit_to_app_rounded,
                            color: AppColors.golden, size: 36),
                        const SizedBox(height: 12),
                        const Text(
                          'هل تريد إغلاق التطبيق؟',
                          textAlign: TextAlign.center,
                          style: TextStyle(
                            color: Colors.white,
                            fontSize: 18,
                            fontWeight: FontWeight.w800,
                          ),
                        ),
                        const SizedBox(height: 8),
                        Text(
                          'سيتم إيقاف جميع الخدمات في الخلفية قبل الإغلاق.',
                          textAlign: TextAlign.center,
                          style: TextStyle(
                              color: Colors.white.withValues(alpha: 0.85)),
                        ),
                        const SizedBox(height: 20),
                        Row(
                          children: [
                            Expanded(
                              child: OutlinedButton(
                                style: OutlinedButton.styleFrom(
                                  side: const BorderSide(color: Colors.white24),
                                  foregroundColor: Colors.white,
                                  backgroundColor:
                                      Colors.white.withValues(alpha: 0.05),
                                  shape: RoundedRectangleBorder(
                                      borderRadius: BorderRadius.circular(14)),
                                ),
                                onPressed: () => Navigator.of(ctx).pop(false),
                                child: const Text('البقاء'),
                              ),
                            ),
                            const SizedBox(width: 12),
                            Expanded(
                              child: FilledButton(
                                style: FilledButton.styleFrom(
                                  backgroundColor: AppColors.danger,
                                  shape: RoundedRectangleBorder(
                                      borderRadius: BorderRadius.circular(14)),
                                  padding:
                                      const EdgeInsets.symmetric(vertical: 14),
                                ),
                                onPressed: () => Navigator.of(ctx).pop(true),
                                child: const Text('إغلاق التطبيق'),
                              ),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                ),
              ),
            ),
          ),
        );
      },
    );

    if (confirmed == true) {
      await AppShutdown.exitApp(context);
      return false;
    }
    return false;
  }
}

// class PersistentCallBar extends StatelessWidget {
//   const PersistentCallBar({super.key});

//   @override
//   Widget build(BuildContext context) {
//     return BlocBuilder<CallCubit, CallState>(
//       builder: (context, state) {
//         if (!state.isInCall) return const SizedBox.shrink();
//         return DraggableCard(
//           child: AnimatedContainer(
//             duration: const Duration(milliseconds: 50),
//             curve: Curves.fastLinearToSlowEaseIn,
//             height: 80,
//             width: 180,
//             decoration: const BoxDecoration(
//               color: AppColors.black,
//               borderRadius: BorderRadius.all(
//                 Radius.circular(5),
//               ),
//             ),
//             child: Row(
//               mainAxisAlignment: MainAxisAlignment.spaceBetween,
//               children: [
//                 state.roomImg != null
//                     ? Image.network(
//                         state.roomImg!.contains('https://lklklive.com/img/')
//                             ? state.roomImg!
//                             : 'https://lklklive.com/img/${state.roomImg}',
//                         fit: BoxFit.cover,
//                         height: 80,
//                         width: 66,
//                       )
//                     : const SizedBox(),
//                 IconButton(
//                   icon: Icon(
//                     state.isMuted ? Icons.mic_off : Icons.mic,
//                     color: Colors.white,
//                   ),
//                   onPressed: () => context.read<CallCubit>().toggleMute(),
//                 ),
//                 IconButton(
//                   icon: const Icon(Icons.call_end, color: const Color(0xFFFF0000)),
//                   onPressed: () => context.read<CallCubit>().endCall(),
//                 ),
//               ],
//             ),
//           ),
//         );
//       },
//     );
//   }
// }

// void _showDownloadNotification() {
//   AwesomeNotifications().createNotification(
//     content: NotificationContent(
//       id: 1,
//       channelKey: 'download_channel',
//       title: 'Download Complete',
//       body: 'All necessary files have been downloaded.',
//       notificationLayout: NotificationLayout.ProgressBar,
//     ),
//   );
// }

// Future<void> _checkDownloadPreference() async {
//   final prefs = await SharedPreferences.getInstance();
//   final hasShownDialog = prefs.getBool('hasShownDownloadDialog') ?? false;

//   if (!hasShownDialog) {
//     _startDownload();
//   }
// }

// Future<void> _showDownloadDialog() async {
//   final connectivity = await Connectivity().checkConnectivity();
//   final isWifi = connectivity == ConnectivityResult.wifi;

//   final result = await showDialog<String>(
//     context: context,
//     builder: (context) => AlertDialog(
//       title: const AutoSizeText("Download Data"),
//       content: AutoSizeText(
//         isWifi
//             ? "Downloading on Wi-Fi is recommended. Proceed?"
//             : "You're on mobile data. Continue downloading?",
//       ),
//       actions: [
//         TextButton(
//           onPressed: () => Navigator.pop(context, 'later'),
//           child: const AutoSizeText("Remind Me Later"),
//         ),
//         TextButton(
//           onPressed: () => Navigator.pop(context, 'never'),
//           child: const AutoSizeText("Don't Ask Again"),
//         ),
//         TextButton(
//           onPressed: () => Navigator.pop(context, 'download'),
//           child: const AutoSizeText("Download Now"),
//         ),
//       ],
//     ),
//   );

//   final prefs = await SharedPreferences.getInstance();
//   if (result == 'download') {
//     prefs.setBool('hasShownDownloadDialog', true);
//     _startDownload();
//   } else if (result == 'never') {
//     prefs.setBool('hasShownDownloadDialog', true);
//   }
// }
