import 'package:equatable/equatable.dart';

class AlertState extends Equatable {
  @override
  List<Object?> get props => [];
}

class AlertInitial extends AlertState {}

class AlertLoading extends AlertState {}

class AlertLoaded extends AlertState {
  final int massage;
  final int relation;
  final int friendRequest;
  final int visitorList;

  AlertLoaded({
    required this.massage,
    required this.relation,
    required this.friendRequest,
    required this.visitorList,
  });

  @override
  List<Object?> get props => [massage, relation, friendRequest, visitorList];
}

class AlertError extends AlertState {
  final String message;

  AlertError({required this.message});

  @override
  List<Object?> get props => [message];
}
