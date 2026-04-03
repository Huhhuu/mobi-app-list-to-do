import 'package:flutter/material.dart';

import '../core/task_ui.dart';
import '../models/task_item.dart';
import 'notification_settings_screen.dart';
import 'task_detail_screen.dart';
import 'task_share_screen.dart';

enum _BucketMenuAction { share, rename, delete, requestPermission }

class TaskListBucketScreen extends StatefulWidget {
  const TaskListBucketScreen({
    super.key,
    required this.title,
    required this.isShared,
    required this.canManageList,
    required this.initialTasks,
    this.onTasksChanged,
    this.onTitleChanged,
    this.onShareRequested,
    this.onDeleteRequested,
    this.onRequestPermission,
  });

  final String title;
  final bool isShared;
  final bool canManageList;
  final List<TaskItem> initialTasks;
  final ValueChanged<List<TaskItem>>? onTasksChanged;
  final ValueChanged<String>? onTitleChanged;
  final VoidCallback? onShareRequested;
  final Future<bool> Function()? onDeleteRequested;
  final VoidCallback? onRequestPermission;

  @override
  State<TaskListBucketScreen> createState() => _TaskListBucketScreenState();
}

class _TaskListBucketScreenState extends State<TaskListBucketScreen> {
  static const List<String> _categories = <String>[
    'Cong viec',
    'Hoc tap',
    'Ca nhan',
    'Gia dinh',
    'Suc khoe',
  ];
  static const List<int> _priorities = <int>[1, 2, 3];

  late List<TaskItem> _tasks;
  late String _listTitle;
  String _searchQuery = '';

  final TextEditingController _draftTitleController = TextEditingController();
  final TextEditingController _draftNoteController = TextEditingController();
  String _draftCategory = 'Cong viec';
  int _draftPriority = 2;
  DateTime _draftDueDate = DateTime.now();
  bool _draftReminderEnabled = true;

  @override
  void initState() {
    super.initState();
    _tasks = List<TaskItem>.from(widget.initialTasks);
    _listTitle = widget.title;
  }

  @override
  void dispose() {
    _draftTitleController.dispose();
    _draftNoteController.dispose();
    super.dispose();
  }

  void _emitChanges() {
    widget.onTasksChanged?.call(List<TaskItem>.from(_tasks));
  }

  Future<void> _openTaskDetail(int index) async {
    if (widget.isShared && !widget.canManageList) {
      _showTaskPreview(index);
      return;
    }

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
    _emitChanges();
  }

