import 'package:flutter/material.dart';
import 'package:lklk/features/auth/domain/entities/user_entity.dart';

class WeeklyTopThree extends StatelessWidget {
  final List<UserEntity> users;
  const WeeklyTopThree({super.key, required this.users});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16.0),
      child: AspectRatio(
        aspectRatio: 109 / 58,
        child: Stack(
          fit: StackFit.expand,
          children: [
            Image.asset(
              'assets/event/banner_for_best_top_3_users.png',
              fit: BoxFit.cover,
            ),
            Align(
              alignment: const Alignment(0, -0.2),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                crossAxisAlignment: CrossAxisAlignment.end,
                children: [
                  Transform.translate(
                    offset: const Offset(0, 10),
                    child: _TopUserCard(
                      user: users.length > 1 ? users[1] : null,
                      frameAsset: 'assets/event/top 2 badge_1.png',
                      avatarFrame: 'assets/event/top 2 without bg.png',
                    ),
                  ),
                  _TopUserCard(
                    user: users.isNotEmpty ? users[0] : null,
                    crown: 'assets/event/top 1 badge_1.png',
                    avatarFrame: 'assets/event/top 1 without bg.png',
                    big: true,
                  ),
                  Transform.translate(
                    offset: const Offset(0, 10),
                    child: _TopUserCard(
                      user: users.length > 2 ? users[2] : null,
                      frameAsset: 'assets/event/top 3 badge_1.png',
                      avatarFrame: 'assets/event/top 3 without bg.png',
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _TopUserCard extends StatelessWidget {
  final UserEntity? user;
  final String? crown; // top-1 badge
  final String? frameAsset; // top-2, top-3 badges
  final String avatarFrame; // frame that contains the avatar
  final bool big;

  const _TopUserCard({
    required this.user,
    required this.avatarFrame,
    this.crown,
    this.frameAsset,
    this.big = false,
  });

  @override
  Widget build(BuildContext context) {
    final double size = big ? 126 : 98;
    return SizedBox(
      width: size,
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          if (crown != null)
            Image.asset(
              crown!,
              height: 40,
              fit: BoxFit.contain,
            ),
          Stack(
            alignment: Alignment.center,
            children: [
              Image.asset(
                avatarFrame,
                height: size,
                fit: BoxFit.contain,
              ),
              // avatar placeholder (no logic here)
              ClipOval(
                child: Container(
                  width: big ? 58 : 50,
                  height: big ? 58 : 50,
                  color: Colors.white24,
                ),
              ),
            ],
          ),
          const SizedBox(height: 4),
          Text(
            user?.name ?? '-',
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
            textAlign: TextAlign.center,
            style: const TextStyle(
              color: Color(0xFFFFE9B0),
              fontSize: 11,
              fontWeight: FontWeight.w600,
            ),
          ),
        ],
      ),
    );
  }
}
