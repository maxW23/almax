import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:country_flags/country_flags.dart';
import 'package:lklk/features/home/presentation/manger/language/language_cubit.dart';

class LanguageSwitcher extends StatelessWidget {
  final Color textColor;
  final Color iconColor;
  final Color dropdownColor;
  final bool isFlagOnly;
  final double flagSize;
  final double borderRadius;
  final double minWidth;

  const LanguageSwitcher({
    super.key,
    this.textColor = Colors.white,
    this.iconColor = Colors.white,
    this.dropdownColor = Colors.white,
    this.isFlagOnly = false,
    this.flagSize = 24,
    this.borderRadius = 12,
    this.minWidth = 120, // عرض أدنى مضمون للعنصر
  });

  @override
  Widget build(BuildContext context) {
    final languageCubit = context.watch<LanguageCubit>();
    final currentLanguage = languageCubit.state.languageCode;

    return SizedBox(
      width: isFlagOnly ? flagSize * 2 : minWidth,
      child: Container(
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(borderRadius),
        ),
        child: DropdownButtonHideUnderline(
          child: DropdownButton<String>(
            value: currentLanguage,
            isExpanded: true, // تم التغيير لـ true لاستخدام العرض الكامل
            borderRadius: BorderRadius.circular(borderRadius),
            dropdownColor: dropdownColor,
            style: TextStyle(
              fontSize: 16,
              color: textColor,
              fontWeight: FontWeight.w500,
            ),
            icon: Icon(Icons.keyboard_arrow_down, color: iconColor, size: 24),
            items: [
              _buildDropdownItem('en', 'US', 'English', context),
              _buildDropdownItem('ar', 'SA', 'العربية', context),
            ],
            onChanged: (String? newLanguage) {
              if (newLanguage != null) {
                languageCubit.switchLanguage(newLanguage);
              }
            },
          ),
        ),
      ),
    );
  }

  DropdownMenuItem<String> _buildDropdownItem(
      String value, String countryCode, String text, BuildContext context) {
    return DropdownMenuItem(
      value: value,
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 8),
        child: isFlagOnly
            ? Center(
                child: CountryFlag.fromCountryCode(
                  countryCode,
                  shape: const RoundedRectangle(3),
                  height: flagSize,
                  width: flagSize * 1.5,
                ),
              )
            : Row(
                mainAxisAlignment: MainAxisAlignment.start,
                children: [
                  CountryFlag.fromCountryCode(
                    countryCode,
                    shape: const RoundedRectangle(3),
                    height: flagSize,
                    width: flagSize * 1.5,
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Text(
                      text,
                      style: TextStyle(
                        color: textColor,
                        fontSize: 12, // حجم خط أكبر
                      ),
                      overflow: TextOverflow.visible,
                    ),
                  ),
                ],
              ),
      ),
    );
  }
}
