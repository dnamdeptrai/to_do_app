import 'package:flutter/material.dart';
import '../Model/UserDatabase.dart';

class ProfileController {
  final String userEmail;
  Map<String, dynamic>? userData;

  final phoneCtl = TextEditingController();
  final passwordCtl = TextEditingController();
  final cfPasswordCtl = TextEditingController();

  ProfileController(this.userEmail);
  Future<void> loadUserData() async {
    userData = await UserDatabase.instance.timbangEmail(userEmail);
    if (userData != null) {
      phoneCtl.text = userData!['phone'] ?? '';
    }
  }

  Future<void> updateProfile(BuildContext context) async {
    if (phoneCtl.text.isEmpty) {
      _showError(context, "Số điện thoại không được để trống!");
      return;
    }

    Map<String, dynamic> dataToUpdate = {
      'phone': phoneCtl.text.trim(),
    };
    if (passwordCtl.text.isNotEmpty) {
      if (passwordCtl.text.length < 6) {
        _showError(context, "Mật khẩu mới phải có ít nhất 6 ký tự!");
        return;
      }
      if (passwordCtl.text != cfPasswordCtl.text) {
        _showError(context, "Mật khẩu xác nhận không khớp!");
        return;
      }
      dataToUpdate['password'] = passwordCtl.text.trim();
    }
    try {
      await UserDatabase.instance.updateUser(userEmail, dataToUpdate);
      
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text("Cập nhật thông tin thành công!"),
          backgroundColor: Colors.green,
        ),
      );
      
      Navigator.pop(context); 
      
    } catch (e) {
      _showError(context, "Lỗi khi cập nhật: $e");
    }
  }

  void _showError(BuildContext context, String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        backgroundColor: Colors.red,
      ),
    );
  }

  void dispose() {
    phoneCtl.dispose();
    passwordCtl.dispose();
    cfPasswordCtl.dispose();
  }
}