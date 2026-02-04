import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../../domain/entities/task_entity.dart';
import '../../../domain/entities/user_level_entity.dart';
import '../../cubit/tasks_cubit.dart';
import '../../utils/tasks_localization.dart';
import 'level_card.dart';
import 'common/level_text_styles.dart';
import 'task_item.dart';

class MyLevelTab extends StatefulWidget {
  final List<TaskEntity> tasks;
  final UserLevelEntity? userLevel;

  const MyLevelTab({
    super.key,
    required this.tasks,
    this.userLevel,
  });

  @override
  State<MyLevelTab> createState() => _MyLevelTabState();
}

class _MyLevelTabState extends State<MyLevelTab>
    with AutomaticKeepAliveClientMixin {
  @override
  bool get wantKeepAlive => true;

  @override
  Widget build(BuildContext context) {
    super.build(context);
    return CustomScrollView(
      slivers: [
        SliverPadding(
          padding: const EdgeInsets.all(16),
          sliver: SliverList(
            delegate: SliverChildListDelegate([
              if (widget.userLevel != null)
                LevelCard(userLevel: widget.userLevel!),
              const SizedBox(height: 20),
              Text(TasksLocalization.tasks(context),
                  style: LevelTextStyles.sectionTitle()),
              const SizedBox(height: 12),
            ]),
          ),
        ),
        SliverPadding(
          padding: const EdgeInsets.symmetric(horizontal: 16),
          sliver: SliverList.separated(
            itemCount: widget.tasks.length,
            separatorBuilder: (_, __) => const SizedBox(height: 12),
            itemBuilder: (context, index) {
              final task = widget.tasks[index];
              return TaskItem(
                task: task,
                onPromote: () {
                  context.read<TasksCubit>().claimReward(task.id);
                },
              );
            },
          ),
        ),
        const SliverToBoxAdapter(child: SizedBox(height: 16)),
      ],
    );
  }
}
