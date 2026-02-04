// ignore_for_file: public_member_api_docs, sort_constructors_first

import 'package:auto_size_text/auto_size_text.dart';
import 'package:flutter/material.dart';

class ImageButtonWithOverlay extends StatelessWidget {
  final String image;
  final String title;
  final String text;
  final VoidCallback? onTap;
  final double height;
  final double borderRadius;
  final EdgeInsetsGeometry padding;
  final Color titleColor;
  final Color textColor;

  const ImageButtonWithOverlay({
    super.key,
    required this.image,
    required this.title,
    required this.text,
    this.onTap,
    this.height = 100,
    this.borderRadius = 14,
    this.padding = const EdgeInsets.symmetric(horizontal: 12, vertical: 12),
    this.titleColor = Colors.white,
    this.textColor = Colors.white,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: ClipRRect(
        borderRadius: BorderRadius.circular(borderRadius),
        child: SizedBox(
          height: height,
          width: double.infinity,
          child: Stack(
            fit: StackFit.expand,
            children: [
              // Background image
              Image.asset(
                image,
                fit: BoxFit.fill,
              ),
              // Subtle overlay for legibility
              Container(
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    begin: Alignment.topCenter,
                    end: Alignment.bottomCenter,
                    colors: [
                      Colors.black.withOpacity(0.10),
                      Colors.black.withOpacity(0.20),
                    ],
                  ),
                ),
              ),
              // Texts overlay
              Padding(
                padding: padding,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.end,
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    // Title on top
                    AutoSizeText(
                      title,
                      maxLines: 1,
                      minFontSize: 14,
                      style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.w700,
                        color: titleColor,
                        shadows: const [
                          Shadow(
                              color: Colors.black54,
                              blurRadius: 2,
                              offset: Offset(1, 1)),
                        ],
                      ),
                    ),
                    // Text at bottom
                    AutoSizeText(
                      text,
                      maxLines: 1,
                      minFontSize: 12,
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.w600,
                        color: textColor,
                        shadows: const [
                          Shadow(
                              color: Colors.black54,
                              blurRadius: 2,
                              offset: Offset(0.5, 0.5)),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
