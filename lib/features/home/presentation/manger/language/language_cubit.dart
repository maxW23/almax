import 'package:equatable/equatable.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:flutter/material.dart';
import 'dart:ui' as ui;
part 'language_state.dart';

class LanguageCubit extends Cubit<Locale> {
  static const String _languageKey = 'selectedLanguage';

  LanguageCubit() : super(_getDeviceLocale()) {
    _loadSavedLanguage();
  }

  static Locale _getDeviceLocale() {
    final deviceLang = ui.window.locale.languageCode;
    return (deviceLang == 'ar') ? const Locale('ar') : const Locale('en');
  }

  Future<void> _loadSavedLanguage() async {
    final prefs = await SharedPreferences.getInstance();
    final savedLang = prefs.getString(_languageKey);

    if (savedLang == 'ar' || savedLang == 'en') {
      emit(Locale(savedLang!));
    } else {
      emit(_getDeviceLocale());
    }
  }

  Future<void> switchLanguage(String languageCode) async {
    if (languageCode != 'ar' && languageCode != 'en') return;

    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(_languageKey, languageCode);
    emit(Locale(languageCode));
  }
}
