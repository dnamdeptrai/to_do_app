import 'package:flutter/material.dart';
import 'package:to_do_app/View/CategoryView.dart';
import '../Controller/SettingsController.dart';
import '../View/HomeView.dart';
import '../View/CalendarView.dart';
import '../View/CategoryView.dart';

class SettingsView extends StatefulWidget {
  final String userEmail;
  const SettingsView({super.key, required this.userEmail});

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
        backgroundColor: const Color.fromARGB(255, 255, 255, 255),
      ),
      body: ListView(
        children: [
          SwitchListTile(
            thumbIcon: WidgetStatePropertyAll(Icon(Icons.dark_mode)),
            title: const Text("Chế độ tối"),
            subtitle: const Text("Bật/tắt giao diện dark mode"),
            value: controller.darkMode,
            onChanged: (value) {
              controller.toggleDarkMode(value, () => setState(() {}));
            },
          ),
          SwitchListTile(
            thumbIcon: WidgetStatePropertyAll(Icon(Icons.notification_add)),
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
      bottomNavigationBar: _buildBottomNavigationBar(context),
    );
  }

  Widget _buildBottomNavigationBar(BuildContext context) {
    return BottomAppBar(
      color: Colors.white,
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
                Navigator.pushAndRemoveUntil(
                  context,
                  MaterialPageRoute(
                    builder: (context) => HomeView(userEmail: widget.userEmail),
                  ),
                  (route) => false,
                );
              },
            ),

            IconButton(
              icon: const Icon(Icons.folder),
              iconSize: 30.0,
              onPressed: () {
                Navigator.pushAndRemoveUntil(
                  context,
                  MaterialPageRoute(
                    builder: (context) =>
                        CategoryView(userEmail: widget.userEmail),
                  ),
                  (route) => false,
                );
              },
            ),

            IconButton(
              icon: const Icon(Icons.calendar_today),
              iconSize: 30.0,
              onPressed: () {
                Navigator.pushAndRemoveUntil(
                  context,
                  MaterialPageRoute(
                    builder: (context) =>
                        CategoryView(userEmail: widget.userEmail),
                  ),
                  (route) => false,
                );
              },
            ),

            IconButton(
              icon: const Icon(Icons.settings),
              iconSize: 30.0,
              onPressed: () {
              },
            ),
          ],
        ),
      ),
    );
  }
}
