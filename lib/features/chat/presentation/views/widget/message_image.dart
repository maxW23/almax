import 'dart:io';
import 'package:flutter/material.dart';
import 'package:lklk/core/constants/app_colors.dart';
import 'package:lklk/features/chat/domain/enitity/message_entity.dart';
import 'package:lklk/features/chat/presentation/views/widget/photo_gallery_view.dart';
import 'package:lklk/features/chat/presentation/views/widget/transparent_image.dart';

class MessageImage extends StatelessWidget {
  const MessageImage({super.key, required this.message, required this.current});
  final MessagePrivate message;
  final bool current;
  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: AppColors.transparent,
        borderRadius: BorderRadius.circular(8),
      ),
      child: Column(
        crossAxisAlignment:
            current ? CrossAxisAlignment.end : CrossAxisAlignment.start,
        children: [
          InkWell(
            onTap: () {
              /// navigate to to the photo gallery view, for viewing the taped image
              Navigator.of(context).push(
                MaterialPageRoute<void>(
                  builder: (BuildContext context) => PhotoGalleryView(
                    image: message.message,
                  ),
                ),
              );
            },
            child: SizedBox(
              /// 45% of total width
              width: MediaQuery.of(context).size.width * 0.38,

              child: AspectRatio(
                aspectRatio: 1,
                child: ClipRRect(
                  borderRadius: BorderRadius.circular(8),
                  child: Uri.parse(message.message).isAbsolute
                      ? FadeInImage.memoryNetwork(
                          placeholder: transparentImage,
                          image: message.message,
                          fit: BoxFit.cover,
                        )
                      : Image.file(
                          File(
                            message.message,
                          ),
                          fit: BoxFit.cover,
                        ),
                ),
              ),
            ),
          ),
          // Visibility(
          //   visible: message..isNotEmpty,
          //   child: Padding(
          //     padding: EdgeInsets.only(
          //       bottom: 8,
          //       top: 8,
          //       right: current ? 8 : 0,
          //       left: current ? 0 : 8,
          //     ),
          //     child: AutoSizeText(
          //       message.message,
          //       style: const TextStyle(fontSize: 12),
          //     ),
          //   ),
          // ),
        ],
      ),
    );
  }
}
