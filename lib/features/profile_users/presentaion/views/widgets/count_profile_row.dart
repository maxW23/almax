// ignore_for_file: public_member_api_docs, sort_constructors_first
import 'package:flutter/material.dart';
import 'package:lklk/core/utils/functions/snackbar_helper.dart';
import 'package:lklk/core/utils/logger.dart';
import 'package:lklk/features/home/presentation/manger/room_cubit/room_cubit_cubit.dart';
import 'package:lklk/generated/l10n.dart';
import 'package:lklk/features/auth/domain/entities/user_entity.dart';
import 'package:lklk/features/profile_users/presentaion/manger/user_cubit/user_cubit_cubit.dart';
import 'package:lklk/features/profile_users/presentaion/views/widgets/count_profile_widget.dart';
import 'package:lklk/core/realtime/notification_realtime_service.dart';
import 'friend_list_page.dart';
import 'friend_waiting_list_page.dart';
import 'visitors_list_page.dart';

class CountProfileRow extends StatefulWidget {
  const CountProfileRow({
    super.key,
    required this.userCubit,
    required this.friendNumber,
    required this.visitorNumber,
    required this.friendRequest,
    required this.relationRequest,
    required this.user,
    required this.roomCubit,
  });

  final UserCubit userCubit;
  final RoomCubit roomCubit;

  final UserEntity user;
  final int friendNumber;
  final int visitorNumber;
  final int friendRequest;
  final int relationRequest;

  @override
  State<CountProfileRow> createState() => _CountProfileRowState();
}

class _CountProfileRowState extends State<CountProfileRow> {
  @override
  Widget build(BuildContext context) {
    final rt = NotificationRealtimeService.instance;
    return ValueListenableBuilder<int>(
      valueListenable: rt.visitorUnread,
      builder: (context, visitorUnread, _) {
        try {
          debugAppLogger.debug('[CountProfileRow] 🔁 rebuild: visitorUnread=$visitorUnread');
        } catch (_) {}
        return ValueListenableBuilder<int>(
          valueListenable: rt.friendUnread,
          builder: (context, friendUnread, __) {
            try {
              debugAppLogger.debug('[CountProfileRow] 🔁 rebuild: friendUnread=$friendUnread');
            } catch (_) {}
            return ValueListenableBuilder<int>(
              valueListenable: rt.relationUnread,
              builder: (context, relationUnread, ___) {
                // Relation has its own dedicated UI (RelationIconRequest),
                // so requests here should reflect friendUnread only
                final int requestsBadge = friendUnread;
                try {
                  debugAppLogger.debug('[CountProfileRow] 📊 computed: requestsBadge=$requestsBadge relationUnread=$relationUnread');
                } catch (_) {}
                return Row(
                  mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                  children: [
                    CountProfileWidget(
                      isAlert: visitorUnread > 0,
                      number: '${widget.visitorNumber}',
                      title: S.of(context).visitors,
                      badgeCount: visitorUnread,
                      onTap: () async {
                        final vipLevel = int.tryParse(widget.user.vip ?? '0') ?? 0;
                        if (vipLevel >= 2) {
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (context) => VisitorsListPage(
                                userCubit: widget.userCubit,
                                roomCubit: widget.roomCubit,
                              ),
                            ),
                          );
                          // Reset visitor unread counter once user opens the list
                          await NotificationRealtimeService.instance.markVisitorRead();
                        } else {
                          SnackbarHelper.showMessage(
                              context, S.of(context).seeYourVisitors);
                        }
                      },
                    ),
                    CountProfileWidget(
                      // show dot if either friend or relation has unread
                      isAlert: (requestsBadge > 0) || (relationUnread > 0),
                      number: '${widget.friendRequest}',
                      title: S.of(context).requests,
                      badgeCount: requestsBadge,
                      onTap: () async {
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (context) => FriendWaitingListPage(
                              userCubit: widget.userCubit,
                              roomCubit: widget.roomCubit,
                            ),
                          ),
                        );
                        // Reset both friend and relation unread counters
                        await NotificationRealtimeService.instance.markFriendRead();
                        await NotificationRealtimeService.instance.markRelationRead();
                      },
                    ),
                    CountProfileWidget(
                      number: '${widget.friendNumber}',
                      title: S.of(context).friends,
                      onTap: () async {
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (context) => FriendListPage(
                              userCubit: widget.userCubit,
                              roomCubit: widget.roomCubit,
                            ),
                          ),
                        );
                      },
                    ),
                  ],
                );
              },
            );
          },
        );
      },
    );
  }
}
