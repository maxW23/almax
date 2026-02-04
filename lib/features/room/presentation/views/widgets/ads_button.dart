import 'package:flutter/material.dart';
import 'package:lklk/core/constants/assets.dart';
import 'package:lklk/features/profile_users/presentaion/manger/user_cubit/user_cubit_cubit.dart';
import 'package:lklk/features/room/presentation/views/widgets/ads_bottomsheet.dart';
import 'package:flutter_svg/flutter_svg.dart';

class AdsButton extends StatelessWidget {
  const AdsButton({super.key, required this.userCubit});
  final UserCubit userCubit;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () => AdsBottomsheet.showBasicModalBottomSheet(context, userCubit),
      child: SvgPicture.asset(
        AssetsData.coinsBtnIconSvg,
        fit: BoxFit.fill,
        width: MediaQuery.of(context).size.width * 0.10,
        height: MediaQuery.of(context).size.width * 0.10,
      ),
    );
  }
}
