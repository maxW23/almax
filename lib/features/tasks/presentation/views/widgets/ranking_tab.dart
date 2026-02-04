import 'package:flutter/material.dart';
import '../../../domain/entities/ranking_entity.dart';
import 'ranking_tab_inline.dart';

class RankingTab extends StatelessWidget {
  final List<dynamic> rankings;
  final List<AgencyRankingEntity> topAgencies;
  final String selectedPeriod;
  final Function(String) onPeriodChanged;
  final String searchQuery;
  final bool showInlineSearch;
  final ValueChanged<String>? onSearchChanged;

  const RankingTab({
    super.key,
    required this.rankings,
    required this.topAgencies,
    required this.selectedPeriod,
    required this.onPeriodChanged,
    this.searchQuery = '',
    this.showInlineSearch = false,
    this.onSearchChanged,
  });

  @override
  Widget build(BuildContext context) {
    return RankingTabInline(
      rankings: rankings,
      topAgencies: topAgencies,
      selectedPeriod: selectedPeriod,
      onPeriodChanged: onPeriodChanged,
      searchQuery: searchQuery,
      showInlineSearch: showInlineSearch,
      onSearchChanged: onSearchChanged,
    );
  }
}

/*
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:country_flags/country_flags.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:lklk/features/home/presentation/manger/top_user_cubit/top_users_cubit.dart';
import 'package:lklk/features/auth/domain/entities/user_entity.dart';
import 'package:lklk/core/constants/assets.dart';
import '../../../domain/entities/ranking_entity.dart';
import 'package:lklk/features/profile_users/presentaion/manger/user_cubit/user_cubit_cubit.dart';
import 'package:lklk/features/home/presentation/manger/room_cubit/room_cubit_cubit.dart';
import 'package:lklk/features/profile_users/presentaion/views/pages/other_user_profile.dart';

/*
class RankingTab extends StatelessWidget {
  final List<dynamic> rankings;
  final List<AgencyRankingEntity> topAgencies;
  final String selectedPeriod;
  final Function(String) onPeriodChanged;
  final String searchQuery;
  final bool showInlineSearch;
  final ValueChanged<String>? onSearchChanged;

  const RankingTab({
    super.key,
    required this.rankings,
    required this.topAgencies,
    required this.selectedPeriod,
    required this.onPeriodChanged,
    this.searchQuery = '',
    this.showInlineSearch = false,
    this.onSearchChanged,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        // Top 3 Agencies with platform base per Figma
        SizedBox(
          height: 280,
          child: Stack(
            children: [
              // Base platform
              Positioned(
                right: 24,
                bottom: 8,
                child: Container(
                  height: 14,
                  decoration: BoxDecoration(
                    gradient: LinearGradient(
                      colors: [
                        const Color(0xFF3E4DA3).withValues(alpha: 0.6),
                        const Color(0xFF3859D0).withValues(alpha: 0.6),
                      ],
                    ),
                    borderRadius: BorderRadius.circular(8),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withValues(alpha: 0.25),
                        blurRadius: 12,
                        offset: const Offset(0, 6),
                  if (pool.isEmpty) {
                    return _buildEmptyState(message: 'No users available.');
                  }
*/

import 'package:flutter/material.dart';
import '../../../domain/entities/ranking_entity.dart';
import 'ranking_tab_inline.dart';

class RankingTab extends StatelessWidget {
  final List<dynamic> rankings;
  final List<AgencyRankingEntity> topAgencies;
  final String selectedPeriod;
  final Function(String) onPeriodChanged;
  final String searchQuery;
  final bool showInlineSearch;
  final ValueChanged<String>? onSearchChanged;

  const RankingTab({
    super.key,
    required this.rankings,
    required this.topAgencies,
    required this.selectedPeriod,
    required this.onPeriodChanged,
    this.searchQuery = '',
    this.showInlineSearch = false,
    this.onSearchChanged,
  });

  @override
  Widget build(BuildContext context) {
    return RankingTabInline(
      rankings: rankings,
      topAgencies: topAgencies,
      selectedPeriod: selectedPeriod,
      onPeriodChanged: onPeriodChanged,
      searchQuery: searchQuery,
      showInlineSearch: showInlineSearch,
      onSearchChanged: onSearchChanged,
    );
  }
}
*/

