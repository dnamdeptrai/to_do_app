import 'package:flutter/material.dart';
import '../Controller/HomeController.dart';
import '../View/SettingView.dart';
import '../View/CalendarView.dart';
import '../View/CategoryView.dart';
import '../View/ProfileDrawerView.dart';
import 'package:flutter_slidable/flutter_slidable.dart';

class HomeView extends StatefulWidget {
  final String userEmail;
  const HomeView({super.key, required this.userEmail});

  @override
  State<HomeView> createState() => _HomeViewState();
}

class _HomeViewState extends State<HomeView> {
  late HomeController _controller;
  List<Map<String, dynamic>> _tasks = [];

  @override
  void initState() {
    super.initState();
    _controller = HomeController(userEmail: widget.userEmail);
    _loadTasks();
  }

  Future<void> _loadTasks() async {
    final tasks = await _controller.loadTasks();
    setState(() {
      _tasks = tasks;
    });
  }

  Future<void> _toggleTask(Map<String, dynamic> task) async {
    await _controller.toggleTaskCompletion(task);
    _loadTasks();
  }

  Future<void> _showDeleteConfirmDialog(Map<String, dynamic> task) async {
    showDialog(
      context: context,
      builder: (BuildContext dialogContext) {
        return AlertDialog(
          title: const Text("Xác nhận xoá"),
          content: const Text(
              "Bạn chắc chắn xoá task này chứ?? Đừng lười biếng nha! 😉"),
          actions: [
            TextButton(
              child: const Text("Huỷ"),
              onPressed: () {
                Navigator.of(dialogContext).pop();
              },
            ),
            TextButton(
              style: TextButton.styleFrom(foregroundColor: Colors.red),
              child: const Text("Xoá"),
              onPressed: () async {
                await _controller.deleteTask(task);
                Navigator.of(dialogContext).pop();
                _loadTasks();
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(
                    content: Text("Đã xoá task!"),
                    backgroundColor: Colors.red,
                  ),
                );
              },
            ),
          ],
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF0F5F9),
      endDrawer: ProfileDrawerView(userEmail: widget.userEmail),
      body: Builder(
        builder: (BuildContext bodyContext) {
          return SafeArea(
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 20.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const SizedBox(height: 20),
                  _buildHeader(bodyContext), 
                  const SizedBox(height: 10),
                  _buildDateAndProgress(),
                  const SizedBox(height: 20),
                  Expanded(
                    child: _tasks.isEmpty
                        ? const Center(child: Text("Chưa có công việc"))
                        : ListView.builder(
                            itemCount: _tasks.length,
                            itemBuilder: (context, index) {
                              final task = _tasks[index];
                              return _buildTaskItem(task);
                            },
                          ),
                  ),
                ],
              ),
            ),
          );
        },
      ),

      bottomNavigationBar: _buildBottomNavigationBar(context),

      floatingActionButton: SizedBox(
        width: 100,
        height: 100,
        child: FloatingActionButton(
          onPressed: () {
            _controller.openAddTaskView(context, _loadTasks);
          },
          backgroundColor: const Color(0xFF0051DC),
          shape: const CircleBorder(
            side: BorderSide(
              color: Colors.white,
              width: 9,
            ),
          ),
          child: const Icon(Icons.add, size: 40, color: Colors.white),
        ),
      ),
            floatingActionButtonLocation: FloatingActionButtonLocation.centerDocked,
    );
  }
  Widget _buildHeader(BuildContext context) {
    final String firstLetter = widget.userEmail.isNotEmpty ? widget.userEmail[0].toUpperCase() : "?";
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        const Text(
          "Hôm nay",
          style: TextStyle(fontSize: 32, fontWeight: FontWeight.bold),
        ),
        GestureDetector(
          onTap: () {
            Scaffold.of(context).openEndDrawer();
          },
          child: CircleAvatar(
            radius: 20,
            backgroundColor: Colors.blueAccent.shade700, // Thêm màu nền
            child: Text(
              firstLetter,
              style: const TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.bold,
                color: Colors.white,
              ),
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildDateAndProgress() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          _controller.getFormattedDate(),
          style: const TextStyle(fontSize: 16, color: Colors.grey),
        ),
        const SizedBox(height: 4),
        Text(
          _controller.getProgressText(_tasks),
          style: const TextStyle(fontSize: 14, color: Colors.grey),
        ),
      ],
    );
  }

  Widget _buildBottomNavigationBar(BuildContext context) {
    return BottomAppBar(
      color: Colors.white,
      shape: const CircularNotchedRectangle(),
      notchMargin: 10.0,
      elevation: 5.0,
      child: SizedBox(
        height: 50.0,
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: <Widget>[
            Row(
              children: [
                IconButton(
                  icon: const Icon(Icons.home),
                  iconSize: 30.0,
                  onPressed: () {},
                ),
                SizedBox(width: 30),
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
              ],
            ),
            Row(
              children: [
                IconButton(
                  icon: const Icon(Icons.calendar_today),
                  iconSize: 30.0,
                  onPressed: () {
                    Navigator.pushAndRemoveUntil(
                      context,
                      MaterialPageRoute(
                        builder: (context) =>
                            CalendarView(userEmail: widget.userEmail),
                      ),
                      (route) => false,
                    );
                  },
                ),
                SizedBox(width: 30),
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
          ],
        ),
      ),
    );
  }

  Widget _buildTaskItem(Map<String, dynamic> task) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8.0),
      child: Slidable(
        startActionPane: ActionPane(
          motion: const StretchMotion(),
          extentRatio: 0.4,
          children: [
            SlidableAction(
              onPressed: (context) {
                _controller.openEditTaskView(context, task, _loadTasks);
              },
              backgroundColor: Colors.blueAccent,
              foregroundColor: Colors.white,
              icon: Icons.edit,
              borderRadius: const BorderRadius.only(
                topLeft: Radius.circular(15),
                bottomLeft: Radius.circular(15),
              ),
            ),
            SlidableAction(
              onPressed: (context) {
                _showDeleteConfirmDialog(task);
              },
              backgroundColor: Colors.red,
              foregroundColor: Colors.white,
              icon: Icons.delete,
              borderRadius: const BorderRadius.only(
                topRight: Radius.circular(15),
                bottomRight: Radius.circular(15),
              ),
            ),
          ],
        ),
        child: GestureDetector(
          onTap: () => _toggleTask(task),
          child: Container(
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
                const Icon(Icons.task, color: Colors.blueAccent),
                const SizedBox(width: 15),
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
                  (task["isDone"] == 1)
                      ? Icons.check_circle
                      : Icons.circle_outlined,
                  color:
                      (task["isDone"] == 1) ? Colors.green : Colors.grey[400],
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
