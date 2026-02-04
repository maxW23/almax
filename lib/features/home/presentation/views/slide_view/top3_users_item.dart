import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:auto_size_text/auto_size_text.dart';
import 'package:lklk/core/constants/app_colors.dart';
import 'package:lklk/core/constants/assets.dart';
import 'package:lklk/core/constants/styles.dart';
import 'package:lklk/core/utils/gradient_text.dart';
import 'package:lklk/features/auth/domain/entities/user_entity.dart';
import 'package:lklk/features/room/presentation/views/widgets/image_user_section_with_fram.dart';
import 'package:lklk/features/room/presentation/views/widgets/level_row_user_title_widget_section.dart';
import 'package:lklk/features/room/presentation/views/widgets/name_user_widget.dart';

class Top3UsersItem extends StatelessWidget {
  const Top3UsersItem({
    super.key,
    required this.user,
    required this.numberOfUser,
    this.positionedRight,
    required this.positionedTop,
    this.padding = 0,
    this.colorNumberPoint = AppColors.golden,
    required this.numberOfCubitTopUsers,
    this.linkPath,
  });

  final UserEntity user;
  final int numberOfUser;
  final double? positionedRight;
  final double positionedTop;
  final double padding;
  final Color colorNumberPoint;
  final int numberOfCubitTopUsers;
  final String? linkPath;

  @override
  Widget build(BuildContext context) {
    final s = MediaQuery.of(context).size;

    return SizedBox(
      width: s.width / 2,
      height: s.height / 4,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.center,
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Expanded(
            child: Stack(
              alignment: Alignment.topCenter,
              children: [
                ImageUserSectionWithFram(
                  img: user.img,
                  linkPath: linkPath,
                  isImage: true,
                  padding: padding,
                  paddingImageOnly: padding,
                  height: 200,
                  width: 200,
                  radius: 65,
                ),
                Positioned(
                  // right: positionedRight,
                  top: positionedTop,
                  child: ClipOval(
                    child: Container(
                      width: 25, // Adjust the width to fit your needs
                      height: 25, // Adjust the height to fit your needs
                      decoration: BoxDecoration(
                        color: colorNumberPoint,
                        borderRadius: BorderRadius.circular(100),
                        border: Border.all(
                            color: AppColors.goldenwhitecolor, width: 2),
                      ),
                      child: Center(
                        child: AutoSizeText(
                          '$numberOfUser',
                          style: const TextStyle(
                              color: AppColors.black,
                              fontSize: 12, // Adjust the font size as needed
                              fontWeight: FontWeight.bold),
                        ),
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
          Padding(
            padding: const EdgeInsets.only(bottom: 10),
            child: Container(
              width: 140.w,
              padding: const EdgeInsets.symmetric(horizontal: 34, vertical: 5),
              decoration: BoxDecoration(
                color: AppColors.white.withValues(alpha: .7),
                borderRadius: BorderRadius.circular(30),
                boxShadow: [
                  BoxShadow(
                    color: AppColors.black.withValues(alpha: .7),
                    blurRadius: 13,
                    spreadRadius: 1,
                    blurStyle: BlurStyle.outer,
                  ),
                ],
              ),
              child: NameUserWidget(
                name: user.name ?? "",
                vip: user.vip,
                textAlign: TextAlign.center,
                style:
                    const TextStyle(fontSize: 12, fontWeight: FontWeight.w700),
              ),
            ),
          ),
          LevelRowUserTitleWidgetSection(
            roomID: user.type ?? "",
            isRoomTypeUser: false,
            isWakel: false,
            user: user,
            mainAxisAlignment: MainAxisAlignment.center,
          ),
          const SizedBox(
            height: 12,
          ),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 34, vertical: 5),
            decoration: BoxDecoration(
              color: AppColors.black.withValues(alpha: .1),
              borderRadius: BorderRadius.circular(30),
              boxShadow: [
                BoxShadow(
                  color: AppColors.black.withValues(alpha: .6),
                  blurRadius: 20,
                  spreadRadius: .4,
                  blurStyle: BlurStyle.normal,
                ),
              ],
            ),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              mainAxisSize: MainAxisSize.min,
              children: [
                GradientText(
                  numberOfCubitTopUsers == 4
                      ? (user.monLevel ?? "0000")
                      : (user.rmonLevelTwo ?? "0000"),
                  // textDirectionBool: true,
                  gradient: const LinearGradient(colors: [
                    AppColors.white,
                    AppColors.white,

                    // AppColors.goldenhad1,
                    // AppColors.brownshad1,
                    // AppColors.brownshad2,
                    // AppColors.goldenhad2,
                  ]),

                  style: Styles.textStyle12bold.copyWith(),
                ),
                const SizedBox(
                    width: 4), // Add spacing between text and image if needed
                Image.asset(
                  AssetsData.coins,
                  width: 16, // Adjust the size as needed
                  height: 16, // Adjust the size as needed
                ),
              ],
            ),
          )
        ],
      ),
    );
  }
}
