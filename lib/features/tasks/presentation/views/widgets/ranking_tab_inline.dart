import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:lklk/core/constants/app_colors.dart';
import 'package:lklk/features/home/presentation/manger/top_user_cubit/top_users_cubit.dart';
import 'package:lklk/features/auth/domain/entities/user_entity.dart';
import 'package:lklk/features/profile_users/presentaion/manger/user_cubit/user_cubit_cubit.dart';
import 'package:lklk/features/home/presentation/manger/room_cubit/room_cubit_cubit.dart';
import 'package:lklk/features/profile_users/presentaion/views/pages/other_user_profile.dart';
import '../../utils/tasks_localization.dart';

import '../../../domain/entities/ranking_entity.dart';
import 'common/level_text_styles.dart';
import 'package:intl/intl.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:lklk/features/room/presentation/views/widgets/user_widget_title.dart';
import 'package:lklk/features/home/presentation/manger/language/language_cubit.dart';
import 'skeletons/ranking_tab_skeleton.dart';
import 'package:lklk/core/utils/list_performance_optimizer.dart';

// Normalize user image path similar to CircularUserImage.updateImagePath()
String? normalizeUserImage(String? path) {
  final normalized = path?.trim();
  if (normalized == null ||
      normalized.isEmpty ||
      normalized.toLowerCase() == 'null') {
    return null;
  } else if (normalized.contains('https://lh3.googleusercontent.com')) {
    return normalized;
  } else if (normalized.contains('https://lklklive.com')) {
    return normalized;
  } else if (normalized.contains('https://')) {
    return normalized;
  } else if (normalized.contains('assets')) {
    return normalized;
  } else {
    return 'https://lklklive.com/imguser/$normalized';
  }
}

// Helpers for formatting and UI bits used in list rows
int _parseInt(String? s) {
  if (s == null) return 0;
  final raw = s.trim().toLowerCase();
  if (raw.isEmpty || raw == 'null') return 0;
  if (raw.endsWith('m')) {
    final v = double.tryParse(raw.replaceAll('m', '')) ?? 0.0;
    return (v * 1000000).round();
  }
  if (raw.endsWith('k')) {
    final v = double.tryParse(raw.replaceAll('k', '')) ?? 0.0;
    return (v * 1000).round();
  }
  final cleaned = raw.replaceAll(RegExp(r'[^0-9]'), '');
  return int.tryParse(cleaned) ?? 0;
}

String _formatPoints(int points) {
  if (points >= 1000000) {
    return '${(points / 1000000).toStringAsFixed(1)}M';
  }
  if (points >= 1000) {
    return '${(points / 1000).toStringAsFixed(1)}k';
  }
  return points.toString();
}

DateTime? _parseDate(String? s) {
  if (s == null || s.trim().isEmpty || s.toLowerCase() == 'null') return null;
  try {
    return DateTime.parse(s);
  } catch (_) {
    return null;
  }
}

String _formatDate(DateTime dateTime) {
  return DateFormat('EEE dd MMM').format(dateTime);
}

String _formatTime(DateTime dateTime) {
  return DateFormat('h:mm a').format(dateTime);
}

// (Removed) overlay badge and country chip helpers after switching to UserWidgetTitle

class RankingTabInline extends StatefulWidget {
  const RankingTabInline({
    super.key,
    required this.rankings,
    required this.topAgencies,
    required this.selectedPeriod,
    required this.onPeriodChanged,
    this.searchQuery = '',
    this.showInlineSearch = false,
    this.onSearchChanged,
  });

  final List<dynamic> rankings;
  final List<AgencyRankingEntity> topAgencies;
  final String selectedPeriod;
  final Function(String) onPeriodChanged;
  final String searchQuery;
  final bool showInlineSearch;
  final ValueChanged<String>? onSearchChanged;

  @override
  State<RankingTabInline> createState() => _RankingTabInlineState();
}

