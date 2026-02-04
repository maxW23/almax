import 'package:flutter/material.dart';

class AnimatedEaseInOutWidget extends StatefulWidget {
  const AnimatedEaseInOutWidget({super.key, required this.child});
  final Widget child;

  @override
  State<AnimatedEaseInOutWidget> createState() =>
      _AnimatedEaseInOutWidgetState();
}

class _AnimatedEaseInOutWidgetState extends State<AnimatedEaseInOutWidget>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _animation;

  @override
  void initState() {
    super.initState();

    _controller = AnimationController(
      duration: const Duration(seconds: 2),
      vsync: this,
    )..repeat(reverse: true);

    _animation = Tween<double>(begin: 0.8, end: 1.2).animate(
      CurvedAnimation(parent: _controller, curve: Curves.easeInOut),
    );
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
      child: widget.child, // Pass the widget's child here
      builder: (context, child) {
        return Transform.scale(
          scale: _animation.value,
          child: child, // Use the passed child
        );
      },
    );
  }
}
