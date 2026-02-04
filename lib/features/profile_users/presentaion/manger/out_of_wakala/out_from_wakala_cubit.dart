import 'dart:convert';
import 'package:lklk/core/utils/logger.dart';

import 'package:lklk/core/services/api_service.dart';
import 'package:meta/meta.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

part 'out_from_wakala_state.dart';

class OutFromWakalaCubit extends Cubit<OutFromWakalaState> {
  OutFromWakalaCubit() : super(OutFromWakalaInitial());
  bool _busy = false;

  Future<void> outFromWakala(String id) async {
    if (_busy) return;
    _busy = true;
    log("outFromWakala ");

    try {
      // استدعاء الطلب باستخدام `ApiService`
      final response = await ApiService().post('/del/wakel/$id');
      // Log raw response safely (may be String like 'done' or a Map)
      log("outFromWakala ${response.data}");

      if (response.statusCode == 200) {
        // نجاح الطلب مع رسالة من الخادم إذا توفرت
        String msg = 'done';
        final data = response.data;
        if (data is Map && data['message'] is String) {
          msg = (data['message'] as String).trim();
        } else if (data is String && data.trim().isNotEmpty) {
          msg = data.trim();
        }
        emit(OutFromWakalaSuccess(msg));
      } else {
        // خطأ في الطلب
        String errorMessage = 'Unknown error occurred';
        final data = response.data;
        if (data is Map && data['message'] is String) {
          errorMessage = data['message'] as String;
        } else if (data is String && data.trim().isNotEmpty) {
          // Backend may return plain text error
          errorMessage = data;
        }
        emit(OutFromWakalaError(errorMessage));
      }
    } catch (e) {
      // خطأ في تنفيذ الطلب
      emit(OutFromWakalaError("Error: $e"));
    } finally {
      _busy = false;
    }
  }
}