class _RankingTabInlineState extends State<RankingTabInline>
    with AutomaticKeepAliveClientMixin {
  @override
  bool get wantKeepAlive => true;

  @override
  Widget build(BuildContext context) {
    super.build(context);
    return Column(
      children: [
        // Podium (Top 3)
        SizedBox(
          height: 220,
          child: BlocBuilder<TopUsersCubit, TopUsersState>(
            builder: (context, state) {
              if (state is TopUsersLoading) {
                return const PodiumSkeleton();
              }
              if (state is TopUsersError) {
                return Center(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Text(TasksLocalization.error(context),
                          style:
                              const TextStyle(color: const Color(0xFFFF0000))),
                      const SizedBox(height: 4),
                      Text(state.message,
                          style: const TextStyle(
                              color: Colors.white70, fontSize: 12)),
                    ],
                  ),
                );
              }
              if (state is TopUsersLoaded) {
                final users = state.users;
                final top3 = users.take(3).toList();
                return _Podium(top3: top3);
              }
              return const SizedBox();
            },
          ),
        ),

        // Period selector: Daily | Weekly | Monthly
        Padding(
          padding: const EdgeInsets.fromLTRB(16, 4, 16, 8),
          child: Row(
            children: [
              Expanded(
                child: GestureDetector(
                  onTap: () => widget.onPeriodChanged('Monthly'),
                  child: Container(
                    height: 36,
                    decoration: BoxDecoration(
                      color: widget.selectedPeriod.toLowerCase() == 'monthly'
                          ? Colors.white.withValues(alpha: 0.22)
                          : Colors.white.withValues(alpha: 0.10),
                      borderRadius: BorderRadius.circular(20),
                      border: Border.all(
                        color: widget.selectedPeriod.toLowerCase() == 'monthly'
                            ? Colors.white
                            : Colors.white24,
                        width: widget.selectedPeriod.toLowerCase() == 'monthly'
                            ? 1.4
                            : 1,
                      ),
                    ),
                    alignment: Alignment.center,
                    child: Text(
                      TasksLocalization.monthly(context),
                      style: const TextStyle(
                          color: Colors.white, fontWeight: FontWeight.w700),
                    ),
                  ),
                ),
              ),
              const SizedBox(width: 8),
              Expanded(
                child: GestureDetector(
                  onTap: () => widget.onPeriodChanged('Weekly'),
                  child: Container(
                    height: 36,
                    decoration: BoxDecoration(
                      color: widget.selectedPeriod.toLowerCase() == 'weekly'
                          ? Colors.white.withValues(alpha: 0.22)
                          : Colors.white.withValues(alpha: 0.10),
                      borderRadius: BorderRadius.circular(20),
                      border: Border.all(
                        color: widget.selectedPeriod.toLowerCase() == 'weekly'
                            ? Colors.white
                            : Colors.white24,
                        width: widget.selectedPeriod.toLowerCase() == 'weekly'
                            ? 1.4
                            : 1,
                      ),
                    ),
                    alignment: Alignment.center,
                    child: Text(
                      TasksLocalization.weekly(context),
                      style: const TextStyle(
                          color: Colors.white, fontWeight: FontWeight.w700),
                    ),
                  ),
                ),
              ),
              const SizedBox(width: 8),
              Expanded(
                child: GestureDetector(
                  onTap: () => widget.onPeriodChanged('Daily'),
                  child: Container(
                    height: 36,
                    decoration: BoxDecoration(
                      color: widget.selectedPeriod.toLowerCase() == 'daily'
                          ? Colors.white.withValues(alpha: 0.22)
                          : Colors.white.withValues(alpha: 0.10),
                      borderRadius: BorderRadius.circular(20),
                      border: Border.all(
                        color: widget.selectedPeriod.toLowerCase() == 'daily'
                            ? Colors.white
                            : Colors.white24,
                        width: widget.selectedPeriod.toLowerCase() == 'daily'
                            ? 1.4
                            : 1,
                      ),
                    ),
                    alignment: Alignment.center,
                    child: Text(
                      TasksLocalization.daily(context),
                      style: const TextStyle(
                          color: Colors.white, fontWeight: FontWeight.w700),
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),

        if (widget.showInlineSearch)
          Padding(
            padding: const EdgeInsets.fromLTRB(16, 6, 16, 6),
            child: _SearchField(
              initialText: widget.searchQuery,
              onChanged: widget.onSearchChanged,
            ),
          ),

        // List (ranks 4..50)
        Expanded(
          child: BlocBuilder<TopUsersCubit, TopUsersState>(
            builder: (context, state) {
              if (state is TopUsersLoading) {
                return ListPerformanceOptimizer.optimizedListView(
                  padding: const EdgeInsets.only(top: 8),
                  cacheExtent: 300.0,
                  itemCount: 12,
                  itemBuilder: (_, __) => const RankingRowSkeleton(),
                );
              }
              if (state is! TopUsersLoaded) {
                return const SizedBox();
              }
              final users = state.users;
              final pool = users.length > 3
                  ? users.sublist(3)
                  : <UserEntity>[]; // 4..50 only
              final q = widget.searchQuery.trim().toLowerCase();
              final filtered = q.isEmpty
                  ? pool
                  : pool.where((u) {
                      final name = (u.name ?? '').toLowerCase();
                      return name.contains(q) ||
                          u.iduser.toLowerCase().contains(q);
                    }).toList();

              // Keep original rank from full list
              int originalRank(UserEntity u) =>
                  users.indexWhere((e) => e.iduser == u.iduser) + 1;
              filtered
                  .sort((a, b) => originalRank(a).compareTo(originalRank(b)));

              if (filtered.isEmpty) {
                return const Center(
                  child: Text('No results',
                      style: TextStyle(color: Colors.white70)),
                );
              }

              return ListPerformanceOptimizer.optimizedListView(
                padding:
                    const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                cacheExtent: 300.0,
                itemCount: filtered.length,
                itemBuilder: (context, index) {
                  final u = filtered[index];
                  final rank = originalRank(u);
                  return _UserRow(
                    user: u,
                    rank: rank,
                    onTap: () {
                      Navigator.of(context).push(
                        MaterialPageRoute(
                          builder: (_) => OtherUserProfile(
                            user: u,
                            userCubit: context.read<UserCubit>(),
                            roomCubit: context.read<RoomCubit>(),
                          ),
                        ),
                      );
                    },
                  );
                },
              );
            },
          ),
        ),
      ],
    );
  }
}

class _Podium extends StatelessWidget {
  const _Podium({required this.top3});
  final List<UserEntity> top3;

  @override
  Widget build(BuildContext context) {
    Widget buildHexAvatar(UserEntity? u, double width, double height) {
      final imgUrl = normalizeUserImage(u?.img);
      final image = (imgUrl != null && imgUrl.isNotEmpty)
          ? CachedNetworkImage(
              imageUrl: imgUrl,
              fit: BoxFit.cover,
              memCacheWidth: (width * 2).toInt(),
              memCacheHeight: (height * 2).toInt(),
              fadeInDuration: Duration.zero,
              placeholder: (_, __) => Container(
                color: Colors.white12,
                alignment: Alignment.center,
                child: const SizedBox(
                  width: 16,
                  height: 16,
                  child: CircularProgressIndicator(
                      strokeWidth: 1.6, color: Colors.white70),
                ),
              ),
              errorWidget: (_, __, ___) => Container(
                color: Colors.white24,
                alignment: Alignment.center,
                child: const Icon(Icons.person, color: Colors.white),
              ),
            )
          : Container(
              color: Colors.white24,
              child: const Icon(Icons.person, color: Colors.white),
            );
      // Visual insets: total size -> outer border -> white border -> image
      const totalInset = 8.0; // keep overall padding as before
      const outerBorderThickness = 2.0; // #338CD5 thickness
      const innerWhiteThickness = 2.0; // white thickness
      final clipW = width - totalInset;
      final clipH = height - totalInset;
      final radius =
          (clipW < clipH ? clipW : clipH) * 0.06; // proportional rounding
      return SizedBox(
        width: width,
        height: height,
        child: Center(
          child: SizedBox(
            width: clipW,
            height: clipH,
            child: Stack(
              fit: StackFit.expand,
              children: [
                // Outer colored border (#338CD5)
                ClipPath(
                  clipper: _RoundedHexagonClipper(cornerRadius: radius),
                  child: Container(color: const Color(0xFF338CD5)),
                ),
                // Inner white border
                Padding(
                  padding: const EdgeInsets.all(outerBorderThickness),
                  child: ClipPath(
                    clipper: _RoundedHexagonClipper(cornerRadius: radius),
                    child: Container(color: Colors.white),
                  ),
                ),
                // Image layer
                Padding(
                  padding: const EdgeInsets.all(
                      outerBorderThickness + innerWhiteThickness),
                  child: ClipPath(
                    clipper: _RoundedHexagonClipper(cornerRadius: radius),
                    child: image,
                  ),
                ),
              ],
            ),
          ),
        ),
      );
    }

    Widget buildAvatarWithName(UserEntity? u, double width, double height) {
      final name = u?.name ?? 'User';
      return Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          GestureDetector(
            onTap: (u == null)
                ? null
                : () {
                    Navigator.of(context).push(
                      MaterialPageRoute(
                        builder: (_) => OtherUserProfile(
                          user: u,
                          userCubit: context.read<UserCubit>(),
                          roomCubit: context.read<RoomCubit>(),
                        ),
                      ),
                    );
                  },
            child: buildHexAvatar(u, width, height),
          ),
          const SizedBox(height: 4),
          SizedBox(
            width: width - 8.0, // match inner visible area
            child: Text(
              name,
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
              textAlign: TextAlign.center,
              style: LevelTextStyles.listTitle()
                  .copyWith(fontSize: 12, fontWeight: FontWeight.w700),
            ),
          ),
        ],
      );
    }

    return LayoutBuilder(
      builder: (context, constraints) {
        final w = constraints.maxWidth;
        final h = constraints.maxHeight;
        // Make them slightly narrower and a bit taller
        const double centerW = 66.0;
        const double centerH = 78.0;
        const double sideW = 58.0;
        const double sideH = 68.0;
        return Stack(
          clipBehavior: Clip.none,
          children: [
            // Background podium image
            Positioned.fill(
              child: Center(
                child: Image.asset(
                  'assets/tasks/images/Agency Ranking.png',
                  fit: BoxFit.contain,
                ),
              ),
            ),
            // Rank 1 avatar (center)
            if (top3.isNotEmpty)
              Positioned(
                left: w * 0.494 - centerW / 2,
                top: h * 0.05,
                child: buildAvatarWithName(top3[0], centerW, centerH),
              ),
            // Rank 2 avatar (left)
            if (top3.length > 1)
              Positioned(
                left: w * 0.2556 - sideW / 2,
                top: h * 0.14,
                child: buildAvatarWithName(top3[1], sideW, sideH),
              ),
            // Rank 3 avatar (right)
            if (top3.length > 2)
              Positioned(
                left: w * 0.735 - sideW / 2,
                top: h * 0.18,
                child: buildAvatarWithName(top3[2], sideW, sideH),
              ),
          ],
        );
      },
    );
  }
}

// Hexagon clipper (pointy-top) used for podium avatars
class _RoundedHexagonClipper extends CustomClipper<Path> {
  _RoundedHexagonClipper({this.cornerRadius = 4});
  final double cornerRadius;

  @override
  Path getClip(Size size) {
    final w = size.width;
    final h = size.height;

    // Pointy-top hexagon vertices
    final p0 = Offset(w * 0.5, 0);
    final p1 = Offset(w, h * 0.25);
    final p2 = Offset(w, h * 0.75);
    final p3 = Offset(w * 0.5, h);
    final p4 = Offset(0, h * 0.75);
    final p5 = Offset(0, h * 0.25);
    final verts = [p0, p1, p2, p3, p4, p5];

    double r = cornerRadius.clamp(0, w * 0.2);
    if (r <= 0) {
      return Path()..addPolygon(verts, true);
    }

    Path path = Path();
    for (int i = 0; i < verts.length; i++) {
      final prev = verts[(i - 1) < 0 ? verts.length - 1 : i - 1];
      final curr = verts[i];
      final next = verts[(i + 1) % verts.length];

      // Directions
      final v1 = (curr - prev);
      final v2 = (next - curr);
      final len1 = v1.distance;
      final len2 = v2.distance;
      final d1 = len1 == 0 ? Offset.zero : v1 / len1;
      final d2 = len2 == 0 ? Offset.zero : v2 / len2;

      final pIn = curr - d1 * r;
      final pOut = curr + d2 * r;

      if (i == 0) {
        path.moveTo(pIn.dx, pIn.dy);
      } else {
        path.lineTo(pIn.dx, pIn.dy);
      }
      // Quadratic bezier around the corner
      path.quadraticBezierTo(curr.dx, curr.dy, pOut.dx, pOut.dy);
    }
    path.close();
    return path;
  }

  @override
  bool shouldReclip(covariant CustomClipper<Path> oldClipper) => false;
}

class _UserRow extends StatelessWidget {
  const _UserRow({required this.user, required this.rank, required this.onTap});
  final UserEntity user;
  final int rank;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    // Derive extra info for display
    // Display level3 as requested instead of coins-based totals
    final pointsStr = user.level3 ?? '0';
    final points = _parseInt(pointsStr);
    final lastActive =
        _parseDate(user.updated_at) ?? _parseDate(user.created_at);
    final languageCubit = context.read<LanguageCubit>();
    final selectedLanguage = languageCubit.state.languageCode;
    // Consider Arabic locales as RTL explicitly (e.g., ar, ar-SA, ar_EG)
    final isRTL = selectedLanguage.toLowerCase().startsWith('ar');

    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(12),
      child: Container(
        margin: const EdgeInsets.only(bottom: 10),
        padding: const EdgeInsets.all(12),
        decoration: BoxDecoration(
          color: Colors.white.withValues(alpha: 0.06),
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: Colors.white24, width: 1),
        ),
        child: Builder(builder: (context) {
          final rankWidget = Container(
            width: 32,
            alignment: Alignment.center,
            child: Text(
              '$rank',
              style: TextStyle(
                color: rank <= 3 ? Colors.amber : Colors.white,
                fontWeight: FontWeight.bold,
              ),
            ),
          );

          final userWidget = Expanded(
            child: UserWidgetTitle(
              user: user,
              userCubit: context.read<UserCubit>(),
              isID: true,
              isLevel: true,
              isIcon: false,
              isAnimatedIcon: false,
              islevelTrailing: false,
              isRoomTypeUser: true,
              isWakel: false,
              isSmall: true,
              isNameOnly: true,
              contentPadding: const EdgeInsets.symmetric(horizontal: 0),
              nameColor: AppColors.white,
              idColor: AppColors.white,
            ),
          );

          final statsWidget = Transform.translate(
            offset: const Offset(0, 0),
            child: Column(
              crossAxisAlignment:
                  isRTL ? CrossAxisAlignment.start : CrossAxisAlignment.end,
              children: [
                Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    const Icon(Icons.bar_chart,
                        color: Colors.lightBlueAccent, size: 16),
                    const SizedBox(width: 4),
                    Text(
                      _formatPoints(points),
                      style: const TextStyle(
                        color: Colors.lightBlueAccent,
                        fontSize: 14,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ],
                ),
                if (lastActive != null) ...[
                  const SizedBox(height: 2),
                  Text(
                    _formatDate(lastActive),
                    style: LevelTextStyles.listCounter().copyWith(fontSize: 10),
                  ),
                  Text(
                    _formatTime(lastActive),
                    style: LevelTextStyles.listCounter().copyWith(fontSize: 10),
                  ),
                ],
              ],
            ),
          );

          final left = isRTL ? statsWidget : rankWidget;
          final right = isRTL ? rankWidget : statsWidget;

          return Row(
            children: [
              left,
              const SizedBox(width: 8),
              userWidget,
              const SizedBox(width: 10),
              right,
            ],
          );
        }),
      ),
    );
  }
}

