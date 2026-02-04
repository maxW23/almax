import 'package:dynamic_tabbar/dynamic_tabbar.dart';
import 'package:flutter/material.dart';
import 'package:auto_size_text/auto_size_text.dart';
import 'package:lklk/core/constants/app_colors.dart';
import 'package:lklk/core/cache/rooms_cache_manager.dart';
import 'package:lklk/core/widgets/best50_icon.dart';
import 'package:lklk/core/widgets/create_room_icon.dart';
import 'package:lklk/core/widgets/search_icon_button.dart';
import 'package:lklk/features/home/presentation/manger/banner_cubit/banner_cubit.dart';
import 'package:lklk/features/home/presentation/manger/banner_cubit/banner_state.dart';
import 'package:lklk/features/home/presentation/manger/cubit/room_me_cubit.dart';
import 'package:lklk/features/home/presentation/manger/room_manager.dart';
import 'package:lklk/features/home/presentation/manger/rooms_cubit/rooms_cubit.dart';
import 'package:lklk/features/profile_users/presentaion/manger/user_cubit/user_cubit_cubit.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:lklk/features/home/presentation/manger/room_cubit/room_cubit_cubit.dart';
import 'package:lklk/features/room/domain/entities/room_entity.dart';
import 'package:lklk/generated/l10n.dart';
import 'package:pull_to_refresh_new/pull_to_refresh.dart';
import 'package:skeletonizer/skeletonizer.dart';
import 'room_item_widget_titles_container.dart';
import 'package:lklk/core/constants/assets.dart';
import 'image_slideshow_widget.dart';
import 'dart:developer' as dev;

/// نسخة محسنة من RoomsHomeViewBodyWidget مع كاش ذكي ومنع الوميض
class OptimizedRoomsHomeViewBody extends StatefulWidget {
  const OptimizedRoomsHomeViewBody({
    super.key,
    required this.roomCubit,
    required this.userCubit,
    required this.roomMeCubit,
  });

  final RoomCubit roomCubit;
  final UserCubit userCubit;
  final RoomMeCubit roomMeCubit;

  @override
  State<OptimizedRoomsHomeViewBody> createState() =>
      _OptimizedRoomsHomeViewBodyState();
}

