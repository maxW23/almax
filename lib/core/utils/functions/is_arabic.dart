import 'package:intl/intl.dart';
import 'dart:ui' as ui;

bool isArabic() {
  return Intl.getCurrentLocale().contains('ar') ||
      Intl.getCurrentLocale() == 'ar';
}

ui.TextDirection getTextDirection(String selectedLanguage) {
  return selectedLanguage == 'ar' ? ui.TextDirection.rtl : ui.TextDirection.ltr;
}

ui.TextDirection getReveseTextDirection(String selectedLanguage) {
  return selectedLanguage == 'ar' ? ui.TextDirection.ltr : ui.TextDirection.rtl;
}
