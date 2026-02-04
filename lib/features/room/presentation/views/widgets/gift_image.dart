import 'package:flutter/material.dart';
import 'package:lklk/core/constants/app_colors.dart';
import 'package:lklk/core/utils/image_loader.dart';

class GiftImage extends StatelessWidget {
  const GiftImage({
    super.key,
    required this.imgElement,
    this.height = 40,
    this.width = 40,
  });

  final String? imgElement;
  final double? height;
  final double? width;
  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: height,
      width: width,
      child: CircleAvatar(
        backgroundColor: AppColors.transparent,
        child: ClipOval(
            child: (imgElement != null)
                ? ImageLoader(
                    imageUrl: imgElement!,
                    width: 40, //60
                    height: 40, //60
                    fit: BoxFit.cover,
                    shape: const CircleBorder(),
                    placeholderColor: Colors.grey.shade300,
                    fallbackWidget: Container(
                      width: 40, //60
                      height: 40, //60
                      decoration: const BoxDecoration(
                        shape: BoxShape.circle,
                        color: Colors.grey,
                      ),
                      child: const Icon(
                        Icons.error,
                        color: const Color(0xFFFF0000),
                        size: 30,
                      ),
                    ),
                  )
                : const SizedBox()
            // (gift.imgElementLocal != null ||
            //     gift.imgElementLocal!.startsWith('/data/user'))
            // ? Image.file(
            //     File(gift.imgElementLocal!),
            //     height: 40,
            //     width: 40,
            //     fit: BoxFit.cover,
            //   )
            // : (gift.imgElement != null)
            //     ? ImageLoader(
            //         imageUrl: gift.imgElement!,
            //         width: 40,
            //         height: 40,
            //         fit: BoxFit.cover,
            //         shape: const CircleBorder(),
            //         placeholderColor: Colors.grey.shade300,
            //         fallbackWidget: Container(
            //           width: 40,
            //           height: 40,
            //           decoration: const BoxDecoration(
            //             shape: BoxShape.circle,
            //             color: Colors.grey,
            //           ),
            //           child: const Icon(
            //             Icons.error,
            //             color: const Color(0xFFFF0000),
            //             size: 30,
            //           ),
            //         ),
            //       )
            //     : const SizedBox()
            ),
      ),
    );
  }
}
