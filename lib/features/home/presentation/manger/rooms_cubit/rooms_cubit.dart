import 'dart:async';
import 'dart:convert';
import 'package:lklk/core/utils/logger.dart';

import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:equatable/equatable.dart';
import 'package:lklk/core/services/api_service.dart';
import 'package:lklk/core/service_locator.dart';
import '../../../../room/domain/entities/room_entity.dart';
part 'rooms_state.dart';

class RoomsCubit extends Cubit<RoomsState> {
  RoomsCubit() : super(const RoomsState());

  // إضافة دالة لتحديث البيانات مباشرة
  void refreshRooms() {
    emit(state.copyWith(status: RoomsStatus.loading));
  }

  Future<List<RoomEntity?>> fetchRooms(int pageNumber, String where) async {
    log("fetchRooms $pageNumber $where");

    // نُبقي الحالة initial في أول تحميل لعرض Skeleton من الواجهة بدون تغيير التصميم
    // لا نقوم بإرسال حالة loading للصفحة الأولى لتفادي الوميض

    try {
      final response = await sl<ApiService>().get('/rooms?page=$pageNumber');
      log("fetchRooms response $where --- $response");
      final parsedData = jsonDecode(response.data);

      final List<dynamic> jsonRooms = parsedData['rooms'];
      log("fetchRooms jsonRooms $jsonRooms");

      final rooms = jsonRooms.map((json) => RoomEntity.fromJson(json)).toList();

      emit(state.copyWith(status: RoomsStatus.loaded, rooms: rooms));
      return rooms;
    } catch (e) {
      log("fetchRooms catch $e");

      emit(state.copyWith(
          status: RoomsStatus.error, errorMessage: e.toString()));
      return [];
    }
  }

  Future<List<RoomEntity?>> fetchCountryRooms(
      int pageNumber, String country) async {
    emit(state.copyWith(status: RoomsStatus.loading));
    try {
      final response = await sl<ApiService>()
          .get('/search/room/country?name=$country'); //?page=$pageNumber
      log("Roooms response $response");
      final parsedData = jsonDecode(response.data);
      final List<dynamic> jsonRooms =
          parsedData['room'] ?? parsedData['rooms'] ?? [];

      // final List<dynamic> jsonRooms = response.data['room'];
      final rooms = jsonRooms.map((json) => RoomEntity.fromJson(json)).toList();
      log("Roooms rooms $rooms");

      emit(state.copyWith(status: RoomsStatus.loaded, roomsCountry: rooms));
      return rooms;
    } catch (e) {
      emit(state.copyWith(
          status: RoomsStatus.error, errorMessage: e.toString()));
      return [];
    }
  }
}
