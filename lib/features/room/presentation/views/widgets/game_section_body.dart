import 'package:flutter/material.dart';
import 'package:lklk/features/room/presentation/views/widgets/game_button.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:lklk/features/home/presentation/manger/game_cubit/game_cubit_cubit.dart';
import 'package:lklk/features/room/domain/entities/game_bean.dart';
import 'package:lklk/features/room/domain/entities/game_config.dart';
import 'package:lklk/features/room/domain/entities/game_list_baen.dart';

class GameSectionBody extends StatefulWidget {
  const GameSectionBody({super.key, required this.roomId});
  final int roomId;
  @override
  State<GameSectionBody> createState() => _GameSectionBodyState();
}

class _GameSectionBodyState extends State<GameSectionBody> {
  List<GameBean>? games;
  GameConfig? gameConfig;
  @override
  void initState() {
    getGameList();
    super.initState();
  }

  Future<void> getGameList() async {
    final cubit = context.read<GameCubitCubit>();

    GameListBaen? result = await cubit.getGameList(widget.roomId);

    if (result != null) {
      setState(() {
        games = result.gameList;
        gameConfig = result.config;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return GameButton(games: games, gameConfig: gameConfig);
  }
}
