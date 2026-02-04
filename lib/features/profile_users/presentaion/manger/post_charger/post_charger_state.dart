part of 'post_charger_cubit.dart';

enum PostChargerStatus {
  initial,
  loading,
  loaded,
  convertLoading,
  convertSuccess,
  error
}

class PostChargerState {
  final PostChargerStatus status;
  final List<PostCharger>? users;
  final String? errorMessage;
  final String? successMessage;

  const PostChargerState({
    this.status = PostChargerStatus.initial,
    this.users,
    this.errorMessage,
    this.successMessage,
  });

  PostChargerState copyWith({
    PostChargerStatus? status,
    List<PostCharger>? users,
    String? errorMessage,
    String? successMessage,
  }) {
    return PostChargerState(
      status: status ?? this.status,
      users: users ?? this.users,
      errorMessage: errorMessage ?? this.errorMessage,
      successMessage: successMessage ?? this.successMessage,
    );
  }
}
