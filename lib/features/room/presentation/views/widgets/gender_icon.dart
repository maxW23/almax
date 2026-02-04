import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:lklk/core/constants/app_colors.dart';
import 'package:lklk/features/room/presentation/views/widgets/white_spot_mini.dart';

class GenderIcon extends StatelessWidget {
  const GenderIcon({
    super.key,
    required this.isFemale,
    this.size,
    this.iconSize,
  });

  final bool isFemale;
  final double? size; // container diameter in dp
  final double? iconSize; // icon size in dp

  @override
  Widget build(BuildContext context) {
    final double base = size ?? 17;
    final double inner = iconSize ?? 8;
    return Container(
      width: base.w, // زيادة الحجم لتحسين المظهر ثلاثي الأبعاد
      height: base.h,
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: isFemale
              ? [
                  const Color(0xFFF974E8), // لون متدرج أغمق للأنثى
                  const Color(0xFFD81B60), // لون متدرج أغمق للأنثى
                ]
              : [
                  const Color(0xFF42A5F5), // لون أزرق فاتح
                  const Color(0xFF1976D2), // لون أزرق داكن
                ],
        ),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.3),
            spreadRadius: 1,
            blurRadius: 6,
            offset: const Offset(0, 3),
          ),
          BoxShadow(
            color: Colors.white.withValues(alpha: 0.1), // إضاءة ثلاثية الأبعاد
            spreadRadius: 2,
            blurRadius: 4,
            offset: const Offset(-2, -2),
          ),
        ],
      ),
      child: Stack(
        alignment: Alignment.center,
        children: [
          // طبقة الانعكاس ثلاثية الأبعاد
          WhiteSpotMini(),
          // أيقونة الجنس مع تأثير ثلاثي الأبعاد,
          isFemale
              ? Transform.rotate(
                  angle: 0.7854, // 45 درجة بالراديان (يسار)
                  child: Icon(
                    FontAwesomeIcons.venus,
                    size: inner.r,
                    color: Colors.white,
                    shadows: [
                      Shadow(
                        color: Colors.black.withValues(alpha: 0.4),
                        blurRadius: 2,
                        offset: const Offset(1, 1),
                      )
                    ],
                  ),
                )
              : Icon(
                  FontAwesomeIcons.mars,
                  size: inner.r,
                  color: Colors.white,
                  shadows: [
                    Shadow(
                      color: Colors.black.withValues(alpha: 0.4),
                      blurRadius: 2,
                      offset: const Offset(1, 1),
                    )
                  ],
                ),
        ],
      ),
    );
  }
}
