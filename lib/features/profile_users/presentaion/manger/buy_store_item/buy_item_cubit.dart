import 'dart:convert';

import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:lklk/core/services/api_service.dart';
import 'package:lklk/features/profile_users/presentaion/manger/buy_store_item/buy_item_state.dart';

class BuyItemCubit extends Cubit<BuyItemState> {
  BuyItemCubit() : super(BuyItemInitial());

  Future<String> buyStoreItem(int id) async {
    emit(BuyItemLoading());
    try {
      final response = await ApiService().post('/store/buy/$id');

      if (response.statusCode == 200) {
        emit(BuyItemSuccess());
        return '${jsonDecode(response.data)}';
      } else {
        final errorMessage = jsonDecode(response.data)['message'] ??
            response.statusMessage ??
            'Unknown error';
        emit(BuyItemError('Error: $errorMessage'));
        return 'Some Thing Wrong ${jsonDecode(response.data)}';
      }
    } catch (e) {
      emit(BuyItemError('Error: $e'));
      return 'error ';
    }
  }
}
