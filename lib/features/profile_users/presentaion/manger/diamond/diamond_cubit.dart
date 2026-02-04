import 'dart:convert';

import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:lklk/core/services/api_service.dart';
import 'package:lklk/core/utils/logger.dart';
import 'package:meta/meta.dart';

part 'diamond_state.dart';

class DiamondCubit extends Cubit<DiamondState> {
  DiamondCubit() : super(DiamondInitial());

  /// Attempts to convert diamonds to coins (server-side operation).
  /// Returns true on success, false on failure.
  Future<bool> buyDiamond(int amount) async {
    emit(DiamondLoading()); // إرسال حالة تحميل

    try {
      AppLogger.debug(
          '[BUY_DIAMOND] request -> endpoint: /diamond/to/coins, payload: {"diamond": $amount}',
          tag: 'purchase');
      final response = await ApiService().post(
        '/diamond/to/coins',
        data: {'diamond': amount}, // إرسال البيانات
      );
      AppLogger.debug(
          '[BUY_DIAMOND] response <- code: ${response.statusCode}, data: ${response.data}',
          tag: 'purchase');
      if (response.statusCode == 200) {
        emit(DiamondPurchased());
        AppLogger.info('[BUY_DIAMOND] success', tag: 'purchase');
        return true;
      } else {
        emit(DiamondFailed(
            'Failed to buy diamonds. Error ${response.statusCode}: ${jsonDecode(response.data)}'));
        AppLogger.warning(
            '[BUY_DIAMOND] failed with code ${response.statusCode}',
            tag: 'purchase');
        return false;
      }
    } catch (e) {
      emit(DiamondFailed('Failed to buy diamonds. Error: $e'));
      AppLogger.error('[BUY_DIAMOND] exception: $e', tag: 'purchase', error: e);
      return false;
    }
  }
}
