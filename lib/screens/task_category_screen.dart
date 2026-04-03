import 'package:flutter/material.dart';

import '../core/task_ui.dart';
import '../data/mock_tasks.dart';
import '../models/task_item.dart';
import 'category_management_screen.dart';
import 'task_detail_screen.dart';

class TaskCategoryScreen extends StatefulWidget {
  const TaskCategoryScreen({super.key});

  @override
  State<TaskCategoryScreen> createState() => _TaskCategoryScreenState();
}

class _TaskCategoryScreenState extends State<TaskCategoryScreen> {
  late List<TaskItem> _tasks;
  String _search = '';

  @override
  void initState() {
    super.initState();
    _tasks = MockTasks.build();
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

  List<String> _categories() {
    final Set<String> categorySet = _tasks
        .map((TaskItem task) => task.category)
        .toSet();
    final List<String> result =
        categorySet
            .where(
              (String category) =>
                  category.toLowerCase().contains(_search.toLowerCase()),
            )
            .toList()
          ..sort();
    return result;
  }

  List<int> _categoryIndexes(String category) {
    return List<int>.generate(
      _tasks.length,
      (int index) => index,
    ).where((int index) => _tasks[index].category == category).toList();
  }

  List<int> _indexesByBucket(List<int> indexes, String bucket) {
    return indexes
        .where(
          (int index) =>
              TaskUi.timeBucketLabel(_tasks[index].dueTime) == bucket,
        )
        .toList();
  }

  Widget _taskLine(int index) {
    final TaskItem task = _tasks[index];
    return Card(
      margin: const EdgeInsets.only(bottom: 8),
      color: TaskUi.taskBackground(task),
      child: ListTile(
        onTap: () => _openTaskDetail(index),
        dense: true,
        leading: Icon(
          Icons.task_alt_rounded,
          color: TaskUi.priorityColor(task.priority),
        ),
        title: Text(
          task.title,
          style: task.isDone
              ? const TextStyle(
                  decoration: TextDecoration.lineThrough,
                  color: Colors.black45,
                )
              : null,
        ),
        subtitle: Text(
          '${TaskUi.priorityLabel(task.priority)} | ${TaskUi.formatDate(task.dueTime)}',
        ),
      ),
    );
  }

  Widget _timeSection(String label, List<int> indexes) {
    if (indexes.isEmpty) {
      return const SizedBox.shrink();
    }

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: <Widget>[
        Padding(
          padding: const EdgeInsets.only(top: 6, bottom: 6),
          child: Row(
            children: <Widget>[
              Icon(
                Icons.schedule_rounded,
                size: 16,
                color: Theme.of(context).colorScheme.primary,
              ),
              const SizedBox(width: 6),
              Text(label, style: const TextStyle(fontWeight: FontWeight.w700)),
            ],
          ),
        ),
        ...indexes.map(_taskLine),
      ],
    );
  }

  @override
  Widget build(BuildContext context) {
    final List<String> categories = _categories();

    return Column(
      children: <Widget>[
        Padding(
          padding: const EdgeInsets.fromLTRB(16, 16, 16, 10),
          child: Column(
            children: <Widget>[
              TextField(
                onChanged: (String value) {
                  setState(() {
                    _search = value;
                  });
                },
                decoration: InputDecoration(
                  hintText: 'Tim nhom cong viec...',
                  prefixIcon: const Icon(Icons.search_rounded),
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                ),
              ),
              const SizedBox(height: 10),
              SizedBox(
                width: double.infinity,
                child: OutlinedButton.icon(
                  onPressed: () {
                    Navigator.of(context).push(
                      MaterialPageRoute<void>(
                        builder: (BuildContext context) =>
                            const CategoryManagementScreen(),
                      ),
                    );
                  },
                  icon: const Icon(Icons.settings_suggest_rounded),
                  label: const Text('Quan ly nhom cong viec'),
                ),
              ),
            ],
          ),
        ),
        Expanded(
          child: ListView.builder(
            padding: const EdgeInsets.fromLTRB(16, 0, 16, 16),
            itemCount: categories.length,
            itemBuilder: (BuildContext context, int index) {
              final String category = categories[index];
              final List<int> categoryIndexes = _categoryIndexes(category);
              final List<int> today = _indexesByBucket(
                categoryIndexes,
                'Hom nay',
              );
              final List<int> tomorrow = _indexesByBucket(
                categoryIndexes,
                'Ngay mai',
              );
              final List<int> upcoming = _indexesByBucket(
                categoryIndexes,
                'Sap toi',
              );

              return Card(
                margin: const EdgeInsets.only(bottom: 10),
                child: ExpansionTile(
                  leading: const Icon(Icons.folder_copy_rounded),
                  title: Text(
                    category,
                    style: Theme.of(context).textTheme.titleMedium?.copyWith(
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                  subtitle: Text(
                    '${categoryIndexes.length} cong viec trong nhom',
                  ),
                  childrenPadding: const EdgeInsets.fromLTRB(12, 0, 12, 12),
                  children: <Widget>[
                    Wrap(
                      spacing: 8,
                      runSpacing: 8,
                      children: <Widget>[
                        Chip(label: Text('Hom nay: ${today.length}')),
                        Chip(label: Text('Ngay mai: ${tomorrow.length}')),
                        Chip(label: Text('Sap toi: ${upcoming.length}')),
                      ],
                    ),
                    _timeSection('Hom nay', today),
                    _timeSection('Ngay mai', tomorrow),
                    _timeSection('Sap toi', upcoming),
                  ],
                ),
              );
            },
          ),
        ),
      ],
    );
  }
}
