import 'package:flutter/material.dart';
import 'package:table_calendar/table_calendar.dart';
import 'package:intl/intl.dart';
import '../Controller/CalendarController.dart';
import 'HomeView.dart';
import 'SettingView.dart';
import 'CategoryView.dart';

class CalendarView extends StatefulWidget {
  final String userEmail;
  const CalendarView({super.key, required this.userEmail});

  @override
  State<CalendarView> createState() => _CalendarViewState();
}

class _CalendarViewState extends State<CalendarView> {
  late CalendarController _controller;

  List<Map<String, dynamic>> _dailyTasks = [];
  bool _isLoading = false;

  @override
  void initState() {
    super.initState();
    _controller = CalendarController(widget.userEmail);
    _loadTasksForSelectedDay(_controller.focusedDay);
  }

  Future<void> _loadTasksForSelectedDay(DateTime day) async {
    if (_isLoading) return;

    setState(() {
      _isLoading = true;
      _dailyTasks = [];
      _controller.selectedDay = day;
      _controller.focusedDay = day;
    });

    await _controller.loadTasksForDate(day);
    setState(() {
      _dailyTasks = _controller.dailyTasks;
      _isLoading = false;
    });
  }

  Widget? _markerBuilder(BuildContext context, DateTime day, List events) {
    return FutureBuilder<double>(
      future: _controller.getDailyProgress(day),
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.done &&
            snapshot.hasData) {
          final progress = snapshot.data!;
          final markerColor = _controller.getProgressColor(progress);
          if (progress > 0.0) {
            return Positioned(
              bottom: 1,
              child: Container(
                width: 6.0,
                height: 6.0,
                decoration: BoxDecoration(
                  color: markerColor,
                  shape: BoxShape.circle,
                ),
              ),
            );
          }
        }
        return const SizedBox.shrink();
      },
    );
  }

  Widget _buildTaskList() {
    if (_isLoading) {
      return const Center(child: CircularProgressIndicator());
    }

    if (_dailyTasks.isEmpty) {
      final formattedDate = DateFormat(
        'dd/MM/yyyy',
      ).format(_controller.selectedDay!);
      return Center(
        child: Text(
          "Không có công việc nào trong ngày $formattedDate.",
          style: const TextStyle(color: Colors.grey, fontSize: 16),
        ),
      );
    }
    return ListView.builder(
      itemCount: _dailyTasks.length,
      itemBuilder: (context, index) {
        final task = _dailyTasks[index];
        return _buildTaskItem(task);
      },
    );
  }

  Widget _buildTaskItem(Map<String, dynamic> task) {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 4.0),
      padding: const EdgeInsets.all(12.0),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(10.0),
        boxShadow: [
          BoxShadow(
            color: Colors.grey.withOpacity(0.1),
            spreadRadius: 1,
            blurRadius: 3,
          ),
        ],
      ),
      child: Row(
        children: [
          Expanded(
            child: Text(
              task["taskName"],
              style: TextStyle(
                fontSize: 16,
                decoration: (task["isDone"] == 1)
                    ? TextDecoration.lineThrough
                    : null,
                color: (task["isDone"] == 1) ? Colors.grey : Colors.black,
              ),
            ),
          ),
          Icon(
            (task["isDone"] == 1) ? Icons.check_circle : Icons.circle_outlined,
            color: (task["isDone"] == 1) ? Colors.green : Colors.grey[400],
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text("Lịch Công Việc")),
      body: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          TableCalendar(
            firstDay: DateTime.utc(2020, 1, 1),
            lastDay: DateTime.utc(2030, 12, 31),
            focusedDay: _controller.focusedDay,
            selectedDayPredicate: _controller.isDaySelected,

            onDaySelected: (selectedDay, focusedDay) {
              if (!isSameDay(_controller.selectedDay, selectedDay)) {
                _loadTasksForSelectedDay(selectedDay);
              }
            },
            calendarFormat: CalendarFormat.month,
            calendarBuilders: CalendarBuilders(markerBuilder: _markerBuilder),
          ),

          const Divider(height: 1),
          Padding(
            padding: const EdgeInsets.symmetric(
              vertical: 8.0,
              horizontal: 16.0,
            ),
            child: Text(
              "Công việc ${DateFormat('dd/MM/yyyy').format(_controller.selectedDay!)}:",
              style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
          ),

          Expanded(child: _buildTaskList()),
        ],
      ),
      bottomNavigationBar: _buildBottomNavigationBar(context),
    );
  }

  Widget _buildBottomNavigationBar(BuildContext context) {
    return BottomAppBar(
      color: Colors.white,
      elevation: 5.0,
      child: SizedBox(
        height: 50.0,
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceAround,
          children: <Widget>[
            IconButton(
              icon: const Icon(Icons.home),
              iconSize: 30.0,
              onPressed: () {
                Navigator.pushAndRemoveUntil(
                  context,
                  MaterialPageRoute(
                    builder: (context) => HomeView(userEmail: widget.userEmail),
                  ),
                  (route) => false,
                );
              },
            ),

            IconButton(
              icon: const Icon(Icons.folder),
              iconSize: 30.0,
              onPressed: () {
                Navigator.pushAndRemoveUntil(
                  context,
                  MaterialPageRoute(
                    builder: (context) =>
                        CategoryView(userEmail: widget.userEmail),
                  ),
                  (route) => false,
                );
              },
            ),

            IconButton(
              icon: const Icon(Icons.calendar_today),
              iconSize: 30.0,
              onPressed: () {},
            ),

            IconButton(
              icon: const Icon(Icons.settings),
              iconSize: 30.0,
              onPressed: () {
                Navigator.pushAndRemoveUntil(
                  context,
                  MaterialPageRoute(
                    builder: (context) =>
                        SettingsView(userEmail: widget.userEmail),
                  ),
                  (route) => false,
                );
              },
            ),
          ],
        ),
      ),
    );
  }
}
