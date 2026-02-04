import 'package:flutter/material.dart';
import 'package:lklk/features/auth/domain/entities/user_entity.dart';
import 'package:lklk/features/profile_users/presentaion/manger/user_cubit/user_cubit_cubit.dart';
import 'package:lklk/features/room/presentation/views/widgets/exit_room_button_app_bar.dart';
import 'package:lklk/features/room/presentation/views/widgets/faviorate_room_btn.dart';
import 'package:lklk/zego_sdk_manager.dart';
import '../../../../home/presentation/manger/room_cubit/room_cubit_cubit.dart';
import '../../../domain/entities/room_entity.dart';

import 'user_information_widget.dart';

class RoomAppbar extends StatelessWidget implements PreferredSizeWidget {
  const RoomAppbar({
    super.key,
    required this.room,
    required this.roomCubit,
    this.users,
    this.bannedUsers,
    required this.userCubit,
    required this.onSend,
    this.adminUsers,
  });
  final RoomEntity room;
  final RoomCubit roomCubit;
  final List<UserEntity>? users;
  final List<UserEntity>? adminUsers;
  final List<UserEntity>? bannedUsers;
  final UserCubit userCubit;
  final void Function(ZIMMessage) onSend;
  @override
  Widget build(BuildContext context) {
    double width = MediaQuery.sizeOf(context).width;
    return PreferredSize(
      preferredSize: const Size(double.infinity, kToolbarHeight),
      child: AppBar(
        backgroundColor: Colors.transparent,
        leadingWidth: width / 2.5,
        automaticallyImplyLeading: false,
        elevation: 0.0,
        actions: [
          UserInformationWidget(
            room: room,
            roomCubit: roomCubit,
            bannedUsers: bannedUsers,
            users: users,
            userCubit: userCubit,
            onSend: onSend,
            adminUsers: adminUsers,
          ),
          const Spacer(),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 5),
            child: FavoriteRoomBtn(
              room: room,
            ),
          ),
          ExitRoomButtonAppBar(
            roomCubit: roomCubit,
            userCubit: userCubit,
            room: room,
          ),
        ],
      ),
    );
  }

  @override
  Size get preferredSize => const Size.fromHeight(kToolbarHeight);
}
