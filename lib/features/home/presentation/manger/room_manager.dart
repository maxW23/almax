import 'package:lklk/features/room/domain/entities/room_entity.dart';

class RoomManager {
  static final RoomManager _instance = RoomManager._internal();

  factory RoomManager() => _instance;

  RoomManager._internal();

  final List<RoomEntity> allRooms = [];
  final List<RoomEntity> roomsCountry = [];
}
