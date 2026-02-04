import 'package:flutter/material.dart';

class GradientUnderlineIndicator extends Decoration {
  final Gradient gradient;
  final double strokeWidth;

  const GradientUnderlineIndicator({
    required this.gradient,
    this.strokeWidth = 2,
  });

  @override
  BoxPainter createBoxPainter([VoidCallback? onChanged]) {
    return _GradientUnderlinePainter(this, onChanged);
  }
}

class _GradientUnderlinePainter extends BoxPainter {
  final GradientUnderlineIndicator decoration;

  _GradientUnderlinePainter(this.decoration, VoidCallback? onChanged)
      : super(onChanged);

  @override
  void paint(Canvas canvas, Offset offset, ImageConfiguration configuration) {
    assert(configuration.size != null);
    final Rect rect = offset & configuration.size!;

    final Paint paint = Paint()
      ..shader = decoration.gradient.createShader(rect)
      ..strokeWidth = decoration.strokeWidth
      ..strokeCap = StrokeCap.square;

    // Draw the line at the bottom of the rect
    canvas.drawLine(
      Offset(rect.left, rect.bottom - decoration.strokeWidth / 2),
      Offset(rect.right, rect.bottom - decoration.strokeWidth / 2),
      paint,
    );
  }
}
