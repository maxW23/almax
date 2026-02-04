// ignore_for_file: public_member_api_docs, sort_constructors_first

import 'package:flutter/material.dart';
import 'package:lklk/features/profile_users/presentaion/views/pages/level_page.dart';

import 'user_level_widget_bottom.dart';
import 'user_level_widget_top.dart';

class UserLevel extends StatelessWidget {
  const UserLevel({
    super.key,
    required this.widget,
    required this.selectedTab,
  });

  final LevelPage widget;
  final int selectedTab;

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        UserLevelWidgetTop(user: widget.user, selectedTab: selectedTab),
        UserLevelWidgetBottom(user: widget.user, selectedTab: selectedTab)
      ],
    );
  }
}
