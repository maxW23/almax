import 'package:flutter/material.dart';
import 'package:auto_size_text/auto_size_text.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:lklk/core/constants/app_colors.dart';
import 'package:lklk/core/constants/assets.dart';
import 'package:lklk/core/utils/image_loader.dart';
import 'package:lklk/generated/l10n.dart';

class CoverImageProfileUser extends StatefulWidget {
  const CoverImageProfileUser({
    super.key,
    this.imagePath,
    this.onTap,
    required this.isOther,
    this.isWakel = false,
    this.onTap2,
    required this.power,
  });
  final String? imagePath;
  final void Function()? onTap;
  final void Function()? onTap2;
  final bool isOther, isWakel;
  final String? power;
  @override
  State<CoverImageProfileUser> createState() => _CoverImageProfileUserState();
}

class _CoverImageProfileUserState extends State<CoverImageProfileUser> {
  late String? _imagePath;

  @override
  void initState() {
    super.initState();
    _updateImagePath(widget.imagePath);
  }

  @override
  void didUpdateWidget(CoverImageProfileUser oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (widget.imagePath != oldWidget.imagePath) {
      _updateImagePath(widget.imagePath);
    }
  }

  void _updateImagePath(String? path) {
    if (path == null) {
      _imagePath = null;
    } else if (path.contains('https://lh3.googleusercontent.com')) {
      _imagePath = path;
    } else if (path.contains('https://lklklive.com')) {
      _imagePath = path;
    } else if (path.contains('https://')) {
      _imagePath = path; // https://cdn.iconscout.com/
    } else {
      _imagePath = 'https://lklklive.com/imguser/$path';
    }
  }

  @override
  Widget build(BuildContext context) {
    var size = MediaQuery.of(context).size;

    return Container(
      height: size.height / 2.6,
      decoration: const BoxDecoration(
        color: AppColors.grey,
        // shape: BoxShape.rectangle, // يمكن تغييره حسب الحاجة
      ),
      child: Stack(
        children: [
          ImageLoader(
            imageUrl: _imagePath ?? AssetsData.userTestNetwork,
            width: double.infinity,
            height: size.height / 2.6,
            fit: BoxFit.fill,
            placeholderColor: AppColors.grey,
            fallbackWidget: Container(
              width: double.infinity,
              height: size.height / 2.6,
              color: AppColors.grey,
              child: const Icon(
                Icons.broken_image,
                color: const Color(0xFFFF0000),
                size: 40,
              ),
            ),
          ),
          if (widget.isOther)
            Positioned(
                bottom: 0,
                left: 0,
                child: GestureDetector(
                  onTap: widget.onTap,
                  behavior: HitTestBehavior.opaque,
                  child: Container(
                    margin: const EdgeInsets.symmetric(
                        horizontal: 10, vertical: 10),
                    width: 80,
                    height: 40,
                    decoration: BoxDecoration(
                      gradient: const LinearGradient(
                        colors: [AppColors.secondColor, AppColors.primary],
                      ),
                      borderRadius: BorderRadius.circular(20),
                    ),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        const Icon(
                          FontAwesomeIcons.home,
                          color: AppColors.white,
                          size: 14,
                        ),
                        const SizedBox(
                          width: 6,
                        ),
                        AutoSizeText(
                          S.of(context).entry,
                          style: const TextStyle(
                            color: AppColors.white,
                            fontSize: 12,
                            fontWeight: FontWeight.bold,
                          ),
                        )
                      ],
                    ),
                  ),
                )),
          if (widget.isOther && widget.isWakel)
            Positioned(
                top: 0,
                left: 0,
                child: GestureDetector(
                  onTap: widget.onTap2,
                  behavior: HitTestBehavior.opaque,
                  child: Padding(
                    padding: const EdgeInsets.all(20),
                    child: const Icon(
                      FontAwesomeIcons.arrowsRotate,
                      color: AppColors.golden,
                    ),
                  ),
                )),
        ],
      ),
    );
  }
}
