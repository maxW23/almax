import 'package:flutter/material.dart';
import 'package:lklk/features/room/presentation/views/widgets/circular_user_image.dart';
import 'package:lklk/features/room/presentation/views/widgets/user_name_text.dart';

class MicrophoneItem extends StatelessWidget {
  final String userName;
  final String imagePath;
  final bool isEmpty;
  const MicrophoneItem({
    super.key,
    required this.userName,
    required this.imagePath,
    required this.isEmpty,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        CircularUserImage(imagePath: imagePath, isEmpty: isEmpty),
        const SizedBox(height: 2),
        UserNameText(userName: userName),
      ],
    );
  }
}
