import 'package:flutter/material.dart';
import 'package:auto_size_text/auto_size_text.dart';
import 'package:lklk/core/utils/functions/snackbar_helper.dart';
import 'package:lklk/features/profile_users/presentaion/manger/fetch_elements_cubit/fetch_elements_cubit.dart';
import 'package:lklk/generated/l10n.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:lklk/core/constants/app_colors.dart';
import 'package:lklk/core/constants/assets.dart';
import 'package:lklk/features/profile_users/presentaion/manger/buy_store_item/buy_item_cubit.dart';
import 'package:lklk/features/profile_users/presentaion/views/widgets/store_profile_view.dart';

class StoreBottomNavigationbar extends StatelessWidget {
  const StoreBottomNavigationbar({
    super.key,
    required this.widget,
    required this.selectedItemId,
    required this.fetchElementsCubit,
  });

  final StoreProfileView widget;
  final int? selectedItemId;
  final FetchElementsCubit fetchElementsCubit;

  @override
  Widget build(BuildContext context) {
    return BlocProvider<BuyItemCubit>(
      lazy: true,
      create: (context) => BuyItemCubit(),
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 6),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            Image.asset(
              AssetsData.coins,
              height: 24,
            ),
            AutoSizeText(
              '${widget.user.wallet}',
              style: const TextStyle(
                fontWeight: FontWeight.w600,
                fontSize: 20,
              ),
            ),
            const Spacer(),
            if (selectedItemId != null)
              BuyBtn(
                  selectedItemId: selectedItemId,
                  fetchElementsCubit: fetchElementsCubit)
          ],
        ),
      ),
    );
  }
}

class BuyBtn extends StatelessWidget {
  const BuyBtn({
    super.key,
    required this.selectedItemId,
    required this.fetchElementsCubit,
  });

  final int? selectedItemId;
  final FetchElementsCubit fetchElementsCubit;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(
        horizontal: 10,
      ),
      decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(14),
          gradient: const LinearGradient(
              colors: [AppColors.golden, AppColors.goldenhad2])),
      child: TextButton(
          onPressed: () async {
            final buyItemCubit = BlocProvider.of<BuyItemCubit>(context);
            final int itemId = selectedItemId ?? 0;
            final String message = await buyItemCubit.buyStoreItem(itemId);
            await fetchElementsCubit.fetchMyElements();

            SnackbarHelper.showMessage(context, message);
          },
          child: AutoSizeText(
            S.of(context).buy,
            style: const TextStyle(
                fontWeight: FontWeight.w600,
                fontSize: 20,
                color: AppColors.white),
          )),
    );
  }
}
