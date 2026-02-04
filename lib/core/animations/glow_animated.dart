import 'package:avatar_glow/avatar_glow.dart';
import 'package:flutter/material.dart';
import '../constants/app_colors.dart';

class GlowAnimated extends StatefulWidget {
  const GlowAnimated(
      {super.key, required this.child, this.glowColor = AppColors.danger});
  final Widget child;
  final Color glowColor;
  @override
  State<GlowAnimated> createState() => _GlowAnimatedState();
}

class _GlowAnimatedState extends State<GlowAnimated> {
  @override
  Widget build(BuildContext context) {
    return Center(
      child: AvatarGlow(
        glowColor: widget.glowColor,
        glowCount: 2,

        duration: const Duration(milliseconds: 2000),
        repeat: true,
        // showTwoGlows: true,
        curve: Curves.easeOutQuad,
        child: widget.child,
      ),
    );
  }
}
