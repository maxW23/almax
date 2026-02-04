// color_util.dart
import 'package:flutter/material.dart';

class ColorUtil {
  static Color extractColor(String? idColor) {
    if (idColor == null || idColor == "null") {
      return const Color(0xff000000);
    } else if (idColor.length > 1) {
      String colorHex = idColor.substring(1);
      int colorValue = int.parse(colorHex, radix: 16);
      return Color(0xFF000000 + colorValue);
    } else {
      return const Color(0xff000000);
    }
  }

  static Color extractColorTwo(String? idColorTwo) {
    if (idColorTwo == null || idColorTwo == "null") {
      return const Color(0xff000000);
    }
    if (idColorTwo.length > 1) {
      String colorHexTwo = idColorTwo.substring(1);
      int colorValueTwo = int.parse(colorHexTwo, radix: 16);
      return Color(0xFF000000 + colorValueTwo);
    } else {
      return const Color(0xff000000);
    }
  }
}
