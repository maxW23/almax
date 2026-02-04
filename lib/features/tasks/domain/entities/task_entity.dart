class TaskEntity {
  final String id;
  final String title;
  final String description;
  final int currentProgress;
  final int totalProgress;
  final int points;
  final bool isCompleted;
  final String? icon;
  final TaskType type;

  TaskEntity({
    required this.id,
    required this.title,
    required this.description,
    required this.currentProgress,
    required this.totalProgress,
    required this.points,
    required this.isCompleted,
    this.icon,
    required this.type,
  });

  double get progressPercentage =>
      totalProgress > 0 ? currentProgress / totalProgress : 0;
}

enum TaskType { daily, achievement, special }
