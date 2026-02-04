import 'package:lklk/core/utils/logger.dart';
import 'dart:convert';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:lklk/features/weekly_star_event/view/weekly_star_event_view.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:country_flags/country_flags.dart';
import 'package:dynamic_tabbar/dynamic_tabbar.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:auto_size_text/auto_size_text.dart';
import 'package:lklk/core/constants/app_colors.dart';
import 'package:lklk/core/utils/custom_fading_widget.dart';
import 'package:lklk/core/widgets/best50_icon.dart';
import 'package:lklk/core/widgets/create_room_icon.dart';
import 'package:lklk/core/widgets/search_icon_button.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:lklk/features/home/presentation/manger/banner_cubit/banner_cubit.dart';
import 'package:lklk/features/home/presentation/manger/banner_cubit/banner_state.dart';
import 'package:lklk/features/home/presentation/manger/cubit/room_me_cubit.dart';
import 'package:lklk/features/home/presentation/manger/room_manager.dart';
import 'package:lklk/features/home/presentation/manger/rooms_cubit/rooms_cubit.dart';
import 'package:lklk/features/home/presentation/views/slide_view/top_relation_page.dart';
import 'package:lklk/features/invitations/presentation/views/invitation_center_page.dart';
import 'package:lklk/features/profile_users/presentaion/manger/user_cubit/user_cubit_cubit.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:lklk/features/home/presentation/manger/room_cubit/room_cubit_cubit.dart';
import 'package:lklk/features/profile_users/presentaion/views/widgets/empty_screen.dart';
import 'package:lklk/features/profile_users/presentaion/views/widgets/post_chargers_page.dart';
import 'package:lklk/features/room/domain/entities/room_entity.dart';
import 'package:lklk/features/room/presentation/views/widgets/room_view_bloc.dart';
import 'package:lklk/features/room/presentation/views/widgets/flages_countrys.dart';
import 'package:lklk/generated/l10n.dart';
import 'package:lklk/features/tasks/presentation/views/tasks_page.dart';
import 'package:skeletonizer/skeletonizer.dart';
import 'package:url_launcher/url_launcher.dart';
import 'room_item_widget_titles_container.dart';
import 'package:lklk/core/constants/assets.dart';
import 'image_slideshow_widget.dart';
import 'top_six_rooms_widget.dart';
import 'top_buttons/top_buttons_section.dart';
import 'package:lklk/features/wakala_challenge/presentation/views/wakala_challenge_page.dart';
import 'package:lklk/features/cp_challenge/presentation/views/cp_challenge_page.dart';

class RoomsHomeViewBodyWidget extends StatefulWidget {
  const RoomsHomeViewBodyWidget({
    super.key,
    required this.roomCubit,
    required this.userCubit,
    required this.roomMeCubit,
  });

  final RoomCubit roomCubit;
  final UserCubit userCubit;
  final RoomMeCubit roomMeCubit;

  @override
  State<RoomsHomeViewBodyWidget> createState() =>
      _RoomsHomeViewBodyWidgetState();
}

