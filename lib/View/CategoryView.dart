import 'package:flutter/material.dart';
import '../Controller/CategoryController.dart';
import '../View/HomeView.dart';
import '../View/SettingView.dart';
import '../View/CalendarView.dart';

class CategoryView extends StatefulWidget {
  final String userEmail;
  const CategoryView({super.key, required this.userEmail});

  @override
  State<CategoryView> createState() => _CategoryViewState();
}

class _CategoryViewState extends State<CategoryView> {
  late CategoryController _controller;
  late Future<void> _loadingFuture;
  String _progressText = "Đang tải tiến độ...";

  @override
  void initState() {
    super.initState();
    _controller = CategoryController(userEmail: widget.userEmail);
    _loadingFuture = _loadTasksAndProgress();
  }

  Future<void> _loadTasksAndProgress() async {
    await _controller.loadAndGroupTasks();
    if (mounted) {
      setState(() {
        _progressText = _controller.getProgressText();
      });
    }
  }

  Future<void> _toggleTask(Map<String, dynamic> task) async {
    await _controller.toggleTaskCompletion(task);
    await _loadTasksAndProgress();
    setState(() {
      _progressText = _controller.getProgressText();
    });
  }

  Widget _buildHeader() {
    return const Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(
          "Phân loại",
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
          _progressText,
          style: const TextStyle(fontSize: 14, color: Colors.grey),
        ),
      ],
    );
  }

  Widget _buildTaskItem(Map<String, dynamic> task) {
    final isDone = task["isDone"] == 1;

    return GestureDetector(
      onTap: () => _toggleTask(task),
      child: Container(
        margin: const EdgeInsets.symmetric(vertical: 4.0),
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
                  decoration: isDone ? TextDecoration.lineThrough : null,
                  color: isDone ? Colors.grey : Colors.black,
                ),
              ),
            ),
            Icon(
              isDone
                  ? Icons.check_circle 
                  : Icons.circle_outlined, 
              color: isDone ? Colors.green : Colors.grey[400],
            ),
          ],
        ),
      ),
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
              icon: const Icon(Icons.folder, color: Colors.blueAccent), // Icon hiện tại nên sáng hơn
              iconSize: 30.0,
              onPressed: () {},
            ),

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
                child: FutureBuilder(
                  future: _loadingFuture,
                  builder: (context, snapshot) {
                    if (snapshot.connectionState == ConnectionState.waiting) {
                      return const Center(child: CircularProgressIndicator());
                    }
                    if (_controller.activeCategories.isEmpty) {
                      return const Center(
                        child: Text(
                          "Chưa có công việc nào cần hoàn thành hôm nay.",
                          style: TextStyle(color: Colors.grey, fontSize: 16),
                        ),
                      );
                    }

                    return ListView.builder(
                      itemCount: _controller.activeCategories.length,
                      itemBuilder: (context, index) {
                        final category = _controller.activeCategories[index];
                        final tasks = _controller.groupedTasks[category]!;

                        return Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Padding(
                              padding: const EdgeInsets.only(
                                top: 16.0,
                                bottom: 8.0,
                              ),
                              child: Text(
                                "$category:",
                                style: const TextStyle(
                                  fontSize: 20,
                                  fontWeight: FontWeight.bold,
                                  color: Colors.black87,
                                ),
                              ),
                            ),
                            ...tasks
                                .map((task) => _buildTaskItem(task))
                                .toList(),
                          ],
                        );
                      },
                    );
                  },
                ),
              ),
            ],
          ),
        ),
      ),
      bottomNavigationBar: _buildBottomNavigationBar(context),
    );
  }
}