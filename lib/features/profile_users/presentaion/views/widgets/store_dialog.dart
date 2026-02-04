import 'package:lklk/core/utils/logger.dart';
import 'dart:io';

import 'package:flutter/material.dart';
import 'package:auto_size_text/auto_size_text.dart';
import 'package:lklk/core/player/svga_custom_player.dart';
import 'package:lklk/core/utils/custom_fading_widget.dart';
import 'package:lklk/core/utils/image_loader.dart';
import 'package:lklk/features/auth/domain/entities/user_entity.dart';
import 'package:lklk/features/room/presentation/views/widgets/circular_user_image.dart';
import 'package:path/path.dart' as path;

class StoreDialog extends StatelessWidget {
  final String? image, type;
  final UserEntity user;

  const StoreDialog(
      {super.key, required this.image, required this.user, required this.type});

  @override
  Widget build(BuildContext context) {
    log('image $image');
    String? fileExtension = path.extension(image!).replaceAll('.', '');
    log('image type: $fileExtension');

    return AlertDialog(
      insetPadding: EdgeInsets.fromLTRB(
        24,
        24,
        24,
        24 + MediaQuery.of(context).viewPadding.bottom,
      ),
      actions: [
        const SizedBox(
          height: 50,
        ),
        fileExtension == 'gif'
            ? Align(
                alignment: Alignment.center,
                child: SizedBox(
                  height: 100,
                  width: 100,
                  child: Stack(
                    alignment: Alignment.center,
                    children: [
                      type == 'frame'
                          ? Padding(
                              padding: const EdgeInsets.all(14),
                              child: CircularUserImage(
                                imagePath: user.img,
                                radius: 100,
                              ),
                            )
                          : const SizedBox(),
                      image != null
                          ? (image!.startsWith('/data/user')
                              ? Image.file(
                                  File(image!),
                                  fit: BoxFit.cover,
                                  width: 100,
                                  height: 100,
                                )
                              : ImageLoader(
                                  imageUrl: image!,
                                  width: 100,
                                  height: 100,
                                  fit: BoxFit.cover,
                                  shape: const CircleBorder(),
                                  placeholderColor: Colors.grey.shade300,
                                  fallbackWidget: Container(
                                    width: 100,
                                    height: 100,
                                    decoration: BoxDecoration(
                                      shape: BoxShape.circle,
                                      color: Colors.grey.shade300,
                                    ),
                                    child: const Icon(
                                      Icons.error,
                                      color: const Color(0xFFFF0000),
                                      size: 40,
                                    ),
                                  ),
                                ))
                          : (const CustomFadingWidget(
                              child: SizedBox(
                              width: 100,
                              height: 100,
                            ))),
                    ],
                  ),
                ),
              )
            : CustomSVGAWidget(
                height: 100,
                width: 100,
                isRepeat: true,
                pathOfSvgaFile: image!,
                child: type == 'frame'
                    ? CircularUserImage(
                        imagePath: user.img,
                        radius: 100,
                      )
                    : null,
              ),
        Center(
          child: AutoSizeText(
            user.name!,
            style: const TextStyle(fontWeight: FontWeight.w600, fontSize: 20),
            textAlign: TextAlign.center,
          ),
        ),
        const SizedBox(
          height: 50,
        ),
      ],
    );
  }
}
