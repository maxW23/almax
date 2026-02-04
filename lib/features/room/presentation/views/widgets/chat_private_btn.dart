import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

import 'package:lklk/core/constants/assets.dart';

import 'package:lklk/features/chat/presentation/views/chat_view.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:lklk/features/home/presentation/manger/room_cubit/room_cubit_cubit.dart';
import 'package:lklk/features/profile_users/presentaion/manger/user_cubit/user_cubit_cubit.dart';
import 'package:lklk/core/realtime/notification_realtime_service.dart';

class ChatPrivateBtn extends StatefulWidget {
  const ChatPrivateBtn({
    super.key,
    required this.userCubit,
    required this.roomCubit,
  });
  final UserCubit userCubit;
  final RoomCubit roomCubit;

  @override
  State<ChatPrivateBtn> createState() => _ChatPrivateBtnState();
}

class _ChatPrivateBtnState extends State<ChatPrivateBtn> {
  String _formatCount(int c) => c > 99 ? '99+' : '$c';

  @override
  Widget build(BuildContext context) {
    final rt = NotificationRealtimeService.instance;
    return ValueListenableBuilder<int>(
      valueListenable: rt.chatUnread,
      builder: (context, unread, _) {
        return GestureDetector(
          onTap: () async {
            await NotificationRealtimeService.instance.markChatRead();
            await showModalBottomSheet(
              context: context,
              isScrollControlled: true, // Allows flexible height
              shape: const RoundedRectangleBorder(
                borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
              ),
              clipBehavior: Clip.antiAlias,
              builder: (context) => SizedBox(
                height: MediaQuery.of(context).size.height * 0.6,
                child: Scaffold(
                  body: ChatView(
                    userCubit: widget.userCubit,
                    roomCubit: widget.roomCubit,
                  ),
                ),
              ),
            );
          },
          child: Stack(
            children: [
              Padding(
                padding: EdgeInsets.all(0),
                child: SvgPicture.asset(
                  AssetsData.chatIconBtnSvg,
                  width: MediaQuery.of(context).size.width * 0.10,
                  height: MediaQuery.of(context).size.width * 0.10,
                ),
              ),
              if (unread > 0)
                Positioned(
                  right: 0,
                  top: 0,
                  child: Container(
                    padding: const EdgeInsets.symmetric(horizontal: 5, vertical: 1.5),
                    constraints: BoxConstraints(minWidth: 14.r, minHeight: 14.r),
                    decoration: BoxDecoration(
                      color: const Color(0xFFFF0000),
                      borderRadius: BorderRadius.circular(10.r),
                    ),
                    alignment: Alignment.center,
                    child: Text(
                      _formatCount(unread),
                      style: TextStyle(
                        color: Colors.white,
                        fontWeight: FontWeight.w900,
                        fontSize: 9.sp,
                      ),
                    ),
                  ),
                ),
            ],
          ),
        );
      },
    );
  }
}
