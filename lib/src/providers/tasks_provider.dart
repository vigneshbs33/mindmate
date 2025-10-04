import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:uuid/uuid.dart';

import '../models/task_item.dart';
import '../services/hive_service.dart';
import '../services/notification_service.dart';
import 'app_providers.dart';

final tasksProvider = StateNotifierProvider<TasksController, List<TaskItem>>((ref) {
  final hive = ref.watch(hiveServiceProvider);
  final notif = ref.watch(notificationServiceProvider);
  return TasksController(hive, notif);
});

class TasksController extends StateNotifier<List<TaskItem>> {
  TasksController(this._hive, this._notifier) : super([]) {
    _load();
  }

  final HiveService _hive;
  final NotificationService _notifier;
  static const _uuid = Uuid();

  void _load() {
    final box = _hive.tasksBox;
    state = box.values.toList()..sort((a, b) => a.dueAt.compareTo(b.dueAt));
  }

  Future<void> addTask(String title, DateTime dueAt, {String? note, bool remind = false}) async {
    final task = TaskItem(id: _uuid.v4(), title: title, note: note, dueAt: dueAt, remind: remind);
    await _hive.tasksBox.put(task.id, task);
    if (remind) {
      await _notifier.scheduleNotification(
        id: task.id.hashCode,
        title: 'Task Reminder',
        body: title,
        scheduledAt: dueAt,
      );
    }
    _load();
  }

  Future<void> toggleDone(String id) async {
    final t = _hive.tasksBox.get(id);
    if (t == null) return;
    final updated = t.copyWith(done: !t.done);
    await _hive.tasksBox.put(id, updated);
    _load();
  }

  Future<void> deleteTask(String id) async {
    await _hive.tasksBox.delete(id);
    _load();
  }

  Future<void> deleteCompletedTasks() async {
    final toDelete = state.where((t) => t.done).map((t) => t.id).toList();
    for (final id in toDelete) {
      await _hive.tasksBox.delete(id);
    }
    _load();
  }
}


