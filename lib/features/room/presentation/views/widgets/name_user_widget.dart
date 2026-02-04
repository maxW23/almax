import 'dart:developer';

import 'package:flutter/material.dart';
import 'package:auto_size_text/auto_size_text.dart';
import 'package:lklk/core/constants/styles.dart';
import 'package:lklk/core/constants/svip_colors.dart';
import 'package:lklk/core/utils/gradient_text.dart';

class NameUserWidget extends StatefulWidget {
  const NameUserWidget({
    super.key,
    this.vip,
    required this.name,
    this.isWhite = false,
    this.textAlign = TextAlign.start,
    this.style = Styles.textStyle14bold,
    this.increaseFont = true,
    this.nameColor,
    this.useGradient = true,
  });
  final String? vip;
  final String name;
  final TextAlign textAlign;
  final TextStyle style;
  final bool isWhite;
  final bool increaseFont;
  // Optional: override the computed VIP color
  final Color? nameColor;
  // If false, render as plain solid color text (no shader mask)
  final bool useGradient;
  @override
  State<NameUserWidget> createState() => _NameUserWidgetState();
}

class _NameUserWidgetState extends State<NameUserWidget> {
  late Color colorNameOne;
  // final Color colorNameTwo = AppColors.white;

  @override
  void initState() {
    // Prefer explicit override if provided, otherwise compute from VIP settings
    colorNameOne = widget.nameColor ??
        (widget.vip != null && widget.vip != "null"
            ? updateSVIPSettings(int.parse(widget.vip ?? '0'), widget.isWhite)
            : updateSVIPSettings(0, widget.isWhite));
    // log("colorNameOne vippppp  $colorNameOne");

    super.initState();
  }

  @override
  void didUpdateWidget(NameUserWidget oldWidget) {
    super.didUpdateWidget(oldWidget);
    // Recompute when any relevant input changes (override color, vip, isWhite)
    if (widget.nameColor != oldWidget.nameColor ||
        widget.vip != oldWidget.vip ||
        widget.isWhite != oldWidget.isWhite) {
      colorNameOne = widget.nameColor ??
          (widget.vip != null && widget.vip != "null"
              ? updateSVIPSettings(int.parse(widget.vip ?? '0'), widget.isWhite)
              : updateSVIPSettings(0, widget.isWhite));
    }
  }

  @override
  Widget build(BuildContext context) {
    if (!widget.useGradient) {
      // Solid color rendering path (reliable on all devices)
      return AutoSizeText(
        widget.name,
        style: widget.style.copyWith(
          color: widget.nameColor ?? colorNameOne,
          fontWeight: FontWeight.w800,
          fontSize: widget.increaseFont
              ? (widget.style.fontSize ?? 14) + 2
              : (widget.style.fontSize ?? 14),
          shadows: const [
            Shadow(
              color: Colors.black54,
              blurRadius: 1.5,
              offset: Offset(0.5, 0.5),
            ),
          ],
        ),
        maxLines: 1,
        textAlign: widget.textAlign,
        overflow: TextOverflow.ellipsis,
      );
    }

    return GradientText(
      widget.name,
      textDirectionBool: false,
      gradient: LinearGradient(
        begin: Alignment.topLeft,
        end: Alignment.bottomRight,
        transform: const GradientRotation(45),
        colors: [
          colorNameOne,
          colorNameOne,
        ],
      ),
      style: widget.style.copyWith(
        fontWeight: FontWeight.w800, // جعل الخط أثقل
        fontSize: widget.increaseFont
            ? (widget.style.fontSize ?? 14) + 2
            : (widget.style.fontSize ?? 14),
        shadows: const [
          Shadow(
            color: Colors.black54,
            blurRadius: 1.5,
            offset: Offset(0.5, 0.5),
          ),
        ],
      ),
      maxLines: 1,
      textAlign: widget.textAlign,
    );
  }
}
