import 'package:flutter/material.dart';
import 'package:lklk/core/service_locator.dart';
import 'package:lklk/features/room/domain/entities/luck_bag_entity.dart';
import 'package:lklk/features/room/presentation/manger/lucky_bag/luck_bag_cubit.dart';
import 'package:flutter_svg/flutter_svg.dart';

import 'lucky_bag_buy_dialog.dart'; // أضف هذا
import 'lucky_bag_types.dart'; // وأيضاً هذا

class LuckyBagBtn extends StatelessWidget {
  const LuckyBagBtn({
    super.key,
    required this.roomID,
  });

  final String roomID;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () async {
        final result = await showModalBottomSheet<LuckyBagResult>(
          context: context,
          isScrollControlled: true,
          backgroundColor: Colors.transparent,
          builder: (context) {
            return LuckyBagBuyBottomSheet(
              initialType: LuckyBagType.superr,
              initialAmount: 8000,
              initialMaxParticipants: 7,
            );
          },
        );

        if (result != null) {
          final luckBagCubit = sl<LuckBagCubit>();

          final luckBagEntity = LuckBagEntity(
            roomID: roomID,
            who: result.maxParticipants.toString(),
            how: result.amount.toString(),
          );

          if (!luckBagCubit.isClosed && !luckBagCubit.isClosed) {
            luckBagCubit.purchaseBag(luckBagEntity);
          } else {
            // إعادة تهيئة الـ Cubit إذا كان مغلقاً
            resetLuckBagCubit();
            luckBagCubit.purchaseBag(luckBagEntity);
          }
        }
      },
      child: SvgPicture.asset(
        'assets/icons/room_btn/money_bag_icon_btn.svg',
        height: 45,
        width: 45,
      ),
    );
  }
}
