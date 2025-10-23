import 'package:flutter/material.dart';
import '../Model/TaskDatabase.dart';
import 'package:intl/intl.dart';
import 'NotificationsController.dart'; 

class AddTaskController {
  final TextEditingController tasknameCtl;
  final TextEditingController noteCtl;
  String? selectedCategory;
  String? selectedPriority;
  DateTime? selectedDate;
  final String userEmail;

  final Map<String, dynamic>? taskToEdit;
  bool get isEditing => taskToEdit != null;

  bool setNotification = false;
  TimeOfDay? notificationTime;

  AddTaskController({
    required this.tasknameCtl,
    required this.noteCtl,
    required this.userEmail,
    this.taskToEdit, 
  }) {
    if (isEditing) {
      tasknameCtl.text = taskToEdit!['taskName'];
      noteCtl.text = taskToEdit!['note'] ?? '';
    }
  }

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
        selectedDate == null ||
        selectedCategory == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("Vui lòng nhập đầy đủ thông tin")),
      );
      return;
    }
    if (setNotification && notificationTime == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("Vui lòng chọn giờ để đặt thông báo")),
      );
      return;
    }
    final formattedDate = DateFormat("yyyy-MM-dd").format(selectedDate!);
    final task = {
      "userEmail": userEmail,
      "taskName": tasknameCtl.text.trim(),
      "note": noteCtl.text.trim(),
      "priority": _mapPriority(selectedPriority!),
      "isDone": isEditing
          ? taskToEdit!['isDone']
          : 0,
      "createdAt": formattedDate,
      "category": selectedCategory!,
    };

    try {
      int taskId;

      if (isEditing) {
        taskId = taskToEdit!['id'];
        task['id'] = taskId; 
        await NotificationsController().cancelNotification(taskId);
        await TaskDatabase.instance.updateTask(task);
      } else {
        taskId = await TaskDatabase.instance.addTask(task);
      }
      if (selectedPriority == "Rất quan trọng" &&
          setNotification &&
          notificationTime != null) {
        final DateTime scheduledDateTime = DateTime(
          selectedDate!.year,
          selectedDate!.month,
          selectedDate!.day,
          notificationTime!.hour,
          notificationTime!.minute,
        );

        if (scheduledDateTime.isAfter(DateTime.now())) {
          String taskName = tasknameCtl.text.trim();

          await NotificationsController().scheduleOneTimeTaskNotification(
            id: taskId, 
            title: "Nhiệm vụ quan trọng! ⏰",
            body:
                "Nhiệm vụ '$taskName' rất quan trọng cần phải hoàn thành trong hôm nay đó nha!",
            scheduledTime: scheduledDateTime,
          );
        } else if (!isEditing) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
                content: Text(
                    "Đã lưu task, nhưng giờ thông báo ở quá khứ nên đã bỏ qua.")),
          );
        }
      }


      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(
          content: Text(
              isEditing ? "Cập nhật thành công!" : "Thêm task thành công!")));

      Navigator.pop(context);
    } catch (e) {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text("Lỗi khi lưu task: $e")));
    }
  }
}
