class TaskItem {
  TaskItem({
    this.id,
    required this.title,
    required this.category,
    required this.dueTime,
    required this.isDone,
    required this.priority,
    required this.isShared,
    required this.reminderEnabled,
    required this.note,
    required this.subtasks,
  });

  final int? id;
  final String title;
  final String category;
  final DateTime dueTime;
  final bool isDone;
  final int priority;
  final bool isShared;
  final bool reminderEnabled;
  final String note;
  final List<String> subtasks;

  TaskItem copyWith({
    int? id,
    String? title,
    String? category,
    DateTime? dueTime,
    bool? isDone,
    int? priority,
    bool? isShared,
    bool? reminderEnabled,
    String? note,
    List<String>? subtasks,
  }) {
    return TaskItem(
      id: id ?? this.id,
      title: title ?? this.title,
      category: category ?? this.category,
      dueTime: dueTime ?? this.dueTime,
      isDone: isDone ?? this.isDone,
      priority: priority ?? this.priority,
      isShared: isShared ?? this.isShared,
      reminderEnabled: reminderEnabled ?? this.reminderEnabled,
      note: note ?? this.note,
      subtasks: subtasks ?? this.subtasks,
    );
  }

  Map<String, dynamic> toMap() {
    return <String, dynamic>{
      'id': id,
      'title': title,
      'category': category,
      'dueTime': dueTime.millisecondsSinceEpoch,
      'isDone': isDone ? 1 : 0,
      'priority': priority,
      'isShared': isShared ? 1 : 0,
      'reminderEnabled': reminderEnabled ? 1 : 0,
      'note': note,
      'subtasks': subtasks.join('||'),
    };
  }

  factory TaskItem.fromMap(Map<String, dynamic> map) {
    final String subtasksRaw = (map['subtasks'] ?? '') as String;

    return TaskItem(
      id: map['id'] as int?,
      title: (map['title'] ?? '') as String,
      category: (map['category'] ?? '') as String,
      dueTime: DateTime.fromMillisecondsSinceEpoch(
        (map['dueTime'] ?? 0) as int,
      ),
      isDone: (map['isDone'] ?? 0) == 1,
      priority: (map['priority'] ?? 1) as int,
      isShared: (map['isShared'] ?? 0) == 1,
      reminderEnabled: (map['reminderEnabled'] ?? 0) == 1,
      note: (map['note'] ?? '') as String,
      subtasks: subtasksRaw.isEmpty
          ? <String>[]
          : subtasksRaw
                .split('||')
                .where((String item) => item.isNotEmpty)
                .toList(),
    );
  }
}
