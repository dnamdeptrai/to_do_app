import 'package:flutter/material.dart';
import '../Controller/AddTaskController.dart';

class AddTaskView extends StatefulWidget {
  final String userEmail;
  final Map<String, dynamic>? taskToEdit;

  const AddTaskView({
    super.key,
    required this.userEmail,
    this.taskToEdit,
  });

  @override
  State<AddTaskView> createState() => _AddTaskViewState();
}

class _AddTaskViewState extends State<AddTaskView> {
  final tasknameCtl = TextEditingController();
  final noteCtl = TextEditingController();

  String? _selectedPriority;
  String? _selectedCategory;
  DateTime? _selectedDate;
  bool _setNotification = false;
  TimeOfDay? _selectedNotificationTime;

  bool get _isEditing => widget.taskToEdit != null;

  final List<String> _priorities = [
    "Rất quan trọng",
    "Quan trọng",
    "Quan trọng ít",
  ];
  final List<String> _category = [
    "Cá nhân",
    "Công việc",
    "Học tập",
    "Gia đình",
    "Giải trí",
    "Khác",
  ];

  @override
  void initState() {
    super.initState();

    if (_isEditing) {
      final task = widget.taskToEdit!;

      tasknameCtl.text = task['taskName'];
      noteCtl.text = task['note'] ?? '';

      _selectedCategory = task['category'];
      _selectedPriority = _reverseMapPriority(task['priority']);
      _selectedDate = DateTime.tryParse(task['createdAt']);
    }
  }

  String _reverseMapPriority(int priority) {
    switch (priority) {
      case 1:
        return "Rất quan trọng";
      case 2:
        return "Quan trọng";
      case 3:
        return "Quan trọng ít";
      default:
        return "Quan trọng ít";
    }
  }

  @override
  void dispose() {
    tasknameCtl.dispose();
    noteCtl.dispose();
    super.dispose();
  }

  Future<void> _pickDate() async {
    DateTime now = DateTime.now();
    final DateTime? picked = await showDatePicker(
      context: context,
      initialDate: _selectedDate ?? now,
      firstDate: DateTime(now.year - 1),
      lastDate: DateTime(now.year + 2),
    );
    if (picked != null) {
      setState(() {
        _selectedDate = picked;
      });
    }
  }

