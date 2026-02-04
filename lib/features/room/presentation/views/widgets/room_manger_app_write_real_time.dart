import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:lklk/features/home/presentation/manger/room_cubit/room_cubit_cubit.dart';
import 'package:lklk/features/home/presentation/manger/top_bar_room_cubit/money_bag_top_bar_cubit.dart';
import 'package:lklk/features/home/presentation/manger/top_bar_room_cubit/top_bar_room_cubit.dart';
import 'package:lklk/features/room/presentation/manger/lucky_bag/combined_realtime_service.dart';

class RoomMangerAppWriteRealTime extends StatefulWidget {
  const RoomMangerAppWriteRealTime({
    super.key,
    required this.roomID,
    required this.roomCubit,
  });
  final String roomID;
  final RoomCubit roomCubit;

  @override
  State<RoomMangerAppWriteRealTime> createState() =>
      _RoomMangerAppWriteRealTimeState();
}

class _RoomMangerAppWriteRealTimeState
    extends State<RoomMangerAppWriteRealTime> {
  late final CombinedRealtimeService _combinedService;

  @override
  void initState() {
    super.initState();
    final topBarCubit = context.read<TopBarRoomCubit>();
    final moneyBagTopBarCubit = context.read<MoneyBagTopBarCubit>();
    _combinedService = CombinedRealtimeService(
      topBarCubit: topBarCubit,
      moneyBagTopBarCubit: moneyBagTopBarCubit,
      roomCubit: widget.roomCubit,
      roomID: widget.roomID,
    );
    _combinedService.initRealtime();
  }

  @override
  void dispose() {
    _combinedService.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return const SizedBox();
  }
}
