import '../models/task_item.dart';

abstract class TaskRepository {
  Future<List<TaskItem>> getAllTasks();
  Future<TaskItem> createTask(TaskItem task);
  Future<TaskItem> updateTask(TaskItem task);
  Future<void> deleteTask(int id);
}

class InMemoryTaskRepository implements TaskRepository {
  InMemoryTaskRepository({List<TaskItem>? seed})
    : _items = List<TaskItem>.from(seed ?? <TaskItem>[]),
      _nextId = (seed == null || seed.isEmpty)
          ? 1
          : (seed
                    .map((TaskItem task) => task.id ?? 0)
                    .reduce((int a, int b) => a > b ? a : b) +
                1);

  final List<TaskItem> _items;
  int _nextId;

  @override
  Future<List<TaskItem>> getAllTasks() async {
    return List<TaskItem>.from(_items);
  }

  @override
  Future<TaskItem> createTask(TaskItem task) async {
    final TaskItem created = task.copyWith(id: _nextId);
    _nextId += 1;
    _items.add(created);
    return created;
  }

  @override
  Future<TaskItem> updateTask(TaskItem task) async {
    final int index = _items.indexWhere((TaskItem item) => item.id == task.id);
    if (index == -1) {
      return task;
    }
    _items[index] = task;
    return task;
  }

  @override
  Future<void> deleteTask(int id) async {
    _items.removeWhere((TaskItem task) => task.id == id);
  }
}