class _RoomsHomeViewBodyWidgetState extends State<RoomsHomeViewBodyWidget>
    with SingleTickerProviderStateMixin, WidgetsBindingObserver {
  int _currentPage = 1;
  bool _isLoading = false;
  bool _isRefreshing = false;
  final ScrollController _scrollController = ScrollController();
  final ScrollController _scrollControllerME = ScrollController();
  late TabController _tabController;
  String? selectedCountry = 'null';
  final RoomManager roomManager = RoomManager();
  double _overscrollAccumulated = 0.0;
  final double _overlayTriggerDistance = 70.0;
  bool _showRefreshOverlay = false;
  final Set<String> _precachedBannerUrls = <String>{};
  List<String> _initialBannerUrls = <String>[];

  // حمايات لمنع تكرار الطلبات بدون تفاعل المستخدم
  bool _userDragging = false;
  int _lastTabIndex = 1;
  DateTime _lastRefreshAt = DateTime.fromMillisecondsSinceEpoch(0);
  static const Duration _refreshCooldown = Duration(seconds: 8);

  // BannerCubit ثابت لتجنّب إعادة الإنشاء عند فتح الشاشة مجدداً
  static final BannerCubit _bannerCubit = BannerCubit();
  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    if (state == AppLifecycleState.resumed && _canRefreshNow()) {
      _refreshData();
    }
  }

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addObserver(this);
    // اطلب البيانات (سيعرض الكاش فوراً إن كان متاحاً ثم يُحدّث لاحقاً)
    _bannerCubit.fetchBanners();
    _loadInitialBannersFromPrefs();
    // تحميل البيانات المخزنة محلياً أولاً
    _loadCachedData();

    // ثم تحميل البيانات من الخادم
    _fetchFirstPage();

    _scrollController.addListener(_scrollListener);
    _tabController = TabController(
      length: 2,
      vsync: this,
      initialIndex: 1,
    );
  }

  void _loadCachedData() async {
    // هنا يمكنك إضافة كود لتحميل البيانات من التخزين المحلي
  }

  Future<void> _loadInitialBannersFromPrefs() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final raw = prefs.getString('cachedBanners');
      if (raw == null || raw.isEmpty) return;
      final List<dynamic> decoded = jsonDecode(raw);
      final urls = decoded
          .map((e) => (e as Map<String, dynamic>)['img'])
          .whereType<String>()
          .where((u) => u.startsWith('https'))
          .toList();
      if (urls.isNotEmpty) {
        // precache early to ensure instant first frame
        await _precacheBannerImages(urls);
        if (mounted) {
          setState(() {
            _initialBannerUrls = urls;
          });
        }
      }
    } catch (_) {}
  }

  Future<void> _precacheBannerImages(List<String> urls) async {
    // Limit total to avoid decode storm
    const int maxPrefetch = 4;
    const int batchSize = 2;
    if (urls.isEmpty) return;
    int i = 0;
    // compute target decode size based on banner slot (~100px height)
    final dpr = MediaQuery.of(context).devicePixelRatio;
    final double logicalW = MediaQuery.of(context).size.width;
    final int targetW = (logicalW * dpr).clamp(256, 1024).round();
    final int targetH = (100 * dpr).clamp(128, 512).round();
    while (i < urls.length && i < maxPrefetch) {
      final int end =
          (i + batchSize) < urls.length ? (i + batchSize) : urls.length;
      final slice = urls.sublist(i, end);
      await Future.wait(slice.map((url) async {
        if (_precachedBannerUrls.contains(url)) return;
        _precachedBannerUrls.add(url);
        try {
          final provider = ResizeImage(CachedNetworkImageProvider(url),
              width: targetW, height: targetH);
          await precacheImage(provider, context);
        } catch (_) {}
      }));
      // yield to next frame
      await Future.delayed(const Duration(milliseconds: 16));
      i = end;
    }
  }

  void _cacheData(List<RoomEntity> rooms) async {
    // هنا يمكنك إضافة كود لحفظ البيانات في التخزين المحلي
  }

  bool _canRefreshNow() {
    final now = DateTime.now();
    if (now.difference(_lastRefreshAt) < _refreshCooldown) return false;
    _lastRefreshAt = now;
    return true;
  }

  void _fetchFirstPage() {
    _fetchNextPage(1, isRefresh: true);

    // استخدام widget.roomMeCubit مباشرة بدلاً من context.read
    if (widget.roomMeCubit.state.roomsMe == null) {
      widget.roomMeCubit.fetchRoomsMe();
    }
  }

  void _fetchCountryRooms(String countryCode) {
    setState(() {
      _isLoading = true;
      roomManager.roomsCountry.clear();
    });
    context.read<RoomsCubit>().fetchCountryRooms(1, countryCode).then((rooms) {
      setState(() {
        _isLoading = false;
        roomManager.roomsCountry.addAll(rooms.cast<RoomEntity>());
      });
    }).catchError((e) {
      setState(() {
        _isLoading = false;
      });
    });
  }

  void _fetchNextPage(int pageKey, {bool isRefresh = false}) {
    if (mounted && !_isLoading) {
      setState(() {
        // لتفادي الوميض: لا نُظهر حالة التحميل أثناء التحديث إذا كان لدينا عناصر معروضة
        if (!isRefresh || roomManager.allRooms.isEmpty) {
          _isLoading = true;
        }
        if (isRefresh) _isRefreshing = true;
      });
      context
          .read<RoomsCubit>()
          .fetchRooms(pageKey, "RoomsHomeViewBodyWidget _fetchNextPage ")
          .then((rooms) {
        if (mounted) {
          setState(() {
            _isLoading = false;
            _isRefreshing = false;
            final newRooms =
                rooms.where((room) => room != null).cast<RoomEntity>().toList();

            if (isRefresh) {
              roomManager.allRooms.clear();
              roomManager.allRooms.addAll(newRooms);
              _cacheData(newRooms);
              _showRefreshOverlay = false;
            } else {
              final existingIds = roomManager.allRooms.map((r) => r.id).toSet();
              for (final room in newRooms) {
                if (existingIds.add(room.id)) {
                  roomManager.allRooms.add(room);
                }
              }
            }
          });
        }
      }).catchError((e) {
        if (mounted) {
          setState(() {
            _isLoading = false;
            _isRefreshing = false;
            if (isRefresh) {
              _showRefreshOverlay = false;
            }
          });
        }
      });
    }
  }

  void _refreshData() {
    _currentPage = 1;
    _fetchNextPage(_currentPage, isRefresh: true);

    // تحديث بيانات الغرف الخاصة بالمستخدم أيضاً
    widget.roomMeCubit.fetchRoomsMe();

    // لا نقوم بتحديث البانر هنا للحفاظ عليه من إعادة التحميل
  }

  void _scrollListener() {
    // لا نحمل صفحات إضافية إلا عند سحب المستخدم فعلياً
    if (!_userDragging) return;

    var currentPositions = _scrollController.position.pixels;
    var maxScrollLength = _scrollController.position.maxScrollExtent;

    if (maxScrollLength <= 0) {
      return; // حماية في حال عدم وجود محتوى قابل للتمرير
    }

    double triggerFraction;
    if (_currentPage <= 3) {
      triggerFraction = 1 / 2.5;
    } else if (_currentPage == 4) {
      triggerFraction = 0.5;
    } else if (_currentPage < 10) {
      triggerFraction = 0.9;
    } else {
      return;
    }

    if (currentPositions >= maxScrollLength * triggerFraction && !_isLoading) {
      _currentPage++;
      _fetchNextPage(_currentPage);
    }
  }

  @override
  void dispose() {
    _scrollController.removeListener(_scrollListener);
    _scrollController.dispose();
    _scrollControllerME.dispose();
    if (mounted) _tabController.dispose();
    WidgetsBinding.instance.removeObserver(this);
    super.dispose();
  }

  Widget _buildRoomsContent(
    List<RoomEntity>? rooms,
    double heightImages,
    double width,
  ) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 15),
      child: Stack(
        children: [
          NotificationListener<ScrollNotification>(
            onNotification: (notification) {
              // unify drag start/end and overscroll handling to reduce listeners
              if (notification is ScrollStartNotification &&
                  notification.dragDetails != null) {
                _userDragging = true;
              } else if (notification is OverscrollNotification &&
                  notification.metrics.pixels <= 0) {
                _overscrollAccumulated += notification.overscroll.abs();
                if (_overscrollAccumulated >= _overlayTriggerDistance &&
                    !_isRefreshing) {
                  _overscrollAccumulated = 0;
                  _startOverlayRefresh();
                }
              } else if (notification is ScrollEndNotification) {
                if (_userDragging &&
                    _scrollController.position.pixels == 0 &&
                    _canRefreshNow()) {
                  _refreshData();
                }
                _userDragging = false;
                _overscrollAccumulated = 0;
              }
              return false;
            },
            child: CustomScrollView(
              controller: _scrollController,
              cacheExtent: 600,
              slivers: [
                // ✅ ثابت لا يعاد بناؤه
                SliverToBoxAdapter(
                  child: _slideSection(heightImages, width),
                ),

                // ✅ قسم أفضل 6 غرف - يظهر فقط عند الكل (بدون فلترة دولة)
                SliverToBoxAdapter(
                  child: BlocBuilder<RoomsCubit, RoomsState>(
                    buildWhen: (p, c) => p.rooms != c.rooms,
                    builder: (context, state) {
                      if (selectedCountry != 'null') {
                        return const SizedBox.shrink();
                      }
                      final List<RoomEntity> list = state.rooms ?? [];
                      if (list.isEmpty) return const SizedBox.shrink();
                      final topRooms = list.take(6).toList();
                      if (topRooms.isEmpty) return const SizedBox.shrink();
                      return RepaintBoundary(
                        child: Padding(
                          padding: const EdgeInsets.only(bottom: 10, top: 10),
                          child: TopSixRoomsWidget(
                            rooms: topRooms,
                            roomCubit: widget.roomCubit,
                            userCubit: widget.userCubit,
                          ),
                        ),
                      );
                    },
                  ),
                ),

                // ✅ قائمة البلدان (مخفية الآن لأن اختيار الدولة سيتم من الأيقونة في AppBar)
                const SliverToBoxAdapter(child: SizedBox.shrink()),

                // ✅ قسم أزرار Top (Wealth, Attraction, Room, Relation)

                SliverToBoxAdapter(
                  child: RepaintBoundary(
                    child: TopButtonsSection(userCubit: widget.userCubit),
                  ),
                )
,

                // 👇 هذا الجزء فقط يتغير
                roomsSection(),
              ],
            ),
          ),
          if (_showRefreshOverlay)
            Positioned(
              top: 240,
              left: 0,
              right: 0,
              child: SizedBox(
                height: 40,
                width: 40,
                child: DecoratedBox(
                  decoration: const BoxDecoration(
                    shape: BoxShape.circle,
                    color: AppColors.white,
                  ),
                  child: Center(
                    child: SizedBox(
                      width: 20,
                      height: 20,
                      child: CircularProgressIndicator(
                        strokeWidth: 3,
                        color: AppColors.black,
                      ),
                    ),
                  ),
                ),
              ),
            ),
        ],
      ),
    );
  }

