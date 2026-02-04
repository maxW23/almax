import 'package:flutter/material.dart';
import 'package:lklk/generated/l10n.dart';
import 'package:lklk/features/profile_users/presentaion/manger/user_cubit/user_cubit_cubit.dart';
import 'package:lklk/features/profile_users/presentaion/views/widgets/count_profile_widget.dart';

class CountProfileEditRow extends StatelessWidget {
  const CountProfileEditRow({
    super.key,
    required this.userCubit,
    this.friendNumber,
    this.visitorNumber,
    this.giftSend,
    this.giftReciver,
  });
  final UserCubit userCubit;
  final int? friendNumber;
  final int? visitorNumber;
  final String? giftSend, giftReciver;
  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceEvenly,
      children: [
        CountProfileWidget(
          number: '$visitorNumber',
          title: S.of(context).visitors,
          onTap: () {
            // Navigator.push(
            //     context,
            //     MaterialPageRoute(
            //       builder: (context) => VisitorsListPage(
            //         userCubit: userCubit,
            //       ),
            //     ));
          },
        ),
        CountProfileWidget(
          number: '$friendNumber',
          title: S.of(context).friends,
          onTap: () {
            // Navigator.push(
            //     context,
            //     MaterialPageRoute(
            //       builder: (context) => FriendListPage(
            //         userCubit: userCubit,
            //       ),
            //     ));
          },
        ),
        CountProfileWidget(
          number: giftSend ?? '0',
          title: S.of(context).send,
        ),
        CountProfileWidget(
          number: giftReciver ?? '0',
          title: S.of(context).recived,
        ),
      ],
    );
  }
}
