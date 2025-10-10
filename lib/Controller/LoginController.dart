import 'package:flutter/material.dart';
import 'package:to_do_app/Model/UserDatabase.dart';
import 'package:to_do_app/View/HomeView.dart';
import 'package:to_do_app/main.dart';
import 'NotificationsController.dart';

class LoginController {
  final TextEditingController emailCtl;
  final TextEditingController passwordCtl;

  LoginController({required this.emailCtl, required this.passwordCtl});

  Future<void> login(BuildContext context) async {
    String email = emailCtl.text.trim();
    String password = passwordCtl.text.trim();
    bool isValidEmail(String email) {
      if (email.isEmpty) return false;
      final regex = RegExp(r'^[\w-\.]+@([\w-]+\.)+[\w-]{2,4}$');
      return regex.hasMatch(email);
    }

    if (email.isEmpty || password.isEmpty) {
      showDialog(
        context: context,
        builder: (context) => AlertDialog(
          title: const Text("Thông báo"),
          content: const Text("Vui lòng nhập đủ thông tin!"),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: const Text("OK"),
            ),
          ],
        ),
      );
      return;
    }
    final user = await UserDatabase.instance.timbangEmail(email);
    if (!isValidEmail(email)) {
      showDialog(
        context: context,
        builder: (context) => AlertDialog(
          title: const Text("Thông báo"),
          content: const Text("Email bạn nhập không hợp lệ!"),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: const Text("OK"),
            ),
          ],
        ),
      );
      return;
    }
    if (user == null) {
      showDialog(
        context: context,
        builder: (context) => AlertDialog(
          title: const Text("Thông báo"),
          content: const Text("Người dùng không tồn tại!"),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: const Text("OK"),
            ),
          ],
        ),
      );
      return;
    }

    if (user['password'] != password) {
      showDialog(
        context: context,
        builder: (context) => AlertDialog(
          title: const Text("Thông báo"),
          content: const Text("Sai mật khẩu!"),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: const Text("OK"),
            ),
          ],
        ),
      );
      return;
    }
    await NotificationsController().cancelAllNotifications(); 
    await NotificationsController().scheduleDailyNotifications(email); 
    
    Navigator.pushReplacement(
      context,
      MaterialPageRoute(builder: (_) => HomeView(userEmail: email)),
    );
  }

  void back(BuildContext context) {
    ScaffoldMessenger.of(
      context,
    ).showSnackBar(const SnackBar(content: Text("Đã đăng xuất")));
    Navigator.pushAndRemoveUntil(
      context,
      MaterialPageRoute(builder: (_) => const start()),
      (route) => false,
    );
  }
}
