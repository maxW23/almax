part of 'relation_progress_cubit.dart';

@immutable
abstract class RelationProgressState {}

class RelationProgressInitial extends RelationProgressState {}

class RelationProgressLoading extends RelationProgressState {}

class RelationProgressRelationRequestSent extends RelationProgressState {}

class RelationProgressRelationRequestSentRecently
    extends RelationProgressState {}

class RelationProgressError extends RelationProgressState {
  final String message;

  RelationProgressError(this.message);
} //

class RelationProgressRelationRequestAccepted extends RelationProgressState {}

class RelationProgressRelationRequestDeleted extends RelationProgressState {}
