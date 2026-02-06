import 'package:dio/dio.dart';
import 'package:equatable/equatable.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:lklk/core/services/auth_service.dart';
import 'package:lklk/features/room/domain/entities/game_list_baen.dart';
part 'game_cubit_state.dart';

// lklk_game_add
class GameCubitCubit extends Cubit<GameCubitState> {
  GameCubitCubit() : super(GameCubitInitial());

  final Dio dio = Dio();

  Future<GameListBaen?> getGameList(int roomId) async {
    try {
      // Prefer test server game list for verification before production
      final response = await dio.get(
        'https://gztest.leadercc.com/lklklive_games/test_game_list.json',
      );

      if (response.statusCode == 200) {
        final result = response.data;
        final responseData = result['data'];
        final GameListBaen gameList = GameListBaen.fromJson(responseData);

        emit(GameCubitLoaded(gameList));
        return gameList;
      } else {
        throw Exception('Failed to get game list from room');
      }
    } catch (e) {
      throw Exception('Failed to get game list from room');
    }
  }
}
