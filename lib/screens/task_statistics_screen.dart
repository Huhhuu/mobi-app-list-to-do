import 'package:flutter/material.dart';

import '../data/mock_tasks.dart';
import '../models/task_item.dart';
import 'statistics_task_source_screen.dart';

class TaskStatisticsScreen extends StatelessWidget {
  const TaskStatisticsScreen({super.key});

  List<TaskItem> _allTasks() => MockTasks.build();

  List<TaskItem> _completedTasks() {
    return _allTasks().where((TaskItem task) => task.isDone).toList();
  }

  List<TaskItem> _overdueTasks() {
    final DateTime now = DateTime.now();
    return _allTasks().where((TaskItem task) {
      return !task.isDone && task.dueTime.isBefore(now);
    }).toList();
  }

  List<TaskItem> _todayTasks() {
    final DateTime now = DateTime.now();
    final DateTime today = DateTime(now.year, now.month, now.day);

    return _allTasks().where((TaskItem task) {
      final DateTime taskDate = DateTime(
        task.dueTime.year,
        task.dueTime.month,
        task.dueTime.day,
      );
      return taskDate == today;
    }).toList();
  }

  List<TaskItem> _sharedTasks() {
    return _allTasks().where((TaskItem task) => task.isShared).toList();
  }

  void _openSourceTasks(
    BuildContext context,
    String title,
    List<TaskItem> tasks,
  ) {
    Navigator.of(context).push(
      MaterialPageRoute<void>(
        builder: (BuildContext context) =>
            StatisticsTaskSourceScreen(title: title, tasks: tasks),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final List<TaskItem> completed = _completedTasks();
    final List<TaskItem> overdue = _overdueTasks();
    final List<TaskItem> today = _todayTasks();
    final List<TaskItem> shared = _sharedTasks();

    return ListView(
      padding: const EdgeInsets.all(16),
      children: <Widget>[
        _StatsCard(
          title: 'Tien do hoan thanh',
          value:
              '${((completed.length / (_allTasks().isEmpty ? 1 : _allTasks().length)) * 100).round()}%',
          progress:
              completed.length /
              (_allTasks().isEmpty ? 1 : _allTasks().length),
          color: const Color(0xFF2A9D8F),
          onTap: () =>
              _openSourceTasks(context, 'Cong viec da hoan thanh', completed),
        ),
        const SizedBox(height: 12),
        _StatsCard(
          title: 'Cong viec qua han',
          value: overdue.length.toString().padLeft(2, '0'),
          progress:
              overdue.length /
              (_allTasks().isEmpty ? 1 : _allTasks().length),
          color: const Color(0xFFE76F51),
          onTap: () => _openSourceTasks(context, 'Cong viec qua han', overdue),
        ),
        const SizedBox(height: 12),
        _StatsCard(
          title: 'Cong viec trong hom nay',
          value: today.length.toString().padLeft(2, '0'),
          progress:
              today.length / (_allTasks().isEmpty ? 1 : _allTasks().length),
          color: const Color(0xFF264653),
          onTap: () =>
              _openSourceTasks(context, 'Cong viec trong hom nay', today),
        ),
        const SizedBox(height: 12),
        _StatsCard(
          title: 'Cong viec da chia se',
          value: shared.length.toString().padLeft(2, '0'),
          progress:
              shared.length /
              (_allTasks().isEmpty ? 1 : _allTasks().length),
          color: const Color(0xFF3A86FF),
          onTap: () => _openSourceTasks(context, 'Cong viec chia se', shared),
        ),
      ],
    );
  }
}

class _StatsCard extends StatelessWidget {
  const _StatsCard({
    required this.title,
    required this.value,
    required this.progress,
    required this.color,
    required this.onTap,
  });

  final String title;
  final String value;
  final double progress;
  final Color color;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final double clampedProgress = progress.clamp(0, 1);

    return Card(
      child: InkWell(
        borderRadius: BorderRadius.circular(16),
        onTap: onTap,
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: <Widget>[
              Row(
                children: <Widget>[
                  Expanded(
                    child: Text(
                      title,
                      style: Theme.of(context).textTheme.titleMedium,
                    ),
                  ),
                  const Icon(Icons.chevron_right_rounded),
                ],
              ),
              const SizedBox(height: 10),
              Text(
                value,
                style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                  fontWeight: FontWeight.bold,
                  color: color,
                ),
              ),
              const SizedBox(height: 10),
              LinearProgressIndicator(
                value: clampedProgress,
                color: color,
                minHeight: 8,
                borderRadius: BorderRadius.circular(8),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
