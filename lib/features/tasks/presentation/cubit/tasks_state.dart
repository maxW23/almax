import 'package:equatable/equatable.dart';
import '../../domain/entities/task_entity.dart';
import '../../domain/entities/user_level_entity.dart';
import '../../domain/entities/ranking_entity.dart';

abstract class TasksState extends Equatable {
  const TasksState();

  @override
  List<Object?> get props => [];
}

class TasksInitial extends TasksState {}

class TasksLoading extends TasksState {}

class TasksLoaded extends TasksState {
  final List<TaskEntity> myLevelTasks;
  final List<TaskEntity> upgradeTasks;
  final UserLevelEntity? userLevel;
  final List<RankingEntity> dailyRankings;
  final List<RankingEntity> weeklyRankings;
  final List<RankingEntity> monthlyRankings;
  final List<AgencyRankingEntity> topAgencies;
  final int selectedTabIndex;
  final String selectedRankingPeriod;
  final String? rawMissionsText;

  const TasksLoaded({
    required this.myLevelTasks,
    required this.upgradeTasks,
    this.userLevel,
    required this.dailyRankings,
    required this.weeklyRankings,
    required this.monthlyRankings,
    required this.topAgencies,
    required this.selectedTabIndex,
    required this.selectedRankingPeriod,
    this.rawMissionsText,
  });

  @override
  List<Object?> get props => [
        myLevelTasks,
        upgradeTasks,
        userLevel,
        dailyRankings,
        weeklyRankings,
        monthlyRankings,
        topAgencies,
        selectedTabIndex,
        selectedRankingPeriod,
        rawMissionsText,
      ];

  TasksLoaded copyWith({
    List<TaskEntity>? myLevelTasks,
    List<TaskEntity>? upgradeTasks,
    UserLevelEntity? userLevel,
    List<RankingEntity>? dailyRankings,
    List<RankingEntity>? weeklyRankings,
    List<RankingEntity>? monthlyRankings,
    List<AgencyRankingEntity>? topAgencies,
    int? selectedTabIndex,
    String? selectedRankingPeriod,
    String? rawMissionsText,
  }) {
    return TasksLoaded(
      myLevelTasks: myLevelTasks ?? this.myLevelTasks,
      upgradeTasks: upgradeTasks ?? this.upgradeTasks,
      userLevel: userLevel ?? this.userLevel,
      dailyRankings: dailyRankings ?? this.dailyRankings,
      weeklyRankings: weeklyRankings ?? this.weeklyRankings,
      monthlyRankings: monthlyRankings ?? this.monthlyRankings,
      topAgencies: topAgencies ?? this.topAgencies,
      selectedTabIndex: selectedTabIndex ?? this.selectedTabIndex,
      selectedRankingPeriod:
          selectedRankingPeriod ?? this.selectedRankingPeriod,
      rawMissionsText: rawMissionsText ?? this.rawMissionsText,
    );
  }
}

class TasksError extends TasksState {
  final String message;

  const TasksError(this.message);

  @override
  List<Object> get props => [message];
}

class TaskClaimLoading extends TasksState {
  final String taskId;

  const TaskClaimLoading(this.taskId);

  @override
  List<Object> get props => [taskId];
}

class TaskClaimSuccess extends TasksState {
  final String message;

  const TaskClaimSuccess(this.message);

  @override
  List<Object> get props => [message];
}

class TaskClaimError extends TasksState {
  final String message;

  const TaskClaimError(this.message);

  @override
  List<Object> get props => [message];
}
