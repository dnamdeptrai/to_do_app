import 'package:flutter/material.dart';
import '../main.dart';

// Bước 1: Tạo một class để biểu diễn một Task
class Task {
  final IconData icon;
  final String title;
  bool isCompleted; // Trạng thái này có thể thay đổi

  Task({required this.icon, required this.title, this.isCompleted = false});
}

class HomeView extends StatefulWidget {
  // Chuyển thành StatefulWidget
  const HomeView({super.key});

  @override
  State<HomeView> createState() => _HomeViewState();
}

class _HomeViewState extends State<HomeView> {
  // Tạo State class
  // Bước 2: Khởi tạo danh sách các task
  final List<Task> _tasks = [
    Task(icon: Icons.description, title: 'Finish project proposal'),
    Task(icon: Icons.phone, title: 'Call client for feedback'),
    Task(icon: Icons.refresh, title: 'Reschedule team meeting'),
    Task(icon: Icons.shopping_cart, title: 'Buy groceries (milk, eggs, bread)'),
    Task(icon: Icons.run_circle_outlined, title: 'Go for a 30-minute run'),
    Task(icon: Icons.book, title: "Read a chapter of 'Atomic Habits'"),
  ];

  // Hàm để cập nhật trạng thái hoàn thành của task
  void _toggleTaskCompletion(int index) {
    setState(() {
      _tasks[index].isCompleted = !_tasks[index].isCompleted;
    });
  }

  // Hàm để tính toán số task đã hoàn thành (cập nhật động)
  String _getTasksCompletedProgress() {
    int completedCount = _tasks
        .where((task) => task.isCompleted)
        .length;
    return '$completedCount/${_tasks.length} tasks completed';
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
              _buildDateAndProgress(), // Sẽ cập nhật để hiển thị tiến độ động
              const SizedBox(height: 20),
              Expanded(
                child: ListView
                    .builder( // Sử dụng ListView.builder để hiệu quả hơn
                  itemCount: _tasks.length,
                  itemBuilder: (context, index) {
                    final task = _tasks[index];
                    return _buildTaskItem(
                      icon: task.icon,
                      title: task.title,
                      isCompleted: task.isCompleted,
                      onTap: () =>
                          _toggleTaskCompletion(
                              index), // Thêm hành động khi nhấn
                    );
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
          // TODO: Thêm logic để thêm task mới (nếu cần)
        },
        backgroundColor: const Color(0xFF4285F4),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(100.0),
        ),
        label: const Icon(Icons.add, size: 30,),
      ),
      floatingActionButtonLocation: FloatingActionButtonLocation.centerDocked,
    );
  }

  Widget _buildHeader() {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        const Text(
          'Hôm Nay',
          style: TextStyle(
            fontSize: 32,
            fontWeight: FontWeight.bold,
          ),
        ),
        Row(
          children: [
            CircleAvatar(
              radius: 20,
              backgroundImage: const NetworkImage(
                'https://i.pravatar.cc/300',
              ),
              backgroundColor: Colors.grey[200],
            ),
          ],
        ),
      ],
    );
  }

  Widget _buildDateAndProgress() {
    final now = DateTime.now();
    String dayOfWeek = _getDayOfWeek(now.weekday);
    String month = _getMonth(now.month);
    String dayOfMonth = now.day.toString();
    final String formattedDate = '$dayOfWeek, $dayOfMonth $month';

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          formattedDate,
          style: const TextStyle(
            fontSize: 16,
            color: Colors.grey,
          ),
        ),
        const SizedBox(height: 4),
        Text(
          _getTasksCompletedProgress(), // Hiển thị tiến độ động
          style: const TextStyle(
            fontSize: 14,
            color: Colors.grey,
          ),
        ),
      ],
    );
  }

  String _getDayOfWeek(int day) {
    switch (day) {
      case DateTime.monday:
        return 'Thứ Hai';
      case DateTime.tuesday:
        return 'Thứ Ba';
      case DateTime.wednesday:
        return 'Thứ Tư';
      case DateTime.thursday:
        return 'Thứ Năm';
      case DateTime.friday:
        return 'Thứ Sáu';
      case DateTime.saturday:
        return 'Thứ Bảy';
      case DateTime.sunday:
        return 'Chủ Nhật';
      default:
        return '';
    }
  }

  String _getMonth(int month) {
    switch (month) {
      case DateTime.january:
        return 'Tháng 1';
      case DateTime.february:
        return 'Tháng 2';
      case DateTime.march:
        return 'Tháng 3';
      case DateTime.april:
        return 'Tháng 4';
      case DateTime.may:
        return 'Tháng 5';
      case DateTime.june:
        return 'Tháng 6';
      case DateTime.july:
        return 'Tháng 7';
      case DateTime.august:
        return 'Tháng 8';
      case DateTime.september:
        return 'Tháng 9';
      case DateTime.october:
        return 'Tháng 10';
      case DateTime.november:
        return 'Tháng 11';
      case DateTime.december:
        return 'Tháng 12';
      default:
        return '';
    }
  }

  // Bước 3: Sửa đổi _buildTaskItem để nhận thêm callback onTap
  Widget _buildTaskItem({
    required IconData icon,
    required String title,
    required bool isCompleted,
    required VoidCallback onTap, // Thêm VoidCallback để xử lý sự kiện nhấn
  }) {
    return GestureDetector( // Bọc Container bằng GestureDetector để bắt sự kiện nhấn
      onTap: onTap, // Gọi callback khi nhấn
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
            Icon(icon, color: Colors.grey[600]),
            const SizedBox(width: 15),
            Expanded(
              child: Text(
                title,
                style: TextStyle(
                  fontSize: 16,
                  decoration: isCompleted ? TextDecoration.lineThrough : null,
                  color: isCompleted ? Colors.grey : Colors.black,
                ),
              ),
            ),
            // Thay đổi Icon dựa trên isCompleted và cũng cho phép nhấn vào đây (tùy chọn)
            Icon(
              isCompleted ? Icons.check_circle : Icons.circle_outlined,
              color: isCompleted ? Colors.green : Colors.grey[400],
            ),
          ],
        ),
      ),
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
          mainAxisAlignment: MainAxisAlignment.spaceAround,
          children: <Widget>[
            IconButton(
              icon: const Icon(Icons.home),
              iconSize: 30.0,
              onPressed: () {
                print("da nhan");
              },
            ),
            IconButton(
              icon: const Icon(Icons.folder),
              iconSize: 30.0,
              onPressed: () {},
            ),
            const SizedBox(width: 50),
            IconButton(
              icon: const Icon(Icons.calendar_today),
              iconSize: 30.0,
              onPressed: () {},
            ),

            // chỗ này cài tạm bấm setting là out ra màn hình ban đầu, để test
            IconButton(
              icon: const Icon(Icons.settings),
              iconSize: 30.0,
              onPressed: () {
                Navigator.pushAndRemoveUntil(
                  context,
                  MaterialPageRoute(builder: (context) => const start()),
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