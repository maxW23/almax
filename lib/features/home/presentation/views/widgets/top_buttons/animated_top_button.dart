import 'package:flutter/material.dart';
import 'package:lklk/features/home/presentation/views/widgets/top_buttons/animated_users_button.dart';

/// Widget لعرض زر Top كـ Wrapper فوق AnimatedUsersButton
/// يحافظ على نفس السلوك السابق (3 صور، أول 6، أنيميشن 6 ثواني)
class AnimatedTopButton extends StatelessWidget {
  /// مسار صورة خلفية الزر
  final String buttonImagePath;

  /// كود API للحصول على المستخدمين (44 للثروة، 55 للجاذبية، ...)
  final int apiCode;

  /// مسار إطار الصورة الذي يوضع فوق كل صورة مستخدم
  final String frameImagePath;

  /// دالة يتم استدعاؤها عند الضغط على الزر
  final VoidCallback? onTap;

  const AnimatedTopButton({
    super.key,
    required this.buttonImagePath,
    required this.apiCode,
    required this.frameImagePath,
    this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return RepaintBoundary(
      child: AnimatedUsersButton(
        buttonImagePath: buttonImagePath,
        frameImagePath: frameImagePath,
        apiCode: apiCode,
        itemsPerGroup: 3,
        totalItemsLimit: 6,
        middleIconPath: null,
        onTap: onTap,
        forceRefresh: false,
        avatarSize: 36,
        contentPadding: const EdgeInsets.only(top: 10),
        rightSpacerFraction: 0.14,
        duration: const Duration(milliseconds: 6000),
        verticalOffset: 5,
      ),
    );
  }
}