  Future<void> _pickNotificationTime() async {
    if (_selectedDate == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
            content: Text("Bạn phải chọn ngày thực hiện task trước!")),
      );
      return;
    }
    final TimeOfDay? pickedTime = await showTimePicker(
      context: context,
      initialTime: TimeOfDay.now(),
    );

    if (pickedTime != null) {
      setState(() {
        _selectedNotificationTime = pickedTime;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        decoration: const BoxDecoration(
          image: DecorationImage(
            image: AssetImage("assets/img/startbg.jpeg"),
            fit: BoxFit.cover,
          ),
        ),
        child: Center(
          child: SingleChildScrollView(
            padding: const EdgeInsets.all(20),
            child: Column(
              children: [
                Text(
                  _isEditing ? "Sửa Task" : "Thêm Task mới",
                  style: const TextStyle(
                      fontSize: 24, fontWeight: FontWeight.bold),
                ),
                const SizedBox(height: 20),
                TextField(
                  controller: tasknameCtl,
                  decoration: const InputDecoration(
                    prefixIcon: Icon(Icons.task),
                    labelText: "Công việc",
                    border: OutlineInputBorder(),
                  ),
                ),
                const SizedBox(height: 20),
                TextField(
                  controller: noteCtl,
                  decoration: const InputDecoration(
                    prefixIcon: Icon(Icons.note),
                    labelText: "Ghi chú",
                    border: OutlineInputBorder(),
                  ),
                ),
                const SizedBox(height: 20),
                DropdownButtonFormField<String>(
                  value: _selectedCategory,
                  decoration: const InputDecoration(
                    prefixIcon: Icon(Icons.category),
                    labelText: "Phân loại",
                    border: OutlineInputBorder(),
                  ),
                  items: _category.map((category) {
                    return DropdownMenuItem<String>(
                      value: category,
                      child: Text(category),
                    );
                  }).toList(),
                  onChanged: (value) {
                    setState(() {
                      _selectedCategory = value;
                    });
                  },
                ),
                const SizedBox(height: 20),
                DropdownButtonFormField<String>(
                  value: _selectedPriority,
                  decoration: const InputDecoration(
                    prefixIcon: Icon(Icons.flag),
                    labelText: "Mức ưu tiên",
                    border: OutlineInputBorder(),
                  ),
                  items: _priorities.map((priority) {
                    return DropdownMenuItem<String>(
                      value: priority,
                      child: Text(priority),
                    );
                  }).toList(),
                  onChanged: (value) {
                    setState(() {
                      _selectedPriority = value;

                      if (_selectedPriority != "Rất quan trọng") {
                        _setNotification = false;
                        _selectedNotificationTime = null;
                      }
                    });
                  },
                ),
                if (_selectedPriority == "Rất quan trọng") ...[
                  const SizedBox(height: 10),
                  Container(
                    decoration: BoxDecoration(
                      border: Border.all(color: Colors.grey),
                      borderRadius: BorderRadius.circular(8),
                      color: Colors.white.withOpacity(0.8),
                    ),
                    child: Column(
                      children: [
                        SwitchListTile(
                          title: const Text("Đặt thông báo cho task này?"),
                          value: _setNotification,
                          onChanged: (bool value) {
                            setState(() {
                              _setNotification = value;

                              if (!_setNotification) {
                                _selectedNotificationTime = null;
                              } else if (_selectedNotificationTime == null) {
                                _pickNotificationTime();
                              }
                            });
                          },
                        ),
                        if (_setNotification)
                          ListTile(
                            leading: const Icon(Icons.alarm,
                                color: Colors.blueAccent),
                            title: Text(
                              _selectedNotificationTime == null
                                  ? "Chọn giờ thông báo"
                                  : "Thông báo lúc: ${_selectedNotificationTime!.format(context)}",
                              style: TextStyle(
                                  color: _selectedNotificationTime == null
                                      ? Colors.red
                                      : Colors.black),
                            ),
                            trailing:
                                const Icon(Icons.arrow_forward_ios, size: 16),
                            onTap: _pickNotificationTime,
                          ),
                      ],
                    ),
                  ),
                ],
                const SizedBox(height: 20),
                Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 8,
                    vertical: 6,
                  ),
                  decoration: BoxDecoration(
                    border: Border.all(color: Colors.black, width: 1),
                    borderRadius: BorderRadius.circular(8),
                    color: Colors.white,
                  ),
                  child: Row(
                    children: [
                      Expanded(
                        child: Text(
                          _selectedDate == null
                              ? "Chưa chọn ngày"
                              : "Ngày: ${_selectedDate!.day}/${_selectedDate!.month}/${_selectedDate!.year}",
                          style: const TextStyle(fontSize: 16),
                        ),
                      ),
                      IconButton(
                        onPressed: _pickDate,
                        icon: const Icon(Icons.calendar_today),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 30),
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    ElevatedButton(
                      onPressed: () {
                        final controller = AddTaskController(
                          tasknameCtl: tasknameCtl,
                          noteCtl: noteCtl,
                          userEmail: widget.userEmail,
                          taskToEdit: widget.taskToEdit,
                        );
                        controller.selectedCategory = _selectedCategory;
                        controller.selectedPriority = _selectedPriority;
                        controller.selectedDate = _selectedDate;
                        controller.setNotification = _setNotification;
                        controller.notificationTime = _selectedNotificationTime;

                        controller.saveTask(context);
                      },
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.blueAccent,
                        padding: const EdgeInsets.symmetric(
                          horizontal: 40.0,
                          vertical: 15.0,
                        ),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(30.0),
                        ),
                      ),
                      child: Text(
                        _isEditing ? "Cập nhật" : "Tạo Task!",
                        style:
                            const TextStyle(fontSize: 18, color: Colors.white),
                      ),
                    ),
                    const SizedBox(width: 20),
                    ElevatedButton(
                      onPressed: () => Navigator.pop(context),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.white,
                        padding: const EdgeInsets.symmetric(
                          horizontal: 40.0,
                          vertical: 15.0,
                        ),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(30.0),
                        ),
                      ),
                      child: const Text(
                        "Huỷ",
                        style: TextStyle(fontSize: 18, color: Colors.black),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
