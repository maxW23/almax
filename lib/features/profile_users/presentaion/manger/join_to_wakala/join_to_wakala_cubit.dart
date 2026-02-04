import 'dart:convert';
import 'package:lklk/core/utils/logger.dart';

import 'package:lklk/core/services/api_service.dart';
// ignore: unused_import
import 'package:meta/meta.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

part 'join_to_wakala_state.dart';

class JoinToWakalaCubit extends Cubit<JoinToWakalaState> {
  JoinToWakalaCubit() : super(JoinToWakalaInitial());
  bool _busy = false;

  Future<void> joinToWakala(String id) async {
    if (_busy) return;
    _busy = true;
    log("joinToWakala");
    try {
      final response = await ApiService().post('/wakel/$id');
      // Log raw response safely (may be String like 'done' or a Map)
      log("joinToWakala ${response.data}");

      if (response.statusCode == 200) {
        // Successful response with server message if present
        String msg = 'done';
        final data = response.data;
        if (data is Map && data['message'] is String) {
          msg = (data['message'] as String).trim();
        } else if (data is String && data.trim().isNotEmpty) {
          msg = data.trim();
        }
        emit(JoinToWakalaSuccess(msg));
      } else {
        // Error response
        String errorMessage = 'Unknown error occurred';
        final data = response.data;
        if (data is Map && data['message'] is String) {
          errorMessage = data['message'] as String;
        } else if (data is String && data.trim().isNotEmpty) {
          // Backend may return plain text error
          errorMessage = data;
        }
        emit(JoinToWakalaError(errorMessage));
      }
    } catch (e) {
      emit(JoinToWakalaError("Error: $e"));
    } finally {
      _busy = false;
    }
  }
}
