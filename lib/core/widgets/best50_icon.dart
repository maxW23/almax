import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:lklk/features/home/presentation/views/slide_view/tap_bar_top_50_page.dart';
import 'package:lklk/features/profile_users/presentaion/manger/user_cubit/user_cubit_cubit.dart';

class Best50Icon extends StatelessWidget {
  const Best50Icon({super.key, required this.userCubit});
  final UserCubit userCubit;

  @override
  Widget build(BuildContext context) {
    return IconButton(
      padding: EdgeInsets.zero,
      constraints: const BoxConstraints(minWidth: 36, minHeight: 36),
      onPressed: () => Navigator.push(
        context,
        MaterialPageRoute(
          builder: (context) => TapBarTop50Page(
            userCubit: userCubit,
            initialTabIndex: 1,
          ),
        ),
      ),
      icon: SvgPicture.asset(
        'assets/icons/top_icon.svg',
        color: Colors.black,
        width: 20,
        height: 20,
      ),
    );
  }
}
