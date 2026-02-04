// country_item.dart
import 'package:lklk/core/utils/logger.dart';
import 'package:auto_size_text/auto_size_text.dart';
import 'package:country_flags/country_flags.dart';
import 'package:flutter/material.dart';
import 'package:lklk/core/constants/app_colors.dart';
import 'package:lklk/features/home/presentation/views/widgets/country_data.dart';

class CountryItem extends StatelessWidget {
  final CountryData country;
  final bool isSelected;
  final VoidCallback onTap;

  const CountryItem({
    super.key,
    required this.country,
    required this.isSelected,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return Material(
      // لازم يكون هناك Material كتجهيز للرسم (الـ ink splash يُرسم على Material).
      color: Colors
          .transparent, // نخلي الخلفية شفافة هنا لأننا نرسم الخلفية في Ink.
      child: Ink(
        // Ink يستخدم بدلاً من Container عند الحاجة لعرض gradient/decoration مع دعم الـ ink.
        decoration: BoxDecoration(
          gradient: isSelected
              ? LinearGradient(
                  colors: [AppColors.primary, AppColors.secondColor],
                )
              : null,
          color: isSelected ? null : AppColors.white,
          borderRadius: BorderRadius.circular(isSelected ? 8 : 4),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withValues(alpha: 0.1),
              blurRadius: 4,
              offset: const Offset(0, 2),
            ),
          ],
        ),
        child: InkWell(
          // InkWell يعطي الـ ripple ويعتمد على ال-Material و Ink أعلاه.
          borderRadius: BorderRadius.circular(isSelected ? 8 : 4),
          onTap: () {
            // طباعة للتأكد، ثم استدعاء callback المرسَل من الخارج.
            log("CountryItem tapped: ${country.code}");
            onTap();
          },
          child: Padding(
            padding: EdgeInsets.symmetric(
              horizontal: isSelected ? 13 : 8,
              vertical: 8, // زيادة بسيطة للمساحة الملموسة
            ),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                if (country.code != 'null') ...[
                  CountryFlag.fromCountryCode(
                    country.code,
                    height: 17,
                    width: 24,
                    shape: const RoundedRectangle(3),
                  ),
                  const SizedBox(width: 8),
                ],
                AutoSizeText(
                  country.name,
                  style: TextStyle(
                    color: isSelected ? AppColors.white : AppColors.black,
                    fontWeight: FontWeight.bold,
                    fontSize: isSelected ? 16 : 14,
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
