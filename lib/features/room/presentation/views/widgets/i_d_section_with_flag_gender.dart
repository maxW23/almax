import 'package:country_flags/country_flags.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:lklk/features/room/presentation/views/widgets/gender_icon.dart';
import 'package:lklk/features/room/presentation/views/widgets/i_d_section_user_widget.dart';
import 'package:lklk/features/room/presentation/views/widgets/user_widget_title.dart';

class IDSectionWithFlagGender extends StatelessWidget {
  const IDSectionWithFlagGender({
    super.key,
    required this.widget,
  });

  final UserWidgetTitle widget;

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        widget.user.gender == "female"
            ? GenderIcon(
                isFemale: true,
                size: widget.isSmall ? 14 : 17,
                iconSize: widget.isSmall ? 6 : 8,
              )
            : GenderIcon(
                isFemale: false,
                size: widget.isSmall ? 14 : 17,
                iconSize: widget.isSmall ? 6 : 8,
              ),
        SizedBox(width: widget.isSmall ? 2.w : 3.w),
        CountryFlag.fromCountryCode(
          widget.user.country != "null" ? widget.user.country ?? 'sy' : 'sy',
          shape: RoundedRectangle(3.r),
          height: (widget.isSmall ? 12.h : 15.h),
          width: (widget.isSmall ? 16.w : 20.w),
          // borderRadius: 2,
        ),
        SizedBox(width: widget.isSmall ? 3.w : 5.w),
        Expanded(
          child: IDSectionUserWidget(
            currentUser: widget.user,
            mainAxisAlignment: MainAxisAlignment.start,
            isSmall: widget.isSmall,
            idColor: widget.idColor,
          ),
        ),
      ],
    );
  }
}
