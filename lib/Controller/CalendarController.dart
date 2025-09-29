import 'package:flutter/material.dart';
import 'package:table_calendar/table_calendar.dart';
import 'package:intl/intl.dart';
import '../Model/TaskDatabase.dart';

class CalendarController {
  DateTime focusedDay = DateTime.now();
  DateTime? selectedDay;
  final String userEmail;

  List<Map<String, dynamic>> dailyTasks = [];

  CalendarController(this.userEmail) {
    selectedDay = DateTime.now();
  }
  bool isDaySelected(DateTime day) {
    return isSameDay(selectedDay, day);
  }

  Future<void> loadTasksForDate(DateTime day) async {
    final dateKey = DateFormat('yyyy-MM-dd').format(day);
    TaskDatabase.setCurrentUser(userEmail);
    dailyTasks = await TaskDatabase.instance.getTasksByDate(dateKey);
  }

  Future<double> getDailyProgress(DateTime day) async {
    final dateKey = DateFormat('yyyy-MM-dd').format(day);

    TaskDatabase.setCurrentUser(userEmail);

    try {
      return await TaskDatabase.instance.getTaskProgressForDate(dateKey);
    } catch (e) {
      debugPrint("Lỗi khi tính tiến độ cho ngày $dateKey: $e");
      return 0.0;
    }
  }

  Color getProgressColor(double progress) {
    if (progress == 1.0) {
      return Colors.green.shade600;
    } else if (progress > 0.0) {
      return Colors.yellow.shade600;
    } else {
      return Colors.red.shade600;
    }
  }
}
