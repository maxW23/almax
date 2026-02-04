import 'package:flutter/material.dart';
import 'dart:developer' as dev;

/// مُحسِّن أداء القوائم - تحسينات بسيطة وآمنة
class ListPerformanceOptimizer {
  static const String _logTag = 'ListPerformanceOptimizer';

  /// ListView محسن للأداء
  static Widget optimizedListView({
    required int itemCount,
    required IndexedWidgetBuilder itemBuilder,
    ScrollController? controller,
    Axis scrollDirection = Axis.vertical,
    bool shrinkWrap = false,
    ScrollPhysics? physics,
    EdgeInsetsGeometry? padding,
    double? itemExtent,
    double? cacheExtent,
  }) {
    dev.log('🚀 Creating optimized ListView with $itemCount items',
        name: _logTag);

    return ListView.builder(
      controller: controller,
      scrollDirection: scrollDirection,
      shrinkWrap: shrinkWrap,
      physics: physics,
      padding: padding,
      itemExtent: itemExtent,
      cacheExtent: cacheExtent ?? 250.0, // تحسين cache extent
      itemCount: itemCount,
      itemBuilder: (context, index) {
        // إضافة RepaintBoundary لتحسين الأداء
        return RepaintBoundary(
          child: itemBuilder(context, index),
        );
      },
    );
  }

  /// GridView محسن للأداء
  static Widget optimizedGridView({
    required int itemCount,
    required IndexedWidgetBuilder itemBuilder,
    required SliverGridDelegate gridDelegate,
    ScrollController? controller,
    Axis scrollDirection = Axis.vertical,
    bool shrinkWrap = false,
    ScrollPhysics? physics,
    EdgeInsetsGeometry? padding,
    double? cacheExtent,
  }) {
    dev.log('🚀 Creating optimized GridView with $itemCount items',
        name: _logTag);

    return GridView.builder(
      controller: controller,
      scrollDirection: scrollDirection,
      shrinkWrap: shrinkWrap,
      physics: physics,
      padding: padding,
      cacheExtent: cacheExtent ?? 250.0,
      gridDelegate: gridDelegate,
      itemCount: itemCount,
      itemBuilder: (context, index) {
        return RepaintBoundary(
          child: itemBuilder(context, index),
        );
      },
    );
  }

  /// PageView محسن للأداء
  static Widget optimizedPageView({
    required int itemCount,
    required IndexedWidgetBuilder itemBuilder,
    PageController? controller,
    Axis scrollDirection = Axis.horizontal,
    bool allowImplicitScrolling = false,
    ValueChanged<int>? onPageChanged,
  }) {
    dev.log('🚀 Creating optimized PageView with $itemCount pages',
        name: _logTag);

    return PageView.builder(
      controller: controller,
      scrollDirection: scrollDirection,
      allowImplicitScrolling: allowImplicitScrolling,
      onPageChanged: onPageChanged,
      itemCount: itemCount,
      itemBuilder: (context, index) {
        return RepaintBoundary(
          child: itemBuilder(context, index),
        );
      },
    );
  }

  /// تحسين أداء الـ Sliver Lists
  static Widget optimizedSliverList({
    required int itemCount,
    required IndexedWidgetBuilder itemBuilder,
    double? itemExtent,
  }) {
    dev.log('🚀 Creating optimized SliverList with $itemCount items',
        name: _logTag);

    if (itemExtent != null) {
      // استخدام SliverFixedExtentList للأداء الأفضل
      return SliverFixedExtentList(
        itemExtent: itemExtent,
        delegate: SliverChildBuilderDelegate(
          (context, index) => RepaintBoundary(
            child: itemBuilder(context, index),
          ),
          childCount: itemCount,
        ),
      );
    } else {
      return SliverList(
        delegate: SliverChildBuilderDelegate(
          (context, index) => RepaintBoundary(
            child: itemBuilder(context, index),
          ),
          childCount: itemCount,
        ),
      );
    }
  }

  /// تحسين أداء الـ AnimatedList
  static Widget optimizedAnimatedList({
    required GlobalKey<AnimatedListState> key,
    required Widget Function(BuildContext, int, Animation<double>) itemBuilder,
    int initialItemCount = 0,
    Axis scrollDirection = Axis.vertical,
    bool reverse = false,
    ScrollController? controller,
    bool? primary,
    ScrollPhysics? physics,
    bool shrinkWrap = false,
    EdgeInsetsGeometry? padding,
  }) {
    dev.log('🚀 Creating optimized AnimatedList', name: _logTag);

    return AnimatedList(
      key: key,
      initialItemCount: initialItemCount,
      scrollDirection: scrollDirection,
      reverse: reverse,
      controller: controller,
      primary: primary,
      physics: physics,
      shrinkWrap: shrinkWrap,
      padding: padding,
      itemBuilder: (context, index, animation) {
        return RepaintBoundary(
          child: itemBuilder(context, index, animation),
        );
      },
    );
  }
}

/// ScrollController محسن مع debouncing
class OptimizedScrollController extends ScrollController {
  static const String _logTag = 'OptimizedScrollController';

  DateTime? _lastScrollTime;
  static const Duration _scrollDebounceTime =
      Duration(milliseconds: 16); // 60 FPS

  @override
  void addListener(VoidCallback listener) {
    super.addListener(() {
      final now = DateTime.now();
      if (_lastScrollTime == null ||
          now.difference(_lastScrollTime!) > _scrollDebounceTime) {
        _lastScrollTime = now;
        listener();
      }
    });
  }

  /// انتقال سلس للموضع
  Future<void> smoothScrollTo(
    double offset, {
    Duration duration = const Duration(milliseconds: 300),
    Curve curve = Curves.easeInOut,
  }) async {
    try {
      await animateTo(
        offset,
        duration: duration,
        curve: curve,
      );
      dev.log('✅ Smooth scroll completed to offset: $offset', name: _logTag);
    } catch (e) {
      dev.log('❌ Smooth scroll failed: $e', name: _logTag);
    }
  }

  /// انتقال سلس للفهرس
  Future<void> smoothScrollToIndex(
    int index, {
    required double itemHeight,
    Duration duration = const Duration(milliseconds: 300),
    Curve curve = Curves.easeInOut,
  }) async {
    final targetOffset = index * itemHeight;
    await smoothScrollTo(
      targetOffset,
      duration: duration,
      curve: curve,
    );
  }
}
