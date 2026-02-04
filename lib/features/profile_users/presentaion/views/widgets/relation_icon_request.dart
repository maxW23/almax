// ignore_for_file: public_member_api_docs, sort_constructors_first

import 'package:flutter/material.dart';
import 'package:lklk/core/constants/app_colors.dart';
import 'package:lklk/features/auth/domain/entities/user_entity.dart';
import 'package:lklk/features/home/presentation/manger/room_cubit/room_cubit_cubit.dart';
import 'package:lklk/features/profile_users/presentaion/manger/user_cubit/user_cubit_cubit.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:lklk/features/profile_users/presentaion/views/pages/user_profile_edit_page.dart';
import 'package:lklk/core/realtime/notification_realtime_service.dart';

import 'received_relation_requests_list_page.dart';

class RelationIconRequest extends StatefulWidget {
  const RelationIconRequest({
    super.key,
    required this.userCubit,
    required this.roomCubit,
    required this.user,
  });

  final UserCubit userCubit;
  final RoomCubit roomCubit;
  final UserEntity user;

  @override
  State<RelationIconRequest> createState() => _RelationIconRequestState();
}

class _RelationIconRequestState extends State<RelationIconRequest> {
  @override
  Widget build(BuildContext context) {
    final rt = NotificationRealtimeService.instance;
    return Padding(
      padding: const EdgeInsets.only(right: 12, left: 12, top: 5),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          ValueListenableBuilder<int>(
            valueListenable: rt.relationUnread,
            builder: (context, relationUnread, _) {
              final bool showBadge = relationUnread > 0;
              final String label = relationUnread > 99
                  ? '99+'
                  : (relationUnread > 0 ? '$relationUnread' : '');
              return Stack(
                children: [
                  TextButton(
                    onPressed: () async {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (context) =>
                              ReceivedRelationRequestsListPage(
                            userCubit: widget.userCubit,
                            roomCubit: widget.roomCubit,
                          ),
                        ),
                      );
                      await NotificationRealtimeService.instance
                          .markRelationRead();
                    },
                    child: Column(
                      children: [
                        SvgPicture.asset(
                          'assets/images/my_profile_icon/Heart_icon_red.svg',
                          height: 26,
                          width: 30,
                          fit: BoxFit.fill,
                        ),
                        Text(
                          'CP',
                          style: TextStyle(
                              color: AppColors.black,
                              fontSize: 9,
                              fontWeight: FontWeight.w900),
                        )
                      ],
                    ),
                  ),
                  if (showBadge)
                    Positioned(
                      top: 10,
                      right: 8,
                      child: Container(
                        padding: const EdgeInsets.symmetric(
                            horizontal: 4, vertical: 1.5),
                        constraints:
                            const BoxConstraints(minWidth: 14, minHeight: 14),
                        decoration: BoxDecoration(
                          color: AppColors.danger,
                          borderRadius: BorderRadius.circular(10),
                          boxShadow: const [
                            BoxShadow(
                                color: Colors.black26,
                                blurRadius: 2,
                                offset: Offset(0, 1)),
                          ],
                        ),
                        alignment: Alignment.center,
                        child: Text(
                          label,
                          style: const TextStyle(
                            color: Colors.white,
                            fontSize: 9,
                            fontWeight: FontWeight.w800,
                            height: 1.0,
                          ),
                        ),
                      ),
                    ),
                ],
              );
            },
          ),
          const SizedBox(height: 6),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 5),
            child: GestureDetector(
              onTap: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => UserProfileEditPage(
                      userCubit: widget.userCubit,
                      user: widget.user,
                    ),
                  ),
                );
              },
              child: Container(
                width: 77,
                height: 20,
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(10),
                  gradient: const LinearGradient(
                    colors: [Color(0xFF6D2EC2), Color(0xFFB50189)],
                    begin: Alignment.centerLeft,
                    end: Alignment.centerRight,
                  ),
                ),
                alignment: Alignment.center,
                child: Text(
                  Localizations.localeOf(context)
                          .languageCode
                          .toLowerCase()
                          .startsWith('ar')
                      ? 'تعديل الملف'
                      : 'Edit Profile',
                  style: const TextStyle(
                    color: Colors.white,
                    fontSize: 11,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
