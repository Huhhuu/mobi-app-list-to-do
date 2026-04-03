import 'package:flutter/material.dart';

import '../core/task_ui.dart';
import '../models/task_item.dart';

class TaskDetailScreen extends StatefulWidget {
  const TaskDetailScreen({super.key, required this.task});

  final TaskItem task;

  @override
  State<TaskDetailScreen> createState() => _TaskDetailScreenState();
}

class _TaskDetailScreenState extends State<TaskDetailScreen> {
  static const List<String> _categories = <String>[
    'Cong viec',
    'Ca nhan',
    'Hoc tap',
    'Suc khoe',
    'Gia dinh',
  ];

  static const List<int> _priorities = <int>[1, 2, 3];

  late TaskItem _task;
  late TextEditingController _noteController;

  @override
  void initState() {
    super.initState();
    _task = widget.task;
    _noteController = TextEditingController(text: _task.note);
  }

  @override
  void dispose() {
    _noteController.dispose();
    super.dispose();
  }

  void _updateTask(TaskItem nextTask) {
    setState(() {
      _task = nextTask;
    });
  }

  Future<void> _pickDueDateTime() async {
    final DateTime? selectedDate = await showDatePicker(
      context: context,
      initialDate: _task.dueTime,
      firstDate: DateTime.now().subtract(const Duration(days: 365)),
      lastDate: DateTime.now().add(const Duration(days: 3650)),
    );

    if (selectedDate == null || !mounted) {
      return;
    }

    final TimeOfDay? selectedTime = await showTimePicker(
      context: context,
      initialTime: TimeOfDay.fromDateTime(_task.dueTime),
    );

    if (selectedTime == null) {
      return;
    }

    final DateTime nextDueTime = DateTime(
      selectedDate.year,
      selectedDate.month,
      selectedDate.day,
      selectedTime.hour,
      selectedTime.minute,
    );

    _updateTask(_task.copyWith(dueTime: nextDueTime));
  }

