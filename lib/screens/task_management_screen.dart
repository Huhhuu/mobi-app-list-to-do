import 'package:flutter/material.dart';

import '../core/task_ui.dart';
import '../data/mock_tasks.dart';
import '../models/task_item.dart';
import 'task_detail_screen.dart';

class TaskManagementScreen extends StatefulWidget {
  const TaskManagementScreen({super.key});

  @override
  State<TaskManagementScreen> createState() => _TaskManagementScreenState();
}

class _TaskManagementScreenState extends State<TaskManagementScreen> {
  late List<TaskItem> _tasks;
  String _searchQuery = '';

  @override
  void initState() {
    super.initState();
    _tasks = MockTasks.build();
  }

  void _toggleTask(int index, bool value) {
    setState(() {
      _tasks[index] = _tasks[index].copyWith(isDone: value);
    });
  }

  Future<void> _openTaskDetail(int index) async {
    final TaskItem? updatedTask = await Navigator.of(context).push<TaskItem>(
      MaterialPageRoute<TaskItem>(
        builder: (BuildContext context) =>
            TaskDetailScreen(task: _tasks[index]),
      ),
    );

    if (updatedTask == null) {
      return;
    }

    setState(() {
      _tasks[index] = updatedTask;
    });
  }

  List<int> _filteredIndexes() {
    final String normalizedQuery = _searchQuery.trim().toLowerCase();
    final DateTime now = DateTime.now();
    final DateTime today = DateTime(now.year, now.month, now.day);

    return List<int>.generate(_tasks.length, (int index) => index).where((
      int index,
    ) {
      final TaskItem task = _tasks[index];
      final bool matchScope = !task.isShared;
      final DateTime taskDate = DateTime(
        task.dueTime.year,
        task.dueTime.month,
        task.dueTime.day,
      );
      final bool matchToday = taskDate == today;
      final bool matchText =
          normalizedQuery.isEmpty ||
          task.title.toLowerCase().contains(normalizedQuery) ||
          task.category.toLowerCase().contains(normalizedQuery);
      return matchScope && matchToday && matchText;
    }).toList();
  }

  Widget _buildTaskTile(int index) {
    final TaskItem task = _tasks[index];
    final Color priorityColor = TaskUi.priorityColor(task.priority);
    final TextStyle? baseTitle = Theme.of(context).textTheme.titleMedium;
    final TextStyle? baseSubtitle = Theme.of(context).textTheme.bodyMedium;
    final TextStyle? doneTitleStyle = baseTitle?.copyWith(
      decoration: TextDecoration.lineThrough,
      color: Colors.black45,
    );
    final TextStyle? doneSubtitleStyle = baseSubtitle?.copyWith(
      decoration: TextDecoration.lineThrough,
      color: Colors.black38,
    );

    return Card(
      margin: const EdgeInsets.only(bottom: 10),
      color: TaskUi.taskBackground(task),
      shape: RoundedRectangleBorder(
        side: BorderSide(
          color: priorityColor.withValues(alpha: 0.7),
          width: 1.2,
        ),
        borderRadius: BorderRadius.circular(16),
      ),
      child: ListTile(
        onTap: () => _openTaskDetail(index),
        leading: Icon(
          task.isShared ? Icons.group_rounded : Icons.person_rounded,
          color: priorityColor,
        ),
        title: Text(
          task.title,
          style: task.isDone ? doneTitleStyle : baseTitle,
        ),
        subtitle: Text.rich(
          TextSpan(
            children: <InlineSpan>[
              TextSpan(
                text: 'Nhom: ${task.category} | ',
                style: task.isDone ? doneSubtitleStyle : baseSubtitle,
              ),
              TextSpan(
                text: 'Uu tien: ${TaskUi.priorityLabel(task.priority)}',
                style: (task.isDone ? doneSubtitleStyle : baseSubtitle)
                    ?.copyWith(
                      color: task.isDone ? Colors.black38 : priorityColor,
                      fontWeight: FontWeight.w700,
                    ),
              ),
              TextSpan(
                text: ' | ${TaskUi.formatDate(task.dueTime)}',
                style: task.isDone ? doneSubtitleStyle : baseSubtitle,
              ),
            ],
          ),
        ),
        trailing: Checkbox(
          value: task.isDone,
          onChanged: (bool? checked) => _toggleTask(index, checked ?? false),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final List<int> filteredIndexes = _filteredIndexes();

    return ListView(
      padding: const EdgeInsets.all(16),
      children: <Widget>[
        TextField(
          onChanged: (String value) {
            setState(() {
              _searchQuery = value;
            });
          },
          decoration: InputDecoration(
            hintText: 'Tim cong viec...',
            prefixIcon: const Icon(Icons.search_rounded),
            border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
          ),
        ),
        const SizedBox(height: 12),
        const Text(
          'Ngay cua toi',
          style: TextStyle(fontWeight: FontWeight.w700),
        ),
        const SizedBox(height: 4),
        Text(
          'Chi hien thi cong viec ca nhan trong hom nay.',
          style: Theme.of(context).textTheme.bodySmall,
        ),
        const SizedBox(height: 10),
        if (filteredIndexes.isEmpty)
          const Card(
            child: Padding(
              padding: EdgeInsets.all(16),
              child: Text('Hom nay ban chua co cong viec ca nhan nao.'),
            ),
          ),
        ...filteredIndexes.map(_buildTaskTile),
      ],
    );
  }
}
