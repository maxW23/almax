import 'package:flutter/material.dart';
import 'package:auto_size_text/auto_size_text.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:lklk/core/utils/functions/snackbar_helper.dart';
import 'package:lklk/features/profile_users/presentaion/manger/user_cubit/user_cubit_cubit.dart';
import 'package:lklk/generated/l10n.dart';
import 'package:lklk/core/constants/app_colors.dart';
import 'package:lklk/features/profile_users/presentaion/manger/fetch_elements_cubit/fetch_elements_cubit.dart';
import 'package:lklk/features/profile_users/presentaion/views/widgets/store_profile_view.dart';

class CupboardBottomNavigationbar extends StatelessWidget {
  final StoreProfileView widget;
  final int? selectedItemId;
  final FetchElementsCubit fetchElementsCubit;

  const CupboardBottomNavigationbar({
    super.key,
    required this.widget,
    required this.selectedItemId,
    required this.fetchElementsCubit,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 6),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.center,
        mainAxisAlignment: MainAxisAlignment.spaceEvenly,
        children: [
          if (selectedItemId != null)
            Container(
              padding: const EdgeInsets.symmetric(
                horizontal: 10,
              ),
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(14),
                gradient: const LinearGradient(
                  colors: [AppColors.golden, AppColors.goldenhad2],
                ),
              ),
              child: TextButton(
                onPressed: () async {
                  final int itemId = selectedItemId ?? 0;
                  //log('use $itemId');

                  final String message =
                      await fetchElementsCubit.useElement(itemId);
                  BlocProvider.of<UserCubit>(context)
                      .getProfileUser("CupboardBottomNavigationbar");
                  fetchElementsCubit.fetchMyElements();
                  SnackbarHelper.showMessage(context, message,
                      bottomMargin: 50);
                },
                child: AutoSizeText(
                  S.of(context).use,
                  style: const TextStyle(
                    fontWeight: FontWeight.w600,
                    fontSize: 20,
                    color: AppColors.white,
                  ),
                ),
              ),
            ),
          if (selectedItemId != null)
            Container(
              padding: const EdgeInsets.symmetric(
                horizontal: 10,
              ),
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(14),
                gradient: const LinearGradient(
                  colors: [AppColors.golden, AppColors.goldenhad2],
                ),
              ),
              child: TextButton(
                onPressed: () async {
                  final int itemId = selectedItemId ?? 0;
                  //log('disable $itemId');

                  final String message =
                      await fetchElementsCubit.disableElement(itemId);
                  fetchElementsCubit.fetchMyElements();
                  SnackbarHelper.showMessage(context, message,
                      bottomMargin: 50);
                },
                child: AutoSizeText(
                  S.of(context).unuse,
                  style: const TextStyle(
                    fontWeight: FontWeight.w600,
                    fontSize: 20,
                    color: AppColors.white,
                  ),
                ),
              ),
            ),
        ],
      ),
    );
  }
}
