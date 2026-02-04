import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:lklk/core/constants/app_colors.dart';
import 'package:lklk/features/room/presentation/views/widgets/button_icon_with_text_widget.dart';

class AddAdminBtn extends StatelessWidget {
  const AddAdminBtn({
    super.key,
    this.onPressed,
    required this.title,
  });

  final void Function()? onPressed;
  final String title;

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: 70.w,
      height: 70.h,
      child: TextButton(
        onPressed: onPressed,
        child: ButtonIconWithTextWidget(
          text: title,
                    colorText: AppColors.black,
          svgAsset: 'assets/icons/user_vip_sheet_icons/admin_icon_gray.svg',
        ),
      ),
    );
  }
}