/*
import 'ranking_tab_inline.dart';

class RankingTab extends StatelessWidget {
  final List<dynamic> rankings;
  final List<AgencyRankingEntity> topAgencies;
  final String selectedPeriod;
  final Function(String) onPeriodChanged;
  final String searchQuery;
  final bool showInlineSearch;
  final ValueChanged<String>? onSearchChanged;

  const RankingTab({
    super.key,
    required this.rankings,
    required this.topAgencies,
    required this.selectedPeriod,
    required this.onPeriodChanged,
    this.searchQuery = '',
    this.showInlineSearch = false,
    this.onSearchChanged,
  });

  @override
  Widget build(BuildContext context) {
    return RankingTabInline(
      rankings: rankings,
      topAgencies: topAgencies,
      selectedPeriod: selectedPeriod,
      onPeriodChanged: onPeriodChanged,
      searchQuery: searchQuery,
      showInlineSearch: showInlineSearch,
      onSearchChanged: onSearchChanged,
    );
  }
}
                  final items = List<RankingEntity>.generate(
                    pool.length,
                    (i) => _mapUserToRanking(pool[i], i, 4),
                  );
                  return ListView.builder(
                    padding: const EdgeInsets.all(16),
                    itemCount: items.length,
                    itemBuilder: (context, index) {
                      final u = pool[index];
                      return InkWell(
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
                        child: _buildRankingItem(items[index]),
                      );
                    },
                  );
                } else {
                  // Search within ranks 4..50 only, keep original ranks
                  final filtered = _filterUsers(pool, searchQuery);
                  if (filtered.isEmpty) {
                    return _buildEmptyState(
                      message: "No results for '$searchQuery'",
                    );
                  }
                  final items = filtered
                      .map((u) => _mapUserToRankingWithOriginalRank(u, users))
                      .toList();
                  return ListView.builder(
                    padding: const EdgeInsets.all(16),
                    itemCount: items.length,
                    itemBuilder: (context, index) {
                      final u = filtered[index];
                      return InkWell(
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
                        child: _buildRankingItem(items[index]),
                      );
                    },
                  );
                }
              }
              return const SizedBox();
{{ ... }}
            },
          ),
        ),
      ],
    );
  }

  Widget _buildTopUser(UserEntity user, int rank, double height) {
    final imageUrl = (user.img != null && user.img!.isNotEmpty)
        ? user.img!
        : (user.avatarUrlNotifier.value ?? '');
    final pointsStr =
        user.totalSocre ?? user.giftSend ?? user.giftRecive ?? '0';
    final points = _parseInt(pointsStr);
    final last = _parseDate(user.updated_at) ?? _parseDate(user.created_at);

    return Container(
      width: 110,
      margin: const EdgeInsets.symmetric(horizontal: 8),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.end,
        mainAxisSize: MainAxisSize.min,
        children: [
          // User Image with rank badge overlay (wrapped to reserve space for badge)
          SizedBox(
            height: 66, // 54 image + ~12 badge overhang
            child: Stack(
              clipBehavior: Clip.none,
              alignment: Alignment.center,
              children: [
                Transform.rotate(
                  angle: 0.523599, // ~30° to fake a hex frame
                  child: Container(
                    width: 54,
                    height: 54,
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(10),
                      border: Border.all(
                        color: rank == 1
                            ? Colors.amber
                            : rank == 2
                                ? Colors.grey[400]!
                                : Colors.brown[400]!,
                        width: 2,
                      ),
                    ),
                  ),
                ),
                ClipRRect(
                  borderRadius: BorderRadius.circular(10),
                  child: imageUrl.isNotEmpty
                      ? CachedNetworkImage(
                          imageUrl: imageUrl,
                          width: 46,
                          height: 46,
                          fit: BoxFit.cover,
                          fadeInDuration: Duration.zero,
                          fadeOutDuration: Duration.zero,
                          errorWidget: (_, __, ___) => Image.asset(
                            AssetsData.userProfileIconA,
                            width: 30,
                            height: 30,
                            color: Colors.white,
                          ),
                        )
                      : Image.asset(
                          AssetsData.userProfileIconA,
                          width: 30,
                          height: 30,
                          color: Colors.white,
                        ),
                ),
                Positioned(
                  bottom: -12,
                  child: CircleAvatar(
                    radius: 12,
                    backgroundColor: Colors.white,
                    child: Text(
                      '$rank',
                      style: TextStyle(
                        color: rank == 1
                            ? Colors.amber[800]
                            : rank == 2
                                ? Colors.grey[800]
                                : Colors.brown[800],
                        fontWeight: FontWeight.w800,
                        fontSize: 12,
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 12),
          // User Name
          Text(
            user.name ?? 'User',
            style: const TextStyle(
              color: Colors.white,
              fontSize: 11,
              fontWeight: FontWeight.w800,
            ),
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
          ),
          // Points + Date
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            mainAxisSize: MainAxisSize.min,
            children: [
              const Icon(
                Icons.monetization_on,
                color: Colors.amber,
                size: 12,
              ),
              const SizedBox(width: 3),
              Text(
                '${(points / 1000).toStringAsFixed(1)}k',
                style: const TextStyle(
                  color: Colors.amber,
                  fontSize: 10,
                  fontWeight: FontWeight.bold,
                ),
              ),
              if (last != null) ...[
                const SizedBox(width: 6),
                Text(
                  _formatDate(last),
                  style: TextStyle(
                    color: Colors.white.withValues(alpha: 0.7),
                    fontSize: 9,
                  ),
                ),
              ]
            ],
          ),
          const SizedBox(height: 6),
          // Podium column
          Container(
            width: double.infinity,
            height: height,
            decoration: BoxDecoration(
              gradient: LinearGradient(
                begin: Alignment.topCenter,
                end: Alignment.bottomCenter,
                colors: rank == 1
                    ? [Colors.amber[600]!, Colors.amber[800]!]
                    : rank == 2
                        ? [Colors.grey[500]!, Colors.grey[700]!]
                        : [Colors.brown[500]!, Colors.brown[700]!],
              ),
              borderRadius: const BorderRadius.only(
                topLeft: Radius.circular(10),
                topRight: Radius.circular(10),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildRankingItem(RankingEntity ranking, {VoidCallback? onTap}) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(12),
      child: Container(
      margin: const EdgeInsets.only(bottom: 12),
      decoration: BoxDecoration(
        color: Colors.white.withValues(alpha: 0.05),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: Colors.white.withValues(alpha: 0.1), width: 1),
      ),
      child: Stack(
        children: [
          // Left rank-colored stripe
          Positioned(
            left: 0,
            top: 0,
            bottom: 0,
            child: Container(
              width: 3,
              decoration: BoxDecoration(
                color: _rankColor(ranking.rank),
                borderRadius: const BorderRadius.only(
                  topLeft: Radius.circular(12),
                  bottomLeft: Radius.circular(12),
                ),
              ),
            ),
          ),
          // Content
          Padding(
            padding: const EdgeInsets.all(12).copyWith(left: 14),
            child: Row(
              children: [
                // Rank
                Container(
                  width: 30,
                  alignment: Alignment.center,
                  child: Text(
                    ranking.rank.toString(),
                    style: TextStyle(
                      color: ranking.rank <= 3 ? Colors.amber : Colors.white,
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
                const SizedBox(width: 12),
                // User Avatar (network with placeholder)
                Container(
                  width: 50,
                  height: 50,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    border: Border.all(
                      color: ranking.hasVip
                          ? Colors.purple
                          : Colors.white.withValues(alpha: 0.3),
                      width: 2,
                    ),
                  ),
                  child: ClipOval(
                    child: CachedNetworkImage(
                      imageUrl: ranking.userImage,
                      fit: BoxFit.cover,
                      fadeInDuration: Duration.zero,
                      fadeOutDuration: Duration.zero,
                      errorWidget: (_, __, ___) => Image.asset(
                        AssetsData.userProfileIconA,
                        fit: BoxFit.cover,
                      ),
                    ),
                  ),
                ),
                const SizedBox(width: 12),
                // User Info
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: [
                          Text(
                            ranking.userName,
                            style: const TextStyle(
                              color: Colors.white,
                              fontSize: 14,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          const SizedBox(width: 8),
                          if (ranking.country != null)
                            _buildCountryChip(ranking.country!),
                        ],
                      ),
                      const SizedBox(height: 4),
                      Row(
                        children: [
                          Text(
                            'ID:${ranking.userId}',
                            style: TextStyle(
                              color: Colors.white.withValues(alpha: 0.5),
                              fontSize: 11,
                            ),
                          ),
                          const SizedBox(width: 8),
                          _buildBadge(
                              'LVL.${ranking.level}', Colors.lightBlueAccent),
                          if (ranking.hasVip)
                            _buildBadge(
                                'VIP${ranking.vipLevel}', Colors.purple),
                          if (ranking.hasDiamond)
                            _buildBadge(
                                'DMD${ranking.diamondLevel}', Colors.cyan),
                        ],
                      ),
                    ],
                  ),
                ),
                // Points
                Column(
                  crossAxisAlignment: CrossAxisAlignment.end,
                  children: [
                    Row(
                      children: [
                        Icon(
                          Icons.monetization_on,
                          color: Colors.amber,
                          size: 16,
                        ),
                        const SizedBox(width: 4),
                        Text(
                          '${(ranking.points / 1000).toStringAsFixed(1)}k',
                          style: TextStyle(
                            color: Colors.amber,
                            fontSize: 14,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 4),
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.end,
                      children: [
                        Text(
                          _formatDate(ranking.lastActive),
                          style: TextStyle(
                            color: Colors.white.withValues(alpha: 0.6),
                            fontSize: 10,
                          ),
                        ),
                        Text(
                          _formatTime(ranking.lastActive),
                          style: TextStyle(
                            color: Colors.white.withValues(alpha: 0.6),
                            fontSize: 10,
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildBadge(String text, Color color) {
    return Container(
      margin: const EdgeInsets.only(left: 4),
      padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.2),
        borderRadius: BorderRadius.circular(4),
        border: Border.all(
          color: color,
          width: 1,
        ),
      ),
      child: Text(
        text,
        style: TextStyle(
          color: color,
          fontSize: 10,
          fontWeight: FontWeight.bold,
        ),
      ),
    );
  }

  // Helpers
  List<UserEntity> _filterUsers(List<UserEntity> users, String query) {
    final q = query.trim().toLowerCase();
    if (q.isEmpty) return users;
    return users.where((u) {
      final name = (u.name ?? '').toLowerCase();
      final id = (u.iduser).toString();
      return name.contains(q) || id.contains(q);
    }).toList();
  }

  RankingEntity _mapUserToRanking(UserEntity u, int index, int baseRank) {
    final img = (u.img != null && u.img!.isNotEmpty)
        ? u.img!
        : (u.avatarUrlNotifier.value ?? '');
    final pointsStr = u.totalSocre ?? u.giftSend ?? u.giftRecive ?? '0';
    final points = _parseInt(pointsStr);
    final lvl = int.tryParse(u.level1 ?? '') ?? 0;
    final vipLvl = int.tryParse(u.vip ?? '') ?? 0;
    final dmdLvl = int.tryParse(u.level2 ?? '') ?? 0;
    final ct =
        (u.country ?? '').isEmpty ? null : (u.country ?? '').toUpperCase();
    final last =
        _parseDate(u.updated_at) ?? _parseDate(u.created_at) ?? DateTime.now();

    return RankingEntity(
      rank: baseRank + index,
      userId: u.iduser,
      userName: u.name ?? 'User',
      userImage: img,
      points: points,
      level: lvl,
      hasVip: vipLvl > 0,
      vipLevel: vipLvl,
      hasDiamond: dmdLvl > 0,
      diamondLevel: dmdLvl,
      country: ct,
      lastActive: last,
    );
  }

  RankingEntity _mapUserToRankingWithOriginalRank(
      UserEntity u, List<UserEntity> all) {
    final idx = all.indexWhere((e) => e.iduser == u.iduser);
    final safeIndex = idx >= 0 ? idx : 0;
    return _mapUserToRanking(u, safeIndex, 1);
  }

  int _parseInt(String? s) {
    if (s == null) return 0;
    final raw = s.trim();
    if (raw.isEmpty) return 0;
    final lower = raw.toLowerCase();
    if (lower.endsWith('m')) {
      final numPart = lower.replaceAll('m', '');
      final v = double.tryParse(numPart) ?? 0.0;
      return (v * 1000000).round();
    }
    if (lower.endsWith('k')) {
      final numPart = lower.replaceAll('k', '');
      final v = double.tryParse(numPart) ?? 0.0;
      return (v * 1000).round();
    }
    // fallback: digits only
    final cleaned = lower.replaceAll(RegExp(r'[^0-9]'), '');
    return int.tryParse(cleaned) ?? 0;
  }

  DateTime? _parseDate(String? s) {
    if (s == null || s.isEmpty) return null;
    try {
      return DateTime.parse(s);
    } catch (_) {
      return null;
    }
  }

  Widget _buildEmptyState({required String message}) {
    return Center(
      child: Text(
        message,
        style: const TextStyle(color: Colors.white70),
      ),
    );
  }

  Widget _buildErrorState(BuildContext context, {required String message}) {
    return Center(
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Text(
            message,
            style: const TextStyle(color: const Color(0xFFFF0000),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 8),
          TextButton(
            onPressed: () => context.read<TopUsersCubit>().fetchTopUsers(12),
            child: const Text('Retry', style: TextStyle(color: Colors.white)),
          ),
        ],
      ),
    );
  }

  Widget _buildCountryChip(String countryCode) {
    return Container(
      margin: const EdgeInsets.only(left: 4),
      padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
      decoration: BoxDecoration(
        color: Colors.white.withValues(alpha: 0.15),
        borderRadius: BorderRadius.circular(4),
        border: Border.all(color: Colors.white.withValues(alpha: 0.25), width: 1),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          ClipRRect(
            borderRadius: BorderRadius.circular(2),
            child: CountryFlag.fromCountryCode(
              countryCode.toUpperCase(),
              width: 14,
              height: 10,
            ),
          ),
        ],
      ),
    );
  }

  Color _rankColor(int rank) {
    if (rank == 1) return Colors.amber;
    if (rank == 2) return Colors.grey;
    if (rank == 3) return Colors.brown;
    return const Color(0xFFFF0000).withValues(alpha: 0.6);
  }

  String _formatDate(DateTime dateTime) {
    return DateFormat('EEE dd MMM').format(dateTime);
  }

  String _formatTime(DateTime dateTime) {
    return DateFormat('h:mm a').format(dateTime);
  }
}

*/
