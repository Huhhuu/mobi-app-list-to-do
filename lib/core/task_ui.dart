import 'package:flutter/material.dart';

import '../models/task_item.dart';

class TaskUi {
  TaskUi._();

  static String priorityLabel(int priority) {
    switch (priority) {
      case 3:
        return 'Cao';
      case 2:
        return 'Trung binh';
      default:
        return 'Thap';
    }
  }

  static Color priorityColor(int priority) {
    switch (priority) {
      case 3:
        return const Color(0xFFD62828);
      case 2:
        return const Color(0xFFF77F00);
      default:
        return const Color(0xFF2A9D8F);
    }
  }

  static String timeBucketLabel(DateTime dueTime) {
    final DateTime now = DateTime.now();
    final DateTime today = DateTime(now.year, now.month, now.day);
    final DateTime tomorrow = today.add(const Duration(days: 1));
    final DateTime taskDate = DateTime(
      dueTime.year,
      dueTime.month,
      dueTime.day,
    );

    if (taskDate == today) {
      return 'Hom nay';
    }
    if (taskDate == tomorrow) {
      return 'Ngay mai';
    }
    return 'Sap toi';
  }

  static String formatDate(DateTime dueTime) {
    return '${dueTime.day}/${dueTime.month}/${dueTime.year}';
  }

  static String formatTime(DateTime dueTime) {
    final String hour = dueTime.hour.toString().padLeft(2, '0');
    final String minute = dueTime.minute.toString().padLeft(2, '0');
    return '$hour:$minute';
  }

  static Color taskBackground(TaskItem task) {
    final Color base = priorityColor(task.priority);
    final double opacity = task.isDone ? 0.08 : 0.16;
    return base.withValues(alpha: opacity);
  }
}
