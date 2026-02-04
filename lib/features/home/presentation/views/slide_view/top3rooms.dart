import 'package:flutter/material.dart';
import 'package:auto_size_text/auto_size_text.dart';
import 'package:lklk/core/constants/app_colors.dart';
import 'package:lklk/core/constants/assets.dart';
import 'package:lklk/core/constants/styles.dart';
import 'package:lklk/core/utils/gradient_text.dart';
import 'package:lklk/features/room/domain/entities/room_entity.dart';
import 'package:lklk/features/room/presentation/views/widgets/name_user_widget.dart';
import 'package:cached_network_image/cached_network_image.dart';

class Top3RoomsItem extends StatelessWidget {
  const Top3RoomsItem({
    super.key,
    required this.room,
    required this.numberOfUser,
    this.padding = 0,
    this.colorNumberPoint = AppColors.golden,
    required this.imagePath,
    required this.frameSize,
    required this.imageSize,
  });

  final RoomEntity room;
  final int numberOfUser;

  final double padding;
  final double frameSize;
  final double imageSize;
  final Color colorNumberPoint;
  final String imagePath;

  @override
  Widget build(BuildContext context) {
    final s = MediaQuery.of(context).size;

    return SizedBox(
      width: s.width / 2,
      height: s.height / 3,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.center,
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Stack(
            alignment: Alignment.topCenter,
            children: [
              // CustomSVGAWidget(
              //   isPadding: false,
              //   height: im,ageSize, // Pass the intended size
              //   width: imageSize,
              //   isRepeat: true,
              //   pathOfSvgaFile: imagePath,
              //   child: Padding(
              //     padding: EdgeInsets.all(padding),
              //     child: CircularUserImage(
              //       imagePath: "https://lklklive.com/img/${room.img}",
              //       isEmpty: false,
              //       radius: imageSize,
              //     ),
              //   ),
              // ),
              Stack(
                alignment: Alignment.center,
                children: [
                  Container(
                    width: imageSize,
                    height: imageSize,
                    padding: EdgeInsets.all(padding),
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      // borderRadius: BorderRadius.circular(20),
                      image: DecorationImage(
                        image: CachedNetworkImageProvider(
                            "https://lklklive.com/img/${room.img}"),
                        fit: BoxFit.cover,
                      ),
                    ),
                  ),
                  Image.asset(
                    width: frameSize,
                    height: frameSize,
                    imagePath,
                    fit: BoxFit.cover,
                  ),
                ],
              ),
              Positioned(
                // right: positionedRight,
                // left: positionedRight,
                top: 0,
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
          const SizedBox(
            height: 10,
          ),
          Padding(
            padding: const EdgeInsets.only(bottom: 5),
            child: Container(
              width: 170,
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
                name: room.name,
                vip: '5',
                textAlign: TextAlign.center,
                style:
                    const TextStyle(fontSize: 12, fontWeight: FontWeight.bold),
              ),
            ),
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
              children: [
                GradientText(
                  '${room.coin}',
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
