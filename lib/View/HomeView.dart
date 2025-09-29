import 'dart:nativewrappers/_internal/vm/lib/ffi_patch.dart';

import 'package:flutter/material.dart';
import '../Controller/HomeController.dart';
import '../View/SettingView.dart';

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

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF0F5F9),
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 20.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const SizedBox(height: 20),
              _buildHeader(),
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
      ),
      bottomNavigationBar: _buildBottomNavigationBar(context),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () {
          _controller.openAddTaskView(context, _loadTasks);
        },
        backgroundColor: const Color(0xFF4285F4),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(100.0),
        ),
        label: const Icon(Icons.add, size: 30),
      ),
      floatingActionButtonLocation: FloatingActionButtonLocation.centerDocked,
    );
  }

  Widget _buildHeader() {
    return const Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(
          "Hôm nay",
          style: TextStyle(fontSize: 32, fontWeight: FontWeight.bold),
        ),
        CircleAvatar(
          radius: 20,
          backgroundImage: NetworkImage("https://i.pravatar.cc/300"),
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
            // Nhóm 1: Home và Folder
            Row(
              children: [
                IconButton(
                  icon: const Icon(Icons.home),
                  iconSize: 30.0,
                  onPressed: () {},
                ),
                IconButton(
                  icon: const Icon(Icons.folder),
                  iconSize: 30.0,
                  onPressed: () {},
                ),
              ],
            ),
            Row(
              children: [
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
                        builder: (context) => const SettingsView(),
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
    return GestureDetector(
      onTap: () => _toggleTask(task),
      child: Container(
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
              color: (task["isDone"] == 1) ? Colors.green : Colors.grey[400],
            ),
          ],
        ),
      ),
    );
  }
}
