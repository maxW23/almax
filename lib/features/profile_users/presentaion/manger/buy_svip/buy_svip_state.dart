part of 'buy_svip_cubit.dart';

abstract class BuySvipState extends Equatable {
  const BuySvipState();

  @override
  List<Object> get props => [];
}

class BuySvipInitial extends BuySvipState {}

class BuySvipLoading extends BuySvipState {}

class BuySvipSuccess extends BuySvipState {
  final String message;

  const BuySvipSuccess(this.message);

  @override
  List<Object> get props => [message];
}

class BuySvipError extends BuySvipState {
  final String error;

  const BuySvipError(this.error);

  @override
  List<Object> get props => [error];
}
