part of 'freind_cubit.dart';

@immutable
abstract class FreindState {}

class FreindInitial extends FreindState {} //

class FreindLoading extends FreindState {} //FreindEmpty

class FreindLoadingList extends FreindState {} //FreindEmpty

class FreindEmpty extends FreindState {} //

class FreindError extends FreindState {
  final String message;

  FreindError(this.message);
} //

/// حالة خاصة عندما يحتاج المستخدم VIP2 أو أعلى
class FreindRequiresVip extends FreindState {
  final int requiredVipLevel;
  final String feature;

  FreindRequiresVip({
    this.requiredVipLevel = 2,
    this.feature = 'رؤية الزوار',
  });
}

class FreindWaitingFriendRequestsLoaded extends FreindState {
  final List<FriendshipEntity> friendshipEntity;

  FreindWaitingFriendRequestsLoaded(this.friendshipEntity);
  List<Object> get props => [friendshipEntity];
}

class FreindVisitorProfilesLoaded extends FreindState {
  final List<UserEntity> users;

  FreindVisitorProfilesLoaded(this.users);
  List<Object> get props => [users];
}

class FreindFriendsListLoaded extends FreindState {
  final List<FriendUser> users;

  FreindFriendsListLoaded(this.users);
  List<Object> get props => [users];
}
