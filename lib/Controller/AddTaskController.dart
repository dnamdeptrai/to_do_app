import 'package:flutter/material.dart';
import '../Model/TaskDatabase.dart';

class AddTaskController {
  final TextEditingController tasknameCtl;
  final TextEditingController noteCtl;
  String? selectedPriority;
  DateTime? selectedDate;
  final String userEmail; 

  AddTaskController({
    required this.tasknameCtl,
    required this.noteCtl,
    required this.userEmail,
  });

  int _mapPriority(String priority) {
    switch (priority) {
      case "Rất quan trọng":
        return 1;
      case "Quan trọng":
        return 2;
      case "Quan trọng ít":
        return 3;
      default:
        return 3;
    }
  }

  Future<void> saveTask(BuildContext context) async {
    if (tasknameCtl.text.isEmpty ||
        selectedPriority == null ||
        selectedDate == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("Vui lòng nhập đầy đủ thông tin")),
      );
      return;
    }

    final task = {
      "userEmail": userEmail,
      "taskName": tasknameCtl.text.trim(),
      "note": noteCtl.text.trim(),
      "priority": _mapPriority(selectedPriority!),
      "isDone": 0,
      "createdAt": selectedDate!.toIso8601String(),
    };

    try {
      await TaskDatabase.instance.addTask(task);

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("Thêm task thành công")),
      );

      Navigator.pop(context); 
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text("Lỗi khi thêm task: $e")),
      );
    }
  }
}
