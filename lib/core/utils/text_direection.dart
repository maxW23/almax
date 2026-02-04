import 'package:flutter/material.dart';

// Utility function to determine text direction based on the presence of Arabic characters
TextDirection getTextDirection(String text) {
  return text.contains(
    RegExp(
      r'[\u0600-\u06FF\u0750-\u077F\u08A0-\u08FF\uFB50-\uFDFF\uFE70-\uFEFF]',
    ),
  )
      ? TextDirection.rtl
      : TextDirection.ltr;
}
