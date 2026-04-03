import 'package:flutter/material.dart';

import '../core/task_ui.dart';
import '../models/task_item.dart';
import 'task_detail_screen.dart';

class StatisticsTaskSourceScreen extends StatefulWidget {
  const StatisticsTaskSourceScreen({
    super.key,
    required this.title,
    required this.tasks,
  });

  final String title;
  final List<TaskItem> tasks;

  @override
  State<StatisticsTaskSourceScreen> createState() =>
      _StatisticsTaskSourceScreenState();
}

class _StatisticsTaskSourceScreenState
    extends State<StatisticsTaskSourceScreen> {
  late List<TaskItem> _tasks;

  @override
  void initState() {
    super.initState();
    _tasks = List<TaskItem>.from(widget.tasks);
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

  String _sourceLabel(TaskItem task) {
    return task.isShared
        ? 'Nguon: Danh sach chia se'
        : 'Nguon: Danh sach cua toi';
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text(widget.title)),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: <Widget>[
          if (_tasks.isEmpty)
            const Card(
              child: Padding(
                padding: EdgeInsets.all(16),
                child: Text('Khong co cong viec phu hop trong thong ke nay.'),
              ),
            ),
          ...List<Widget>.generate(_tasks.length, (int index) {
            final TaskItem task = _tasks[index];
            final Color priorityColor = TaskUi.priorityColor(task.priority);

            return Card(
              margin: const EdgeInsets.only(bottom: 10),
              color: TaskUi.taskBackground(task),
              child: ListTile(
                onTap: () => _openTaskDetail(index),
                leading: Icon(Icons.source_rounded, color: priorityColor),
                title: Text(task.title),
                subtitle: Text(
                  '${_sourceLabel(task)}\nNhom: ${task.category} | Uu tien: ${TaskUi.priorityLabel(task.priority)} | Han: ${TaskUi.formatDate(task.dueTime)}',
                ),
                isThreeLine: true,
              ),
            );
          }),
        ],
      ),
    );
  }
}
