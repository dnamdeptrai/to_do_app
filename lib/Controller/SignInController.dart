import 'package:flutter/material.dart';
import 'package:to_do_app/Model/UserDatabase.dart';
import '../View/LogInView.dart';

class SignInController {
  final TextEditingController emailCtl;
  final TextEditingController phoneCtl;
  final TextEditingController passwordCtl;
  final TextEditingController cfPasswordCtl;

  SignInController({
    required this.emailCtl,
    required this.phoneCtl,
    required this.passwordCtl,
    required this.cfPasswordCtl,
  });

  Future<void> signIn(BuildContext context) async {
    if (emailCtl.text.isEmpty ||
        phoneCtl.text.isEmpty ||
        passwordCtl.text.isEmpty ||
        cfPasswordCtl.text.isEmpty) {
      showDialog(
        context: context,
        builder: (context) => AlertDialog(
          title: const Text("Thông báo"),
          content: const Text("Bạn chưa nhập đầy đủ thông tin!"),
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
    bool isValidEmail(String email) {
      if (email.isEmpty) return false;
      final regex = RegExp(r'^[\w-\.]+@([\w-]+\.)+[\w-]{2,4}$');
      return regex.hasMatch(email);
    }

    if (!isValidEmail(emailCtl.text.trim())) {
      showDialog(
        context: context,
        builder: (context) => AlertDialog(
          title: const Text("Thông báo"),
          content: const Text("Email không hợp lệ!"),
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

    if (passwordCtl.text.length < 6) {
      showDialog(
        context: context,
        builder: (context) => AlertDialog(
          title: const Text("Thông báo"),
          content: const Text("Mật khẩu phải có ít nhất 6 ký tự!"),
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

    if (passwordCtl.text != cfPasswordCtl.text) {
      showDialog(
        context: context,
        builder: (context) => AlertDialog(
          title: const Text("Thông báo"),
          content: const Text("Mật khẩu xác nhận không khớp!"),
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

    final db = UserDatabase.instance;
    final existingUser = await db.timbangEmail(emailCtl.text);
    if (existingUser != null) {
      print(existingUser);
      showDialog(
        context: context,
        builder: (context) => AlertDialog(
          title: const Text("Thông báo"),
          content: const Text("Tài khoản đã tồn tại!"),
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

    await db.addUser({
      "email": emailCtl.text.trim(),
      "phone": phoneCtl.text.trim(),
      "password": passwordCtl.text.trim(),
    });

    Navigator.pushAndRemoveUntil(
      context,
      MaterialPageRoute(builder: (_) => const LogInView()),
      (route) => false,
    );
  }
}
