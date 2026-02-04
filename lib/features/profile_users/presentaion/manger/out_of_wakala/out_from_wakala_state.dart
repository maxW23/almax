part of 'out_from_wakala_cubit.dart';

@immutable
abstract class OutFromWakalaState {}

class OutFromWakalaInitial extends OutFromWakalaState {}

class OutFromWakalaSuccess extends OutFromWakalaState {
  final String message;
  OutFromWakalaSuccess(this.message);
}

class OutFromWakalaError extends OutFromWakalaState {
  final String message;

  OutFromWakalaError(this.message);
}
