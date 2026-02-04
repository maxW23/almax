// lib/cubit/search_room_state.dart

import 'package:equatable/equatable.dart';
import 'package:lklk/features/room/domain/entities/room_entity.dart';

abstract class SearchRoomState extends Equatable {
  const SearchRoomState();

  @override
  List<Object> get props => [];
}

class SearchRoomInitial extends SearchRoomState {}

class SearchRoomLoading extends SearchRoomState {}

class SearchRoomLoaded extends SearchRoomState {
  final List<RoomEntity> rooms;

  const SearchRoomLoaded(this.rooms);

  @override
  List<Object> get props => [rooms];
}

class SearchRoomError extends SearchRoomState {
  final String message;

  const SearchRoomError(this.message);

  @override
  List<Object> get props => [message];
}
