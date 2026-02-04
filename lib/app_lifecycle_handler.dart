import 'dart:async';
import 'package:flutter/material.dart';
import 'package:lklk/core/services/api_service.dart';
import 'package:lklk/core/utils/logger.dart';
import 'package:shared_preferences/shared_preferences.dart';

class AppLifecycleHandler with WidgetsBindingObserver {
  AppLifecycleHandler() {
    WidgetsBinding.instance.addObserver(this);
    _checkPendingRequests();
  }
  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    if (state == AppLifecycleState.paused) {
      // <-- التعديل هنا
      _sendOfflineRequest();
    }
  }

  Future<void> _sendOfflineRequest() async {
    try {
      await Future.delayed(const Duration(seconds: 1)); // <-- تأخير قصير
      await ApiService().get('/rooms?page=1');
    } catch (e) {
      AppLogger.debug('Failed to send offline request: $e');
      await _saveRequest(); // <-- احفظ الطلب إذا فشل
    }
  }

  Future<void> _saveRequest() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString('pending_request', '/rooms?page=1');
  }

  void dispose() {
    WidgetsBinding.instance.removeObserver(this);
  }

  Future<void> _checkPendingRequests() async {
    final prefs = await SharedPreferences.getInstance();
    if (prefs.containsKey('pending_request')) {
      final request = prefs.getString('pending_request');
      try {
        await ApiService().get(request!);
        await prefs.remove('pending_request');
      } catch (e) {
        AppLogger.debug('فشل إعادة الإرسال: $e');
      }
    }
  }
}
