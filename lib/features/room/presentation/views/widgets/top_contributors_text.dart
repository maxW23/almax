// ignore: file_names

import 'package:flutter/material.dart';
import 'package:auto_size_text/auto_size_text.dart';
import 'package:lklk/core/constants/app_colors.dart';
import 'package:lklk/core/constants/assets.dart';

class TopContributorsText extends StatelessWidget {
  const TopContributorsText({
    super.key,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      alignment: Alignment.center,
      decoration: const BoxDecoration(
          borderRadius: BorderRadius.only(
            topLeft: Radius.circular(30),
            topRight: Radius.circular(30),
          ),
          gradient: LinearGradient(colors: [
            AppColors.goldenhad1,
            AppColors.goldenhad2,
            AppColors.white,
            AppColors.white,
            AppColors.white,
            AppColors.white,
            AppColors.white,
            AppColors.goldenhad2,
            AppColors.goldenhad1,
          ])),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Image.asset(AssetsData.cup, width: 25, height: 25),
          const SizedBox(
            width: 10,
          ),
          const AutoSizeText(
            'Top Contributors',
            style: TextStyle(
              fontSize: 20,
              fontWeight: FontWeight.w700,
              color: AppColors.goldenhad1,
              backgroundColor: AppColors.white,
            ),
          ),
        ],
      ),
    );
  }
}
/**
 class TopUserBottomSheet extends StatefulWidget {
  final UserCubit userCubit;
  final List<UserEntity>? users;
  final bool isAdd;
  final int? roomId;
  final IconData? icon;
  final Function(int, String)? onUserAction;
  final Function()? onUpdateUI;

  const TopUserBottomSheet({
    super.key,
    required this.userCubit,
    required this.users,
    this.isAdd = false,
    this.roomId,
    this.icon,
    this.onUserAction,
    this.onUpdateUI,
  });

  @override
  State<TopUserBottomSheet> createState() => _TopUserBottomSheetState();

  // Static method to show the bottom sheet
  static Future<void> showBasicModalBottomSheet(
    BuildContext context,
    UserCubit userCubit,
    List<UserEntity>? users, {
    bool isAdd = false,
    int? roomId,
    IconData? icon,
    Function(int, String)? onUserAction,
    Function()? onUpdateUI,
  }) async {
    showModalBottomSheet(
     barrierColor: Colors.transparent,
      backgroundColor: AppColors.white,
      context: context,
      builder: (BuildContext context) {
        return TopUserBottomSheet(
          userCubit: userCubit,
          users: users,
          isAdd: isAdd,
          roomId: roomId,
          icon: icon,
          onUserAction: onUserAction,
          onUpdateUI: onUpdateUI,
        );
      },
    );
  }
}

class _TopUserBottomSheetState extends State<TopUserBottomSheet> {
  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: MediaQuery.of(context).viewInsets,
      child: SizedBox(
        height: MediaQuery.of(context).size.height * 0.7,
        child: ListView.builder(
          itemCount: widget.users?.length ?? 0,
          itemBuilder: (BuildContext context, int index) {
            final user = widget.users![index];
            return UserWidgetTitle(
              user: user,
              userCubit: widget.userCubit,
              icon: widget.icon,
              isAdd: widget.isAdd,
              roomId: widget.roomId,
              onUserAction: widget.onUserAction,
              isIcon: true,
              onTap: () {
                UserVIPBottomSheetWidget.showBasicModalBottomSheet(
                    context, user, widget.userCubit);
              },
            );
          },
        ),
      ),
    );
  }
}

 */
// UserListItem(
//   user: user,
//   isAdd: isAdd,
//   roomId: roomId,
//   icon: icon,
//   onUserAction: onUserAction,
//   onUpdateUI: onUpdateUI,
//   userCubit: userCubit,
// ); // 000 000
