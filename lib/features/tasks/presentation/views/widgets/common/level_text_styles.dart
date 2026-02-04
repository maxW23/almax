import 'package:flutter/material.dart';

class LevelTextStyles {
  LevelTextStyles._();

  static const Color titleColor = Colors.white;
  static const Color subtitleColor = Colors.white70;

  static TextStyle titleLarge() => const TextStyle(
        color: titleColor,
        fontSize: 32,
        fontWeight: FontWeight.w800,
        letterSpacing: 0.5,
      );

  static TextStyle subtitle() => const TextStyle(
        color: subtitleColor,
        fontSize: 14,
        fontWeight: FontWeight.w400,
      );

  static TextStyle sectionTitle() => const TextStyle(
        color: Colors.white,
        fontSize: 20,
        fontWeight: FontWeight.w800,
        letterSpacing: 0.3,
      );

  static TextStyle chip() => const TextStyle(
        color: Colors.white,
        fontSize: 12,
        fontWeight: FontWeight.w600,
      );

  static TextStyle listTitle() => const TextStyle(
        color: Colors.white,
        fontSize: 14,
        fontWeight: FontWeight.w600,
      );

  static TextStyle listCounter() => const TextStyle(
        color: Colors.white70,
        fontSize: 12,
        fontWeight: FontWeight.w500,
      );
}
