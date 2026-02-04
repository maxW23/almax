import 'package:flutter/material.dart';
import 'common/level_text_styles.dart';
import '../../../domain/entities/user_level_entity.dart';
import '../../utils/tasks_localization.dart';
import 'package:lklk/features/room/presentation/views/widgets/circular_user_image.dart';

class UpgradeLevelCard extends StatelessWidget {
  final UserLevelEntity userLevel;

  const UpgradeLevelCard({
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
        children: [
          // User Avatar with custom border image overlay
          SizedBox(
            width: 80,
            height: 80,
            child: Stack(
              alignment: Alignment.center,
              children: [
                // Use CircularUserImage to normalize and load the URL safely
                const SizedBox(width: 74, height: 74),
                Positioned(
                  child: CircularUserImage(
                    imagePath: userLevel.userImage,
                    radius: 37,
                  ),
                ),
                // Border overlay
                Positioned.fill(
                  child: Padding(
                    padding: const EdgeInsets.all(0),
                    child: Image.asset(
                      'assets/tasks/images/userCirlcularBorder.png',
                      fit: BoxFit.contain,
                    ),
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 20),
          // Level Progress
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
            children: [
              _buildLevelInfo(
                '  LVL.${userLevel.currentLevel}',
                Colors.cyan,
                true,
              ),
              Image.asset(
                'assets/tasks/images/Arrows Up Bold.png',
                width: 28,
                height: 28,
              ),
              _buildLevelInfo(
                '  LVL.${userLevel.nextLevel}',
                Colors.white,
                false,
              ),
            ],
          ),
          const SizedBox(height: 20),
          // Points Info
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
            children: [
              _buildPointsInfo(
                TasksLocalization.numberOfPointsToUpgrade(context),
                userLevel.pointsToUpgrade.toString(),
              ),
              _buildPointsInfo(
                TasksLocalization.numberOfPointsNow(context),
                userLevel.currentPoints.toString(),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildLevelInfo(String level, Color color, bool isActive) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 8),
      constraints: const BoxConstraints(minWidth: 110, minHeight: 38),
      decoration: BoxDecoration(
        image: const DecorationImage(
          image: AssetImage('assets/tasks/images/level.levelnumver.png'),
          fit: BoxFit.contain,
        ),
        borderRadius: BorderRadius.circular(20),
      ),
      alignment: Alignment.center,
      child: Text(
        level,
        style: LevelTextStyles.listTitle().copyWith(
          color: Colors.white,
          fontSize: isActive ? 16 : 15,
          fontWeight: FontWeight.bold,
          shadows: [
            if (isActive)
              const Shadow(
                color: Colors.black26,
                blurRadius: 4,
                offset: Offset(0, 1),
              ),
          ],
        ),
      ),
    );
  }

  Widget _buildPointsInfo(String title, String value) {
    return Column(
      children: [
        Text(
          title,
          textAlign: TextAlign.center,
          style: LevelTextStyles.subtitle(),
        ),
        const SizedBox(height: 8),
        Text(
          value,
          style: LevelTextStyles.titleLarge().copyWith(fontSize: 24),
        ),
      ],
    );
  }
}
