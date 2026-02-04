import 'dart:convert';

import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:lklk/core/services/api_service.dart';
import 'package:lklk/features/room/domain/entities/room_entity.dart';
import 'search_room_state.dart';

class SearchRoomCubit extends Cubit<SearchRoomState> {
  SearchRoomCubit() : super(SearchRoomInitial());

  Future<void> searchRooms(String name) async {
    emit(SearchRoomLoading());
    try {
      final response = await ApiService().get(
        '/search/room',
        queryParameters: {'name': name},
      );
      final parsedData = jsonDecode(response.data);

      if (response.statusCode == 200) {
        final List<dynamic> data = parsedData['room'];
        final rooms = data.map((room) => RoomEntity.fromMap(room)).toList();
        emit(SearchRoomLoaded(rooms));
      } else {
        emit(const SearchRoomError('Failed to load rooms'));
      }
    } catch (e) {
      emit(SearchRoomError('An error occurred: $e'));
    }
  }
}
