import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:lklk/features/home/presentation/manger/cubit/room_me_cubit.dart';
import 'package:lklk/features/home/presentation/manger/room_cubit/room_cubit_cubit.dart';
import 'package:lklk/features/home/presentation/views/widgets/room_list_view_widget_titles.dart';
import 'package:lklk/features/profile_users/presentaion/manger/user_cubit/user_cubit_cubit.dart';

class RoomsView extends StatefulWidget {
  const RoomsView({
    super.key,
    required this.roomCubit,
    required this.userCubit,
  });

  final RoomCubit roomCubit;
  final UserCubit userCubit;

  @override
  State<RoomsView> createState() => _RoomsViewState();
}

class _RoomsViewState extends State<RoomsView> {
  late final RoomMeCubit roomMeCubit;

  @override
  void initState() {
    super.initState();
    roomMeCubit = RoomMeCubit();
  }

  @override
  void dispose() {
    roomMeCubit.close();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return BlocProvider<RoomMeCubit>.value(
      value: roomMeCubit,
      child: RoomsHomeViewBodyWidget(
        roomCubit: widget.roomCubit,
        userCubit: widget.userCubit,
        roomMeCubit: roomMeCubit,
      ),
    );
  }
}
