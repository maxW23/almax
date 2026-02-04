part of 'room_me_cubit.dart';

enum RoomMeStatus { initial, loading, loadedMe, error }

extension RoomMeStatusX on RoomMeStatus {
  bool get isInitial => this == RoomMeStatus.initial;
  bool get isLoading => this == RoomMeStatus.loading;
  bool get isError => this == RoomMeStatus.error;
  bool get isLoadedMe => this == RoomMeStatus.loadedMe;
}

class RoomMeState {
  final RoomMeStatus status;
  final List<RoomEntity>? roomsMe;
  final String? errorMessage;

  const RoomMeState({
    this.status = RoomMeStatus.initial,
    this.roomsMe,
    this.errorMessage,
  });

  // Add copyWith to allow partial updates
  RoomMeState copyWith({
    RoomMeStatus? status,
    List<RoomEntity>? roomsMe,
    String? errorMessage,
  }) {
    return RoomMeState(
      status: status ?? this.status,
      roomsMe: roomsMe ?? this.roomsMe,
      errorMessage: errorMessage ?? this.errorMessage,
    );
  }
}
