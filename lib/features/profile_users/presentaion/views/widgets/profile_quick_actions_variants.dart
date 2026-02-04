import 'package:flutter/material.dart';
import 'package:lklk/features/auth/domain/entities/user_entity.dart';
import 'package:lklk/features/home/presentation/manger/room_cubit/room_cubit_cubit.dart';
import 'package:lklk/features/profile_users/domain/entities/elements_entity.dart';
import 'package:lklk/features/profile_users/presentaion/manger/user_cubit/user_cubit_cubit.dart';
import 'package:lklk/features/profile_users/presentaion/views/pages/agency_center_page.dart';
import 'package:lklk/features/profile_users/presentaion/views/pages/profile_gifts_page.dart';
import 'package:lklk/features/profile_users/presentaion/views/widgets/profile_quick_actions_row.dart';
import 'package:lklk/generated/l10n.dart';

/// Specialized quick actions row for the current user's profile page
class SelfProfileQuickActionsRow extends StatelessWidget {
  const SelfProfileQuickActionsRow({
    super.key,
    required this.user,
    required this.userCubit,
    required this.roomCubit,
    this.giftList,
    this.frameList,
    this.entryList,
  });

  final UserEntity user;
  final UserCubit userCubit;
  final RoomCubit roomCubit;
  final List<ElementEntity>? giftList;
  final List<ElementEntity>? frameList;
  final List<ElementEntity>? entryList;

  @override
  Widget build(BuildContext context) {
    return ProfileQuickActionsRow(
      items: [
        ProfileQuickActionItem(
          title: S.of(context).gifts,
          icon: 'assets/images/my_profile_icon/gift_icon_red.svg',
          onTap: () {
            Navigator.push(
              context,
              MaterialPageRoute(
                builder: (_) => ProfileGiftsPage(
                  gifts: giftList ?? const [],
                  frames: frameList ?? const [],
                  cars: entryList ?? const [],
                ),
              ),
            );
          },
        ),
        // if (user.type == 'mini' && (user.power == 'null' || user.power == null))
        //   ProfileQuickActionItem(
        //     title: S.of(context).agency,
        //     icon: 'assets/images/my_profile_icon/agency_icon.svg',
        //     onTap: () {
        //       Navigator.push(
        //         context,
        //         MaterialPageRoute(
        //           builder: (_) => AgencyCenterPage(user: user),
        //         ),
        //       );
        //     },
        //   ),
      ],
    );
  }
}

/// Specialized quick actions row for other user's profile page
class OtherProfileQuickActionsRow extends StatelessWidget {
  const OtherProfileQuickActionsRow({
    super.key,
    required this.user,
    required this.userCubit,
    required this.roomCubit,
    this.giftList,
    this.frameList,
    this.entryList,
  });

  final UserEntity user;
  final UserCubit userCubit;
  final RoomCubit roomCubit;
  final List<ElementEntity>? giftList;
  final List<ElementEntity>? frameList;
  final List<ElementEntity>? entryList;

  @override
  Widget build(BuildContext context) {
    return ProfileQuickActionsRow(
      items: [
        ProfileQuickActionItem(
          title: S.of(context).gifts,
          icon: 'assets/images/my_profile_icon/gift_icon_red.svg',
          onTap: () {
            Navigator.push(
              context,
              MaterialPageRoute(
                builder: (_) => ProfileGiftsPage(
                  gifts: giftList ?? const [],
                  frames: frameList ?? const [],
                  cars: entryList ?? const [],
                ),
              ),
            );
          },
        ),
        if (user.type == 'mini' && (user.power == 'null' || user.power == null))
          ProfileQuickActionItem(
            title: S.of(context).agency,
            icon: 'assets/images/my_profile_icon/agency_icon.svg',
            onTap: () {
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (_) => AgencyCenterPage(user: user),
                ),
              );
            },
          ),
      ],
    );
  }
}
