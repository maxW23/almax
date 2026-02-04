import 'package:flutter/material.dart';
import 'package:auto_size_text/auto_size_text.dart';
import 'package:lklk/core/constants/app_colors.dart';

class StoreAppbar extends StatelessWidget implements PreferredSizeWidget {
  const StoreAppbar({super.key, this.title});
  final String? title;

  @override
  Size get preferredSize => const Size.fromHeight(kToolbarHeight);

  @override
  Widget build(BuildContext context) {
    return PreferredSize(
        preferredSize: const Size(double.infinity, kToolbarHeight),
        child: Container(
          decoration: const BoxDecoration(
            gradient: LinearGradient(
              colors: [
                AppColors.golden,
                AppColors.goldenhad1,
              ],
            ),
            borderRadius: BorderRadius.only(
              bottomLeft: Radius.circular(70),
              bottomRight: Radius.circular(70),
            ),
          ),
          child: AppBar(
              backgroundColor: AppColors.transparent,
              title: AutoSizeText(
                title ?? 'Store',
                style: const TextStyle(
                  color: AppColors.white,
                ),
              ),
              centerTitle: true,
              // leading: Padding(
              //   padding: const EdgeInsets.symmetric(horizontal: 40),
              //   child: GestureDetector(
              //     onTap: () {
              //       Navigator.push(
              //           context,
              //           MaterialPageRoute(
              //             builder: (context) => const CupboardPageStore(),
              //           ));
              //     },
              //     child: IconButton(
              //         onPressed: () {},
              //         icon: const Icon(
              //           FontAwesomeIcons.basketShopping,
              //           color: AppColors.white,
              //         )),
              //   ),
              // ),
              automaticallyImplyLeading: false),
        ));
  }
}