class _OptimizedRoomsHomeViewBodyState extends State<OptimizedRoomsHomeViewBody>
    with SingleTickerProviderStateMixin, WidgetsBindingObserver {
  static const String _logTag = 'OptimizedRoomsHome';

  int _currentPage = 1;
  bool _isLoading = false;
  final ScrollController _scrollController = ScrollController();
  late TabController _tabController;
  String? selectedCountry = 'null';
  final RoomManager roomManager = RoomManager();
  final RefreshController _refreshController = RefreshController();

  // نظام الكاش المحسن
  final RoomsCacheManager _cacheManager = RoomsCacheManager.instance;
  bool _hasCachedData = false;

  // حماية من التحديث المتكرر
  DateTime _lastRefreshTime = DateTime.fromMillisecondsSinceEpoch(0);
  static const Duration _refreshCooldown = Duration(seconds: 3);
  bool _isFromRoomReturn = false;

  // إدارة حالة التطبيق
  bool _isAppInBackground = false;

  late final BannerCubit _bannerCubit;

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    dev.log('🔄 App lifecycle changed: $state', name: _logTag);

    if (state == AppLifecycleState.paused) {
      _isAppInBackground = true;
    } else if (state == AppLifecycleState.resumed && _isAppInBackground) {
      _isAppInBackground = false;
      _isFromRoomReturn = true;

      // تحديث ذكي فقط إذا مر وقت كافي
      if (_canRefreshNow()) {
        dev.log('📱 App resumed - smart refresh triggered', name: _logTag);
        _smartRefresh();
      }
    }
  }

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addObserver(this);
    _bannerCubit = BannerCubit()..fetchBanners();

    dev.log('🚀 Initializing OptimizedRoomsHomeViewBody', name: _logTag);

    // تحميل البيانات المخزنة أولاً
    _loadCachedDataFirst();

    // تحميل غرف المستخدم
    widget.roomMeCubit.fetchRoomsMe();

    _scrollController.addListener(_scrollListener);
    _tabController = TabController(
      length: 2,
      vsync: this,
      initialIndex: 1,
    );
  }

  /// تحميل البيانات المخزنة أولاً ثم التحديث
  Future<void> _loadCachedDataFirst() async {
    try {
      dev.log('📦 Loading cached data first...', name: _logTag);

      final cachedRooms = await _cacheManager.getCachedRooms();
      if (cachedRooms != null && cachedRooms.isNotEmpty) {
        if (mounted) {
          setState(() {
            _hasCachedData = true;
            roomManager.allRooms.clear();
            roomManager.allRooms.addAll(cachedRooms);
          });
        }
        dev.log('✅ Loaded ${cachedRooms.length} cached rooms', name: _logTag);
      } else {
        dev.log('📭 No cached data available, loading fresh data',
            name: _logTag);
      }

      // تحميل البيانات الجديدة في الخلفية
      _fetchFreshData();
    } catch (e) {
      dev.log('❌ Error loading cached data: $e', name: _logTag);
      // في حالة فشل الكاش، تحميل البيانات الجديدة مباشرة
      _fetchFreshData();
    }
  }

  /// تحميل البيانات الجديدة
  Future<void> _fetchFreshData() async {
    if (!mounted) return;

    dev.log('🌐 Fetching fresh data...', name: _logTag);

    // لا نُظهر loading إذا كان لدينا كاش
    if (!_hasCachedData && mounted) {
      setState(() => _isLoading = true);
    }

    try {
      final roomsCubit = context.read<RoomsCubit>();
      final newRooms =
          await roomsCubit.fetchRooms(1, "OptimizedRoomsHome _fetchFreshData");

      if (mounted && newRooms.isNotEmpty) {
        final validRooms =
            newRooms.where((room) => room != null).cast<RoomEntity>().toList();

        if (validRooms.isNotEmpty) {
          // تحديث ذكي بدون وميض
          await _updateRoomsSmartly(validRooms);

          // حفظ في الكاش
          try {
            await _cacheManager.cacheRooms(validRooms);
            dev.log('💾 Fresh data cached successfully', name: _logTag);
          } catch (cacheError) {
            dev.log('⚠️ Failed to cache fresh data: $cacheError',
                name: _logTag);
          }
        } else {
          dev.log('⚠️ No valid rooms in fresh data', name: _logTag);
        }
      } else {
        dev.log('📭 No fresh data received', name: _logTag);
      }
    } catch (e) {
      dev.log('❌ Error fetching fresh data: $e', name: _logTag);
      // إذا فشل تحميل البيانات الجديدة ولا يوجد كاش، أظهر رسالة خطأ
      if (!_hasCachedData && mounted) {
        // يمكن إضافة معالجة خطأ هنا إذا لزم الأمر
      }
    } finally {
      if (mounted) {
        setState(() {
          _isLoading = false;
        });
      }
    }
  }

  /// تحديث الغرف بذكاء بدون وميض
  Future<void> _updateRoomsSmartly(List<RoomEntity> newRooms) async {
    if (!mounted) return;

    dev.log('🔄 Smart update: ${newRooms.length} new rooms', name: _logTag);

    // مقارنة الغرف الجديدة مع الموجودة
    final List<RoomEntity> roomsToUpdate = [];
    final List<RoomEntity> roomsToAdd = [];

    for (final newRoom in newRooms) {
      final existingIndex =
          roomManager.allRooms.indexWhere((room) => room.id == newRoom.id);

      if (existingIndex != -1) {
        // فحص إذا كانت هناك تغييرات فعلية
        final existingRoom = roomManager.allRooms[existingIndex];
        if (_hasRoomChanged(existingRoom, newRoom)) {
          roomsToUpdate.add(newRoom);
          roomManager.allRooms[existingIndex] = newRoom;
        }
      } else {
        roomsToAdd.add(newRoom);
      }
    }

    // إضافة الغرف الجديدة
    if (roomsToAdd.isNotEmpty) {
      roomManager.allRooms.addAll(roomsToAdd);
      dev.log('➕ Added ${roomsToAdd.length} new rooms', name: _logTag);
    }

    if (roomsToUpdate.isNotEmpty) {
      dev.log('🔄 Updated ${roomsToUpdate.length} existing rooms',
          name: _logTag);
    }

    // تحديث واحد فقط للـ UI
    if (mounted && (roomsToAdd.isNotEmpty || roomsToUpdate.isNotEmpty)) {
      setState(() {
        // التحديث تم أعلاه
      });
    }
  }

  /// فحص إذا كانت الغرفة تغيرت
  bool _hasRoomChanged(RoomEntity oldRoom, RoomEntity newRoom) {
    return oldRoom.name != newRoom.name ||
        oldRoom.img != newRoom.img ||
        oldRoom.background != newRoom.background ||
        oldRoom.microphoneNumber != newRoom.microphoneNumber ||
        // Ensure UI updates when the fire counter changes
        oldRoom.fire != newRoom.fire;
  }

  /// تحديث ذكي عند العودة من الغرفة
  Future<void> _smartRefresh() async {
    if (!_canRefreshNow()) return;

    dev.log('🔄 Smart refresh triggered', name: _logTag);

    // تحديث بدون إظهار حالة تحميل إضافية

    // تحديث البيانات بدون إظهار loading
    await _fetchFreshData();

    // تحديث غرف المستخدم أيضاً (دائماً)
    dev.log('🏠 Refreshing user rooms...', name: _logTag);
    widget.roomMeCubit.fetchRoomsMe();

    _refreshController.refreshCompleted();
  }

  bool _canRefreshNow() {
    final now = DateTime.now();
    if (now.difference(_lastRefreshTime) < _refreshCooldown) {
      dev.log('⏰ Refresh blocked - cooldown active', name: _logTag);
      return false;
    }
    _lastRefreshTime = now;
    return true;
  }

  void _scrollListener() {
    // تحميل صفحات إضافية عند الحاجة
    var currentPositions = _scrollController.position.pixels;
    var maxScrollLength = _scrollController.position.maxScrollExtent;

    if (maxScrollLength <= 0 || _isLoading) return;

    if (currentPositions >= maxScrollLength * 0.8 && _currentPage < 10) {
      _loadMoreRooms();
    }
  }

  Future<void> _loadMoreRooms() async {
    if (_isLoading) return;

    setState(() => _isLoading = true);
    _currentPage++;

    try {
      final roomsCubit = context.read<RoomsCubit>();
      final newRooms = await roomsCubit.fetchRooms(
          _currentPage, "OptimizedRoomsHome _loadMoreRooms");

      if (mounted && newRooms.isNotEmpty) {
        final validRooms =
            newRooms.where((room) => room != null).cast<RoomEntity>().toList();

        setState(() {
          for (var room in validRooms) {
            if (!roomManager.allRooms
                .any((existingRoom) => existingRoom.id == room.id)) {
              roomManager.allRooms.add(room);
            }
          }
        });
      }
    } catch (e) {
      dev.log('❌ Error loading more rooms: $e', name: _logTag);
    } finally {
      if (mounted) {
        setState(() => _isLoading = false);
      }
    }
  }

  @override
  void dispose() {
    _scrollController.removeListener(_scrollListener);
    _scrollController.dispose();
    _refreshController.dispose();
    if (mounted) _tabController.dispose();
    WidgetsBinding.instance.removeObserver(this);
    _bannerCubit.close();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final double width = MediaQuery.of(context).size.width;
    const double hightImages = 80;

    return DynamicTabBarWidget(
      automaticIndicatorColorAdjustment: false,
      unselectedLabelColor: AppColors.grey,
      dividerHeight: 0,
      dividerColor: AppColors.transparent,
      leading: _buildLeadingIcons(),
      dynamicTabs: _buildTabs(hightImages, width),
      isScrollable: false,
      labelColor: AppColors.black,
      indicator: const BoxDecoration(
        border: Border(
          bottom: BorderSide(color: AppColors.black, width: 2),
        ),
      ),
      onTabControllerUpdated: (controller) {},
      onTabChanged: (index) {
        // تحديث ذكي فقط عند الحاجة
        if (index == 1 && !_isFromRoomReturn && _canRefreshNow()) {
          _smartRefresh();
        }
        _isFromRoomReturn = false;
      },
      onAddTabMoveTo: MoveToTab.last,
      showBackIcon: true,
      showNextIcon: true,
    );
  }

  Widget _buildLeadingIcons() {
    return Row(
      children: [
        SearchIconButton(
            userCubit: widget.userCubit, roomCubit: widget.roomCubit),
        CreateRoomIcon(
            roomCubit: widget.roomCubit, userCubit: widget.userCubit),
        Best50Icon(userCubit: widget.userCubit),
        const SizedBox(width: 70),
      ],
    );
  }

  List<TabData> _buildTabs(double hightImages, double width) {
    return [
      TabData(
        index: 0,
        title: Tab(child: AutoSizeText(S.of(context).me)),
        content: _buildMeRoomsPage(hightImages, width),
      ),
      TabData(
        index: 1,
        title: Tab(child: AutoSizeText(S.of(context).popular)),
        content: _buildPopularRoomsPage(hightImages, width),
      ),
    ];
  }

  Widget _buildPopularRoomsPage(double hightImages, double width) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 15),
      child: SmartRefresher(
        controller: _refreshController,
        enablePullDown: true,
        onRefresh: _smartRefresh,
        child: CustomScrollView(
          controller: _scrollController,
          slivers: [
            // القسم الثابت
            SliverToBoxAdapter(child: _slideSection(hightImages, width)),

            // قائمة الغرف مع تحديث ذكي
            SliverGrid.builder(
              itemCount: roomManager.allRooms.isEmpty
                  ? (_isLoading ? 10 : 0)
                  : roomManager.allRooms.length + (_isLoading ? 1 : 0),
              gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                crossAxisSpacing: 10,
                mainAxisSpacing: 10,
                crossAxisCount: 2,
              ),
              itemBuilder: (context, index) {
                if (roomManager.allRooms.isEmpty && _isLoading) {
                  return _buildLoadingRoomWidget();
                }

                if (index >= roomManager.allRooms.length) {
                  return _buildLoadingRoomWidget();
                }

                final room = roomManager.allRooms[index];
                return AnimatedSwitcher(
                  duration: const Duration(milliseconds: 300),
                  child: RoomItemWidgetTitlesContainer(
                    key: ValueKey('room_${room.id}'),
                    roomCubit: widget.roomCubit,
                    room: room,
                    userCubit: widget.userCubit,
                    isList: false,
                  ),
                );
              },
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildMeRoomsPage(double hightImages, double width) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 15),
      child: CustomScrollView(
        slivers: [
          SliverToBoxAdapter(child: _slideSection(hightImages, width)),
          const SliverToBoxAdapter(child: SizedBox(height: 10)),
          BlocBuilder<RoomMeCubit, RoomMeState>(
            bloc: widget.roomMeCubit,
            buildWhen: (prev, curr) => prev.roomsMe != curr.roomsMe,
            builder: (context, state) {
              if (state.roomsMe?.isNotEmpty == true) {
                return SliverList.builder(
                  itemCount: state.roomsMe!.length,
                  itemBuilder: (context, index) {
                    return Padding(
                      padding: const EdgeInsets.only(bottom: 10),
                      child: RoomItemWidgetTitlesContainer(
                        key: ValueKey('my_room_${state.roomsMe![index].id}'),
                        isList: true,
                        roomCubit: widget.roomCubit,
                        room: state.roomsMe![index],
                        userCubit: widget.userCubit,
                      ),
                    );
                  },
                );
              }
              return const SliverToBoxAdapter(child: SizedBox());
            },
          ),
        ],
      ),
    );
  }

  Widget _slideSection(double hightImages, double width) {
    return Column(
      children: [
        // البانر مع كاش
        RepaintBoundary(
          child: BlocProvider.value(
            value: _bannerCubit,
            child: BlocBuilder<BannerCubit, BannerState>(
              builder: (context, state) {
                if (state.banners != null) {
                  return Padding(
                    padding: const EdgeInsets.symmetric(vertical: 4),
                    child: ClipRRect(
                      borderRadius: BorderRadius.circular(10),
                      child: ImageSlideshowWidget(
                        height: 100,
                        images: state.banners!
                            .where((banner) => banner.img != null)
                            .map((banner) => banner.img!)
                            .toList(),
                        onTaps: state.banners!.map((banner) => () {}).toList(),
                      ),
                    ),
                  );
                }
                return const SizedBox(height: 100);
              },
            ),
          ),
        ),
        // القسم الثابت
        SizedBox(
          height: 90,
          child: RepaintBoundary(
            child: ClipRRect(
              borderRadius: BorderRadius.circular(10),
              child: ImageSlideshowWidget(
                isLoop: false,
                indicatorRadius: 1,
                height: hightImages,
                width: width,
                fit: BoxFit.cover,
                images: const [AssetsData.top50RelationsBannerSliders],
                onTaps: [() {}],
              ),
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildLoadingRoomWidget() {
    return Skeletonizer(
      enabled: true,
      child: RoomItemWidgetTitlesContainer(
        isList: false,
        roomCubit: widget.roomCubit,
        room: RoomEntity(
          id: 0,
          name: "Loading Room",
          background: "",
          img: "",
          country: "sy",
          helloText: "Loading...",
          microphoneNumber: "10",
          owner: "0",
        ),
        userCubit: widget.userCubit,
      ),
    );
  }
}
