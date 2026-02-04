part of 'top_users_cubit.dart';

abstract class TopUsersState extends Equatable {
  const TopUsersState();

  @override
  List<Object> get props => [];
}

class TopUsersInitial extends TopUsersState {}

class TopUsersLoading extends TopUsersState {}

class TopUsersLoaded extends TopUsersState {
  final List<UserEntity> users;

  const TopUsersLoaded(this.users);

  @override
  List<Object> get props => [users];
}

class TopUserRelationUsersLoaded extends TopUsersState {
  final List<UserRelation> users;

  const TopUserRelationUsersLoaded(this.users);

  @override
  List<Object> get props => [users];
}

class TopUsersError extends TopUsersState {
  final String message;

  const TopUsersError(this.message);

  @override
  List<Object> get props => [message];
}

// ===== States جديدة للتعامل مع response الصور (array of strings) =====

/// حالة التحميل للصور
class TopImagesLoading extends TopUsersState {}

/// حالة تحميل الصور بنجاح
class TopImagesLoaded extends TopUsersState {
  final List<String> imageUrls;

  const TopImagesLoaded(this.imageUrls);

  @override
  List<Object> get props => [imageUrls];
}

/// حالة خطأ في تحميل الصور
class TopImagesError extends TopUsersState {
  final String message;

  const TopImagesError(this.message);

  @override
  List<Object> get props => [message];
}
