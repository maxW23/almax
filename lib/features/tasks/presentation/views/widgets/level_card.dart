import 'package:flutter/material.dart';
import 'common/level_text_styles.dart';
import 'common/promote_button.dart';
import 'common/fancy_progress_bar.dart';
import '../../../domain/entities/user_level_entity.dart';
import '../../utils/tasks_localization.dart';

class LevelCard extends StatelessWidget {
  final UserLevelEntity userLevel;

  const LevelCard({
    super.key,
    required this.userLevel,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [
            const Color(0xFF4A5F7A).withOpacity(0.8),
            const Color(0xFF3D5269).withOpacity(0.8),
          ],
        ),
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.2),
            blurRadius: 10,
            offset: const Offset(0, 5),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Left: Title and subtitle (Figma style)
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'LVL.${userLevel.currentLevel}',
                    style: LevelTextStyles.titleLarge(),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    TasksLocalization.enjoyAdvantages(context),
                    style: LevelTextStyles.subtitle(),
                  ),
                  const SizedBox(height: 12),
                  // Small stats chip (icon + points + chevron)
                  Container(
                    padding:
                        const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
                    decoration: BoxDecoration(
                      color: Colors.white.withOpacity(0.12),
                      borderRadius: BorderRadius.circular(20),
                      border: Border.all(color: Colors.white.withOpacity(0.15)),
                    ),
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Icon(Icons.bar_chart,
                            color: Colors.white.withOpacity(0.9), size: 16),
                        const SizedBox(width: 6),
                        Text(
                          '${userLevel.currentPoints} / ${TasksLocalization.pts(context)}',
                          style: LevelTextStyles.chip(),
                        ),
                        const SizedBox(width: 6),
                        const Icon(Icons.chevron_right,
                            color: Colors.white, size: 16),
                      ],
                    ),
                  ),
                ],
              ),
              // Right: Badge image enlarged without box
              Image.asset(
                'assets/tasks/images/Level Badge_with_down_arrow.png',
                width: 88,
                height: 88,
                fit: BoxFit.contain,
              ),
            ],
          ),
          const SizedBox(height: 18),
          // Progress line and actions
          Row(
            children: [
              Expanded(
                child: Builder(
                  builder: (context) {
                    final int current = userLevel.currentPoints;
                    final int remain = userLevel.pointsToUpgrade;
                    final int total = (remain > 0)
                        ? (current + remain)
                        : (current > 0 ? current : 1);
                    final double progress =
                        (total > 0) ? (current / total).clamp(0.0, 1.0) : 0.0;
                    return FancyProgressBar(
                      progress: progress,
                      height: 12,
                      padding: const EdgeInsets.only(right: 8),
                    );
                  },
                ),
              ),
              PromoteButton(
                label: TasksLocalization.promote(context),
                onPressed: () {},
                borderRadius: 16,
                padding:
                    const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
              ),
              const SizedBox(width: 8),
              Text(
                'LVL.${userLevel.nextLevel}',
                style: const TextStyle(
                  color: Colors.white70,
                  fontSize: 12,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}
