import 'package:flutter/material.dart';
import 'task_item_skeleton.dart';
import 'level_card_skeleton.dart';

class MyLevelTabSkeleton extends StatelessWidget {
  const MyLevelTabSkeleton({super.key});

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: const [
          LevelCardSkeleton(),
          SizedBox(height: 20),
          _SectionTitleSkeleton(),
          SizedBox(height: 12),
          TaskItemSkeleton(),
          TaskItemSkeleton(),
          TaskItemSkeleton(),
          TaskItemSkeleton(),
          TaskItemSkeleton(),
        ],
      ),
    );
  }
}

class UpgradesTabSkeleton extends StatelessWidget {
  const UpgradesTabSkeleton({super.key});

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: const [
          LevelCardSkeleton(),
          SizedBox(height: 20),
          _SectionTitleSkeleton(),
          SizedBox(height: 12),
          TaskItemSkeleton(),
          TaskItemSkeleton(),
          TaskItemSkeleton(),
          TaskItemSkeleton(),
          TaskItemSkeleton(),
        ],
      ),
    );
  }
}

class _SectionTitleSkeleton extends StatelessWidget {
  const _SectionTitleSkeleton();
  @override
  Widget build(BuildContext context) {
    return Container(
      width: 120,
      height: 18,
      decoration: BoxDecoration(
        color: Colors.white12,
        borderRadius: BorderRadius.circular(6),
      ),
    );
  }
}
