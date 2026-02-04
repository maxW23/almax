class UserLevelEntity {
  final int currentLevel;
  final int nextLevel;
  final int currentPoints;
  final int pointsToUpgrade;
  final String userImage;
  final String userName;

  UserLevelEntity({
    required this.currentLevel,
    required this.nextLevel,
    required this.currentPoints,
    required this.pointsToUpgrade,
    required this.userImage,
    required this.userName,
  });
}
