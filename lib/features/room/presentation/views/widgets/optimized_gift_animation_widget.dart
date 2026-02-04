import 'dart:async';
import 'dart:developer' as dev;
import 'package:flutter/material.dart';
import 'package:lklk/features/room/presentation/views/widgets/gift_animation_data.dart';
import 'package:cached_network_image/cached_network_image.dart';

/// نسخة محسنة من GiftAnimationWidget بدون تسرب ذاكرة
class OptimizedGiftAnimationWidget extends StatefulWidget {
  final GiftAnimationData giftData;
  final VoidCallback onAnimationComplete;
  final String? giftId;

  const OptimizedGiftAnimationWidget({
    super.key,
    required this.giftData,
    required this.onAnimationComplete,
    this.giftId,
  });

  @override
  State<OptimizedGiftAnimationWidget> createState() =>
      _OptimizedGiftAnimationWidgetState();
}

class _OptimizedGiftAnimationWidgetState
    extends State<OptimizedGiftAnimationWidget>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<Offset> _pathAnimation;
  late Animation<double> _scaleAnimation;
  late Animation<double> _opacityAnimation;

  // تجمع واحد لكل الـ Timers للتنظيف المضمون
  final Set<Timer> _activeTimers = {};

  // Weak reference للصورة لتقليل استهلاك الذاكرة

  // Flag للتأكد من التنظيف مرة واحدة فقط
  bool _isDisposed = false;

  @override
  void initState() {
    super.initState();
    _initializeAnimations();
    _startAnimation();
  }

  void _initializeAnimations() {
    _controller = AnimationController(
      duration: const Duration(milliseconds: 2500),
      vsync: this,
    );

    // حركة موحدة مبسطة
    _pathAnimation = TweenSequence<Offset>([
      TweenSequenceItem(
        tween: Tween<Offset>(
          begin: widget.giftData.senderOffset,
          end: widget.giftData.centerOffset,
        ).chain(CurveTween(curve: Curves.easeOutCubic)),
        weight: 30,
      ),
      TweenSequenceItem(
        tween: Tween<Offset>(
          begin: widget.giftData.centerOffset,
          end: widget.giftData.targetOffset,
        ).chain(CurveTween(curve: Curves.easeInOutCubic)),
        weight: 70,
      ),
    ]).animate(_controller);

    // تكبير بسيط
    _scaleAnimation = Tween<double>(
      begin: 0.8,
      end: 1.2,
    ).animate(CurvedAnimation(
      parent: _controller,
      curve: const Interval(0.2, 0.5, curve: Curves.easeOut),
    ));

    // شفافية تدريجية
    _opacityAnimation = Tween<double>(
      begin: 0.0,
      end: 1.0,
    ).animate(CurvedAnimation(
      parent: _controller,
      curve: const Interval(0.0, 0.1, curve: Curves.easeIn),
    ));

    // مستمع واحد فقط للانتهاء
    _controller.addStatusListener(_onAnimationStatus);
  }

  void _onAnimationStatus(AnimationStatus status) {
    if (status == AnimationStatus.completed) {
      _completeAnimation();
    }
  }

  void _startAnimation() {
    // Safety timer مع تتبع صحيح
    final safetyTimer = Timer(const Duration(milliseconds: 3000), () {
      if (!_isDisposed && mounted) {
        dev.log('⚠️ Safety timer triggered for gift: ${widget.giftId}');
        _completeAnimation();
      }
    });
    _activeTimers.add(safetyTimer);

    // بدء الحركة
    _controller.forward();
  }

  void _completeAnimation() {
    if (_isDisposed) return;

    // إشعار الوالد
    widget.onAnimationComplete();

    // تنظيف فوري
    _cleanup();
  }

  void _cleanup() {
    if (_isDisposed) return;
    _isDisposed = true;

    // إلغاء جميع الـ Timers
    for (final timer in _activeTimers) {
      timer.cancel();
    }
    _activeTimers.clear();

    // تنظيف الـ controller
    _controller.removeStatusListener(_onAnimationStatus);
    _controller.stop();

    dev.log('✅ Animation cleaned up: ${widget.giftId}');
  }

  @override
  void dispose() {
    _cleanup();
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    if (_isDisposed) {
      return const SizedBox.shrink();
    }

    return AnimatedBuilder(
      animation: _controller,
      builder: (context, child) {
        final position = _pathAnimation.value;
        final scale = _scaleAnimation.value;
        final opacity = _opacityAnimation.value;

        return Positioned(
          left: position.dx - 40,
          top: position.dy - 40,
          child: Opacity(
            opacity: opacity,
            child: Transform.scale(
              scale: scale,
              child: _buildGiftImage(),
            ),
          ),
        );
      },
    );
  }

  Widget _buildGiftImage() {
    return Container(
      width: 80,
      height: 80,
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.2),
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: ClipOval(
        child: Builder(builder: (context) {
          final dpr = MediaQuery.of(context).devicePixelRatio;
          final cacheW = (80 * dpr).round();
          final cacheH = (80 * dpr).round();
          return CachedNetworkImage(
            imageUrl: widget.giftData.imageUrl,
            width: 80,
            height: 80,
            fit: BoxFit.cover,
            memCacheWidth: cacheW,
            memCacheHeight: cacheH,
            maxWidthDiskCache: cacheW,
            maxHeightDiskCache: cacheH,
            placeholder: (context, _) => Container(color: Colors.grey[200]),
            errorWidget: (context, error, stackTrace) {
              return Container(
                color: Colors.grey[300],
                child: const Icon(Icons.card_giftcard, size: 40),
              );
            },
          );
        }),
      ),
    );
  }
}
