class RankingEntity {
  final int rank;
  final String userId;
  final String userName;
  final String userImage;
  final int points;
  final int level;
  final bool hasVip;
  final int vipLevel;
  final bool hasDiamond;
  final int diamondLevel;
  final String? country;
  final DateTime lastActive;

  RankingEntity({
    required this.rank,
    required this.userId,
    required this.userName,
    required this.userImage,
    required this.points,
    required this.level,
    required this.hasVip,
    required this.vipLevel,
    required this.hasDiamond,
    required this.diamondLevel,
    this.country,
    required this.lastActive,
  });
}

class AgencyRankingEntity {
  final int rank;
  final String agencyName;
  final String agencyImage;
  final int totalPoints;

  AgencyRankingEntity({
    required this.rank,
    required this.agencyName,
    required this.agencyImage,
    required this.totalPoints,
  });
}
