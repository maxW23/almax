import 'package:flutter/material.dart';
import 'package:shimmer/shimmer.dart';

class ShimmerWidget extends StatelessWidget {
  final Widget child;
  final Gradient? gradient;
  final int loop;
  final Duration? period;
  final bool enabled;
  final ShimmerDirection direction;

  const ShimmerWidget({
    super.key,
    required this.child,
    this.gradient,
    this.loop = 0,
    this.period,
    this.enabled = true,
    this.direction = ShimmerDirection.ltr,
  });

  @override
  Widget build(BuildContext context) {
    final Gradient effectiveGradient = gradient ??
        LinearGradient(
          colors: [
            Colors.transparent,
            Colors.white.withValues(alpha: .2),
            Colors.transparent,
          ],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        );

    return Stack(
      children: [
        child,
        Shimmer(
          gradient: effectiveGradient,
          loop: loop,
          period: period ?? const Duration(milliseconds: 1350),
          enabled: enabled,
          direction: direction,
          child: child,
        ),
      ],
    );
  }
}
