import 'package:table_calendar/table_calendar.dart';
import 'package:intl/intl.dart';
import '../Model/TaskDatabase.dart';

enum DayStatus { none, incomplete, completed, incompletePast }

class CalendarController {
  DateTime focusedDay = DateTime.now();
  DateTime? selectedDay;
  final String userEmail;

  List<Map<String, dynamic>> dailyTasks = [];

  CalendarController(this.userEmail) {
    selectedDay = DateTime.now();
    TaskDatabase.setCurrentUser(userEmail);
  }

  bool isDaySelected(DateTime day) {
    return isSameDay(selectedDay, day);
  }

  Future<void> loadTasksForDate(DateTime day) async {
    final dateKey = DateFormat('yyyy-MM-dd').format(day);
    dailyTasks = await TaskDatabase.instance.getTasksByDate(dateKey);
  }

  Future<DayStatus> getDayStatus(DateTime day) async {
    final dateKey = DateFormat('yyyy-MM-dd').format(day);
    final status = await TaskDatabase.instance.getDayStatus(dateKey);

    if (!(status['hasTasks'] as bool)) {
      return DayStatus.none;
    }

    if (status['allDone'] as bool) {
      return DayStatus.completed;
    }
    final now = DateTime.now();
    final today = DateTime(now.year, now.month, now.day);
    final dayToCheck = DateTime(day.year, day.month, day.day);

    if (dayToCheck.isBefore(today)) {
      return DayStatus.incompletePast;
    } else {
      return DayStatus.incomplete;
    }
  }
}