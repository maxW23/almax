import 'package:lklk/core/utils/logger.dart';

import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:lklk/core/constants/app_colors.dart';
import 'package:lklk/features/home/presentation/manger/room_cubit/room_cubit_cubit.dart';
import 'package:lklk/features/profile_users/presentaion/views/widgets/profile_item_widget.dart';

class ItemWidget extends StatelessWidget {
  final bool fillColor;
  final IconData icon;
  final String title;
  final String description;
  final Color backgroundColor;
  final Color iconColor;
  final Color color;
  final Function()? onTap;
  final RoomCubit roomCubit;
  final String selectedLanguage;
  final String? svgAsset;
  final bool showDivider;

  const ItemWidget({
    super.key,
    this.fillColor = false,
    this.icon = Icons.attach_money,
    required this.title,
    this.description = "",
    this.backgroundColor = AppColors.primary,
    this.iconColor = AppColors.white,
    this.onTap,
    required this.roomCubit,
    this.color = AppColors.white,
    required this.selectedLanguage,
    this.svgAsset,
    this.showDivider = true,
  });

  @override
  Widget build(BuildContext context) {
    log(selectedLanguage);
    return BlocListener<RoomCubit, RoomCubitState>(
      listener: (context, state) {
        if (state.status.isRoomUpdated) {
          roomCubit.room = state.room;
        }
      },
      child: ProfileItemWidget(
        selectedLanguage: selectedLanguage,
        title: title,
        backgroundColor: backgroundColor,
        description: description,
        fillColor: fillColor,
        icon: icon,
        iconColor: iconColor,
        onTap: onTap,
        svgAsset: svgAsset,
        showDivider: showDivider,
      ),
    );
  }
}
