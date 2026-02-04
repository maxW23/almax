import 'dart:convert';
import 'package:lklk/core/utils/logger.dart';

import 'package:lklk/core/services/api_service.dart';
import 'package:lklk/features/profile_users/domain/entities/post_charger_entity.dart';
import 'package:bloc/bloc.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

part 'post_charger_state.dart';

class PostChargerCubit extends Cubit<PostChargerState> {
  PostChargerCubit() : super(const PostChargerState());
  Future<void> fetchUsers() async {
    emit(state.copyWith(
        status: PostChargerStatus.loading)); // تحديث الحالة إلى "جارٍ التحميل"
    try {
      final response = await ApiService().get('/wakala/list');

      if (response.statusCode == 200) {
        final List<dynamic> responseData = jsonDecode(response.data)['list'];
        final List<PostCharger> users =
            responseData.map((json) => PostCharger.fromJson(json)).toList();

        emit(state.copyWith(
          status: PostChargerStatus.loaded,
          users: users,
        ));
      } else {
        emit(state.copyWith(
          status: PostChargerStatus.error,
          errorMessage: 'Failed to load users: ${response.statusCode}',
        ));
      }
    } catch (e) {
      emit(state.copyWith(
        status: PostChargerStatus.error,
        errorMessage: 'Error: $e',
      ));
    }
  }

  Future<String> convertCoins(String idCharger, String amount) async {
    emit(state.copyWith(
        status: PostChargerStatus
            .convertLoading)); // تحديث الحالة إلى "جارٍ التحويل"
    try {
      final response =
          await ApiService().post('/coin/transfare/$idCharger?amount=$amount');
      log("convertCoins ${response.statusCode} ");
      if (response.statusCode == 200) {
        log("convertCoins ${response.statusCode} ${response.data}");

        emit(state.copyWith(
          status: PostChargerStatus.convertSuccess,
          successMessage: response.data.toString(),
        ));
        return 'done';
      } else {
        emit(state.copyWith(
          status: PostChargerStatus.error,
          errorMessage: 'Failed to convert coins: ${response.statusCode}',
        ));
        return 'failed';
      }
    } catch (e) {
      emit(state.copyWith(
        status: PostChargerStatus.error,
        errorMessage: 'Error: $e',
      ));
      return 'error';
    }
  }
}
