import 'package:lklk/core/utils/logger.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:lklk/core/animations/icon_animated.dart';
import 'package:lklk/features/auth/domain/entities/user_entity.dart';
import 'package:lklk/features/home/presentation/manger/room_cubit/room_cubit_cubit.dart';
import 'package:lklk/features/room/presentation/views/widgets/custom_duration_dialog.dart';
import 'package:lklk/generated/l10n.dart';

class KickUserBtn extends StatelessWidget {
  const KickUserBtn({
    super.key,
    required this.roomCubit,
    required this.roomId,
    required this.userId,
    required this.bannedUsers,
  });

  final RoomCubit roomCubit;
  final String roomId, userId;
  final List<UserEntity>? bannedUsers;

  @override
  Widget build(BuildContext context) {
    final isBanned = bannedUsers?.any((user) => user.iduser == userId) ?? false;

    return BlocBuilder<RoomCubit, RoomCubitState>(
      builder: (context, state) {
        return SizedBox(
          width: 70.w,
          height: 70.h,
          child: AnimatedIconButton(
            text: isBanned ? S.of(context).kickOutdone : S.of(context).kickOut,
            isBanned: isBanned,
            onPressed: () async {
              try {
                if (isBanned) {
                  await roomCubit.removeBanFromUser(int.parse(roomId), userId);
                } else {
                  final String? how = await showDialog<String>(
                    context: context,
                    builder: (ctx) => const CustomDurationDialog(),
                  );
                  await roomCubit.banUserFromRoom(
                      int.parse(roomId), userId, how ?? "");
                }
                // Refresh data via Bloc
                if (context.mounted) {
                  roomCubit.refreshRoomData(int.parse(roomId));
                }
              } catch (e) {
                log('Kick error: $e');
              }
            },
          ),
        );
      },
    );
  }
}
