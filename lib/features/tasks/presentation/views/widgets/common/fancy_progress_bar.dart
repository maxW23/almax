import 'package:flutter/material.dart';

class FancyProgressBar extends StatelessWidget {
  const FancyProgressBar({
    super.key,
    required this.progress,
    this.height = 12,
    this.borderRadius = 7,
    this.trackColor,
    this.fillGradient,
    this.showStar = true,
    this.starAsset = 'assets/tasks/images/blueStars.png',
    this.starSize = 22,
    this.padding = EdgeInsets.zero,
  });

  final double progress; // 0..1
  final double height;
  final double borderRadius;
  final Color? trackColor;
  final Gradient? fillGradient;
  final bool showStar;
  final String starAsset;
  final double starSize;
  final EdgeInsets padding;

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (context, constraints) {
        final clamped = progress.clamp(0.0, 1.0);
        final width = constraints.maxWidth - padding.horizontal;
        final fillW = (width * clamped).clamp(0.0, width);
        // Place the star fully inside the bar (from 0 to width - starSize)
        final starLeft = ((width - starSize) * clamped).clamp(0.0, (width - starSize));
        final effectiveShowStar = showStar && clamped > 0.0;
        final starTop = (height - starSize) / 2;

        return Padding(
          padding: padding,
          child: Stack(
            clipBehavior: Clip.none,
            alignment: Alignment.centerLeft,
            children: [
              // Track
              ClipRRect(
                borderRadius: BorderRadius.circular(borderRadius),
                child: Container(
                  width: width,
                  height: height,
                  color: trackColor ?? Colors.black.withOpacity(0.35),
                ),
              ),
              // Fill
              ClipRRect(
                borderRadius: BorderRadius.circular(borderRadius),
                child: Container(
                  width: fillW,
                  height: height,
                  decoration: BoxDecoration(
                    gradient: fillGradient ??
                        const LinearGradient(
                          begin: Alignment.centerLeft,
                          end: Alignment.centerRight,
                          colors: [Color(0xFFB6F4FF), Color(0xFF4E9CFF)],
                        ),
                    boxShadow: const [
                      BoxShadow(
                        color: Color(0x6639C1FF),
                        blurRadius: 10,
                        offset: Offset(0, 2),
                      ),
                    ],
                  ),
                ),
              ),
              if (effectiveShowStar)
                Positioned(
                  left: starLeft,
                  top: starTop,
                  child: Image.asset(
                    starAsset,
                    width: starSize,
                    height: starSize,
                    errorBuilder: (_, __, ___) => const SizedBox.shrink(),
                  ),
                ),
            ],
          ),
        );
      },
    );
  }
}
