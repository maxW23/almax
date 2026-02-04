import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:lklk/features/home/presentation/manger/game_cubit/game_cubit_cubit.dart';
import 'package:lklk/features/room/presentation/views/widgets/game_section_body.dart';

class GameSection extends StatelessWidget {
  const GameSection({super.key, required this.roomId});
  final int roomId;

  @override
  Widget build(BuildContext context) {
    return BlocProvider<GameCubitCubit>(
        create: (context) => GameCubitCubit(),
        child: GameSectionBody(
          roomId: roomId,
        ));
  }
}
