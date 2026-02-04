import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:lklk/core/utils/functions/snackbar_helper.dart';
import 'package:lklk/generated/l10n.dart';
import 'package:flutter/services.dart';
import 'package:lklk/core/constants/app_colors.dart';
import 'package:lklk/core/constants/color_id_from_backend.dart';
import 'package:lklk/core/constants/styles.dart';
import 'package:lklk/core/utils/gradient_text.dart';
import 'package:lklk/features/auth/domain/entities/user_entity.dart';

class IDSectionUserWidget extends StatefulWidget {
  const IDSectionUserWidget({
    super.key,
    required this.currentUser,
    this.isCopyIcon = true,
    this.isFileIcon = true,
    this.mainAxisAlignment = MainAxisAlignment.start,
    this.isSmall = false,
    this.idColor,
  });

  final UserEntity currentUser;
  final bool isCopyIcon;
  final bool isFileIcon;
  final MainAxisAlignment mainAxisAlignment;
  final bool isSmall;
  // Optional override for ID text and copy icon color
  final Color? idColor;
  @override
  State<IDSectionUserWidget> createState() => _IDSectionUserWidgetState();
}

class _IDSectionUserWidgetState extends State<IDSectionUserWidget> {
  late Color color;
  late Color colorTwo;
  @override
  void initState() {
    super.initState();
    color = ColorUtil.extractColor(widget.currentUser.idColor);
    colorTwo = ColorUtil.extractColorTwo(widget.currentUser.idColorTwo);
    // color = determineColorOne(int.parse(widget.currentUser.level!), true);
    // colorTwo = determineColorTwo(int.parse(widget.currentUser.level!), true);
  }

//////////////////////////////////////////////////////////////////////////
//////////////////////////////////////////////////////////////////////////

  @override
  Widget build(BuildContext context) {
    return InkWell(
      borderRadius: BorderRadius.circular(20),
      splashColor: AppColors.blackWithOpacity5,
      focusColor: AppColors.blackWithOpacity5,
      hoverColor: AppColors.blackWithOpacity5,
      highlightColor: AppColors.blackWithOpacity5,
      onTap: () {
        Clipboard.setData(
            ClipboardData(text: widget.currentUser.totalSocre ?? ""));
        SnackbarHelper.showMessage(
          context,
          S.of(context).doneCopiedToClipboard,
        );
      },
      child: Row(
        mainAxisAlignment: widget.mainAxisAlignment,
        crossAxisAlignment: CrossAxisAlignment.center,
        mainAxisSize: MainAxisSize.min,
        children: [
          // widget.isCopyIcon
          //     ? CircleAvatar(
          //         backgroundColor: AppColors.whiteIcon,
          //         radius: 8.r,
          //         child: Icon(
          //           FontAwesomeIcons.idCard,
          //           size: 8.r,
          //           // color: color,
          //         ))
          //     : const SizedBox(),
          GradientText(
            'ID: ${widget.currentUser.totalSocre}',
            textAlign: TextAlign.center,
            gradient: widget.idColor != null
                ? LinearGradient(colors: [widget.idColor!, widget.idColor!])
                : LinearGradient(colors: [
                    color,
                    colorTwo,
                  ]),
            style: Styles.textStyle12bold.copyWith(
              fontSize: widget.isSmall ? 10 : 12,
            ),
          ),
          widget.isCopyIcon
              ? SizedBox(
                  width: widget.isSmall ? 3.w : 5.w,
                )
              : const SizedBox(),
          widget.isCopyIcon
              ? Icon(
                  Icons.copy,
                  size: widget.isSmall ? 10.r : 12.r,
                  color: widget.idColor ?? colorTwo,
                )
              : const SizedBox(),
          widget.isCopyIcon
              ? SizedBox(
                  width: widget.isSmall ? 0.5.w : 1.w,
                )
              : const SizedBox(),
        ],
      ),
    );
  }
}
