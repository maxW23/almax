import 'dart:convert';

import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:lklk/core/services/api_service.dart';
import 'package:lklk/features/profile_users/domain/entities/elements_entity.dart';
import 'package:lklk/features/profile_users/presentaion/manger/elements/elements_state.dart';

class ElementsCubit extends Cubit<ElementsState> {
  ElementsCubit() : super(ElementsLoading());

  Future<void> fetchElements() async {
    try {
      final response = await ApiService().get('/store');

      if (response.statusCode == 200) {
        final jsonResponse = jsonDecode(response.data);
        final elementsJson = jsonResponse['elament'];
        final elements = elementsJson
            .map<ElementEntity>((json) => ElementEntity.fromJson(json))
            .toList();

        emit(ElementsLoaded(elements));
      } else {
        throw Exception(
            jsonDecode(response.data)['message'] ?? 'Failed to load elements');
      }
    } catch (error) {
      emit(ElementsError('Error fetching elements: $error'));
    }
  }
}
