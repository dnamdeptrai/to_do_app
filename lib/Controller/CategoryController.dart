import 'package:intl/intl.dart';
import '../Model/TaskDatabase.dart';

class CategoryController {
  final String userEmail;
  Map<String, List<Map<String, dynamic>>> groupedTasks = {};
  List<String> activeCategories = [];
  List<Map<String, dynamic>> _allTasksForDay = [];

  final List<String> allDefinedCategories = [
    "Cá nhân",
    "Công việc",
    "Học tập",
    "Gia đình",
    "Giải trí",
    "Khác",
  ];

  CategoryController({required this.userEmail});

  DateTime get _today => DateTime.now();

  String _getVietnameseDayName(int weekday) {
    switch (weekday) {
      case 1:
        return "Thứ Hai";
      case 2:
        return "Thứ Ba";
      case 3:
        return "Thứ Tư";
      case 4:
        return "Thứ Năm";
      case 5:
        return "Thứ Sáu";
      case 6:
        return "Thứ Bảy";
      case 7:
        return "Chủ Nhật";
      default:
        return "Ngày";
    }
  }

  String getFormattedDate() {
    final dayName = _getVietnameseDayName(_today.weekday);
    final dateString = DateFormat("dd/MM/yyyy").format(_today);
    return "$dayName, $dateString";
  }

  String calculateProgressText(List<Map<String, dynamic>> tasks) {
    if (tasks.isEmpty) {
      return "0/0 công việc. Tiến độ: 0%";
    }
    final total = tasks.length;
    final done = tasks.where((t) => t["isDone"] == 1).length;
    final progress = (done / total) * 100;

    return "$done/$total công việc. Tiến độ: ${progress.toStringAsFixed(0)}%";
  }

  String getProgressText() {
    return calculateProgressText(_allTasksForDay);
  }

  Future<void> loadAndGroupTasks() async {
    final dateKey = DateFormat('yyyy-MM-dd').format(_today);
    TaskDatabase.setCurrentUser(userEmail);
    List<Map<String, dynamic>> allTasks = await TaskDatabase.instance
        .getTasksByDate(dateKey);
    _allTasksForDay = allTasks;

    Map<String, List<Map<String, dynamic>>> tempGroupedTasks = {};
    for (var cat in allDefinedCategories) {
      tempGroupedTasks[cat] = [];
    }

    for (var task in allTasks) {
      final category = task['category'] as String? ?? 'Khác';
      final safeCategory = allDefinedCategories.contains(category)
          ? category
          : 'Khác';
      tempGroupedTasks[safeCategory]!.add(task);
    }

    groupedTasks = {};
    activeCategories = [];
    for (var cat in allDefinedCategories) {
      if (tempGroupedTasks[cat]!.isNotEmpty) {
        groupedTasks[cat] = tempGroupedTasks[cat]!;
        activeCategories.add(cat);
      }
    }
  }

  Future<void> toggleTaskCompletion(Map<String, dynamic> task) async {
    final updatedTask = {...task, "isDone": task["isDone"] == 1 ? 0 : 1};
    await TaskDatabase.instance.updateTask(updatedTask);
  }
}