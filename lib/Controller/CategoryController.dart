import 'package:intl/intl.dart';
import '../Model/TaskDatabase.dart';

class CategoryController {
  final String userEmail;
  
  Map<String, List<Map<String, dynamic>>> groupedTasks = {};
  
  Map<String, List<Map<String, dynamic>>> filteredGroupedTasks = {};

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

  String getFormattedDate() {
    final now = DateTime.now();
    return DateFormat("EEEE, dd/MM/yyyy", "vi_VN").format(now);
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
    
    filteredGroupedTasks = groupedTasks;
  }

  void filterTasks(String query) {
    query = query.toLowerCase();

    if (query.isEmpty) {
      filteredGroupedTasks = groupedTasks;
      return;
    }

    Map<String, List<Map<String, dynamic>>> tempFiltered = {};

    groupedTasks.forEach((category, tasks) {
      
      final filteredTasks = tasks.where((task) {
        final taskName = task['taskName'].toString().toLowerCase();
        return taskName.contains(query);
      }).toList();

      if (filteredTasks.isNotEmpty) {
        tempFiltered[category] = filteredTasks;
      }
    });

    filteredGroupedTasks = tempFiltered;
  }

  Future<void> toggleTaskCompletion(Map<String, dynamic> task) async {
    final updatedTask = {...task, "isDone": task["isDone"] == 1 ? 0 : 1};
    await TaskDatabase.instance.updateTask(updatedTask);
  }
}