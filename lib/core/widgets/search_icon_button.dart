import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:lklk/features/home/presentation/manger/room_cubit/room_cubit_cubit.dart';
import 'package:lklk/features/home/presentation/views/search_view.dart';
import 'package:lklk/features/profile_users/presentaion/manger/user_cubit/user_cubit_cubit.dart';

class SearchIconButton extends StatelessWidget {
  const SearchIconButton(
      {super.key, required this.userCubit, required this.roomCubit});
  final RoomCubit roomCubit;
  final UserCubit userCubit;

  @override
  Widget build(BuildContext context) {
    return IconButton(
      padding: EdgeInsets.zero,
      constraints: const BoxConstraints(minWidth: 36, minHeight: 36),
      onPressed: () {
        Navigator.push(
            context,
            MaterialPageRoute(
              builder: (context) => SearchView(
                userCubit: userCubit,
                roomCubit: roomCubit,
              ),
            ));
      },
      icon: SvgPicture.asset(
        'assets/icons/search_icon.svg',
        color: Colors.black,
        width: 20,
        height: 20,
      ),
    );
  }
}
