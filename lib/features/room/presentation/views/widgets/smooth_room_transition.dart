import 'package:flutter/material.dart';

/// مكون لحل مشكلة الومضة السوداء عند فتح الغرفة
class SmoothRoomTransition extends StatefulWidget {
  final Widget child;
  final Duration fadeInDuration;
  final Color backgroundColor;

  const SmoothRoomTransition({
    super.key,
    required this.child,
    this.fadeInDuration = const Duration(milliseconds: 100),
    this.backgroundColor = Colors.black,
  });

  @override
  State<SmoothRoomTransition> createState() => _SmoothRoomTransitionState();
}

class _SmoothRoomTransitionState extends State<SmoothRoomTransition>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _fadeAnimation;
  bool _isReady = false;

  @override
  void initState() {
    super.initState();

    _controller = AnimationController(
      duration: widget.fadeInDuration,
      vsync: this,
    );

    _fadeAnimation = Tween<double>(
      begin: 0.0,
      end: 1.0,
    ).animate(CurvedAnimation(
      parent: _controller,
      curve: Curves.easeInOut,
    ));

    // تأخير قصير للسماح للعناصر بالتحميل
    WidgetsBinding.instance.addPostFrameCallback((_) {
      Future.delayed(const Duration(milliseconds: 100), () {
        if (mounted) {
          setState(() => _isReady = true);
          _controller.forward();
        }
      });
    });
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      color: widget.backgroundColor,
      child: AnimatedBuilder(
        animation: _fadeAnimation,
        builder: (context, child) {
          return Opacity(
            opacity: _isReady ? _fadeAnimation.value : 0.0,
            child: widget.child,
          );
        },
      ),
    );
  }
}
