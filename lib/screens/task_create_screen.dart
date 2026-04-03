import 'package:flutter/material.dart';

import '../core/task_ui.dart';
import 'notification_settings_screen.dart';

class TaskCreateScreen extends StatefulWidget {
  const TaskCreateScreen({super.key});

  @override
  State<TaskCreateScreen> createState() => _TaskCreateScreenState();
}

class _TaskCreateScreenState extends State<TaskCreateScreen> {
  static const List<String> _categories = <String>[
    'Cong viec',
    'Hoc tap',
    'Ca nhan',
    'Gia dinh',
    'Suc khoe',
  ];

  static const List<int> _priorities = <int>[1, 2, 3];

  final GlobalKey<FormState> _formKey = GlobalKey<FormState>();
  final TextEditingController _titleController = TextEditingController();
  final TextEditingController _noteController = TextEditingController();

  String _category = 'Cong viec';
  int _priority = 2;
  DateTime _dueDate = DateTime.now().add(const Duration(days: 1));
  bool _reminderEnabled = true;

  @override
  void dispose() {
    _titleController.dispose();
    _noteController.dispose();
    super.dispose();
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
      selected: _category,
      labelBuilder: (String item) => item,
    );

    if (selected == null) {
      return;
    }

    setState(() {
      _category = selected;
    });
  }

  Future<void> _pickPriority() async {
    final int? selected = await _showSingleChoicePopup<int>(
      title: 'Chon muc uu tien',
      options: _priorities,
      selected: _priority,
      labelBuilder: (int item) => TaskUi.priorityLabel(item),
    );

    if (selected == null) {
      return;
    }

    setState(() {
      _priority = selected;
    });
  }

  Future<void> _pickDateTime() async {
    final DateTime? selectedDate = await showDatePicker(
      context: context,
      initialDate: _dueDate,
      firstDate: DateTime.now().subtract(const Duration(days: 365)),
      lastDate: DateTime.now().add(const Duration(days: 3650)),
    );

    if (selectedDate == null || !mounted) {
      return;
    }

    final TimeOfDay? selectedTime = await showTimePicker(
      context: context,
      initialTime: TimeOfDay.fromDateTime(_dueDate),
    );

    if (selectedTime == null) {
      return;
    }

    setState(() {
      _dueDate = DateTime(
        selectedDate.year,
        selectedDate.month,
        selectedDate.day,
        selectedTime.hour,
        selectedTime.minute,
      );
    });
  }

  void _openNotificationSettings() {
    Navigator.of(context).push(
      MaterialPageRoute<void>(
        builder: (BuildContext context) => const NotificationSettingsScreen(),
      ),
    );
  }

  void _saveTask() {
    if (!_formKey.currentState!.validate()) {
      return;
    }

    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('Da tao cong viec moi (mock UI).')),
    );
    Navigator.of(context).pop();
  }

  @override
  Widget build(BuildContext context) {
    final Color priorityColor = TaskUi.priorityColor(_priority);

    return Scaffold(
      appBar: AppBar(title: const Text('Them cong viec')),
      body: Form(
        key: _formKey,
        child: ListView(
          padding: const EdgeInsets.all(16),
          children: <Widget>[
            TextFormField(
              controller: _titleController,
              decoration: const InputDecoration(
                labelText: 'Tieu de cong viec',
                border: OutlineInputBorder(),
              ),
              validator: (String? value) {
                if (value == null || value.trim().isEmpty) {
                  return 'Vui long nhap tieu de';
                }
                return null;
              },
            ),
            const SizedBox(height: 12),
            TextFormField(
              controller: _noteController,
              maxLines: 3,
              decoration: const InputDecoration(
                labelText: 'Ghi chu',
                border: OutlineInputBorder(),
              ),
            ),
            const SizedBox(height: 12),
            ListTile(
              contentPadding: EdgeInsets.zero,
              onTap: _pickCategory,
              title: const Text('Loai cong viec'),
              subtitle: Text(_category),
              trailing: const Icon(Icons.arrow_drop_down_circle_rounded),
            ),
            ListTile(
              contentPadding: EdgeInsets.zero,
              onTap: _pickPriority,
              title: const Text('Muc uu tien'),
              subtitle: Text(TaskUi.priorityLabel(_priority)),
              trailing: const Icon(Icons.arrow_drop_down_circle_rounded),
            ),
            const SizedBox(height: 4),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
              decoration: BoxDecoration(
                color: priorityColor.withValues(alpha: 0.12),
                borderRadius: BorderRadius.circular(10),
              ),
              child: Text(
                'Uu tien dang chon: ${TaskUi.priorityLabel(_priority)}',
                style: TextStyle(
                  color: priorityColor,
                  fontWeight: FontWeight.w700,
                ),
              ),
            ),
            const SizedBox(height: 12),
            OutlinedButton.icon(
              onPressed: _pickDateTime,
              icon: const Icon(Icons.event_rounded),
              label: Text(
                'Han hoan thanh: ${TaskUi.formatDate(_dueDate)} ${TaskUi.formatTime(_dueDate)}',
              ),
            ),
            const SizedBox(height: 8),
            SwitchListTile(
              contentPadding: EdgeInsets.zero,
              value: _reminderEnabled,
              onChanged: (bool value) {
                setState(() {
                  _reminderEnabled = value;
                });
              },
              title: const Text('Bat nhac nho cho cong viec nay'),
            ),
            OutlinedButton.icon(
              onPressed: _openNotificationSettings,
              icon: const Icon(Icons.notifications_active_rounded),
              label: const Text('Cai dat thong bao'),
            ),
            const SizedBox(height: 20),
            ElevatedButton(
              onPressed: _saveTask,
              child: const Text('Luu cong viec'),
            ),
          ],
        ),
      ),
    );
  }
}
