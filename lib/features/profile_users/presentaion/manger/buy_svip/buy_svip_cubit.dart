import 'dart:convert';

import 'package:equatable/equatable.dart';
import 'package:bloc/bloc.dart';
import 'package:lklk/core/services/api_service.dart';

part 'buy_svip_state.dart';

class BuySvipCubit extends Cubit<BuySvipState> {
  BuySvipCubit() : super(BuySvipInitial());

  Future<void> buySvip(int vip) async {
    emit(BuySvipLoading());

    try {
      final response = await ApiService().post(
        '/buy/vip',
        data: {'vip': vip},
      );
      if (response.statusCode == 200) {
        emit(BuySvipSuccess(jsonDecode(response.data).toString()));
      } else {
        emit(BuySvipError('Failed to buy SVIP: ${response.statusMessage}'));
      }
    } catch (e) {
      emit(BuySvipError('Failed to buy SVIP: $e'));
    }
  }
}