class _SearchField extends StatelessWidget {
  const _SearchField({required this.initialText, required this.onChanged});
  final String initialText;
  final ValueChanged<String>? onChanged;

  @override
  Widget build(BuildContext context) {
    final controller = TextEditingController.fromValue(
      TextEditingValue(
          text: initialText,
          selection: TextSelection.collapsed(offset: initialText.length)),
    );
    return SizedBox(
      height: 44,
      child: TextField(
        controller: controller,
        onChanged: onChanged,
        style: const TextStyle(color: Colors.white),
        cursorColor: Colors.white,
        decoration: InputDecoration(
          filled: true,
          fillColor: Colors.white.withValues(alpha: 0.12),
          prefixIcon: const Icon(Icons.search, color: Colors.white70),
          suffixIcon: (initialText.isNotEmpty)
              ? IconButton(
                  icon: const Icon(Icons.clear, color: Colors.white70),
                  onPressed: () => onChanged?.call(''),
                )
              : null,
          hintText: 'Search users (rank 4-50)',
          hintStyle: const TextStyle(color: Colors.white70),
          contentPadding:
              const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(12),
            borderSide: BorderSide(color: Colors.white.withValues(alpha: 0.2)),
          ),
          enabledBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(12),
            borderSide: BorderSide(color: Colors.white.withValues(alpha: 0.2)),
          ),
          focusedBorder: const OutlineInputBorder(
            borderRadius: BorderRadius.all(Radius.circular(12)),
            borderSide: BorderSide(color: Colors.white, width: 1),
          ),
        ),
      ),
    );
  }
}
