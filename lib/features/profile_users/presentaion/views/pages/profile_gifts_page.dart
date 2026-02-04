import 'package:flutter/material.dart';
import 'package:lklk/features/profile_users/domain/entities/elements_entity.dart';
import 'package:lklk/features/profile_users/presentaion/views/pages/gifts_section.dart';
import 'package:lklk/generated/l10n.dart';

class ProfileGiftsPage extends StatelessWidget {
  const ProfileGiftsPage({super.key, required this.gifts, this.frames, this.cars});
  final List<ElementEntity> gifts;
  final List<ElementEntity>? frames;
  final List<ElementEntity>? cars;

  @override
  Widget build(BuildContext context) {
    final List<ElementEntity> framesList = frames ?? const <ElementEntity>[];
    final List<ElementEntity> carsList = cars ?? const <ElementEntity>[];
    final String noDataText = Localizations.localeOf(context)
            .languageCode
            .toLowerCase()
            .startsWith('ar')
        ? 'لا توجد بيانات'
        : 'No Data';

    return DefaultTabController(
      length: 3,
      child: Scaffold(
        appBar: AppBar(
          title: Text(S.of(context).gifts),
          bottom: TabBar(
            tabs: [
              Tab(text: S.of(context).gifts),
              Tab(text: S.of(context).frame),
              Tab(text: S.of(context).car),
            ],
          ),
        ),
        body: TabBarView(
          children: [
            _buildTab(noDataText, gifts, isLength: true),
            _buildTab(noDataText, framesList, isLength: false),
            _buildTab(noDataText, carsList, isLength: false),
          ],
        ),
      ),
    );
  }

  Widget _buildTab(String noDataText, List<ElementEntity> items,
      {required bool isLength}) {
    if (items.isEmpty) {
      return Center(
        child: Text(
          noDataText,
          style: const TextStyle(fontSize: 16),
        ),
      );
    }
    return SingleChildScrollView(
      child: Padding(
        padding: const EdgeInsets.only(top: 16.0),
        child: GiftsSection(
          giftList: items,
          isLength: isLength,
        ),
      ),
    );
  }
}
