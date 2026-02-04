import 'package:flutter/material.dart';

class AnimatedGameAssetDisplay extends StatefulWidget {
  final List<String> assets;
  final int targetValue;
  final BoxFit? fit;
  final String? id;
  @override
  State<AnimatedGameAssetDisplay> createState() =>
      _AnimatedGameAssetDisplayState();
  const AnimatedGameAssetDisplay({
    super.key,
    required this.assets,
    required this.targetValue,
    this.fit,
    this.id,
  });
}

class _AnimatedGameAssetDisplayState extends State<AnimatedGameAssetDisplay>
    with TickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<int> _animation;
  final int _animationCycles = 3;
  late int _currentTarget;
  @override
  void initState() {
    super.initState();
    _initializeAnimation();
  }

  void _initializeAnimation() {
    // تأكيد أن القيمة ضمن النطاق الصحيح
    _currentTarget = widget.targetValue.clamp(1, widget.assets.length);
    _setupAnimationController();
  }

  void _setupAnimationController() {
    final targetIndex = _currentTarget - 1; // تحويل القيمة إلى index صفري
    final totalItems = widget.assets.length;
    final endValue = _animationCycles * totalItems + targetIndex;

    _controller = AnimationController(
      duration: const Duration(seconds: 2),
      vsync: this,
    )..addStatusListener(_handleAnimationStatus);

    _animation = IntTween(begin: 0, end: endValue).animate(
      CurvedAnimation(parent: _controller, curve: Curves.easeOut),
    );

    _controller.forward();
  }

  void _handleAnimationStatus(AnimationStatus status) {
    if (status == AnimationStatus.completed) {
      _controller.stop();
    }
  }

  @override
  void didUpdateWidget(covariant AnimatedGameAssetDisplay oldWidget) {
    super.didUpdateWidget(oldWidget);
    final idChanged = oldWidget.id != widget.id;
    final valueChanged = oldWidget.targetValue != widget.targetValue;
    final assetsChanged = oldWidget.assets.length != widget.assets.length;
    if (idChanged || valueChanged || assetsChanged) {
      _controller.dispose();
      _initializeAnimation();
    }
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: _animation,
      builder: (context, _) {
        final currentIndex = _animation.value % widget.assets.length;
        return Image.asset(
          widget.assets[currentIndex],
          width: 60,
          height: 60,
          fit: widget.fit,
        );
      },
    );
  }
}