  Future<void> _showTaskPreview(int index) async {
    final TaskItem task = _tasks[index];
    await showDialog<void>(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text(task.title),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: <Widget>[
              Text('Loai: ${task.category}'),
              Text('Uu tien: ${TaskUi.priorityLabel(task.priority)}'),
              Text(
                'Han: ${TaskUi.formatDate(task.dueTime)} ${TaskUi.formatTime(task.dueTime)}',
              ),
              if (task.note.trim().isNotEmpty) ...<Widget>[
                const SizedBox(height: 8),
                Text('Ghi chu: ${task.note}'),
              ],
            ],
          ),
          actions: <Widget>[
            TextButton(
              onPressed: () => Navigator.of(context).pop(),
              child: const Text('Dong'),
            ),
          ],
        );
      },
    );
  }

  void _toggleTask(int index, bool value) {
    setState(() {
      _tasks[index] = _tasks[index].copyWith(isDone: value);
    });
    _emitChanges();
  }

  Future<void> _deleteTask(int index) async {
    if (widget.isShared && !widget.canManageList) {
      return;
    }

    final TaskItem task = _tasks[index];
    final bool? accepted = await showDialog<bool>(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text('Xoa cong viec'),
          content: Text('Ban co chac muon xoa "${task.title}"?'),
          actions: <Widget>[
            TextButton(
              onPressed: () => Navigator.of(context).pop(false),
              child: const Text('Huy'),
            ),
            FilledButton(
              onPressed: () => Navigator.of(context).pop(true),
              child: const Text('Xoa'),
            ),
          ],
        );
      },
    );

    if (accepted != true) {
      return;
    }

    setState(() {
      _tasks.removeAt(index);
    });
    _emitChanges();
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
      title: 'Chon loai cong viec',
      options: _categories,
      selected: _draftCategory,
      labelBuilder: (String item) => item,
    );

    if (selected == null) {
      return;
    }

    setState(() {
      _draftCategory = selected;
    });
  }

  Future<void> _pickPriority() async {
    final int? selected = await _showSingleChoicePopup<int>(
      title: 'Chon muc uu tien',
      options: _priorities,
      selected: _draftPriority,
      labelBuilder: (int item) => TaskUi.priorityLabel(item),
    );

    if (selected == null) {
      return;
    }

    setState(() {
      _draftPriority = selected;
    });
  }

  Future<void> _pickDateTime() async {
    final DateTime? selectedDate = await showDatePicker(
      context: context,
      initialDate: _draftDueDate,
      firstDate: DateTime.now().subtract(const Duration(days: 365)),
      lastDate: DateTime.now().add(const Duration(days: 3650)),
    );

    if (selectedDate == null || !mounted) {
      return;
    }

    final TimeOfDay? selectedTime = await showTimePicker(
      context: context,
      initialTime: TimeOfDay.fromDateTime(_draftDueDate),
    );

    if (selectedTime == null) {
      return;
    }

    setState(() {
      _draftDueDate = DateTime(
        selectedDate.year,
        selectedDate.month,
        selectedDate.day,
        selectedTime.hour,
        selectedTime.minute,
      );
    });
  }

  void _createTaskFromChatBox() {
    if (widget.isShared && !widget.canManageList) {
      return;
    }

    final String title = _draftTitleController.text.trim();
    if (title.isEmpty) {
      return;
    }

    setState(() {
      _tasks.add(
        TaskItem(
          title: title,
          category: _draftCategory,
          dueTime: _draftDueDate,
          isDone: false,
          priority: _draftPriority,
          isShared: widget.isShared,
          reminderEnabled: _draftReminderEnabled,
          note: _draftNoteController.text.trim(),
          subtasks: <String>[],
        ),
      );
      _draftTitleController.clear();
      _draftNoteController.clear();
    });
    _emitChanges();
  }

  void _openNotificationSettings() {
    Navigator.of(context).push(
      MaterialPageRoute<void>(
        builder: (BuildContext context) => const NotificationSettingsScreen(),
      ),
    );
  }

  List<int> _filteredIndexes() {
    final String query = _searchQuery.trim().toLowerCase();

    return List<int>.generate(_tasks.length, (int index) => index).where((
      int index,
    ) {
      final TaskItem task = _tasks[index];
      final bool matchText =
          query.isEmpty ||
          task.title.toLowerCase().contains(query) ||
          task.category.toLowerCase().contains(query);
      return matchText;
    }).toList();
  }

  List<int> _indexesByBucket(List<int> indexes, String bucket) {
    return indexes
        .where(
          (int index) =>
              TaskUi.timeBucketLabel(_tasks[index].dueTime) == bucket,
        )
        .toList();
  }

  Widget _buildTaskTile(int index) {
    final TaskItem task = _tasks[index];
    final Color priorityColor = TaskUi.priorityColor(task.priority);

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
          widget.isShared ? Icons.group_rounded : Icons.person_rounded,
          color: priorityColor,
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
          '${task.category} | ${TaskUi.priorityLabel(task.priority)} | ${TaskUi.formatDate(task.dueTime)}',
        ),
        trailing: Row(
          mainAxisSize: MainAxisSize.min,
          children: <Widget>[
            if (!widget.isShared || widget.canManageList)
              IconButton(
                tooltip: 'Xoa cong viec',
                onPressed: () => _deleteTask(index),
                icon: Icon(
                  Icons.delete_outline_rounded,
                  color: Theme.of(context).colorScheme.error,
                ),
              ),
            Checkbox(
              value: task.isDone,
              onChanged: (bool? value) => _toggleTask(index, value ?? false),
            ),
          ],
        ),
      ),
    );
  }

  Widget _section(String label, List<int> indexes) {
    if (indexes.isEmpty) {
      return const SizedBox.shrink();
    }

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: <Widget>[
        Padding(
          padding: const EdgeInsets.only(top: 6, bottom: 10),
          child: Text(
            label,
            style: Theme.of(context).textTheme.titleSmall?.copyWith(
              fontWeight: FontWeight.w700,
              color: Theme.of(context).colorScheme.primary,
            ),
          ),
        ),
        ...indexes.map(_buildTaskTile),
      ],
    );
  }

  void _openShareScreen() {
    if (widget.onShareRequested != null) {
      widget.onShareRequested!.call();
      return;
    }

    Navigator.of(context).push(
      MaterialPageRoute<void>(
        builder: (BuildContext context) => const TaskShareScreen(),
      ),
    );
  }

  Future<void> _deleteListFromMenu() async {
    final Future<bool> Function()? onDeleteRequested = widget.onDeleteRequested;
    if (onDeleteRequested == null) {
      return;
    }

    final bool deleted = await onDeleteRequested();
    if (!deleted || !mounted) {
      return;
    }
    Navigator.of(context).pop();
  }

  void _onMenuAction(_BucketMenuAction action) {
    if (action == _BucketMenuAction.share) {
      _openShareScreen();
      return;
    }
    if (action == _BucketMenuAction.rename) {
      _renameList();
      return;
    }
    if (action == _BucketMenuAction.delete) {
      _deleteListFromMenu();
      return;
    }
    widget.onRequestPermission?.call();
  }

  Future<void> _renameList() async {
    final TextEditingController controller = TextEditingController(
      text: _listTitle,
    );

    await showDialog<void>(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text('Doi ten danh sach con'),
          content: TextField(
            controller: controller,
            decoration: const InputDecoration(
              labelText: 'Ten danh sach',
              border: OutlineInputBorder(),
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
                if (value.isEmpty) {
                  return;
                }
                setState(() {
                  _listTitle = value;
                });
                widget.onTitleChanged?.call(value);
                Navigator.of(context).pop();
              },
              child: const Text('Luu'),
            ),
          ],
        );
      },
    );

    controller.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final List<int> indexes = _filteredIndexes();
    final List<int> today = _indexesByBucket(indexes, 'Hom nay');
    final List<int> tomorrow = _indexesByBucket(indexes, 'Ngay mai');
    final List<int> upcoming = _indexesByBucket(indexes, 'Sap toi');

    return Scaffold(
      appBar: AppBar(
        title: Text(_listTitle),
        actions: <Widget>[
          PopupMenuButton<_BucketMenuAction>(
            tooltip: 'Tuy chon danh sach',
            icon: const Icon(Icons.more_vert_rounded),
            onSelected: _onMenuAction,
            itemBuilder: (BuildContext context) {
              if (!widget.isShared || widget.canManageList) {
                return <PopupMenuEntry<_BucketMenuAction>>[
                  const PopupMenuItem<_BucketMenuAction>(
                    value: _BucketMenuAction.share,
                    child: Text('Chia se'),
                  ),
                  const PopupMenuItem<_BucketMenuAction>(
                    value: _BucketMenuAction.rename,
                    child: Text('Doi ten'),
                  ),
                  const PopupMenuItem<_BucketMenuAction>(
                    value: _BucketMenuAction.delete,
                    child: Text('Xoa danh sach'),
                  ),
                ];
              }

              return <PopupMenuEntry<_BucketMenuAction>>[
                const PopupMenuItem<_BucketMenuAction>(
                  value: _BucketMenuAction.requestPermission,
                  child: Text('Yeu cau cap quyen'),
                ),
              ];
            },
          ),
        ],
      ),
      body: ListView(
        padding: const EdgeInsets.fromLTRB(16, 16, 16, 180),
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
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(12),
              ),
            ),
          ),
          const SizedBox(height: 12),
          if (indexes.isEmpty)
            Card(
              child: Padding(
                padding: const EdgeInsets.all(16),
                child: Text(
                  widget.isShared && !widget.canManageList
                      ? 'Danh sach con dang trong.'
                      : 'Danh sach con dang trong. Nhap o khung chat ben duoi de tao cong viec.',
                ),
              ),
            ),
          _section('Hom nay', today),
          _section('Ngay mai', tomorrow),
          _section('Sap toi', upcoming),
        ],
      ),
      bottomNavigationBar: widget.isShared && !widget.canManageList
          ? null
          : SafeArea(
              top: false,
              child: Container(
                padding: const EdgeInsets.fromLTRB(12, 8, 12, 12),
                decoration: BoxDecoration(
                  color: Theme.of(context).colorScheme.surface,
                  border: Border(
                    top: BorderSide(
                      color: Theme.of(
                        context,
                      ).dividerColor.withValues(alpha: 0.35),
                    ),
                  ),
                ),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: <Widget>[
                    Wrap(
                      spacing: 8,
                      runSpacing: 8,
                      children: <Widget>[
                        ActionChip(
                          avatar: const Icon(Icons.category_outlined, size: 18),
                          label: Text(_draftCategory),
                          onPressed: _pickCategory,
                        ),
                        ActionChip(
                          avatar: const Icon(Icons.flag_outlined, size: 18),
                          label: Text(TaskUi.priorityLabel(_draftPriority)),
                          onPressed: _pickPriority,
                        ),
                        ActionChip(
                          avatar: const Icon(Icons.event_rounded, size: 18),
                          label: Text(
                            '${TaskUi.formatDate(_draftDueDate)} ${TaskUi.formatTime(_draftDueDate)}',
                          ),
                          onPressed: _pickDateTime,
                        ),
                        FilterChip(
                          label: const Text('Nhac nho'),
                          selected: _draftReminderEnabled,
                          onSelected: (bool value) {
                            setState(() {
                              _draftReminderEnabled = value;
                            });
                          },
                        ),
                        ActionChip(
                          avatar: const Icon(
                            Icons.notifications_active_rounded,
                            size: 18,
                          ),
                          label: const Text('Cai dat thong bao'),
                          onPressed: _openNotificationSettings,
                        ),
                      ],
                    ),
                    const SizedBox(height: 8),
                    TextField(
                      controller: _draftTitleController,
                      decoration: InputDecoration(
                        hintText: 'Nhap cong viec moi...',
                        prefixIcon: const Icon(
                          Icons.chat_bubble_outline_rounded,
                        ),
                        suffixIcon: IconButton(
                          onPressed: _createTaskFromChatBox,
                          icon: const Icon(Icons.send_rounded),
                          tooltip: 'Tao cong viec',
                        ),
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(14),
                        ),
                      ),
                    ),
                    const SizedBox(height: 8),
                    TextField(
                      controller: _draftNoteController,
                      minLines: 1,
                      maxLines: 2,
                      decoration: InputDecoration(
                        hintText: 'Ghi chu (note) cho cong viec...',
                        prefixIcon: const Icon(Icons.notes_rounded),
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(14),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
    );
  }
}
