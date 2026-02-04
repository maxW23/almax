import 'package:flutter/material.dart';
import 'package:lklk/features/home/presentation/views/widgets/top_buttons/animated_users_button.dart';

/// Widget خاص لزر العلاقات (Relation) كـ Wrapper فوق AnimatedUsersButton
/// يحافظ على نفس السلوك السابق: صورتان، أول 4 صور، أيقونة قلب في المنتصف،
/// أنيميشن 6 ثواني مع بداية من الأسفل وتبديل مجموعتين.
class AnimatedRelationButton extends StatelessWidget {
  /// مسار صحورة خلفية الزر
  final String buttonImagePath;

  /// مسار إطار الصورة فوق كل صورة مستخدم
  final String frameImagePath;

  /// مسار أيقونة القلب بين الصورتين
  final String heartIconPath;

  /// دالة الضغط على الزر
  final VoidCallback? onTap;

  const AnimatedRelationButton({
    super.key,
    required this.buttonImagePath,
    required this.frameImagePath,
    required this.heartIconPath,
    this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return RepaintBoundary(
      child: AnimatedUsersButton(
        buttonImagePath: buttonImagePath,
        frameImagePath: frameImagePath,
        apiEndpoint: '/top/88', // نفس API السابق للعلاقات
        forceRefresh: true, // كما في السابق لتجاوز الكاش
        itemsPerGroup: 2,
        totalItemsLimit: 4,
        middleIconPath: heartIconPath,
        onTap: onTap,
        // محاذاة أبعاد و padding كما في النسخة الأصلية
        avatarSize: 36,
        contentPadding: const EdgeInsets.symmetric(horizontal: 8, vertical: 8),
        rightSpacerFraction: 0.14,
        duration: const Duration(milliseconds: 6000),
        verticalOffset: 5,
      ),
    );
  }
}
