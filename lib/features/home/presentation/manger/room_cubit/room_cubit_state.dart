// ignore_for_file: public_member_api_docs, sort_constructors_first
part of 'room_cubit_cubit.dart';

enum RoomCubitStatus {
  initial,
  loading,
  favoriteLoading,
  adminLoading,
  banLoading,
  banRemoved,
  roomError,
  userBanned,
  backgroundUpdated,
  imageUpdated,
  nameUpdated,
  noRoom,
  success,
  authenticated,
  roomLoaded,
  roomUpdated,
  roomCreated,
  passUpdated,
  userUpdated,
  zegoUsersUpdated,
}

class RoomCubitState {
  final RoomCubitStatus status;
  final String? errorMessage;
  final UserEntity? user;
  final RoomEntity? room;

  final List<UserEntity>? usersServer;
  final List<UserEntity>? usersZego;
  final List<UserEntity>? adminsListUsers;
  final List<UserEntity>? bannedUsers;
  final List<UserEntity>? topUsers;

  RoomCubitState({
    required this.status,
    this.errorMessage,
    this.user,
    this.room,
    this.usersServer,
    this.usersZego,
    this.adminsListUsers,
    this.bannedUsers,
    this.topUsers,
  });

  // CopyWith method to create a new state with updated properties
  RoomCubitState copyWith({
    RoomCubitStatus? status,
    String? errorMessage,
    UserEntity? user,
    String? token,
    RoomEntity? room,
    List<UserEntity>? usersServer,
    List<UserEntity>? usersZego,
    List<UserEntity>? adminsListUsers,
    List<UserEntity>? bannedUsers,
    List<UserEntity>? topUsers,
  }) {
    return RoomCubitState(
      status: status ?? this.status,
      errorMessage: errorMessage ?? this.errorMessage,
      user: user ?? this.user,
      room: room ?? this.room,
      usersZego: usersZego ?? this.usersZego,
      usersServer: usersServer ?? this.usersServer,
      adminsListUsers: adminsListUsers ?? this.adminsListUsers,
      bannedUsers: bannedUsers ?? this.bannedUsers,
      topUsers: topUsers ?? this.topUsers,
    );
  }
}

extension RoomCubitStatusX on RoomCubitStatus {
  bool get isInitial => this == RoomCubitStatus.initial;
  bool get isLoading => this == RoomCubitStatus.loading;
  bool get isAdminLoading => this == RoomCubitStatus.adminLoading;
  bool get isAFavoriteLoading => this == RoomCubitStatus.favoriteLoading;
  bool get isBanLoading => this == RoomCubitStatus.banLoading;
  bool get isBanRemoved => this == RoomCubitStatus.banRemoved;
  bool get isRoomError => this == RoomCubitStatus.roomError;
  bool get isUserBanned => this == RoomCubitStatus.userBanned;
  bool get isBackgroundUpdated => this == RoomCubitStatus.backgroundUpdated;
  bool get isImageUpdated => this == RoomCubitStatus.imageUpdated;
  bool get isNameUpdated => this == RoomCubitStatus.nameUpdated;
  bool get isNoRoom => this == RoomCubitStatus.noRoom;
  bool get isSuccess => this == RoomCubitStatus.success;
  bool get isAuthenticated => this == RoomCubitStatus.authenticated;
  bool get isRoomLoaded => this == RoomCubitStatus.roomLoaded;
  bool get isRoomUpdated => this == RoomCubitStatus.roomUpdated;
  bool get isRoomCreated => this == RoomCubitStatus.roomCreated;
  bool get isPassUpdated => this == RoomCubitStatus.passUpdated;
  bool get isUserUpdated => this == RoomCubitStatus.userUpdated;
  bool get isZegoUsersUpdated => this == RoomCubitStatus.zegoUsersUpdated;
}

extension IterableExtension<T> on Iterable<T> {
  T? firstWhereOrNull2(bool Function(T element) test) {
    for (var element in this) {
      if (test(element)) return element;
    }
    return null;
  }
}