// Add this method to start the refresh with overlay
  void _startOverlayRefresh() {
    setState(() {
      _showRefreshOverlay = true;
      _isRefreshing = true;
    });

    // Start the refresh process
    _refreshData();

    // Hide overlay after a delay (or when refresh completes)
    Future.delayed(const Duration(seconds: 2), () {
      if (mounted) {
        setState(() {
          _showRefreshOverlay = false;
        });
      }
    });
  }

  Widget buildHorizontalCountryList() {
    const List<String> countryCodes = [
      'null',
      'sy',
      'eg',
      'sa',
      'jo',
      'ae',
      'dz',
      'bh',
      'dj',
      'iq',
      'kw',
      'lb',
      'ly',
      'ma',
      'mr',
      'om',
      'ps',
      'qa',
      'sd',
      'tn',
      'ye',
      'lk',
      'in',
      'bd',
      'np',
      'pk',
    ];

    List<String> countryNames = [
      S.of(context).all,
      S.of(context).syria,
      S.of(context).egypt,
      S.of(context).saudi_arabia,
      S.of(context).jordan,
      S.of(context).united_arab_emirates,
      S.of(context).algeria,
      S.of(context).bahrain,
      S.of(context).djibouti,
      S.of(context).iraq,
      S.of(context).kuwait,
      S.of(context).lebanon,
      S.of(context).libya,
      S.of(context).morocco,
      S.of(context).mauritania,
      S.of(context).oman,
      S.of(context).palestine,
      S.of(context).qatar,
      S.of(context).sudan,
      S.of(context).tunisia,
      S.of(context).yemen,
      S.of(context).sri_lanka,
      S.of(context).india,
      S.of(context).bangladesh,
      S.of(context).nepal,
      S.of(context).pakistan,
    ];

    final List<Map<String, String>> sortedCountries = List.generate(
      countryCodes.length,
      (index) => {
        'code': countryCodes[index],
        'name': countryNames[index],
      },
    );

    return SliverToBoxAdapter(
      child: _CountrySelectorWidget(
        selectedCountry: selectedCountry,
        countries: sortedCountries,
        onCountrySelected: (String? countryCode) {
          setState(() {
            selectedCountry = countryCode;
          });
          if (countryCode == "null") {
            _fetchFirstPage();
          } else {
            _fetchCountryRooms(countryCode!);
          }
        },
      ),
    );
  }

  // Remove the incorrect override
  SliverMultiBoxAdaptorWidget roomsSection() {
    // Cache values to avoid repeated lookups
    final String? currentCountry = selectedCountry;
    
    // Use context.select to only rebuild when necessary data changes
    final List<RoomEntity> baseRooms = currentCountry == 'null'
        ? roomManager.allRooms
        : roomManager.roomsCountry;

    // Calculate offset - skip first 6 rooms in "All" tab as they're shown in the top section
    final int offset = currentCountry == 'null' && baseRooms.length > 6 ? 6 : 0;
    // Cache the visible rooms to avoid repeated sublist operations
    final List<RoomEntity> visibleRooms = offset < baseRooms.length 
        ? baseRooms.sublist(offset) 
        : <RoomEntity>[];

    // Calculate item count once
    final bool showLoadingIndicator = _isLoading;
    final int itemCount = visibleRooms.isEmpty
        ? (showLoadingIndicator ? 6 : 0)
        : visibleRooms.length + (showLoadingIndicator ? 1 : 0);

    // عند "الكل": نعرض بقية الغرف كشكل مستطيل (مثل تبويب Me) باستخدام SliverList
    // Use const constructors and extract widget for better performance
    if (currentCountry == 'null') {
      return SliverList(
        delegate: SliverChildBuilderDelegate(
          (context, index) {
            if (visibleRooms.isEmpty) {
              return _isLoading
                  ? loadingRoomWidget(index)
                  : (index == 0
                      ? Center(
                          child: Image.asset(
                            AssetsData.logoWhite,
                            color: Colors.grey.withValues(alpha: .5),
                            width: 200,
                            height: 200,
                          ),
                        )
                      : const SizedBox.shrink());
            }

            if (index >= visibleRooms.length) {
              return loadingRoomWidget(index);
            }

            final room = visibleRooms[index];
            return Padding(
              padding: const EdgeInsets.only(bottom: 10),
              child: RoomItemWidgetTitlesContainer(
                key: ValueKey(room.id),
                isList: true,
                roomCubit: widget.roomCubit,
                room: room,
                userCubit: widget.userCubit,
              ),
            );
          },
          childCount: itemCount,
          addAutomaticKeepAlives: false,
          addRepaintBoundaries: true,
          addSemanticIndexes: false,
          findChildIndexCallback: (Key key) {
            if (key is ValueKey<int>) {
              final int id = key.value;
              return visibleRooms.indexWhere((r) => r.id == id);
            }
            return null;
          },
        ),
      );
    }

    // عند تبويب دولة محددة: نبقي عرض الشبكة المربعة كما هو مع فهرسة مستقرة للعناصر
    // Use SliverGrid.builder for better performance with large lists
        return SliverGrid(
      gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: 2,
        crossAxisSpacing: 10,
        mainAxisSpacing: 10,
        childAspectRatio: 0.8,
      ),
      // استخدم Delegate لتفعيل خصائص الفهرسة وتقليل إعادة البناء
      delegate: SliverChildBuilderDelegate(
        (context, index) {
          if (visibleRooms.isEmpty) {
            return _isLoading
                ? loadingRoomWidget(index)
                : (index == 0
                    ? Center(
                        child: Image.asset(
                          AssetsData.logoWhite,
                          color: Colors.grey.withValues(alpha: .5),
                          width: 200,
                          height: 200,
                        ),
                      )
                    : const SizedBox.shrink());
          }
    
          if (index >= visibleRooms.length) {
            return loadingRoomWidget(index);
          }
    
          final room = visibleRooms[index];
          return Padding(
            padding: const EdgeInsets.symmetric(vertical: 4.0),
            child: RoomItemWidgetTitlesContainer(
              key: ValueKey(room.id),
              roomCubit: widget.roomCubit,
              room: room,
              userCubit: widget.userCubit,
              isList: false,
            ),
          );
        },
        childCount: itemCount,
        addAutomaticKeepAlives: false,
        addRepaintBoundaries: true,
        addSemanticIndexes: false,
        findChildIndexCallback: (Key key) {
          if (key is ValueKey<int>) {
            final int id = key.value;
            return visibleRooms.indexWhere((r) => r.id == id);
          }
          return null;
        },
      ),
    );
  }

