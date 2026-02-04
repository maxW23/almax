import 'package:flutter/material.dart';
import 'package:lklk/core/constants/app_colors.dart';
import 'package:lklk/core/constants/styles.dart';
import 'package:lklk/core/utils/gradient_text.dart';
import 'package:lklk/features/room/presentation/views/widgets/circular_user_image.dart';

class UserMessageInfo extends StatelessWidget {
  const UserMessageInfo({
    super.key,
    required this.userName,
    required this.img,
  });

  final String userName;
  final String? img;

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.end,
          children: [
            Column(
              crossAxisAlignment: CrossAxisAlignment.end,
              mainAxisAlignment: MainAxisAlignment.end,
              children: [
                GradientText(
                  userName,
                  gradient: const LinearGradient(colors: [
                    AppColors.grey,
                    AppColors.white,
                  ]),
                  style: Styles.textStyle12bold.copyWith(),
                ),
                const SizedBox(
                  width: 10,
                ),
              ],
            ),
            const SizedBox(
              width: 10,
            ),
            CircularUserImage(
              imagePath: img,
              isEmpty: false,
              radius: 14,
            ),
            const SizedBox(
              width: 10,
            ),
          ],
        ),
      ],
    );
  }
}
