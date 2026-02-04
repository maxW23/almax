import 'package:flutter/material.dart';
import 'package:lklk/core/constants/assets.dart';
import 'package:lklk/core/player/svga_custom_player.dart';

class SheildVIPSVGA extends StatelessWidget {
  final int vip;
  const SheildVIPSVGA({super.key, required this.vip});

  @override
  Widget build(BuildContext context) {
    return CustomSVGAWidget(
      isPadding: false,
      height: 75 * 2,
      width: 75 * 2,
      isRepeat: true,
      pathOfSvgaFile: getImageVIP(vip),
    );
  }

  String getImageVIP(int vip) {
    switch (vip) {
      case 4:
        return AssetsData.vip5SvgaSheildSVGA;
      case 1:
        return AssetsData.vip1SvgaSheildSVGA;
      case 2:
        return AssetsData.vip2SvgaSheildSVGA;
      case 3:
        return AssetsData.vip3SvgaSheildSVGA;
      // case 4:
      //   return AssetsData.vip4SvgaSheildSVGA;
      case 5:
        return AssetsData.vip5SvgaSheildSVGA;

      default:
        return '';
    }
  }
}
