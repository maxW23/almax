import 'package:flutter/material.dart';

class AnimationSlideTransitionWidget extends StatefulWidget {
  const AnimationSlideTransitionWidget({
    super.key,
    required this.child,
  });
  final Widget child;
  @override
  State<AnimationSlideTransitionWidget> createState() =>
      _AnimationSlideTransitionWidgetState();
}

class _AnimationSlideTransitionWidgetState
    extends State<AnimationSlideTransitionWidget>
    with SingleTickerProviderStateMixin {
  late AnimationController _animationController;
  late Animation<Offset> _slidingAnimation;

  @override
  void initState() {
    super.initState();
    _animationController = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 2),
    );

    _slidingAnimation = Tween<Offset>(
      begin: const Offset(-1, 0), // Start from right
      end: const Offset(.2, 0), // End at original position
    ).animate(_animationController);

    _animationController.forward();
  }

  @override
  void dispose() {
    _animationController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return SlideTransition(
      position: _slidingAnimation,
      child: widget.child,
    );
  }
}
