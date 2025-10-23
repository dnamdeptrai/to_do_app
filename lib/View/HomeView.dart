import 'package:flutter/material.dart';
import 'package:flutter_slidable/flutter_slidable.dart';
import '../Controller/HomeController.dart';
import '../View/SettingView.dart';
import '../View/CalendarView.dart';
import '../View/CategoryView.dart';
import '../View/ProfileDrawerView.dart'; // <-- THÊM IMPORT NÀY

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
    _requestNotificationPermissions(); // Hàm này từ bước tối ưu khởi động
  }

  Future<void> _requestNotificationPermissions() async {
    // (Hàm này giữ nguyên)
  }

  Future<void> _loadTasks() async {
    final tasks = await _controller.loadTasks();
    if (mounted) {
      setState(() {
        _tasks = tasks;
      });
    }
  }

  Future<void> _toggleTask(Map<String, dynamic> task) async {
    await _controller.toggleTaskCompletion(task);
    _loadTasks();
  }

  Future<void> _showDeleteConfirmDialog(Map<String, dynamic> task) async {
    // ... (Hàm này giữ nguyên, nó sẽ tự đổi màu theo theme)
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
    // Lấy theme hiện tại
    final theme = Theme.of(context);

    return Scaffold(
      backgroundColor: theme.scaffoldBackgroundColor, // SỬA DARK MODE
      
      // THÊM EndDrawer
      endDrawer: ProfileDrawerView(userEmail: widget.userEmail),

      // BỌC body bằng Builder để lấy đúng context cho EndDrawer
      body: Builder(
        builder: (BuildContext bodyContext) { // 'bodyContext' là context BÊN TRONG Scaffold
          return SafeArea(
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 20.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const SizedBox(height: 20),
                  // Truyền bodyContext và userEmail vào
                  _buildHeader(bodyContext, widget.userEmail), 
                  const SizedBox(height: 10),
                  _buildDateAndProgress(context), // Truyền context
                  const SizedBox(height: 20),
                  Expanded(
                    child: _tasks.isEmpty
                        ? Center(child: Text(
                            "Chưa có công việc",
                            style: TextStyle(color: theme.textTheme.bodySmall?.color), // SỬA DARK MODE
                          ))
                        : ListView.builder(
                            itemCount: _tasks.length,
                            itemBuilder: (context, index) {
                              final task = _tasks[index];
                              // Truyền context vào
                              return _buildTaskItem(context, task); 
                            },
                          ),
                  ),
                ],
              ),
            ),
          );
        },
      ),
      bottomNavigationBar: _buildBottomNavigationBar(context, 0), // SỬA HIGHLIGHT (index 0)
      floatingActionButton: SizedBox(
        width: 100,
        height: 100,
        child: FloatingActionButton(
          onPressed: () {
            _controller.openAddTaskView(context, _loadTasks);
          },
          backgroundColor: const Color(0xFF0051DC),
          shape: CircleBorder(
            side: BorderSide(
              // SỬA DARK MODE: Màu viền trắng/đen
              color: theme.brightness == Brightness.dark ? Colors.black : Colors.white,
              width: 9,
            ),
          ),
          child: const Icon(Icons.add, size: 40, color: Colors.white),
        ),
      ),
      floatingActionButtonLocation: FloatingActionButtonLocation.centerDocked,
    );
  }

  Widget _buildHeader(BuildContext context, String userEmail) {
    final String firstLetter = userEmail.isNotEmpty ? userEmail[0].toUpperCase() : "?";

    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(
          "Hôm nay",
          style: Theme.of(context).textTheme.titleLarge?.copyWith(
                fontWeight: FontWeight.bold,
                fontSize: 32,
              ),
        ),
        GestureDetector( 
          onTap: () {
            Scaffold.of(context).openEndDrawer(); 
          },
          child: CircleAvatar(
            radius: 20,
            backgroundColor: Colors.blueAccent.shade700,
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

  Widget _buildDateAndProgress(BuildContext context) {
    final theme = Theme.of(context);
    
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          _controller.getFormattedDate(),
          style: theme.textTheme.bodyMedium?.copyWith(
            color: theme.brightness == Brightness.dark ? Colors.white70 : Colors.grey[700],
          ),
        ),
        const SizedBox(height: 4),
        Text(
          _controller.getProgressText(_tasks),
          style: theme.textTheme.bodySmall?.copyWith(
            color: theme.brightness == Brightness.dark ? Colors.white60 : Colors.grey[600],
          ),
        ),
      ],
    );
  }

  Widget _buildTaskItem(BuildContext context, Map<String, dynamic> task) {
    final isDone = task["isDone"] == 1;
    final theme = Theme.of(context);
    final isDarkMode = theme.brightness == Brightness.dark;

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
              color: isDarkMode ? Colors.grey[800] : Colors.white, // Nền
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
                Icon(Icons.task, color: isDarkMode ? Colors.blueAccent.shade200 : Colors.blueAccent), // Icon
                const SizedBox(width: 15),
                Expanded(
                  child: Text(
                    task["taskName"],
                    style: TextStyle(
                      fontSize: 16,
                      decoration: (task["isDone"] == 1)
                          ? TextDecoration.lineThrough
                          : null,
                      color: isDone // Màu chữ
                          ? (isDarkMode ? Colors.white54 : Colors.grey)
                          : (isDarkMode ? Colors.white : Colors.black),
                    ),
                  ),
                ),
                Icon(
                  (task["isDone"] == 1)
                      ? Icons.check_circle
                      : Icons.circle_outlined,
                  color: isDone ? Colors.green : (isDarkMode ? Colors.grey[600] : Colors.grey[400]), // Icon check
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildBottomNavigationBar(BuildContext context, int selectedIndex) {
    return BottomAppBar(
      shape: const CircularNotchedRectangle(),
      notchMargin: 10.0,
      child: SizedBox(
        height: 50.0,
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: <Widget>[
            Row(
              children: [
                IconButton(
                  icon: Icon(
                    Icons.home,
                    color: selectedIndex == 0 ? Colors.blueAccent : Theme.of(context).iconTheme.color, // Sửa màu
                  ),
                  iconSize: 30.0,
                  onPressed: () {}, 
                ),
                const SizedBox(width: 30),
                IconButton(
                  icon: Icon(
                    Icons.folder,
                    color: selectedIndex == 1 ? Colors.blueAccent : Theme.of(context).iconTheme.color, // Sửa màu
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
              ],
            ),
            Row(
              children: [
                IconButton(
                  icon: Icon(
                    Icons.calendar_today,
                    color: selectedIndex == 2 ? Colors.blueAccent : Theme.of(context).iconTheme.color, // Sửa màu
                  ),
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
                const SizedBox(width: 30),
                IconButton(
                  icon: Icon(
                    Icons.settings,
                    color: selectedIndex == 3 ? Colors.blueAccent : Theme.of(context).iconTheme.color, // Sửa màu
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
          ],
        ),
      ),
    );
  }
}