import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:lklk/core/services/api_service.dart';
import 'package:lklk/core/utils/logger.dart';
import 'dart:convert';

part 'nova_state.dart';

class NovaCubit extends Cubit<NovaState> {
  final ApiService _apiService;

  NovaCubit({ApiService? apiService})
      : _apiService = apiService ?? ApiService(),
        super(NovaInitial());

  /// Converts coins to Nova points
  /// POST /cointo/point?amount=amount
  Future<bool> coinsToNova(int amount) async {
    try {
      emit(NovaLoading());
      AppLogger.info(
          '[COINS_TO_NOVA] request -> endpoint: /cointo/point, amount: $amount',
          tag: 'nova');

      final response = await _apiService.post(
        '/cointo/point?amount=$amount',
        data: {'amount': amount},
      );

      if (response.statusCode == 200 || response.statusCode == 201) {
        AppLogger.info(
            '[COINS_TO_NOVA] response <- code: ${response.statusCode}, data: ${response.data}',
            tag: 'nova');
        emit(NovaConverted());
        AppLogger.info('[COINS_TO_NOVA] success', tag: 'nova');
        return true;
      } else {
        emit(NovaFailed(
            'Failed to convert coins to Nova. Error ${response.statusCode}: ${jsonDecode(response.data)}'));
        AppLogger.error(
            '[COINS_TO_NOVA] failed with code ${response.statusCode}',
            tag: 'nova');
        return false;
      }
    } catch (e) {
      emit(NovaFailed('Failed to convert coins to Nova. Error: $e'));
      AppLogger.error('[COINS_TO_NOVA] error: $e', tag: 'nova');
      return false;
    }
  }

  /// Converts Nova points to coins
  /// GET /change/wp?used=c|n
  /// This swaps the user's primary currency from coins to nova or vice versa
  /// used: 'c' if invoked from coins screen, 'n' if from nova screen
  Future<bool> swapCurrency({String? used}) async {
    try {
      emit(NovaLoading());
      final endpoint = used == null || used.isEmpty
          ? '/change/wp'
          : '/change/wp?used=$used';
      AppLogger.info('[SWAP_CURRENCY] request -> endpoint: $endpoint, used: ${used ?? '-'}', tag: 'nova');

      final response = await _apiService.get(endpoint);

      if (response.statusCode == 200 || response.statusCode == 201) {
        AppLogger.info(
            '[SWAP_CURRENCY] response <- code: ${response.statusCode}, data: ${response.data}',
            tag: 'nova');
        emit(NovaCurrencySwapped());
        AppLogger.info('[SWAP_CURRENCY] success', tag: 'nova');
        return true;
      } else {
        emit(NovaFailed(
            'Failed to swap currency. Error ${response.statusCode}: ${jsonDecode(response.data)}'));
        AppLogger.error(
            '[SWAP_CURRENCY] failed with code ${response.statusCode}',
            tag: 'nova');
        return false;
      }
    } catch (e) {
      emit(NovaFailed('Failed to swap currency. Error: $e'));
      AppLogger.error('[SWAP_CURRENCY] error: $e', tag: 'nova');
      return false;
    }
  }
}
