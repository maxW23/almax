// ignore_for_file: public_member_api_docs, sort_constructors_first

import 'package:flutter/material.dart';
import 'package:auto_size_text/auto_size_text.dart';
import 'package:lklk/core/utils/functions/snackbar_helper.dart';
import 'package:lklk/generated/l10n.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:lklk/core/constants/app_colors.dart';
import 'package:lklk/core/constants/assets.dart';
import 'package:lklk/core/constants/styles.dart';
import 'package:lklk/core/utils/gradient_text.dart';
import 'package:lklk/features/profile_users/presentaion/manger/buy_svip/buy_svip_cubit.dart';
import 'package:lklk/features/profile_users/presentaion/manger/user_cubit/user_cubit_cubit.dart';

class BottomNavigationBarSVIP extends StatelessWidget {
  final int levelSVIP;

  const BottomNavigationBarSVIP({
    super.key,
    required this.levelSVIP,
  });

  int _getPriceForLevel(int level) {
    switch (level) {
      case 1:
        return 120000;
      case 2:
        return 280000;
      case 3:
        return 950000;
      case 4:
        return 2100000;
      case 5:
        return 4200000;
      default:
        return 0;
    }
  }

  @override
  Widget build(BuildContext context) {
    //log('levelSVIP111 $levelSVIP');
    final userCubit = context.read<UserCubit>();
    int price = _getPriceForLevel(levelSVIP);

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
      decoration: const BoxDecoration(
          color: AppColors.blackshade1,
          border: Border(top: BorderSide(color: AppColors.grey, width: .5))),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.start,
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisSize: MainAxisSize.min,
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.start,
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  Image.asset(
                    AssetsData.coins,
                    width: 30,
                    height: 30,
                  ),
                  const SizedBox(
                    width: 10,
                  ),
                  GradientText(
                    '$price',
                    style: Styles.textStyle34.copyWith(fontSize: 32),
                    gradient: const LinearGradient(
                      begin: Alignment.topLeft,
                      end: Alignment.bottomRight,
                      colors: [
                        Color(0xFFFCC65A),
                        Color(0xFFFDE6B4),
                      ],
                    ),
                  ),
                ],
              ),
              AutoSizeText(
                S.of(context).days30,
                style: Styles.textStyle18.copyWith(
                    color: AppColors.blackshade2, fontWeight: FontWeight.w700),
              ),
            ],
          ),
          const Spacer(),
          Container(
            width: 140,
            height: 50,
            decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(10),
                gradient: const LinearGradient(
                    colors: [AppColors.brownshad1, AppColors.brownshad2],
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight)),
            child: BuyVipBtn(levelSVIP: levelSVIP, userCubit: userCubit),
          )
        ],
      ),
    );
  }
}

class BuyVipBtn extends StatelessWidget {
  const BuyVipBtn({
    super.key,
    required this.levelSVIP,
    required this.userCubit,
  });

  final int levelSVIP;
  final UserCubit userCubit;

  @override
  Widget build(BuildContext context) {
    return BlocProvider<BuySvipCubit>(
      create: (context) => BuySvipCubit(),
      child: BuyVipBtnBody(levelSVIP: levelSVIP, userCubit: userCubit),
    );
  }
}

class BuyVipBtnBody extends StatelessWidget {
  const BuyVipBtnBody({
    super.key,
    required this.levelSVIP,
    required this.userCubit,
  });

  final int levelSVIP;
  final UserCubit userCubit;

  @override
  Widget build(BuildContext context) {
    return BlocConsumer<BuySvipCubit, BuySvipState>(
      listener: (context, state) {
        if (state is BuySvipSuccess) {
          SnackbarHelper.showMessage(
            context,
            state.message,
          );
        } else if (state is BuySvipError) {
          SnackbarHelper.showMessage(context, state.error);
        }
      },
      builder: (context, state) {
        if (state is BuySvipLoading) {
          return const Center(
              child: CircularProgressIndicator(
            color: AppColors.white,
          ));
        }
        return TextButton(
            onPressed: () async {
              await context.read<BuySvipCubit>().buySvip(levelSVIP);
              await userCubit.getProfileUser("BuyVipBtnBody");
            },
            child: AutoSizeText(
              '${S.of(context).join} VIP',
              style: Styles.textStyle28.copyWith(
                  color: AppColors.white,
                  fontSize: 20,
                  fontWeight: FontWeight.w500),
            ));
      },
    );
  }
}
