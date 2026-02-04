import 'dart:math' as math;
import 'package:flutter/material.dart';

class AnimatedBorderContainer extends StatefulWidget {
  final Widget child;
  final double borderWidth;
  final double borderRadius;

  const AnimatedBorderContainer({
    super.key,
    required this.child,
    this.borderWidth = 4,
    this.borderRadius = 16,
  });

  @override
  State<AnimatedBorderContainer> createState() =>
      _AnimatedBorderContainerState();
}

class _AnimatedBorderContainerState extends State<AnimatedBorderContainer>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 3),
    )..repeat();
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: _controller,
      builder: (context, _) {
        final double shift = _controller.value * 2 * math.pi;

        return CustomPaint(
          painter: _BorderPainter(
            shift: shift,
            borderWidth: widget.borderWidth,
            borderRadius: widget.borderRadius,
          ),
          child: Padding(
            padding: EdgeInsets.all(widget.borderWidth),
            child: widget.child,
          ),
        );
      },
    );
  }
}

class _BorderPainter extends CustomPainter {
  final double shift;
  final double borderWidth;
  final double borderRadius;

  _BorderPainter({
    required this.shift,
    required this.borderWidth,
    required this.borderRadius,
  });

  @override
  void paint(Canvas canvas, Size size) {
    final rect = Rect.fromLTWH(0, 0, size.width, size.height);

    final paint = Paint()
      ..shader = SweepGradient(
        colors: [
          Colors.pinkAccent,
          Colors.deepPurpleAccent,
          Colors.pinkAccent,
        ],
        stops: [0.0, 0.5, 1.0],
        transform: GradientRotation(shift),
      ).createShader(rect)
      ..style = PaintingStyle.stroke
      ..strokeWidth = borderWidth
      ..maskFilter = const MaskFilter.blur(BlurStyle.outer, 8); // وهج

    canvas.drawRRect(
      RRect.fromRectAndRadius(rect, Radius.circular(borderRadius)),
      paint,
    );
  }

  @override
  bool shouldRepaint(covariant _BorderPainter oldDelegate) {
    return oldDelegate.shift != shift;
  }
}
