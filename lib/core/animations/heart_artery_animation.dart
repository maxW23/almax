import 'package:flutter/material.dart';
import 'package:lklk/core/constants/app_colors.dart';

class HeartArteryAnimation extends StatefulWidget {
  const HeartArteryAnimation({super.key, this.color = AppColors.danger});
  final Color color;

  @override
  State<HeartArteryAnimation> createState() => _HeartArteryAnimationState();
}

class _HeartArteryAnimationState extends State<HeartArteryAnimation>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _animation;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 30000),
    );

    _animation = Tween<double>(begin: -10, end: 10).animate(
      CurvedAnimation(parent: _controller, curve: Curves.bounceIn),
    );

    _controller.repeat(reverse: true); // Repeat the animation indefinitely
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Expanded(
          child: AnimatedBuilder(
            animation: _controller,
            builder: (context, child) {
              return CustomPaint(
                size: const Size(100, 40), // Adjust size as needed
                painter: HeartArteryPainter(_animation.value, widget.color),
              );
            },
          ),
        ),
      ],
    );
  }
}

class HeartArteryPainter extends CustomPainter {
  final double animationValue;
  final Color color;

  HeartArteryPainter(this.animationValue, this.color);

  @override
  void paint(Canvas canvas, Size size) {
    Paint paint = Paint()
      ..color = color
      ..strokeCap = StrokeCap.round
      ..strokeWidth = 2.0
      ..style = PaintingStyle.stroke;

    double startX = size.width / 4;
    double startY = size.height / 2;
    double endX = size.width * (3 / 4);

    double controlX1 = startX + (size.width / 8);
    double controlY1 = startY - (animationValue * (size.height / 4));
    double controlX2 = endX - (size.width / 8);
    double controlY2 = startY + (animationValue * (size.height / 4));

    Path path = Path()
      ..moveTo(startX, startY)
      ..cubicTo(controlX1, controlY1, controlX2, controlY2, endX, startY);

    canvas.drawPath(path, paint);
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) {
    return true;
  }
}
