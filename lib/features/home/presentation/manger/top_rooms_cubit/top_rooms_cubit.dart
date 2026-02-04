import 'dart:convert';

import 'package:equatable/equatable.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:lklk/features/room/domain/entities/room_entity.dart';
import 'package:lklk/core/services/api_service.dart';

part 'top_rooms_state.dart';

class TopRoomsCubit extends Cubit<TopRoomsState> {
  TopRoomsCubit() : super(TopRoomsInitial());

  Future<void> fetchTopRooms() async {
    emit(TopRoomsLoading());
    try {
      // إرسال الطلب عبر ApiService بدلاً من استخدام Dio مباشرة
      final response = await ApiService().get('/toproom');

      if (response.statusCode == 200) {
        final List<dynamic> data = jsonDecode(response.data);
        final rooms =
            data.map((roomJson) => RoomEntity.fromJson(roomJson)).toList();
        emit(TopRoomsLoaded(rooms));
      } else {
        emit(const TopRoomsError("Failed to fetch top rooms"));
      }
    } catch (e) {
      emit(TopRoomsError(e.toString()));
    }
  }
}
