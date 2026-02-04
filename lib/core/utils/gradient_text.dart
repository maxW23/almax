// ignore_for_file: public_member_api_docs, sort_constructors_first

import 'package:flutter/material.dart';
import 'package:auto_size_text/auto_size_text.dart';
import 'package:lklk/core/utils/text_direection.dart';

class GradientText extends StatelessWidget {
  final String text;
  final TextStyle style;
  final Gradient gradient;
  final bool textDirectionBool;
  final TextAlign textAlign;
  final int? maxLines;
  final TextOverflow overflow;
  final bool softWrap;
  final double minFontSize;
  final double maxFontSize;
  final double stepGranularity;
  final bool wrapWords;

  const GradientText(
    this.text, {
    super.key,
    required this.style,
    required this.gradient,
    this.textDirectionBool = true,
    this.textAlign = TextAlign.start,
    this.maxLines,
    this.overflow = TextOverflow.ellipsis,
    this.softWrap = true,
    this.minFontSize = 12,
    this.maxFontSize = double.infinity,
    this.stepGranularity = 1,
    this.wrapWords = true,
  });

  @override
  Widget build(BuildContext context) {
    TextDirection textDirection =
        textDirectionBool ? getTextDirection(text) : TextDirection.ltr;
    return Directionality(
      textDirection: textDirection,
      child: ShaderMask(
        shaderCallback: (bounds) => gradient.createShader(bounds),
        // Use srcIn so the gradient is drawn only where the text's alpha exists.
        // This avoids cases where modulate may keep the underlying white text color visible.
        blendMode: BlendMode.srcIn,
        child: AutoSizeText(
          text,
          style: style.copyWith(
            color: Colors.white,
            overflow: overflow,
          ),
          textAlign: textAlign,
          maxLines: maxLines,
          overflow: overflow,
          softWrap: softWrap,
          minFontSize: minFontSize,
          maxFontSize: maxFontSize,
          stepGranularity: stepGranularity,
          wrapWords: wrapWords,
        ),
      ),
    );
  }
}

class Text3D extends StatelessWidget {
  final String text;
  final TextStyle style;
  final Gradient gradient;
  final Gradient shadowGradient;
  final bool textDirectionBool;
  final TextAlign textAlign;
  final int? maxLines;
  final double depth; // تحكم في عمق التأثير ثلاثي الأبعاد

  const Text3D(
    this.text, {
    super.key,
    required this.style,
    required this.gradient,
    this.shadowGradient = const LinearGradient(
      colors: [Colors.black54, Colors.black],
    ),
    this.textDirectionBool = true,
    this.textAlign = TextAlign.start,
    this.maxLines,
    this.depth = 3.0,
  });

  @override
  Widget build(BuildContext context) {
    // إذا أردتَ جعل اتجاه النص يعتمد على اللغة (عربي أو إنجليزي):
    TextDirection textDirection =
        textDirectionBool ? getTextDirection(text) : TextDirection.ltr;

    return Directionality(
      textDirection: textDirection,
      child: Stack(
        children: [
          // الطبقة السفلية (الظل)
          Positioned(
            top: depth,
            left: depth,
            child: ShaderMask(
              shaderCallback: (bounds) => shadowGradient.createShader(bounds),
              child: AutoSizeText(
                text,
                style: style.copyWith(
                  // ملاحظة: لا بد أن يكون لون النص هنا أبيض في الغالب؛
                  // لأن الـShaderMask سيحل محل اللون النهائي
                  color: Colors.white,
                ),
                textAlign: textAlign,
                maxLines: maxLines,
                overflow: TextOverflow.ellipsis,
              ),
            ),
          ),

          // الطبقة العلوية (النص الرئيسي)
          ShaderMask(
            shaderCallback: (bounds) => gradient.createShader(bounds),
            child: AutoSizeText(
              text,
              style: style,
              textAlign: textAlign,
              maxLines: maxLines,
              overflow: TextOverflow.ellipsis,
            ),
          ),
        ],
      ),
    );
  }

  // تابع صغير لتحديد اتجاه النص تلقائياً حسب المحتوى (عربي أم إنجليزي)
  TextDirection getTextDirection(String text) {
    final arabicRegExp = RegExp(r'[\u0600-\u06FF]');
    return arabicRegExp.hasMatch(text) ? TextDirection.rtl : TextDirection.ltr;
  }
}
