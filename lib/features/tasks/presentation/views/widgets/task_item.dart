import 'package:flutter/material.dart';
import 'common/level_text_styles.dart';
import 'common/promote_button.dart';
import 'common/fancy_progress_bar.dart';
import '../../../domain/entities/task_entity.dart';
import '../../utils/tasks_localization.dart';

class TaskItem extends StatelessWidget {
  final TaskEntity task;
  final VoidCallback onPromote;

  const TaskItem({
    super.key,
    required this.task,
    required this.onPromote,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white.withOpacity(0.05),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: Colors.white.withOpacity(0.1),
          width: 1,
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Expanded(
                child: Text(
                  task.title,
                  style: LevelTextStyles.listTitle(),
                ),
              ),
              Row(
                children: [
                  Text(
                    task.totalProgress > 0
                        ? '${task.currentProgress}/${task.totalProgress}'
                        : '${task.currentProgress}',
                    style: LevelTextStyles.listCounter(),
                  ),
                  const SizedBox(width: 12),
                  PromoteButton(
                    label: task.isCompleted
                        ? TasksLocalization.taskCompleted(context)
                        : TasksLocalization.promote(context),
                    isCompleted: task.isCompleted,
                    onPressed: task.isCompleted ? null : onPromote,
                  ),
                ],
              )
            ],
          ),
          const SizedBox(height: 12),
          Row(
            children: [
              Expanded(
                child: task.totalProgress > 0
                    ? FancyProgressBar(
                        progress:
                            task.isCompleted ? 1.0 : task.progressPercentage,
                        height: 10,
                        showStar: !task.isCompleted,
                      )
                    : const SizedBox.shrink(),
              ),
              const SizedBox(width: 12),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                decoration: BoxDecoration(
                  color: Colors.amber.withOpacity(0.2),
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(
                    color: Colors.amber.withOpacity(0.5),
                    width: 1,
                  ),
                ),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Icon(
                      Icons.star,
                      color: Colors.amber,
                      size: 14,
                    ),
                    const SizedBox(width: 4),
                    Text(
                      '${task.points}',
                      style: TextStyle(
                        color: Colors.amber,
                        fontSize: 12,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}
