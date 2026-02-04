part of 'join_to_wakala_cubit.dart';

abstract class JoinToWakalaState {}

class JoinToWakalaInitial extends JoinToWakalaState {}

class JoinToWakalaSuccess extends JoinToWakalaState {
  final String message;
  JoinToWakalaSuccess(this.message);
}

class JoinToWakalaError extends JoinToWakalaState {
  final String message;

  JoinToWakalaError(this.message);
}
