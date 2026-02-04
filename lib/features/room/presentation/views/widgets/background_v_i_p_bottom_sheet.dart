import 'package:flutter/material.dart';
import 'package:lklk/core/constants/app_colors.dart';
import 'package:lklk/core/constants/assets.dart';
import 'package:lklk/core/player/svga_custom_player.dart';

class BackgroundVIPBottomSheet extends StatelessWidget {
  const BackgroundVIPBottomSheet({super.key, required this.vip});
  final String vip;

  @override
  Widget build(BuildContext context) {
    final height = MediaQuery.of(context).size.height;
    final width = MediaQuery.of(context).size.width;

    return Positioned(
      top: vip == '0' ? 40 : 0,
      left: 0,
      right: 0,
      bottom: 0,
      child: Container(
        padding: vip == '0' ? const EdgeInsets.only(top: 60) : null,
        decoration: vip == '0'
            ? const BoxDecoration(
                borderRadius: BorderRadius.only(
                  topLeft: Radius.circular(30),
                  topRight: Radius.circular(30),
                ),
                color: AppColors.white,
              )
            : null,
        height: height / 3.5,
        width: double.infinity,
        child: vip != '0'
            ? CustomSVGAWidget(
                height: height,
                width: width,
                isRepeat: true,
                pathOfSvgaFile: getSvgaPath(),
                allowDrawingOverflow: false,
                clearsAfterStop: false,
                fit: BoxFit.cover,
              )
            : null,
      ),
    );
  }

  String getSvgaPath() {
    switch (int.tryParse(vip)) {
      case 1:
        return AssetsData.vipPage1;
      case 2:
        return AssetsData.vipPage2;
      case 3:
        return AssetsData.vipPage3;
      case 4:
        return AssetsData.vipPage4;
      case 5:
        return AssetsData.vipPage5;
      default:
        return '';
    }
  }
}
