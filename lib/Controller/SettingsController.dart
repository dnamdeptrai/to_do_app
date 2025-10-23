import 'package:flutter/material.dart';
import '../Model/UserDatabase.dart';
import '../View/LogInView.dart';
import 'NotificationsController.dart';

class SettingsController {
  static final SettingsController _instance = SettingsController._internal();
  factory SettingsController() => _instance;
  SettingsController._internal();
  
  bool notifications = true;

  void toggleNotifications(
    bool value,
    String userEmail,
    VoidCallback onUpdate,
  ) {
    notifications = value;
    if (notifications) {
      NotificationsController().scheduleDailyNotifications(userEmail);
    } else {
      NotificationsController().cancelAllNotifications();
    }
    onUpdate();
  }

  Future<void> changePassword(
    BuildContext context,
    String email,
    String newPassword,
  ) async {
    final db = await UserDatabase.instance.database;

    final user = await UserDatabase.instance.timbangEmail(email);
    if (user == null) {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(const SnackBar(content: Text("Không tìm thấy tài khoản")));
      return;
    }

    await db.update(
      "users",
      {"password": newPassword},
      where: "email = ?",
      whereArgs: [email],
    );

    ScaffoldMessenger.of(
      context,
    ).showSnackBar(const SnackBar(content: Text("Đổi mật khẩu thành công")));
  }

  void logout(BuildContext context) {
    ScaffoldMessenger.of(
      context,
    ).showSnackBar(const SnackBar(content: Text("Đã đăng xuất")));
    Navigator.pushAndRemoveUntil(
      context,
      MaterialPageRoute(builder: (_) => const LogInView()),
      (route) => false,
    );
  }
}