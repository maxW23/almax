part of 'mini_dashboard_wakala_cubit.dart';

enum MiniDashboardStatus {
  initial,
  loading,
  loaded,
  error,
  acceptUserLoading,
  acceptUserSuccess,
  acceptUserError,
  deleteUserLoading,
  deleteUserSuccess,
  deleteUserError,
}

class MiniDashboardState extends Equatable {
  final MiniDashboardStatus status;
  final List<UserEntity> users;
  final String? message;
  final String? userId;

  const MiniDashboardState({
    this.status = MiniDashboardStatus.initial,
    this.users = const [],
    this.message,
    this.userId,
  });

  MiniDashboardState copyWith({
    MiniDashboardStatus? status,
    List<UserEntity>? users,
    String? message,
    String? userId,
  }) {
    return MiniDashboardState(
      status: status ?? this.status,
      users: users ?? this.users,
      message: message ?? this.message,
      userId: userId ?? this.userId,
    );
  }

  @override
  List<Object?> get props => [status, users, message, userId];
}

extension MiniDashboardStatusX on MiniDashboardStatus {
  bool get isInitial => this == MiniDashboardStatus.initial;
  bool get isLoading => this == MiniDashboardStatus.loading;
  bool get isLoaded => this == MiniDashboardStatus.loaded;
  bool get isError => this == MiniDashboardStatus.error;
  bool get isAcceptUserLoading => this == MiniDashboardStatus.acceptUserLoading;
  bool get isAcceptUserSuccess => this == MiniDashboardStatus.acceptUserSuccess;
  bool get isAcceptUserError => this == MiniDashboardStatus.acceptUserError;
  bool get isDeleteUserLoading => this == MiniDashboardStatus.deleteUserLoading;
  bool get isDeleteUserSuccess => this == MiniDashboardStatus.deleteUserSuccess;
  bool get isDeleteUserError => this == MiniDashboardStatus.deleteUserError;
}
