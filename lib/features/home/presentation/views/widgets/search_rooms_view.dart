import 'package:flutter/material.dart';
import 'package:auto_size_text/auto_size_text.dart';
import 'package:lklk/generated/l10n.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:lklk/features/home/presentation/manger/room_cubit/room_cubit_cubit.dart';
import 'package:lklk/features/home/presentation/manger/search_room/search_room_cubit.dart';
import 'package:lklk/features/home/presentation/manger/search_room/search_room_state.dart';
import 'package:lklk/features/home/presentation/views/widgets/room_item_widget_titles_container.dart';
import 'package:lklk/features/home/presentation/views/widgets/search_white_text_field.dart';
import 'package:lklk/features/profile_users/presentaion/manger/user_cubit/user_cubit_cubit.dart';

class SearchRoomsViewBloc extends StatelessWidget {
  const SearchRoomsViewBloc(
      {super.key, required this.roomCubit, required this.userCubit});
  final RoomCubit roomCubit;
  final UserCubit userCubit;

  @override
  Widget build(BuildContext context) {
    return BlocProvider<SearchRoomCubit>(
      create: (context) => SearchRoomCubit(),
      child: SearchRoomsView(
        roomCubit: roomCubit,
        userCubit: userCubit,
      ),
    );
  }
}

class SearchRoomsView extends StatelessWidget {
  const SearchRoomsView(
      {super.key, required this.roomCubit, required this.userCubit});
  final RoomCubit roomCubit;
  final UserCubit userCubit;
  @override
  Widget build(BuildContext context) {
    final searchRoomCubit = BlocProvider.of<SearchRoomCubit>(context);
    final TextEditingController controller = TextEditingController();

    return SafeArea(
      top: false,
      child: Scaffold(
        body: Column(
          children: [
            SearchTextField(
              controller: controller,
              hintText: S.of(context).iDORName,
              onSubmitted: (value) {
                searchRoomCubit.searchRooms(value);
              },
            ),
            const SizedBox(
              height: 30,
            ),
            Expanded(
              child: BlocBuilder<SearchRoomCubit, SearchRoomState>(
                builder: (context, state) {
                  if (state is SearchRoomLoading) {
                    return const Center(child: CircularProgressIndicator());
                  } else if (state is SearchRoomLoaded) {
                    final rooms = state.rooms;
                    return GridView.builder(
                      itemCount: rooms.length,
                      itemBuilder: (context, index) {
                        final room = rooms[index];
                        return Padding(
                          padding: const EdgeInsets.symmetric(horizontal: 10),
                          child: RoomItemWidgetTitlesContainer(
                              isList: false,
                              room: room,
                              roomCubit: roomCubit,
                              userCubit: userCubit),
                        );
                      },
                      gridDelegate:
                          const SliverGridDelegateWithFixedCrossAxisCount(
                              crossAxisSpacing: 0,
                              mainAxisSpacing: 10,
                              crossAxisCount: 2),
                    );
                  } else if (state is SearchRoomError) {
                    return Center(child: AutoSizeText(state.message));
                  }
                  return Center(
                      child: AutoSizeText(S.of(context).searchForRooms));
                },
              ),
            ),
          ],
        ),
      ),
    );
  }
}