Widget loadingRoomWidget(int index) {
  // هيكل خفيف بدون صور شبكة لتقليل الكلفة أثناء التحميل
  final bool isAllTab = selectedCountry == 'null';
  return Padding(
    padding: EdgeInsets.symmetric(vertical: isAllTab ? 8.0 : 4.0),
    child: isAllTab ? _buildListSkeletonItem() : _buildGridSkeletonItem(),
  );
}




  Widget _buildListSkeletonItem() {
    // عنصر هيكلي خفيف لقائمة "الكل" بدون صور لتقليل الكلفة أثناء التحميل
    return SizedBox(
      height: 100,
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          const SizedBox(width: 30),
          ClipRRect(
            borderRadius: BorderRadius.circular(18),
            child: Container(width: 72, height: 72, color: Colors.black12),
          ),
          const SizedBox(width: 10),
          Expanded(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: const [
                SizedBox(height: 14, child: ColoredBox(color: Colors.black12)),
                SizedBox(height: 8),
                SizedBox(width: 120, height: 12, child: ColoredBox(color: Colors.black12)),
              ],
            ),
          ),
          const SizedBox(width: 10),
          Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: const [
              SizedBox(width: 60, height: 16, child: ColoredBox(color: Colors.black12)),
              SizedBox(height: 8),
              SizedBox(width: 40, height: 12, child: ColoredBox(color: Colors.black12)),
            ],
          ),
          const SizedBox(width: 10),
        ],
      ),
    );
  }
  Widget _buildGridSkeletonItem() {
    return AspectRatio(
      aspectRatio: 1,
      child: ClipRRect(
        borderRadius: BorderRadius.circular(6),
        child: Container(
          color: Colors.black12,
          child: Stack(
            children: const [
              Positioned(
                left: 8,
                right: 8,
                bottom: 8,
                child: Row(
                  children: [
                    SizedBox(width: 60, height: 12, child: ColoredBox(color: Colors.black26)),
                    Spacer(),
                    SizedBox(width: 30, height: 12, child: ColoredBox(color: Colors.black26)),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final double width = MediaQuery.of(context).size.width;
    const double hightImages = 80;

    final double statusBarH = MediaQuery.of(context).padding.top;
    const double toolbarH = kToolbarHeight; // 56.0 by default

    return Stack(
      children: [
        // Top gradient only covering status bar + toolbar
        Positioned(
          top: 0,
          left: 0,
          right: 0,
          child: Container(
            height: statusBarH + toolbarH,
            // decoration: const BoxDecoration(
            //   gradient: LinearGradient(
            //     begin: Alignment.topCenter,
            //     end: Alignment.bottomCenter,
            //     colors: [
            //       Color(0xFF6D2EC2), // بنفسجي فاتح
            //       Color(0xFFB50189), // وردي
            //     ],
            //   ),
            // ),
            // ensure status bar background is transparent so our gradient shows
            // and use light icons for contrast
            child: AnnotatedRegion<SystemUiOverlayStyle>(
              value: const SystemUiOverlayStyle(
                statusBarColor: Colors.transparent,
                statusBarIconBrightness: Brightness.light,
                statusBarBrightness: Brightness.dark,
                systemNavigationBarColor: Colors.transparent,
              ),
              child: const SizedBox.shrink(),
            ),
          ),
        ),

        // The tab bar sits above the rest of the page; keep its behavior
        // unchanged but allow the gradient behind to show at the top.
        DynamicTabBarWidget(
            automaticIndicatorColorAdjustment: false,
            unselectedLabelColor: AppColors.black,
            unselectedLabelStyle: const TextStyle(),
            dividerHeight: 0,
            dividerColor: AppColors.transparent,
            leading: _buildLeadingIcons(),
            dynamicTabs: _buildTabs(hightImages, width),
            isScrollable: false,
            labelColor: AppColors.black,
            indicator: const BoxDecoration(
              border: Border(
                bottom: BorderSide(
                  color: AppColors.black,
                  width: 2,
                ),
              ),
            ),
            onTabControllerUpdated: (controller) {},
            onTabChanged: (index) {
              final int? i = index; // قد يكون null حسب الـ widget
              if (i != null &&
                  i == 1 &&
                  _lastTabIndex != i &&
                  _canRefreshNow()) {
                _refreshData();
              }
              if (i != null) {
                _lastTabIndex = i;
              }
            },
            onAddTabMoveTo: MoveToTab.last,
            showBackIcon: true,
            showNextIcon: true,
          ),
      ],
    );
  }

  Widget _buildLeadingIcons() {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        SearchIconButton(
          userCubit: widget.userCubit,
          roomCubit: widget.roomCubit,
        ),
        CreateRoomIcon(
          roomCubit: widget.roomCubit,
          userCubit: widget.userCubit,
        ),
        Best50Icon(userCubit: widget.userCubit),
        // زر اختيار الدولة من خلال حوار CountryFlagPicker
        IconButton(
          tooltip: 'Country filter',
          iconSize: 22,
          onPressed: () async {
            final code = await showDialog<String>(
              context: context,
              builder: (context) => CountryFlagPicker(
                initiallySelectedCode: selectedCountry,
              ),
            );
            if (!mounted || code == null) return;
            setState(() {
              selectedCountry = code;
            });
            if (code == 'null') {
              _fetchFirstPage();
            } else {
              _fetchCountryRooms(code);
            }
          },
          icon: SvgPicture.asset(
            'assets/icons/falg_icon.svg',
            width: 22,
            height: 22,
            colorFilter: const ColorFilter.mode(
              Colors.black,
              BlendMode.srcIn,
            ),
          ),
        ),
        const SizedBox(
          width: 25,
        )
      ],
    );
  }

  List<TabData> _buildTabs(double hightImages, double width) {
    return [
      TabData(
        index: 0,
        title: Tab(
          child: SizedBox(
            child: AutoSizeText(
              S.of(context).me,
              style: const TextStyle(color: Colors.black),
              maxLines: 1,
            ),
          ),
        ),
        content: ColoredBox(
            color: Colors.white, child: _buildMeRoomsPage(hightImages, width)),
      ),
      TabData(
        index: 1,
        title: Tab(
          child: AutoSizeText(
            S.of(context).popular,
            maxLines: 1,
            style: const TextStyle(color: Colors.black),
          ),
        ),
        content: ColoredBox(
            color: Colors.white,
            child: _buildPopularRoomsPage(hightImages, width)),
      ),
    ];
  }

  BlocBuilder<RoomsCubit, RoomsState> _buildPopularRoomsPage(
      double hightImages, double width) {
    return BlocBuilder<RoomsCubit, RoomsState>(
      buildWhen: (prev, curr) =>
          prev.rooms != curr.rooms || prev.roomsCountry != curr.roomsCountry,
      builder: (context, state) {
        // تم نقل الاستماع للتمرير إلى _buildRoomsContent لتقليل المستمعين
        return _buildRoomsContent(
            selectedCountry == 'null' ? state.rooms : state.roomsCountry,
            hightImages,
            width);
      },
    );
  }

  Widget _buildMeRoomsPage(double hightImages, double width) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 15),
      child: CustomScrollView(
        controller: _scrollControllerME,
        cacheExtent: 600,
        slivers: [
          // القسم الثابت
          SliverToBoxAdapter(
            child: _slideSection(hightImages, width),
          ),
          const SliverToBoxAdapter(
            child: SizedBox(height: 10),
          ),

          // القسم المتغير (BlocBuilder على الغرف فقط)
          BlocBuilder<RoomMeCubit, RoomMeState>(
            bloc: widget.roomMeCubit,
            buildWhen: (prev, curr) => prev.roomsMe != curr.roomsMe,
            builder: (context, state) {
              if (state.roomsMe != null) {
                final roomsM = state.roomsMe!;

                if (roomsM.isNotEmpty) {
                  return SliverList(
                    delegate: SliverChildBuilderDelegate(
                      (context, index) => Padding(
                        padding: const EdgeInsets.only(bottom: 10),
                        child: RoomItemWidgetTitlesContainer(
                          key: ValueKey(roomsM[index].id),
                          isList: true,
                          roomCubit: widget.roomCubit,
                          room: roomsM[index],
                          userCubit: widget.userCubit,
                        ),
                      ),
                      childCount: roomsM.length,
                      addAutomaticKeepAlives: false,
                      addRepaintBoundaries: true,
                      addSemanticIndexes: false,
                      findChildIndexCallback: (Key key) {
                        if (key is ValueKey<int>) {
                          final id = key.value;
                          return roomsM.indexWhere((r) => r.id == id);
                        }
                        return null;
                      },
                    ),
                  );
                } else {
                  return const SliverToBoxAdapter(
                    child: EmptyScreen(),
                  );
                }
              } else {
                return const SliverToBoxAdapter(
                  child: SizedBox.shrink(),
                );
              }
            },
          ),
        ],
      ),
    );
  }

  Column _slideSection(double hightImages, double width) {
    return Column(
      children: [
         Padding(
           padding: const EdgeInsets.only(top: 5),
           child: SizedBox(
            height: 125,
            child: RepaintBoundary(
              child: Padding(
                padding: const EdgeInsets.only(bottom: 0),
                child: ClipRRect(
                  borderRadius: BorderRadius.circular(10),
                  child: ImageSlideshowWidget(
                    isLoop: true,
                    indicatorRadius: 1,
                    height: hightImages,
                    width: width,
                    fit: BoxFit.cover,
                    images: const [
                      // CP challenge entry banner
                      'assets/cp_chanllage/cp_challenge_banner_image.png',
                      // Wakala challenge entry banner
                      'assets/wakala_chanllage/تحدي الوكالات بانر الدخول.png',
                      'assets/invitation_page/banner_inivitation.jpeg',
                      'assets/tasks/images/banner_tasks.jpeg',
                      "assets/event/event_banner.png"
                    ],
                    onTaps: [
                      // open CP challenge page
                      () => Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (_) => const CpChallengePage(),
                            ),
                          ),
                      // open Wakala challenge page
                      () => Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (_) => WakalaChallengePage(
                                userCubit: widget.userCubit,
                              ),
                            ),
                          ),
                      () => Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (_) => const InvitationCenterPage(),
                            ),
                          ),
                      () => Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (_) => const TasksPage(),
                            ),
                          ),
                      () => Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (_) => const WeeklyStarEventView(),
                            ),
                          ),
                    ],
                  ),
                ),
              ),
            ),
                   ),
         ),
        RepaintBoundary(
          child: BlocProvider.value(
            value: _bannerCubit,
            child: BlocListener<BannerCubit, BannerState>(
              listenWhen: (prev, curr) => prev.banners != curr.banners,
              listener: (context, state) {
                final urls = (state.banners ?? [])
                    .where((b) => b.img != null && b.img!.startsWith('https'))
                    .map((b) => b.img!)
                    .toList();
                if (urls.isNotEmpty) {
                  _precacheBannerImages(urls);
                }
              },
              child: BlocBuilder<BannerCubit, BannerState>(
                buildWhen: (p, c) => p.banners != c.banners || p.status != c.status,
                builder: (context, state) {
                  final banners = state.banners;
                  final currentUrls = banners
                          ?.where((banner) => banner.img != null)
                          .map((banner) => banner.img!)
                          .toList() ??
                      [];
                  final urlsToShow =
                      currentUrls.isNotEmpty ? currentUrls : _initialBannerUrls;
                  return urlsToShow.isNotEmpty
                      ? Padding(
                          padding: const EdgeInsets.symmetric(vertical: 4),
                          child: ClipRRect(
                            borderRadius: BorderRadius.circular(10),
                            child: ImageSlideshowWidget(
                              key:
                                  const PageStorageKey('home_banner_slideshow'),
                              height: 110,
                              images: urlsToShow,
                              onTaps: (banners ?? [])
                                  .map((banner) => () {
                                        _onBannerTap(banner.link);
                                      })
                                  .toList(),
                            ),
                          ),
                        )
                      : _buildLoadingOrErrorState(state, width);
                },
              ),
            ),
          ),
        ),
       
      ],
    );
  }

  void _onBannerTap(String? link) {
    log("_onBannerTap link :$link");
    if (link != null && link != "null") {
      if (link.startsWith('https')) {
        launchUrl(Uri.parse(link));
      } else if (link == 'no') {
        Navigator.push(
            context,
            MaterialPageRoute(
              builder: (context) => const PostChargersPage(),
            ));
      } else {
        Navigator.push(
          context,
          PageRouteBuilder(
            transitionDuration: Duration.zero,
            reverseTransitionDuration: Duration.zero,
            pageBuilder: (_, __, ___) => RoomViewBloc(
              roomId: int.parse(link),
              roomCubit: widget.roomCubit,
              userCubit: widget.userCubit,
              backgroundImage: null,
              isForce: true,
              fromOverlay: false,
            ),
          ),
        );
      }
    }
  }

  Widget _buildLoadingOrErrorState(BannerState state, double width) {
    if (state.status.isLoading) {
      return CustomFadingWidget(
        child: Container(
          margin: const EdgeInsets.only(bottom: 10),
          decoration: BoxDecoration(
            color: AppColors.grey,
            borderRadius: BorderRadius.circular(10),
          ),
          width: width,
          height: 100,
        ),
      );
    } else if (state.status.isError) {
      return Center(
        child: Padding(
          padding: const EdgeInsets.all(30),
          child: AutoSizeText(state.errorMessage ?? 'Error loading banners'),
        ),
      );
    }
    return const SizedBox.shrink();
  }
}

