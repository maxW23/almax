import 'package:flutter/material.dart';
import '../../../../../core/constants/app_colors.dart';

class BackgroundAnimatingColorsGradients extends StatefulWidget {
  const BackgroundAnimatingColorsGradients({
    super.key,
    this.primaryColor = AppColors.primary,
    this.secondColor = AppColors.secondColor,
    this.borderRadius,
  });
  final Color primaryColor;
  final Color secondColor;
  final BorderRadiusGeometry? borderRadius;
  @override
  State<BackgroundAnimatingColorsGradients> createState() =>
      _BackgroundAnimatingColorsGradientsState();
}

class _BackgroundAnimatingColorsGradientsState
    extends State<BackgroundAnimatingColorsGradients>
    with TickerProviderStateMixin {
  late AnimationController _bc;
  late Animation<double> ba;

  AlignmentTween aT =
      AlignmentTween(begin: Alignment.topRight, end: Alignment.topLeft);
  AlignmentTween aB =
      AlignmentTween(begin: Alignment.bottomRight, end: Alignment.bottomLeft);

  late Animatable<Color?> darkBackground;
  late Animatable<Color?> normalBackground;
  late Animatable<Color?> lightBackground;

  @override
  void initState() {
    super.initState();

    _bc = AnimationController(
      duration: const Duration(seconds: 7),
      vsync: this,
    )..repeat();
    ba = CurvedAnimation(parent: _bc, curve: Curves.easeIn);

    darkBackground = TweenSequence<Color?>(
      [
        TweenSequenceItem(
          weight: .5,
          tween: ColorTween(
            begin: widget.primaryColor.withValues(alpha: .8),
            end: widget.secondColor.withValues(alpha: .8),
          ),
        ),
        TweenSequenceItem(
          weight: .5,
          tween: ColorTween(
            begin: widget.secondColor.withValues(alpha: .8),
            end: widget.primaryColor.withValues(alpha: .8),
          ),
        ),
      ],
    );

    normalBackground = TweenSequence<Color?>(
      [
        TweenSequenceItem(
          weight: .5,
          tween: ColorTween(
            begin: widget.primaryColor.withValues(alpha: .6),
            end: widget.secondColor.withValues(alpha: .6),
          ),
        ),
        TweenSequenceItem(
          weight: .5,
          tween: ColorTween(
            begin: widget.secondColor.withValues(alpha: .6),
            end: widget.primaryColor.withValues(alpha: .6),
          ),
        ),
      ],
    );

    lightBackground = TweenSequence<Color?>(
      [
        TweenSequenceItem(
          weight: .5,
          tween: ColorTween(
            begin: widget.primaryColor.withValues(alpha: .4),
            end: widget.secondColor.withValues(alpha: .4),
          ),
        ),
        TweenSequenceItem(
          weight: .5,
          tween: ColorTween(
            begin: widget.secondColor.withValues(alpha: .4),
            end: widget.primaryColor.withValues(alpha: .4),
          ),
        ),
      ],
    );
  }

  @override
  Widget build(BuildContext context) {
    double w = MediaQuery.of(context).size.width;
    double h = MediaQuery.of(context).size.height;
    return AnimatedBuilder(
      animation: ba,
      builder: (context, child) {
        return Container(
          width: w,
          height: h,
          decoration: BoxDecoration(
            borderRadius: widget.borderRadius,
            gradient: LinearGradient(
              begin: aT.evaluate(ba),
              end: aB.evaluate(ba),
              colors: [
                darkBackground.evaluate(ba)!,
                normalBackground.evaluate(ba)!,
                lightBackground.evaluate(ba)!,
              ],
            ),
          ),
        );
      },
    );
  }

  @override
  void dispose() {
    _bc.dispose();
    super.dispose();
  }
}
