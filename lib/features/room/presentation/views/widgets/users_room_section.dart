import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:lklk/features/auth/domain/entities/user_entity.dart';
import 'package:lklk/features/home/presentation/manger/room_cubit/room_cubit_cubit.dart';
import 'package:lklk/features/room/presentation/views/widgets/avatar_user_item.dart';

class UsersRoomSection extends StatefulWidget {
  const UsersRoomSection({
    super.key,
    this.onTap,
    required this.roomId,
  });
  final void Function()? onTap;
  final int roomId;

  @override
  State<UsersRoomSection> createState() => _UsersRoomSectionState();
}

class _UsersRoomSectionState extends State<UsersRoomSection>
    with AutomaticKeepAliveClientMixin {
  @override
  bool get wantKeepAlive => true;

  @override
  void dispose() {
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    super.build(context);

    return BlocConsumer<RoomCubit, RoomCubitState>(
      listener: (BuildContext context, RoomCubitState state) {},
      builder: (context, state) {
        final users = state.usersZego ?? [];

        return Padding(
          padding: const EdgeInsets.symmetric(vertical: 8),
          child: GestureDetector(
            onTap: widget.onTap,
            child: _buildUserAvatars(users),
          ),
        );
      },
    );
  }

  Widget _buildUserAvatars(List<UserEntity> users) {
    if (users.isEmpty) {
      return const SizedBox();
    }
    return Stack(
      children: [
        ...users
            .take(5)
            .toList()
            .asMap()
            .entries
            .map((entry) => _buildAvatarItem(entry.key, entry.value)),
      ],
    );
  }

  Widget _buildAvatarItem(int index, UserEntity user) {
    return AvatarUserItem(
      key: ValueKey(user.id), // مفتاح فريد بناء على معرف المستخدم
      urlImage: user.img ?? "",
      margin: EdgeInsets.only(left: (100 - index * 25).toDouble()),
      size: 40,
    );
  }
}
