part of 'top_rooms_cubit.dart';

abstract class TopRoomsState extends Equatable {
  const TopRoomsState();

  @override
  List<Object> get props => [];
}

///////////////////////////////////////////////

class TopRoomsInitial extends TopRoomsState {}

class TopRoomsLoading extends TopRoomsState {}

class TopRoomsLoaded extends TopRoomsState {
  final List<RoomEntity> rooms;

  const TopRoomsLoaded(this.rooms);

  @override
  List<Object> get props => [rooms];
}

class TopRoomsError extends TopRoomsState {
  final String message;

  const TopRoomsError(this.message);

  @override
  List<Object> get props => [message];
}
