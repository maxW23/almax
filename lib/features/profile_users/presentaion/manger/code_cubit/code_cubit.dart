import 'dart:convert';

import 'package:flutter_bloc/flutter_bloc.dart';
import '../../../../../core/services/api_service.dart';

class CodeCubit extends Cubit<String?> {
  CodeCubit() : super(null);

  Future<void> fetchCode() async {
    emit('loading');
    try {
      final response = await ApiService().get('/code');

      if (response.statusCode == 200) {
        emit(jsonDecode(response.data));
      } else {
        emit('Error: Unable to fetch code');
      }
    } catch (e) {
      emit('Error: $e');
    }
  }
}
