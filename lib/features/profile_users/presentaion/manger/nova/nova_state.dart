part of 'nova_cubit.dart';

abstract class NovaState {}

class NovaInitial extends NovaState {}

class NovaLoading extends NovaState {}

class NovaConverted extends NovaState {}

class NovaCurrencySwapped extends NovaState {}

class NovaFailed extends NovaState {
  final String message;

  NovaFailed(this.message);
}
