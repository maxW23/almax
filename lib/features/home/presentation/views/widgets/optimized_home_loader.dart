import 'dart:async';
import 'dart:developer' as dev;
import 'package:flutter/material.dart';

/// مدير محسن لتحميل HomeView مع حل مشاكل التحميل المستمر والشاشة الفارغة
class OptimizedHomeLoader {
  static const Duration _refreshInterval = Duration(minutes: 2);
  static const Duration _bannerCacheTimeout = Duration(hours: 1);
  static const int _maxRetries = 3;

  Timer? _refreshTimer;
  Timer? _bannerRefreshTimer;
  bool _isLoading = false;
  bool _isBannerLoading = false;
  int _retryCount = 0;

  // Singleton
  static final OptimizedHomeLoader _instance = OptimizedHomeLoader._();
  static OptimizedHomeLoader get instance => _instance;
  OptimizedHomeLoader._();

  /// بدء التحديث المحسن للغرف
  void startOptimizedRefresh(BuildContext context) {
    _refreshTimer?.cancel();
    _refreshTimer = Timer.periodic(_refreshInterval, (_) {
      if (!_isLoading && context.mounted) {
        _loadRoomsWithRetry(context);
      }
    });
  }

  /// تحميل الغرف مع إعادة المحاولة
  Future<void> _loadRoomsWithRetry(BuildContext context) async {
    if (_isLoading || _retryCount >= _maxRetries) return;

    _isLoading = true;
    _retryCount++;

    try {
      // استدعاء تحميل الغرف من الـ Cubit
      // context.read<RoomsCubit>().loadRooms();
      _retryCount = 0; // إعادة تعيين العداد عند النجاح
    } catch (e) {
      if (_retryCount < _maxRetries) {
        // إعادة المحاولة بعد تأخير متزايد
        await Future.delayed(Duration(seconds: _retryCount * 2));
        if (context.mounted) {
          _loadRoomsWithRetry(context);
        }
      }
    } finally {
      _isLoading = false;
    }
  }

  /// تحميل Banner محسن مع كاش
  void startOptimizedBannerLoading(BuildContext context) {
    _loadBannerAsync(context);

    // تحديث دوري للبانر
    _bannerRefreshTimer?.cancel();
    _bannerRefreshTimer = Timer.periodic(_bannerCacheTimeout, (_) {
      if (context.mounted) {
        _loadBannerAsync(context);
      }
    });
  }

  Future<void> _loadBannerAsync(BuildContext context) async {
    if (_isBannerLoading) return;

    _isBannerLoading = true;

    try {
      // تحميل من الكاش أولاً
      final cachedBanner = await _getCachedBanner();
      if (cachedBanner != null && context.mounted) {
        _displayBanner(context, cachedBanner);
      }

      // تحميل جديد في الخلفية
      await _loadFreshBanner(context);
    } catch (e) {
      // معالجة الأخطاء
      dev.log('Error loading banner: $e', name: 'OptimizedHomeLoader');
    } finally {
      _isBannerLoading = false;
    }
  }

  Future<Map<String, dynamic>?> _getCachedBanner() async {
    // تنفيذ منطق الكاش هنا
    // يمكن استخدام SharedPreferences أو Hive
    return null;
  }

  void _displayBanner(BuildContext context, Map<String, dynamic> banner) {
    // عرض البانر في الواجهة
    // context.read<BannerCubit>().updateBanner(banner);
  }

  Future<void> _loadFreshBanner(BuildContext context) async {
    // تحميل بانر جديد من الخادم
    // final freshBanner = await ApiService.loadBanner();
    // if (context.mounted) {
    //   _displayBanner(context, freshBanner);
    //   _cacheBanner(freshBanner);
    // }
  }

  void dispose() {
    _refreshTimer?.cancel();
    _bannerRefreshTimer?.cancel();
  }
}

/// Widget للـ Skeleton Loading
class SkeletonLoader extends StatefulWidget {
  final int itemCount;
  final double itemHeight;

  const SkeletonLoader({
    super.key,
    this.itemCount = 6,
    this.itemHeight = 120.0,
  });

  @override
  State<SkeletonLoader> createState() => _SkeletonLoaderState();
}

