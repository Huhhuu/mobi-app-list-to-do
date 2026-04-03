import 'package:flutter/material.dart';

import '../core/task_ui.dart';
import '../data/mock_tasks.dart';
import '../models/task_item.dart';
import 'task_detail_screen.dart';

class TaskReminderScreen extends StatefulWidget {
  const TaskReminderScreen({super.key});

  @override
  State<TaskReminderScreen> createState() => _TaskReminderScreenState();
}

class _TaskReminderScreenState extends State<TaskReminderScreen> {
  late List<TaskItem> _tasks;
  late DateTime _currentMonth;
  DateTime? _selectedDate;

  @override
  void initState() {
    super.initState();
    _tasks = MockTasks.build();
    final DateTime now = DateTime.now();
    _currentMonth = DateTime(now.year, now.month);
    _selectedDate = DateTime(now.year, now.month, now.day);
  }

  bool _isSameDate(DateTime a, DateTime b) {
    return a.year == b.year && a.month == b.month && a.day == b.day;
  }

  List<TaskItem> _tasksOnDate(DateTime date) {
    return _tasks
        .where((TaskItem task) => _isSameDate(task.dueTime, date))
        .toList();
  }

  List<int> _prioritiesForDate(DateTime date) {
    final Set<int> priorities = _tasksOnDate(
      date,
    ).map((TaskItem task) => task.priority).toSet();
    final List<int> sorted = priorities.toList()
      ..sort((int a, int b) => b.compareTo(a));
    return sorted;
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

  Widget _buildCalendarHeader() {
    const List<String> weekDays = <String>[
      'T2',
      'T3',
      'T4',
      'T5',
      'T6',
      'T7',
      'CN',
    ];
    return Row(
      children: weekDays
          .map(
            (String day) => Expanded(
              child: Padding(
                padding: const EdgeInsets.symmetric(vertical: 4),
                child: Text(
                  day,
                  textAlign: TextAlign.center,
                  style: const TextStyle(fontWeight: FontWeight.w700),
                ),
              ),
            ),
          )
          .toList(),
    );
  }

  Widget _buildDayCell(DateTime date) {
    final bool isInCurrentMonth = date.month == _currentMonth.month;
    final bool isSelected =
        _selectedDate != null && _isSameDate(date, _selectedDate!);
    final List<int> markers = _prioritiesForDate(date);

    return InkWell(
      onTap: () {
        setState(() {
          _selectedDate = date;
        });
      },
      borderRadius: BorderRadius.circular(10),
      child: Container(
        margin: const EdgeInsets.all(2),
        decoration: BoxDecoration(
          color: isSelected
              ? Theme.of(context).colorScheme.primary.withValues(alpha: 0.12)
              : null,
          borderRadius: BorderRadius.circular(10),
          border: isSelected
              ? Border.all(color: Theme.of(context).colorScheme.primary)
              : null,
        ),
        padding: const EdgeInsets.symmetric(vertical: 6),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: <Widget>[
            Text(
              '${date.day}',
              style: TextStyle(
                color: isInCurrentMonth ? Colors.black87 : Colors.black38,
                fontWeight: FontWeight.w600,
              ),
            ),
            const SizedBox(height: 3),
            Wrap(
              spacing: 3,
              children: markers
                  .take(3)
                  .map(
                    (int priority) => Container(
                      width: 6,
                      height: 6,
                      decoration: BoxDecoration(
                        color: TaskUi.priorityColor(priority),
                        shape: BoxShape.circle,
                      ),
                    ),
                  )
                  .toList(),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildMonthGrid() {
    final DateTime firstDay = DateTime(
      _currentMonth.year,
      _currentMonth.month,
      1,
    );
    final int startWeekday = (firstDay.weekday + 6) % 7;
    final DateTime startDate = firstDay.subtract(Duration(days: startWeekday));
    final List<DateTime> days = List<DateTime>.generate(
      42,
      (int index) => startDate.add(Duration(days: index)),
    );

    return Column(
      children: List<Widget>.generate(6, (int row) {
        final List<DateTime> week = days.skip(row * 7).take(7).toList();
        return Row(
          children: week
              .map((DateTime date) => Expanded(child: _buildDayCell(date)))
              .toList(),
        );
      }),
    );
  }

  @override
  Widget build(BuildContext context) {
    final DateTime selected = _selectedDate ?? DateTime.now();
    final List<int> selectedIndexes =
        List<int>.generate(_tasks.length, (int index) => index)
            .where((int index) => _isSameDate(_tasks[index].dueTime, selected))
            .toList();

    return ListView(
      padding: const EdgeInsets.all(16),
      children: <Widget>[
        Card(
          child: Padding(
            padding: const EdgeInsets.all(12),
            child: Column(
              children: <Widget>[
                Row(
                  children: <Widget>[
                    IconButton(
                      onPressed: () {
                        setState(() {
                          _currentMonth = DateTime(
                            _currentMonth.year,
                            _currentMonth.month - 1,
                          );
                        });
                      },
                      icon: const Icon(Icons.chevron_left_rounded),
                    ),
                    Expanded(
                      child: Text(
                        'Thang ${_currentMonth.month}/${_currentMonth.year}',
                        textAlign: TextAlign.center,
                        style: Theme.of(context).textTheme.titleMedium
                            ?.copyWith(fontWeight: FontWeight.w700),
                      ),
                    ),
                    IconButton(
                      onPressed: () {
                        setState(() {
                          _currentMonth = DateTime(
                            _currentMonth.year,
                            _currentMonth.month + 1,
                          );
                        });
                      },
                      icon: const Icon(Icons.chevron_right_rounded),
                    ),
                  ],
                ),
                _buildCalendarHeader(),
                _buildMonthGrid(),
              ],
            ),
          ),
        ),
        const SizedBox(height: 12),
        Text(
          'Cong viec ngay ${TaskUi.formatDate(selected)}',
          style: Theme.of(
            context,
          ).textTheme.titleSmall?.copyWith(fontWeight: FontWeight.w700),
        ),
        const SizedBox(height: 8),
        if (selectedIndexes.isEmpty)
          const Card(
            child: Padding(
              padding: EdgeInsets.all(16),
              child: Text('Khong co cong viec trong ngay duoc chon.'),
            ),
          ),
        ...selectedIndexes.map((int index) {
          final TaskItem task = _tasks[index];
          return Card(
            margin: const EdgeInsets.only(bottom: 10),
            color: TaskUi.taskBackground(task),
            child: ListTile(
              onTap: () => _openTaskDetail(index),
              leading: Icon(
                Icons.event_note_rounded,
                color: TaskUi.priorityColor(task.priority),
              ),
              title: Text(task.title),
              subtitle: Text(
                '${TaskUi.formatTime(task.dueTime)} | ${task.category} | ${TaskUi.priorityLabel(task.priority)}',
              ),
              trailing: Icon(
                task.reminderEnabled
                    ? Icons.notifications_active_rounded
                    : Icons.notifications_off_rounded,
              ),
            ),
          );
        }),
      ],
    );
  }
}
