import 'package:flutter/material.dart';
import '../Controller/AddTaskController.dart';

class AddTaskView extends StatefulWidget {
  final String userEmail;
  const AddTaskView({super.key, required this.userEmail});

  @override
  State<AddTaskView> createState() => _AddTaskViewState();
}

class _AddTaskViewState extends State<AddTaskView> {
  final tasknameCtl = TextEditingController();
  final noteCtl = TextEditingController();

  String? _selectedPriority;
  DateTime? _selectedDate;

  final List<String> _priorities = [
    "Rất quan trọng",
    "Quan trọng",
    "Quan trọng ít",
  ];

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
      initialDate: now,
      firstDate: DateTime(now.year - 1),
      lastDate: DateTime(now.year + 2),
    );
    if (picked != null) {
      setState(() {
        _selectedDate = picked;
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
                const Text(
                  "Thêm công việc mới",
                  style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
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
                    });
                  },
                ),
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
                        );
                        controller.selectedPriority = _selectedPriority;
                        controller.selectedDate = _selectedDate;
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
                      child: const Text(
                        "Tạo Task!",
                        style: TextStyle(fontSize: 18, color: Colors.white),
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
