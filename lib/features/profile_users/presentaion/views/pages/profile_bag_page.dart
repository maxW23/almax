import 'package:flutter/material.dart';
import 'package:lklk/features/profile_users/domain/entities/elements_entity.dart';

class ProfileBagPage extends StatelessWidget {
  const ProfileBagPage({super.key, required this.frames, required this.cars});
  final List<ElementEntity> frames;
  final List<ElementEntity> cars; // entries

  @override
  Widget build(BuildContext context) {
    final isAr = Localizations.localeOf(context)
        .languageCode
        .toLowerCase()
        .startsWith('ar');
    return Scaffold(
      appBar: AppBar(title: Text(isAr ? 'الحقيبة' : 'Bag')),
      body: Center(
        child: Padding(
          padding: const EdgeInsets.symmetric(vertical: 24),
          child: Text(
            isAr ? 'لا توجد بيانات' : 'No Data',
            style: const TextStyle(fontSize: 16),
          ),
        ),
      ),
    );
  }
}
