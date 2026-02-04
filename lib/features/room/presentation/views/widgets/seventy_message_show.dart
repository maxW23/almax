import 'package:flutter/material.dart';
import 'package:lklk/core/constants/app_colors.dart';
import 'package:lklk/core/utils/gradient_text.dart';

class SevenyMessageShow extends StatelessWidget {
  const SevenyMessageShow({
    super.key,
    required this.text,
  });
  // final Message message;
  final String text;
  @override
  Widget build(BuildContext context) {
    return Text3D(
      text,
      style: const TextStyle(
        fontSize: 50,
        fontWeight: FontWeight.w900,
        color: AppColors.white,
      ),
      gradient: const LinearGradient(
        begin: Alignment.topCenter,
        end: Alignment.bottomCenter,
        colors: [
          Color(0xFFFFEB3B),
          Color(0xFFFFEB3B),
          AppColors.white,
          Color(0xFFFFC107),
          Color(0xFFFFC107),
        ],
      ),
      // تدرج الظل
      shadowGradient: const LinearGradient(
        begin: Alignment.topLeft,
        end: Alignment.bottomRight,
        colors: [
          Colors.black45,
          Colors.black,
        ],
      ),
      depth: 4.0, // تحكم بعمق الظل
      textDirectionBool: false, // إذا أردت دائماً من اليسار إلى اليمين
    );
  }
}
