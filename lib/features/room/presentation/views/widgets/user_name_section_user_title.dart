import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:lklk/core/constants/app_colors.dart';
import 'package:lklk/core/constants/styles.dart';
import 'package:lklk/features/auth/domain/entities/user_entity.dart';
import 'package:lklk/features/room/presentation/views/widgets/name_user_widget.dart';

class UserNameSectionUserTitle extends StatelessWidget {
  const UserNameSectionUserTitle({
    super.key,
    required this.currentUser,
    this.isNameOnly = false,
    this.isSmall = false,
    this.nameColor,
  });

  final UserEntity currentUser;
  final bool isNameOnly;
  final bool isSmall;
  final Color? nameColor;

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        isNameOnly
            ? const SizedBox()
            : Padding(
                padding:
                    EdgeInsets.only(bottom: isSmall ? 2.r : 4.r),
                child: CircleAvatar(
                  backgroundColor: AppColors.whiteIcon,
                  radius: isSmall ? 8.r : 10.r,
                  child: Icon(
                    FontAwesomeIcons.user,
                    size: isSmall ? 8.sp : 10.sp,
                  ),
                ),
              ),
        SizedBox(width: 6.r),
        Flexible(
          child: Align(
            alignment: AlignmentDirectional.centerStart,
            child: NameUserWidget(
              name: currentUser.name!,
              vip: currentUser.vip,
              textAlign: TextAlign.start,
              style: isSmall ? Styles.textStyle12bold : Styles.textStyle14bold,
              increaseFont: !isSmall,
              nameColor: nameColor,
            ),
          ),
        ),
      ],
    );
  }
}
