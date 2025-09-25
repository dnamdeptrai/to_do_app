import 'package:flutter/material.dart';
import '../Controller/SettingsController.dart';

class SettingsView extends StatefulWidget {
  const SettingsView({super.key});

  @override
  State<SettingsView> createState() => _SettingsScreenState();
}

class _SettingsScreenState extends State<SettingsView> {
  final SettingsController controller = SettingsController();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Cài đặt"),
        backgroundColor: Colors.blue,
      ),
      body: ListView(
        children: [
          SwitchListTile(
            title: const Text("Chế độ tối"),
            subtitle: const Text("Bật/tắt giao diện dark mode"),
            value: controller.darkMode,
            onChanged: (value) {
              controller.toggleDarkMode(value, () => setState(() {}));
            },
          ),
          SwitchListTile(
            title: const Text("Thông báo"),
            subtitle: const Text("Nhận thông báo nhắc việc"),
            value: controller.notifications,
            onChanged: (value) {
              controller.toggleNotifications(value, () => setState(() {}));
            },
          ),
          ListTile(
            leading: const Icon(Icons.lock),
            title: const Text("Đổi mật khẩu"),
            onTap: () {
              controller.changePassword(context, "test@gmail.com", "123456");
            },
          ),
          ListTile(
            leading: const Icon(Icons.logout),
            title: const Text("Đăng xuất"),
            onTap: () {
              controller.logout(context);
            },
          ),
          ListTile(
            leading: const Icon(Icons.info),
            title: const Text("Giới thiệu ứng dụng"),
            onTap: () {
              showAboutDialog(
                context: context,
                applicationName: "ToDo App",
                applicationVersion: "1.0.0",
                children: [const Text("Ứng dụng quản lý công việc hằng ngày.")],
              );
            },
          ),
        ],
      ),
    );
  }
}
