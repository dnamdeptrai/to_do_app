import 'package:flutter/material.dart';
import 'package:to_do_app/View/CategoryView.dart';
import '../Controller/SettingsController.dart';
import '../View/HomeView.dart';
import '../View/CalendarView.dart';
import 'package:provider/provider.dart';
import '../Controller/ThemeProvider.dart';

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
    final themeProvider = context.watch<ThemeProvider>();
    final isDarkMode = themeProvider.themeMode == ThemeMode.dark;

    return Scaffold(
      appBar: AppBar(
        title: const Text("Cài đặt"),
      ),
      body: ListView(
        children: [
          SwitchListTile(
            thumbIcon: WidgetStatePropertyAll(
                Icon(isDarkMode ? Icons.dark_mode : Icons.light_mode)),
            title: const Text("Chế độ tối"),
            subtitle: const Text("Bật/tắt giao diện dark mode"),
            value: isDarkMode,
            onChanged: (value) {
              themeProvider.toggleTheme(value);
            },
          ),

          SwitchListTile(
            thumbIcon: WidgetStatePropertyAll(Icon(Icons.notification_add)),
            title: const Text("Thông báo"),
            subtitle: const Text("Nhận thông báo nhắc việc"),
            value: controller.notifications, 
            onChanged: (value) {
              controller.toggleNotifications(
                value,
                widget.userEmail,
                () => setState(() {}),
              );
            },
          ),
          ListTile(
            leading: const Icon(Icons.lock),
            title: const Text("Đổi mật khẩu"),
            onTap: () {
             ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(
                    content:
                        Text("Vui lòng đổi mật khẩu ở trang cá nhân (avatar)")),
              );
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
      bottomNavigationBar: _buildBottomNavigationBar(context, 3),
    );
  }

  Widget _buildBottomNavigationBar(BuildContext context, int selectedIndex) { 
    return BottomAppBar(
      shape: const CircularNotchedRectangle(),
      notchMargin: 10.0,
      child: SizedBox(
        height: 50.0,
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceAround,
          children: <Widget>[
            IconButton(
              icon: Icon(
                Icons.home,
                color: selectedIndex == 0 ? Colors.blueAccent : null,
              ),
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
              icon: Icon(
                Icons.folder,
                color: selectedIndex == 1 ? Colors.blueAccent : null,
              ),
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
              icon: Icon(
                Icons.calendar_today,
                color: selectedIndex == 2 ? Colors.blueAccent : null,
              ),
              iconSize: 30.0,
              onPressed: () {
                Navigator.pushAndRemoveUntil(
                  context,
                  MaterialPageRoute(
                    builder: (context) =>
                        CalendarView(userEmail: widget.userEmail),
                  ),
                  (route) => false,
                );
              },
            ),

            IconButton(
              icon: Icon(
                Icons.settings,
                color: selectedIndex == 3 ? Colors.blueAccent : null,
              ),
              iconSize: 30.0,
              onPressed: () {}, // Đang ở Settings, không cần điều hướng
            ),
          ],
        ),
      ),
    );
  }
}