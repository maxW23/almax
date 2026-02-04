import 'package:flutter_svg/flutter_svg.dart';
import 'package:lklk/core/utils/logger.dart';

import 'package:flutter/material.dart';
import 'package:permission_handler/permission_handler.dart'; // تأكد من إضافة الحزمة
import 'package:lklk/features/home/presentation/manger/room_cubit/room_cubit_cubit.dart';
import 'package:lklk/features/profile_users/presentaion/manger/user_cubit/user_cubit_cubit.dart';
import 'package:lklk/features/room/domain/entities/room_entity.dart';
import 'package:lklk/features/room/presentation/views/widgets/room_view_bloc.dart';
import 'package:lklk/generated/l10n.dart';

class CreateRoomIcon extends StatefulWidget {
  const CreateRoomIcon({
    super.key,
    required this.roomCubit,
    required this.userCubit,
  });

  final RoomCubit roomCubit;
  final UserCubit userCubit;

  @override
  State<CreateRoomIcon> createState() => _CreateRoomIconState();
}

class _CreateRoomIconState extends State<CreateRoomIcon> {
  RoomEntity? room;
  bool _isCreating = false;

  // دالة طلب إذن الميكروفون
  Future<PermissionStatus> requestMicrophonePermission() async {
    final status = await Permission.microphone.request();
    return status;
  }

  @override
  Widget build(BuildContext context) {
    return IconButton(
      onPressed: _isCreating
          ? null
          : () async {
              setState(() => _isCreating = true);

              // Capture navigation, messenger, and translations before awaits
              final navigator = Navigator.of(context);
              final messenger = ScaffoldMessenger.of(context);
              final s = S.of(context);

              try {
                final status = await requestMicrophonePermission();

                if (!status.isGranted) {
                  if (status.isPermanentlyDenied) {
                    await openAppSettings(); // فتح الإعدادات إذا تم الرفض الدائم
                  } else {
                    messenger.showSnackBar(
                      SnackBar(content: Text(s.microphonePermissionRequired)),
                    );
                  }
                  return;
                }

                final createdRoom = await widget.roomCubit.createRoom();

                if (createdRoom != null) {
                  setState(() => room = createdRoom);

                  navigator.push(
                    PageRouteBuilder(
                      transitionDuration: Duration.zero,
                      reverseTransitionDuration: Duration.zero,
                      pageBuilder: (_, __, ___) => RoomViewBloc(
                        roomId: room!.id,
                        roomCubit: widget.roomCubit,
                        userCubit: widget.userCubit,
                        backgroundImage: room!.background,
                        isForce: false,
                      ),
                    ),
                  );
                } else {
                  messenger.showSnackBar(
                    SnackBar(content: Text(s.failedToCreateRoomPleaseTryAgain)),
                  );
                }
              } catch (e) {
                log("${s.errorCreatingRoom}  $e");
                messenger.showSnackBar(
                  SnackBar(content: Text(s.errorCreatingRoom)),
                );
              } finally {
                setState(() => _isCreating = false);
              }
            },
      icon:SvgPicture.asset(
        'assets/icons/home_icon.svg',
      
       color: Colors.black,
        width: 20,
        height: 20,
      ),
    );
  }
}
