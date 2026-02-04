import 'dart:convert';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:lklk/core/utils/logger.dart';

import 'package:lklk/core/services/api_service.dart';
import 'package:lklk/core/service_locator.dart';
import 'package:lklk/features/room/domain/entities/room_entity.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:bloc/bloc.dart';

part 'room_me_state.dart';

class RoomMeCubit extends Cubit<RoomMeState> {
  RoomMeCubit() : super(const RoomMeState());

  void _safeEmit(RoomMeState newState) {
    if (!isClosed) {
      emit(newState);
    }
  }

  List<RoomEntity>? roomMeCached;
  Future<List<RoomEntity>> fetchRoomsMe() async {
    AppLogger.log('🏠 [RoomMeCubit] Starting fetchRoomsMe()',
        tag: 'RoomMeCubit');
    _safeEmit(state.copyWith(status: RoomMeStatus.loading));
    await loadCachedRoomsMe();
    if (isClosed) {
      return roomMeCached ?? <RoomEntity>[];
    }

    if (roomMeCached != null && roomMeCached!.isNotEmpty) {
      AppLogger.log(
          '📦 [RoomMeCubit] Found ${roomMeCached!.length} cached rooms',
          tag: 'RoomMeCubit');
      _safeEmit(
          state.copyWith(status: RoomMeStatus.loadedMe, roomsMe: roomMeCached));
    } else {
      AppLogger.log('📭 [RoomMeCubit] No cached rooms found',
          tag: 'RoomMeCubit');
    }

    try {
      AppLogger.log('🌐 [RoomMeCubit] Calling API: /user/room',
          tag: 'RoomMeCubit');
      final response = await sl<ApiService>().get('/user/room');
      AppLogger.log('✅ [RoomMeCubit] API response received: ${response.data}',
          tag: 'RoomMeCubit');
      final responseData =
          response.data is String ? jsonDecode(response.data) : response.data;

      if (responseData is! Map<String, dynamic>) {
        AppLogger.log('❌ [RoomMeCubit] Invalid response format',
            tag: 'RoomMeCubit');
        throw Exception("Invalid response format");
      }

      final jsonRooms = responseData['room'];
      AppLogger.log('🗂️ [RoomMeCubit] Room data from API: $jsonRooms',
          tag: 'RoomMeCubit');

      if (jsonRooms == null || jsonRooms is! List) {
        AppLogger.log('❌ [RoomMeCubit] Room data not found or invalid format',
            tag: 'RoomMeCubit');
        throw Exception("Room data not found or invalid format");
      }

      List<RoomEntity> rooms = [];

      for (var item in jsonRooms) {
        if (item is Map<String, dynamic>) {
          // Handle single room object
          rooms.add(RoomEntity.fromJson(item));
        } else if (item is List) {
          // Handle nested list of rooms
          rooms.addAll(
            item
                .whereType<Map<String, dynamic>>()
                .map((e) => RoomEntity.fromJson(e))
                .cast<RoomEntity>(),
          );
        }
      }

      AppLogger.log(
          '🏠 [RoomMeCubit] Parsed ${rooms.length} rooms successfully',
          tag: 'RoomMeCubit');
      await cachedRoomsFunctionMe(rooms);
      if (isClosed) {
        return rooms;
      }
      _safeEmit(state.copyWith(
        status: RoomMeStatus.loadedMe,
        roomsMe: rooms,
        errorMessage: null,
      ));
      return rooms;
    } catch (e) {
      AppLogger.log('❌ [RoomMeCubit] Error: $e', tag: 'RoomMeCubit');
      _safeEmit(state.copyWith(
        status: RoomMeStatus.error,
        errorMessage: e.toString(),
      ));
      return [];
    }
  }

  loadCachedRoomsMe() async {
    final prefs = await SharedPreferences.getInstance();
    final jsonString = prefs.getString('cachedRoomMe');
    if (jsonString != null) {
      try {
        final List<dynamic> jsonList = jsonDecode(jsonString);
        roomMeCached = jsonList
            .map((json) {
              if (json is Map<String, dynamic>) {
                return RoomEntity.fromJson(json);
              } else {
                log('Unexpected JSON format in cached data: $json');
                return null;
              }
            })
            .where((room) => room != null)
            .cast<RoomEntity>()
            .toList();
      } catch (e) {
        log('Error parsing cached rooms: $e');
      }
    }
  }

  cachedRoomsFunctionMe(List<RoomEntity> rooms) async {
    final prefs = await SharedPreferences.getInstance();
    final jsonList = rooms.map((room) => room.toJson()).toList();
    await prefs.setString('cachedRoomMe', jsonEncode(jsonList));
  }
}
