import 'package:lklk/features/room/domain/entities/game_bean.dart';
import 'package:lklk/features/room/domain/entities/game_config.dart';

// lklk_game_add
class GameListBaen {
  List<GameBean>? gameList;
  GameConfig? config;

  GameListBaen({
    this.config,
    this.gameList,
  });

  factory GameListBaen.fromJson(Map<String, dynamic> source) {
    return GameListBaen(
      config: GameConfig.fromJson(source['config']),
      gameList: (source['game_list'] as List<dynamic>)
          .map((item) => GameBean.fromJson(item))
          .toList(),
    );
  }
}
