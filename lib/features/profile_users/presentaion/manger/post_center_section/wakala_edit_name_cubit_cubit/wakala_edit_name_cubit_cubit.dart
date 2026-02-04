import 'package:lklk/core/utils/logger.dart';

import 'package:equatable/equatable.dart';
import 'package:lklk/core/services/api_service.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

part 'wakala_edit_name_cubit_state.dart';

class WakalaEditNameCubitCubit extends Cubit<WakalaEditNameCubitState> {
  final ApiService _apiService = ApiService();

  WakalaEditNameCubitCubit() : super(WakalaEditNameCubitInitial());

  Future<void> changeWakalaName(String name) async {
    emit(WakalaEditNameLoading());
    try {
      final response = await _apiService.get(
        '/new/wakala/name?name=$name',
      );
      if (response.statusCode == 200) {
        emit(WakalaEditNameSuccess(name));
        log("WakalaEditNameSuccess ${response.data}");
      } else {
        emit(WakalaEditNameError('Failed to update name'));
        log("WakalaEditNameError ${response.data}");
      }
    } catch (e) {
      emit(WakalaEditNameError(e.toString()));
    }
  }
}
