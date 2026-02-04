import 'package:flutter/material.dart';
import 'package:lklk/features/auth/domain/entities/user_entity.dart';

class WeeklyUsersList extends StatelessWidget {
  final List<UserEntity> users;
  const WeeklyUsersList({super.key, required this.users});

  @override
  Widget build(BuildContext context) {
    if (users.isEmpty) {
      // Render an empty decorated list to keep layout consistent with design
      return Column(
        children: [
          _header(),
          const SizedBox(height: 10),
          ...List.generate(6, (i) => _emptyRow(i + 1)),
        ],
      );
    }

    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        _header(),
        const SizedBox(height: 10),
        ...users.asMap().entries.map((e) => _userRow(e.key + 1, e.value)).toList(),
      ],
    );
  }

  Widget _header() {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16.0),
      child: AspectRatio(
        aspectRatio: 109 / 18,
        child: Image.asset(
          'assets/event/banner_others.png',
          fit: BoxFit.cover,
        ),
      ),
    );
  }

  Widget _emptyRow(int rank) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 6),
      child: _goldenTile(
        leading: _rankBadge(rank),
        title: Container(
          height: 12,
          width: 120,
          color: Colors.white.withOpacity(0.08),
        ),
        subtitle: Container(
          height: 10,
          width: 60,
          color: Colors.white.withOpacity(0.06),
        ),
        trailing: _pointsBox('-'),
      ),
    );
  }

  Widget _userRow(int rank, UserEntity user) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 6),
      child: _goldenTile(
        leading: _rankBadge(rank),
        title: Text(
          user.name ?? '-',
          maxLines: 1,
          overflow: TextOverflow.ellipsis,
          style: const TextStyle(
            color: Colors.white,
            fontSize: 14,
            fontWeight: FontWeight.w600,
          ),
        ),
        subtitle: Text(
          user.country ?? '',
          maxLines: 1,
          overflow: TextOverflow.ellipsis,
          style: TextStyle(
            color: Colors.white.withOpacity(0.8),
            fontSize: 11,
          ),
        ),
        trailing: _pointsBox(user.point ?? user.totalSocre ?? ''),
      ),
    );
  }

  Widget _goldenTile({
    required Widget leading,
    required Widget title,
    required Widget subtitle,
    required Widget trailing,
  }) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
      decoration: BoxDecoration(
        color: const Color(0xFF2A0E0F).withOpacity(0.85),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: const Color(0xFFFFC24B), width: 1),
      ),
      child: Row(
        children: [
          leading,
          const SizedBox(width: 10),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [title, const SizedBox(height: 4), subtitle],
            ),
          ),
          const SizedBox(width: 10),
          trailing,
        ],
      ),
    );
  }

  Widget _rankBadge(int rank) {
    final String label = rank.toString().padLeft(2, '0');
    return Stack(
      alignment: Alignment.center,
      children: [
        Container(
          width: 36,
          height: 36,
          decoration: BoxDecoration(
            shape: BoxShape.circle,
            gradient: const LinearGradient(
              colors: [Color(0xFFFFE9B0), Color(0xFFFFB648)],
              begin: Alignment.topCenter,
              end: Alignment.bottomCenter,
            ),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withOpacity(0.2),
                blurRadius: 4,
                offset: const Offset(0, 2),
              ),
            ],
          ),
        ),
        Text(
          label,
          style: const TextStyle(
            color: Color(0xFF5A2C00),
            fontWeight: FontWeight.w900,
          ),
        ),
      ],
    );
  }

  Widget _pointsBox(String value) {
    // Small gold circular control with dash (visual placeholder)
    return Container(
      width: 28,
      height: 28,
      decoration: const BoxDecoration(
        shape: BoxShape.circle,
        gradient: LinearGradient(
          colors: [Color(0xFFFFE9B0), Color(0xFFFFB648)],
          begin: Alignment.topCenter,
          end: Alignment.bottomCenter,
        ),
      ),
      alignment: Alignment.center,
      child: const Text(
        '–',
        style: TextStyle(
          color: Color(0xFF5A2C00),
          fontWeight: FontWeight.w900,
          fontSize: 16,
        ),
      ),
    );
  }
}
