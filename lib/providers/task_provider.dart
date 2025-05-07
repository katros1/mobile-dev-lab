import 'package:flutter/foundation.dart';
import '../models/task.dart';
import '../services/local_db_service.dart';

class TaskProvider extends ChangeNotifier {
  List<Task> _tasks = [];
  List<Task> get tasks => _tasks;

  TaskProvider() {
    loadTasks();
  }

  Future<void> loadTasks() async {
    _tasks = await LocalDbService.getTasks();
    notifyListeners();
  }

  Future<void> addTask(Task task) async {
    await LocalDbService.insertTask(task);
    await loadTasks();
  }

  Future<void> deleteTask(int id) async {
    await LocalDbService.deleteTask(id);
    await loadTasks();
  }

  Future<void> updateTask(Task task) async {
    await LocalDbService.updateTask(task);
    await loadTasks();
  }

  Future<void> deleteCompletedTasks() async {
    final completedTasks = _tasks.where((task) => task.isCompleted).toList();
    for (final task in completedTasks) {
      if (task.id != null) {
        await deleteTask(task.id!);
      }
    }
  }
}