  Future<T?> _showSingleChoicePopup<T>({
    required String title,
    required List<T> options,
    required T selected,
    required String Function(T value) labelBuilder,
  }) {
    return showModalBottomSheet<T>(
      context: context,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(22)),
      ),
      builder: (BuildContext context) {
        return SafeArea(
          child: Padding(
            padding: const EdgeInsets.fromLTRB(16, 12, 16, 16),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: <Widget>[
                Text(
                  title,
                  style: Theme.of(context).textTheme.titleMedium?.copyWith(
                    fontWeight: FontWeight.w700,
                  ),
                ),
                const SizedBox(height: 8),
                ...options.map((T option) {
                  final bool isSelected = option == selected;
                  return ListTile(
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                    onTap: () => Navigator.of(context).pop(option),
                    title: Text(labelBuilder(option)),
                    trailing: isSelected
                        ? Icon(
                            Icons.check_circle_rounded,
                            color: Theme.of(context).colorScheme.primary,
                          )
                        : const Icon(Icons.circle_outlined),
                  );
                }),
              ],
            ),
          ),
        );
      },
    );
  }

  Future<void> _pickCategory() async {
    final String? selected = await _showSingleChoicePopup<String>(
      title: 'Chon nhom cong viec',
      options: _categories,
      selected: _task.category,
      labelBuilder: (String item) => item,
    );

    if (selected == null) {
      return;
    }

    _updateTask(_task.copyWith(category: selected));
  }

  Future<void> _pickPriority() async {
    final int? selected = await _showSingleChoicePopup<int>(
      title: 'Chon muc uu tien',
      options: _priorities,
      selected: _task.priority,
      labelBuilder: (int item) => TaskUi.priorityLabel(item),
    );

    if (selected == null) {
      return;
    }

    _updateTask(_task.copyWith(priority: selected));
  }

  void _addSubtask() {
    final TextEditingController controller = TextEditingController();
    showDialog<void>(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text('Them muc nho'),
          content: TextField(
            controller: controller,
            decoration: const InputDecoration(
              hintText: 'Nhap noi dung muc nho',
            ),
          ),
          actions: <Widget>[
            TextButton(
              onPressed: () => Navigator.of(context).pop(),
              child: const Text('Huy'),
            ),
            ElevatedButton(
              onPressed: () {
                final String value = controller.text.trim();
                if (value.isNotEmpty) {
                  _updateTask(
                    _task.copyWith(
                      subtasks: <String>[..._task.subtasks, value],
                    ),
                  );
                }
                Navigator.of(context).pop();
              },
              child: const Text('Them'),
            ),
          ],
        );
      },
    );
  }

  void _removeSubtask(int index) {
    final List<String> next = List<String>.from(_task.subtasks)
      ..removeAt(index);
    _updateTask(_task.copyWith(subtasks: next));
  }

  void _saveChanges() {
    final TaskItem updated = _task.copyWith(note: _noteController.text.trim());
    Navigator.of(context).pop(updated);
  }

  @override
  Widget build(BuildContext context) {
    final Color priorityColor = TaskUi.priorityColor(_task.priority);

    return Scaffold(
      appBar: AppBar(
        title: const Text('Chi tiet cong viec'),
        actions: <Widget>[
          IconButton(
            onPressed: _saveChanges,
            icon: const Icon(Icons.check_rounded),
            tooltip: 'Luu thay doi',
          ),
        ],
      ),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: <Widget>[
          Card(
            color: TaskUi.taskBackground(_task),
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: <Widget>[
                  Text(
                    _task.title,
                    style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 10),
                  OutlinedButton.icon(
                    onPressed: _pickDueDateTime,
                    icon: const Icon(Icons.schedule_rounded),
                    label: Text(
                      'Han: ${TaskUi.formatDate(_task.dueTime)} ${TaskUi.formatTime(_task.dueTime)}',
                    ),
                  ),
                  const SizedBox(height: 6),
                  Row(
                    children: <Widget>[
                      Switch(
                        value: _task.isDone,
                        onChanged: (bool value) {
                          _updateTask(_task.copyWith(isDone: value));
                        },
                      ),
                      const SizedBox(width: 6),
                      const Text('Danh dau hoan thanh'),
                    ],
                  ),
                  Row(
                    children: <Widget>[
                      Switch(
                        value: _task.reminderEnabled,
                        onChanged: (bool value) {
                          _updateTask(_task.copyWith(reminderEnabled: value));
                        },
                      ),
                      const SizedBox(width: 6),
                      const Text('Bat/Tat nhac nho'),
                    ],
                  ),
                  const SizedBox(height: 8),
                  ListTile(
                    contentPadding: EdgeInsets.zero,
                    onTap: _pickCategory,
                    title: const Text('Chinh sua nhom cong viec'),
                    subtitle: Text(_task.category),
                    trailing: const Icon(Icons.arrow_drop_down_circle_rounded),
                  ),
                  ListTile(
                    contentPadding: EdgeInsets.zero,
                    onTap: _pickPriority,
                    title: const Text('Chinh sua uu tien'),
                    subtitle: Text(TaskUi.priorityLabel(_task.priority)),
                    trailing: const Icon(Icons.arrow_drop_down_circle_rounded),
                  ),
                  const SizedBox(height: 8),
                  Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 12,
                      vertical: 8,
                    ),
                    decoration: BoxDecoration(
                      color: priorityColor.withValues(alpha: 0.12),
                      borderRadius: BorderRadius.circular(10),
                    ),
                    child: Text(
                      'Uu tien hien tai: ${TaskUi.priorityLabel(_task.priority)}',
                      style: TextStyle(
                        color: priorityColor,
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                  ),
                  const SizedBox(height: 10),
                  TextField(
                    controller: _noteController,
                    maxLines: 3,
                    decoration: const InputDecoration(
                      labelText: 'Chinh sua ghi chu (note)',
                      border: OutlineInputBorder(),
                    ),
                  ),
                  const SizedBox(height: 10),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: <Widget>[
                      Text(
                        'Cac muc nho trong task',
                        style: Theme.of(context).textTheme.titleSmall?.copyWith(
                          fontWeight: FontWeight.w700,
                        ),
                      ),
                      TextButton.icon(
                        onPressed: _addSubtask,
                        icon: const Icon(Icons.add_rounded),
                        label: const Text('Them muc'),
                      ),
                    ],
                  ),
                  if (_task.subtasks.isEmpty)
                    const Padding(
                      padding: EdgeInsets.only(top: 4),
                      child: Text('Chua co muc nho nao.'),
                    ),
                  ...List<Widget>.generate(_task.subtasks.length, (int index) {
                    return ListTile(
                      contentPadding: EdgeInsets.zero,
                      leading: const Icon(
                        Icons.subdirectory_arrow_right_rounded,
                      ),
                      title: Text(_task.subtasks[index]),
                      trailing: IconButton(
                        onPressed: () => _removeSubtask(index),
                        icon: const Icon(Icons.close_rounded),
                      ),
                    );
                  }),
                  Text('Danh sach: ${_task.isShared ? 'Chia se' : 'Ca nhan'}'),
                ],
              ),
            ),
          ),
          const SizedBox(height: 10),
          ElevatedButton.icon(
            onPressed: _saveChanges,
            icon: const Icon(Icons.save_rounded),
            label: const Text('Luu thong tin task'),
          ),
        ],
      ),
    );
  }
}
