part of 'rooms_cubit.dart';

enum RoomsStatus { initial, loading, loaded, error, me }

extension RoomsStatusX on RoomsStatus {
  bool get isInitial => this == RoomsStatus.initial;
  bool get isLoading => this == RoomsStatus.loading;
  bool get isError => this == RoomsStatus.error;
  bool get isLoaded => this == RoomsStatus.loaded;
  bool get isme => this == RoomsStatus.me;
}

class RoomsState extends Equatable {
  final RoomsStatus status;
  final List<RoomEntity>? rooms;
  final List<RoomEntity>? roomsCountry;
  final List<RoomEntity>? roomsMe;
  final String? errorMessage;

  const RoomsState({
    this.status = RoomsStatus.initial,
    this.rooms,
    this.roomsCountry,
    this.roomsMe,
    this.errorMessage,
  });

  // Add copyWith to allow partial updates
  RoomsState copyWith({
    RoomsStatus? status,
    List<RoomEntity>? rooms,
    List<RoomEntity>? roomsCountry,
    List<RoomEntity>? roomsMe,
    String? errorMessage,
  }) {
    return RoomsState(
      status: status ?? this.status,
      rooms: rooms ?? this.rooms,
      roomsCountry: roomsCountry ?? this.roomsCountry,
      roomsMe: roomsMe ?? this.roomsMe,
      errorMessage: errorMessage ?? this.errorMessage,
    );
  }

  @override
  List<Object?> get props =>
      [status, rooms, roomsCountry, roomsMe, errorMessage];
}
