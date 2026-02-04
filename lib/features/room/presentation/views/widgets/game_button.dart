import 'package:flutter/material.dart';
import 'package:lklk/core/constants/assets.dart';
import 'package:lklk/features/room/domain/entities/game_bean.dart';
import 'package:lklk/features/room/domain/entities/game_config.dart';
import 'package:lklk/features/room/presentation/views/widgets/show_game_list.dart';
import 'package:flutter_svg/flutter_svg.dart';

class GameButton extends StatelessWidget {
  const GameButton({
    super.key,
    required this.games,
    required this.gameConfig,
  });

  final List<GameBean>? games;
  final GameConfig? gameConfig;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () {
        if (gameConfig != null) {
          showGameList(context, games ?? [], gameConfig!);
        }
      },
      child: SvgPicture.asset(
        AssetsData.gameIconBtnSvg,
        fit: BoxFit.fill,
        width: MediaQuery.of(context).size.width * 0.10,
        height: MediaQuery.of(context).size.width * 0.10,
      ),
    );
  }
}
