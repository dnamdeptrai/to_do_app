import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import '../Model/TaskDatabase.dart';
import '../View/AddTaskView.dart';

class HomeController {
  final String userEmail;

  HomeController({required this.userEmail}) {
    TaskDatabase.setCurrentUser(userEmail);
  }

  Future<List<Map<String, dynamic>>> loadTasks() async {
    return await TaskDatabase.instance.getTasks();
  }

  Future<void> toggleTaskCompletion(Map<String, dynamic> task) async {
    final updatedTask = {...task, "isDone": task["isDone"] == 1 ? 0 : 1};
    await TaskDatabase.instance.updateTask(updatedTask);
  }

  String getFormattedDate() {
    final now = DateTime.now();
    return DateFormat("EEEE, dd/MM/yyyy", "vi_VN").format(now);
  }

  String getProgressText(List<Map<String, dynamic>> tasks) {
    if (tasks.isEmpty) return "Chưa có công việc nào";
    final done = tasks.where((t) => t["isDone"] == 1).length;
    return "$done/${tasks.length} công việc đã hoàn thành";
  }

  Future<void> openAddTaskView(
    BuildContext context,
    VoidCallback reload,
  ) async {
    await Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => AddTaskView(userEmail: userEmail),
      ),
    );
    reload();
  }
}