// Country Selector Widget to isolate country selection logic
class _CountrySelectorWidget extends StatelessWidget {
  final String? selectedCountry;
  final List<Map<String, String>> countries;
  final Function(String?) onCountrySelected;
  
  const _CountrySelectorWidget({
    required this.selectedCountry,
    required this.countries,
    required this.onCountrySelected,
  });
  
  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: 45,
      child: ListView.builder(
        reverse: true,
        scrollDirection: Axis.horizontal,
        itemCount: countries.length,
        itemBuilder: (context, index) {
          final country = countries[index];
          final isSelected = selectedCountry == country['code'];
          return GestureDetector(
            key: ValueKey<String>('country_${country['code']}'),
            onTap: () => onCountrySelected(country['code']),
            child: AnimatedContainer(
              duration: const Duration(milliseconds: 300),
              margin: const EdgeInsets.symmetric(horizontal: 4, vertical: 8),
              padding: EdgeInsets.symmetric(
                horizontal: isSelected ? 12 : 8, 
                vertical: 2
              ),
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(isSelected ? 8 : 4),
                gradient: LinearGradient(
                  colors: [
                    isSelected ? AppColors.primary : AppColors.white,
                    isSelected ? AppColors.secondColor : AppColors.white,
                  ],
                ),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withOpacity(0.1),
                    blurRadius: 4,
                    offset: const Offset(0, 2),
                  ),
                ],
              ),
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  if (country['code'] != 'null') ...[
                    CountryFlag.fromCountryCode(
                      country['code']!,
                      height: 17,
                      width: 24,
                      shape: const RoundedRectangle(3),
                    ),
                    const SizedBox(width: 8),
                  ],
                  Text(
                    country['name']!,
                    style: TextStyle(
                      color: isSelected ? AppColors.white : AppColors.black,
                      fontWeight: FontWeight.bold,
                      fontSize: isSelected ? 15 : 14,
                    ),
                  ),
                ],
              ),
            ),
          );
        },
      ),
    );
  }
}

