part of 'post_center_cubit.dart';

@immutable
abstract class PostCenterState {}

class PostCenterInitial extends PostCenterState {}

class PostCenterSuccess extends PostCenterState {
  final WakalaInfo wakalaInfo;

  PostCenterSuccess(this.wakalaInfo);
}

class PostCenterError extends PostCenterState {
  final String message;

  PostCenterError(this.message);
}
