import 'package:flutter/material.dart';
import 'package:lklk/core/constants/app_colors.dart';
import 'package:lklk/core/constants/styles.dart';

class AnimatedLinesWidget extends StatefulWidget {
  const AnimatedLinesWidget(
      {super.key,
      this.isShadow = false,
      required this.isWhite,
      this.size,
      this.color});
  final bool isShadow, isWhite;
  // Optional explicit size to match _circleSvg; defaults to 36 if not provided
  final double? size;
  // Optional color override; when provided it takes precedence over isWhite
  final Color? color;

  @override
  State<AnimatedLinesWidget> createState() => _AnimatedLinesWidgetState();
}

class _AnimatedLinesWidgetState extends State<AnimatedLinesWidget>
    with TickerProviderStateMixin {
  late final AnimationController _controller1;
  late final AnimationController _controller2;
  late final AnimationController _controller3;
  late final Animation<double> _animation1;
  late final Animation<double> _animation2;
  late final Animation<double> _animation3;
  late final double _size;

  @override
  void initState() {
    super.initState();
    _size = widget.size ?? 36.0;
    // Animation Controller and Animations for each line
    _controller1 = AnimationController(
      duration: const Duration(milliseconds: 600),
      vsync: this,
    )..repeat(reverse: true);

    _controller2 = AnimationController(
      duration: const Duration(milliseconds: 800),
      vsync: this,
    )..repeat(reverse: true);

    _controller3 = AnimationController(
      duration: const Duration(milliseconds: 700),
      vsync: this,
    )..repeat(reverse: true);

    // Defining height animations relative to size with varying patterns
    final double min1 = _size * 0.22; // ~8 for 36
    final double max1 = _size * 0.45; // ~16 for 36
    final double min2 = _size * 0.22; // ~8 for 36
    final double max2 = _size * 0.56; // ~20 for 36
    final double min3 = _size * 0.22; // ~8 for 36
    final double max3 = _size * 0.50; // ~18 for 36

    _animation1 = Tween<double>(begin: min1, end: max1).animate(CurvedAnimation(
      parent: _controller1,
      curve: Curves.easeInOut,
    ));
    _animation2 = Tween<double>(begin: min2, end: max2).animate(CurvedAnimation(
      parent: _controller2,
      curve: Curves.easeInOut,
    ));
    _animation3 = Tween<double>(begin: min3, end: max3).animate(CurvedAnimation(
      parent: _controller3,
      curve: Curves.easeInOut,
    ));
  }

  @override
  void dispose() {
    _controller1.dispose();
    _controller2.dispose();
    _controller3.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final Color lineColor = widget.color ??
        (widget.isWhite ? AppColors.white : AppColors.black);
    final double lineWidth = (_size * 0.07).clamp(2.0, 6.0).toDouble();
    final double spacing = (_size * 0.12).clamp(2.0, 8.0).toDouble();

    return SizedBox(
      width: _size,
      height: _size,
      child: Center(
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          crossAxisAlignment: CrossAxisAlignment.end,
          children: [
            AnimatedBuilder(
              animation: _animation1,
              builder: (context, child) {
                return Container(
                  width: lineWidth,
                  height: _animation1.value,
                  decoration: BoxDecoration(
                    color: lineColor,
                    boxShadow: [
                      widget.isWhite
                          ? Styles.blackContainerShadow
                          : const BoxShadow(),
                    ],
                  ),
                );
              },
            ),
            SizedBox(width: spacing),
            AnimatedBuilder(
              animation: _animation2,
              builder: (context, child) {
                return Container(
                  width: lineWidth,
                  height: _animation2.value,
                  decoration: BoxDecoration(
                    color: lineColor,
                    boxShadow: [
                      widget.isWhite
                          ? Styles.blackContainerShadow
                          : const BoxShadow(),
                    ],
                  ),
                );
              },
            ),
            SizedBox(width: spacing),
            AnimatedBuilder(
              animation: _animation3,
              builder: (context, child) {
                return Container(
                  width: lineWidth,
                  height: _animation3.value,
                  decoration: BoxDecoration(
                    color: lineColor,
                    boxShadow: [
                      widget.isWhite
                          ? Styles.blackContainerShadow
                          : const BoxShadow(),
                    ],
                  ),
                );
              },
            ),
          ],
        ),
      ),
    );
  }
}
