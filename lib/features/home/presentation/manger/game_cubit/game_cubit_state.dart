part of 'game_cubit_cubit.dart';

// lklk_game_add
abstract class GameCubitState extends Equatable {
  const GameCubitState();

  @override
  List<Object> get props => [];
}

///////////////////////////////////////////////

class GameCubitInitial extends GameCubitState {}

class GameCubitLoading extends GameCubitState {}

class GameCubitLoaded extends GameCubitState {
  final GameListBaen games;

  const GameCubitLoaded(this.games);

  @override
  List<Object> get props => [games];
}

class GameCubitError extends GameCubitState {
  final String message;

  const GameCubitError(this.message);

  @override
  List<Object> get props => [message];
}