// مكون جديد لعزل البانر عن التحديثات
class BannerProvider extends StatefulWidget {
  final Widget child;
  final BannerState? cachedBannerState;
  final Function(BannerState)? onBannerStateChanged;

  const BannerProvider({
    super.key,
    required this.child,
    this.cachedBannerState,
    this.onBannerStateChanged,
  });

  @override
  State<BannerProvider> createState() => _BannerProviderState();
}

class _BannerProviderState extends State<BannerProvider> {
  BannerCubit? _bannerCubit;

  @override
  void initState() {
    super.initState();

    // إذا كان لدينا حالة مخزنة مسبقاً، لا نحتاج لتحميل البانر مرة أخرى
    if (widget.cachedBannerState == null) {
      _bannerCubit = BannerCubit()..fetchBanners();
    }
  }

  @override
  Widget build(BuildContext context) {
    // إذا كان لدينا حالة مخزنة، نعرضها مباشرة دون استخدام Bloc
    if (widget.cachedBannerState != null) {
      final banners = widget.cachedBannerState!.banners;
      return banners != null
          ? Padding(
              padding: const EdgeInsets.symmetric(vertical: 4),
              child: ClipRRect(
                borderRadius: BorderRadius.circular(10),
                child: ImageSlideshowWidget(
                  height: 100,
                  images: banners
                      .where((banner) => banner.img != null)
                      .map((banner) => banner.img!)
                      .toList(),
                  onTaps: banners
                      .map((banner) => () {
                            // تحتاج إلى تمرير دالة _onBannerTap من الوالد
                            // يمكنك تعديل هذا الجزء حسب احتياجاتك
                          })
                      .toList(),
                ),
              ),
            )
          : Container();
    }

    // إذا لم تكن هناك حالة مخزنة، نستخدم Bloc كالمعتاد
    return BlocProvider.value(
      value: _bannerCubit!,
      child: BlocListener<BannerCubit, BannerState>(
        listener: (context, state) {
          if (widget.onBannerStateChanged != null) {
            widget.onBannerStateChanged!(state);
          }
        },
        child: widget.child,
      ),
    );
  }

  @override
  void dispose() {
    _bannerCubit?.close();
    super.dispose();
  }
}
