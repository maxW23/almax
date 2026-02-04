part of 'relation_cubit.dart';

@immutable
abstract class RelationState {}

class RelationInitial extends RelationState {}

class RelationLoading extends RelationState {}

class RelationError extends RelationState {
  final String message;

  RelationError(this.message);
}

class RelationReceivedRelationRequestsLoaded extends RelationState {
  final List<UserRelation> relationRequests;

  RelationReceivedRelationRequestsLoaded(this.relationRequests);
}

class RelationSentRelationRequestsLoaded extends RelationState {
  final UserRelation relation;
  final UserEntity user;

  RelationSentRelationRequestsLoaded(this.relation, this.user);
}
