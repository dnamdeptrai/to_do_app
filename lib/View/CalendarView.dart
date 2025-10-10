// lib/View/CalendarView.dart

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
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _loadTasksForSelectedDay(_controller.focusedDay);
    });
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
    if (mounted) {
      setState(() {
        _dailyTasks = _controller.dailyTasks;
        _isLoading = false;
      });
    }
  }

  Widget _markerBuilder(BuildContext context, DateTime day, List events) {
    return FutureBuilder<DayStatus>(
      future: _controller.getDayStatus(day),
      builder: (context, snapshot) {
        if (snapshot.hasData && snapshot.data != DayStatus.none) {
          Color dotColor = Colors.transparent;
          switch (snapshot.data!) {
            case DayStatus.incomplete:
              dotColor = Colors.amber;
              break;
            case DayStatus.completed:
              dotColor = Colors.green;
              break;
            case DayStatus.incompletePast:
              dotColor = Colors.red;
              break;
            case DayStatus.none:
              break;
          }
          return Positioned(
            bottom: 5,
            right: 0,
            left: 0,
            child: Center(
              child: Container(
                width: 7,
                height: 7,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  color: dotColor,
                ),
              ),
            ),
          );
        }
        return const SizedBox.shrink();
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Lịch"),
        backgroundColor: const Color(0xFFF0F5F9),
      ),
      body: Column(
        children: [
          TableCalendar(
            locale: 'vi_VN',
            firstDay: DateTime.utc(2020, 1, 1),
            lastDay: DateTime.utc(2030, 12, 31),
            focusedDay: _controller.focusedDay,
            selectedDayPredicate: (day) => _controller.isDaySelected(day),
            onDaySelected: (selectedDay, focusedDay) {
              if (!_controller.isDaySelected(selectedDay)) {
                _loadTasksForSelectedDay(selectedDay);
              }
            },
            calendarBuilders: CalendarBuilders(markerBuilder: _markerBuilder),
            headerStyle: const HeaderStyle(
              formatButtonVisible: false,
              titleCentered: true,
            ),
          ),
          const Divider(height: 1),

          Expanded(
            child: _isLoading
                ? const Center(child: CircularProgressIndicator())
                : _dailyTasks.isEmpty
                ? const Center(
                    child: Text("Không có công việc nào trong ngày này."),
                  )
                : ListView.builder(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 20.0,
                      vertical: 10.0,
                    ),
                    itemCount: _dailyTasks.length,
                    itemBuilder: (context, index) {
                      final task = _dailyTasks[index];

                      return _buildTaskItem(task);
                    },
                  ),
          ),
        ],
      ),
      bottomNavigationBar: _buildBottomNavigationBar(context),
    );
  }

  Widget _buildTaskItem(Map<String, dynamic> task) {
    return Container(
      margin: const EdgeInsets.symmetric(vertical: 8.0),
      padding: const EdgeInsets.all(16.0),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(15.0),
        boxShadow: [
          BoxShadow(
            color: Colors.grey.withOpacity(0.1),
            spreadRadius: 1,
            blurRadius: 5,
            offset: const Offset(0, 3),
          ),
        ],
      ),
      child: Row(
        children: [
          Icon(Icons.notes_rounded, color: Colors.blueAccent),
          const SizedBox(width: 15),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  task["taskName"],
                  style: TextStyle(
                    fontSize: 16,
                    decoration: (task["isDone"] == 1)
                        ? TextDecoration.lineThrough
                        : null,
                    color: (task["isDone"] == 1) ? Colors.grey : Colors.black,
                  ),
                ),
                if (task['note'] != null && task['note'].isNotEmpty)
                  Padding(
                    padding: const EdgeInsets.only(top: 4.0),
                    child: Text(
                      task['note'],
                      style: TextStyle(fontSize: 14, color: Colors.grey[600]),
                    ),
                  ),
              ],
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

  Widget _buildBottomNavigationBar(BuildContext context) {
    return BottomAppBar(
      color: Colors.white,
      shape: const CircularNotchedRectangle(),
      notchMargin: 8.0,
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceAround,
        children: [
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
    );
  }
}
