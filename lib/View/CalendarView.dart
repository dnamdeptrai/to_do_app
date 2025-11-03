import 'package:flutter/material.dart';
import 'package:table_calendar/table_calendar.dart';
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

  Widget _buildCalendar(BuildContext context) {
    final theme = Theme.of(context);
    final isDarkMode = theme.brightness == Brightness.dark;

    return TableCalendar(
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

      headerStyle: HeaderStyle(
        formatButtonVisible: false,
        titleCentered: true,
        titleTextStyle: theme.textTheme.titleMedium ?? TextStyle(), 
      ),

      calendarStyle: CalendarStyle(
        defaultTextStyle: TextStyle(color: isDarkMode ? Colors.white : Colors.black),
        weekendTextStyle: TextStyle(color: isDarkMode ? Colors.red[300] : Colors.red),
        outsideTextStyle: TextStyle(color: isDarkMode ? Colors.white38 : Colors.grey[400]),

        todayDecoration: BoxDecoration(
          color: Colors.blueAccent.withOpacity(0.3), 
          shape: BoxShape.circle,
        ),
        todayTextStyle: TextStyle(
          color: isDarkMode ? Colors.white : Colors.black,
          fontWeight: FontWeight.bold,
        ),

        selectedDecoration: const BoxDecoration(
          color: Colors.blueAccent, 
          shape: BoxShape.circle,
        ),
        selectedTextStyle: const TextStyle(
          color: Colors.white, 
          fontWeight: FontWeight.bold,
        ),
      ),
    );
  }
  

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Scaffold(
      backgroundColor: theme.scaffoldBackgroundColor, 
      appBar: AppBar(
        title: const Text("Lịch"),
      ),
      body: Column(
        children: [
          _buildCalendar(context), 
          const Divider(height: 1),
          Expanded(
            child: _isLoading
                ? const Center(child: CircularProgressIndicator())
                : _dailyTasks.isEmpty
                    ? Center(
                        child: Text(
                          "Không có công việc nào trong ngày này.",
                          style: TextStyle(color: theme.textTheme.bodySmall?.color), 
                        ),
                      )
                    : ListView.builder(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 20.0,
                          vertical: 10.0,
                        ),
                        itemCount: _dailyTasks.length,
                        itemBuilder: (context, index) {
                          final task = _dailyTasks[index];
                          return _buildTaskItem(context, task); 
                        },
                      ),
          ),
        ],
      ),
      bottomNavigationBar: _buildBottomNavigationBar(context, 2), 
    );
  }

  Widget _buildTaskItem(BuildContext context, Map<String, dynamic> task) {
    final theme = Theme.of(context);
    final isDarkMode = theme.brightness == Brightness.dark;
    final isDone = task["isDone"] == 1;

    return Container(
      margin: const EdgeInsets.symmetric(vertical: 8.0),
      padding: const EdgeInsets.all(16.0),
      decoration: BoxDecoration(
        color: isDarkMode ? Colors.grey[800] : Colors.white,
        borderRadius: BorderRadius.circular(15.0),
        boxShadow: [
          BoxShadow(
            color: isDarkMode ? Colors.black.withOpacity(0.3) : Colors.grey.withOpacity(0.1), // Đổ bóng
            spreadRadius: 1,
            blurRadius: 5,
            offset: const Offset(0, 3),
          ),
        ],
      ),
      child: Row(
        children: [
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  task["taskName"],
                  style: TextStyle(
                    fontSize: 15,
                    decoration: isDone
                        ? TextDecoration.lineThrough
                        : null,
                    color: isDone 
                        ? (isDarkMode ? Colors.white54 : Colors.grey)
                        : (isDarkMode ? Colors.white : Colors.black),
                  ),
                ),
                if (task['note'] != null && task['note'].isNotEmpty)
                  Padding(
                    padding: const EdgeInsets.only(top: 2.0),
                    child: Text(
                      task['note'],
                      style: TextStyle(
                        fontSize: 10, 
                        color: isDarkMode ? Colors.white60 : Colors.grey[600] 
                      ),
                    ),
                  ),
              ],
            ),
          ),
          Icon(
            isDone ? Icons.check_circle : Icons.circle_outlined,
            color: isDone ? Colors.green : (isDarkMode ? Colors.grey[600] : Colors.grey[400]), 
          ),
        ],
      ),
    );
  }

  Widget _buildBottomNavigationBar(BuildContext context, int selectedIndex) {
    return BottomAppBar(
      shape: const CircularNotchedRectangle(),
      notchMargin: 8.0,
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceAround,
        children: [
          IconButton(
            icon: Icon(
              Icons.home,
              color: selectedIndex == 0 ? Colors.blueAccent : Theme.of(context).iconTheme.color,
            ),
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
            icon: Icon(
              Icons.folder,
              color: selectedIndex == 1 ? Colors.blueAccent : Theme.of(context).iconTheme.color,
            ),
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
            icon: Icon(
              Icons.calendar_today,
              color: selectedIndex == 2 ? Colors.blueAccent : Theme.of(context).iconTheme.color,
            ),
            iconSize: 30.0,
            onPressed: () {}, 
          ),
          IconButton(
            icon: Icon(
              Icons.settings,
              color: selectedIndex == 3 ? Colors.blueAccent : Theme.of(context).iconTheme.color,
            ),
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