class _SkeletonLoaderState extends State<SkeletonLoader>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _animation;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      duration: const Duration(seconds: 1),
      vsync: this,
    )..repeat(reverse: true);

    _animation = Tween<double>(
      begin: 0.3,
      end: 0.7,
    ).animate(CurvedAnimation(
      parent: _controller,
      curve: Curves.easeInOut,
    ));
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return ListView.builder(
      itemCount: widget.itemCount,
      padding: const EdgeInsets.all(16),
      itemBuilder: (context, index) {
        return AnimatedBuilder(
          animation: _animation,
          builder: (context, child) {
            return Container(
              height: widget.itemHeight,
              margin: const EdgeInsets.only(bottom: 16),
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(12),
                color: Colors.grey.withValues(alpha: _animation.value),
              ),
              child: Row(
                children: [
                  // صورة وهمية
                  Container(
                    width: 80,
                    height: 80,
                    margin: const EdgeInsets.all(16),
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(8),
                      color:
                          Colors.grey.withValues(alpha: _animation.value + 0.1),
                    ),
                  ),
                  // محتوى وهمي
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Container(
                          height: 16,
                          width: double.infinity,
                          margin: const EdgeInsets.only(right: 16, bottom: 8),
                          decoration: BoxDecoration(
                            borderRadius: BorderRadius.circular(4),
                            color: Colors.grey
                                .withValues(alpha: _animation.value + 0.1),
                          ),
                        ),
                        Container(
                          height: 12,
                          width: 150,
                          margin: const EdgeInsets.only(right: 16),
                          decoration: BoxDecoration(
                            borderRadius: BorderRadius.circular(4),
                            color: Colors.grey
                                .withValues(alpha: _animation.value + 0.1),
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            );
          },
        );
      },
    );
  }
}

/// Widget محسن لعرض قائمة الغرف
class OptimizedRoomsList extends StatelessWidget {
  final List<dynamic> rooms;
  final bool isLoading;
  final VoidCallback? onRefresh;

  const OptimizedRoomsList({
    super.key,
    required this.rooms,
    this.isLoading = false,
    this.onRefresh,
  });

  @override
  Widget build(BuildContext context) {
    if (isLoading && rooms.isEmpty) {
      return const SkeletonLoader();
    }

    if (rooms.isEmpty) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              Icons.meeting_room_outlined,
              size: 64,
              color: Colors.grey[400],
            ),
            const SizedBox(height: 16),
            Text(
              'لا توجد غرف متاحة حالياً',
              style: TextStyle(
                fontSize: 16,
                color: Colors.grey[600],
              ),
            ),
            const SizedBox(height: 16),
            if (onRefresh != null)
              ElevatedButton.icon(
                onPressed: onRefresh,
                icon: const Icon(Icons.refresh),
                label: const Text('تحديث'),
              ),
          ],
        ),
      );
    }

    return RefreshIndicator(
      onRefresh: () async {
        onRefresh?.call();
      },
      child: ListView.builder(
        itemCount: rooms.length,
        padding: const EdgeInsets.all(16),
        itemBuilder: (context, index) {
          final room = rooms[index];
          return _buildRoomItem(room);
        },
      ),
    );
  }

  Widget _buildRoomItem(dynamic room) {
    return Container(
      margin: const EdgeInsets.only(bottom: 16),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(12),
        color: Colors.white,
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.1),
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: ListTile(
        contentPadding: const EdgeInsets.all(16),
        leading: ClipRRect(
          borderRadius: BorderRadius.circular(8),
          child: Container(
            width: 60,
            height: 60,
            color: Colors.grey[300],
            // يمكن إضافة صورة الغرفة هنا
            child: const Icon(Icons.meeting_room),
          ),
        ),
        title: Text(
          room?.toString() ?? 'غرفة',
          style: const TextStyle(
            fontWeight: FontWeight.bold,
            fontSize: 16,
          ),
        ),
        subtitle: const Text('معلومات الغرفة'),
        trailing: const Icon(Icons.arrow_forward_ios),
        onTap: () {
          // الانتقال إلى الغرفة
        },
      ),
    );
  }
}
