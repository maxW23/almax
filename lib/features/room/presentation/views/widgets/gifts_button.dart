import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:lklk/core/constants/assets.dart';
import 'package:lklk/core/utils/gifts_bottom_sheet.dart';

import 'package:lklk/features/home/presentation/manger/gifts_show_cubit/gifts_show_cubit.dart';
import 'package:lklk/features/room/presentation/views/widgets/room_buttons_row.dart';
import 'package:flutter_svg/flutter_svg.dart';

class GiftsButton extends StatelessWidget {
  const GiftsButton({
    super.key,
    required this.widget,
  });

  final RoomButtonsRow widget;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () {
        GiftsBottomSheetWidget.showBasicModalBottomSheet(
          context,
          widget.user,
          widget.room.id.toString(),
          widget.userCubit,
          context.read<GiftsShowCubit>(),
          widget.onSend,
          [widget.user],
        );
      },
      child: SvgPicture.asset(
        AssetsData.giftsIconBtnSvg,
        width: MediaQuery.of(context).size.width * 0.10,
        height: MediaQuery.of(context).size.width * 0.10,
      ),
    );
  }
}
