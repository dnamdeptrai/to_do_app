import 'package:flutter/material.dart';
import '../Controller/ProfileController.dart';

class ProfileDrawerView extends StatefulWidget {
  final String userEmail;
  const ProfileDrawerView({super.key, required this.userEmail});

  @override
  State<ProfileDrawerView> createState() => _ProfileDrawerViewState();
}

class _ProfileDrawerViewState extends State<ProfileDrawerView> {
  late ProfileController _controller;
  bool _isLoading = true;
  bool _isEditing = false;

  @override
  void initState() {
    super.initState();
    _controller = ProfileController(widget.userEmail);
    _loadData();
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  Future<void> _loadData() async {
    await _controller.loadUserData();
    if (mounted) {
      setState(() {
        _isLoading = false;
      });
    }
  }

  InputDecoration _fieldDecoration(String label, IconData icon) {
    return InputDecoration(
      prefixIcon: Icon(icon, color: Colors.grey.shade600),
      labelText: label,
      filled: true,
      fillColor: _isEditing ? Colors.white : Colors.grey.shade100,
      border: OutlineInputBorder(
        borderRadius: BorderRadius.circular(10),
        borderSide: BorderSide(color: Colors.grey.shade300),
      ),
      enabledBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(10),
        borderSide: BorderSide(color: Colors.grey.shade300),
      ),
      focusedBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(10),
        borderSide: const BorderSide(color: Colors.blueAccent, width: 2),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Drawer(
      child: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : ListView(
              padding: EdgeInsets.zero,
              children: [
                _buildDrawerHeader(),
                _buildForm(context),
              ],
            ),
    );
  }

  Widget _buildDrawerHeader() {
    final String firstLetter =
        widget.userEmail.isNotEmpty ? widget.userEmail[0].toUpperCase() : "?";

    return DrawerHeader(
      decoration: const BoxDecoration(
        color: Colors.blueAccent,
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisAlignment: MainAxisAlignment.end,
        children: [
          CircleAvatar(
            radius: 30,
            backgroundColor: Colors.white,
            child: Text(
              firstLetter,
              style: TextStyle(
                fontSize: 28,
                fontWeight: FontWeight.bold,
                color: Colors.blueAccent.shade700,
              ),
            ),
          ),
          const SizedBox(height: 10),
          Text(
            widget.userEmail,
            style: const TextStyle(
              color: Colors.white,
              fontSize: 16,
              fontWeight: FontWeight.bold,
            ),
          ),
          Text(
            _controller.phoneCtl.text,
            style: const TextStyle(
              color: Colors.white70,
              fontSize: 14,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildForm(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(16.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          const Text(
            "Thông tin tài khoản",
            style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 15),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 16),
            decoration: BoxDecoration(
              color: Colors.grey.shade100,
              borderRadius: BorderRadius.circular(10),
              border: Border.all(color: Colors.grey.shade300),
            ),
            child: Row(
              children: [
                Icon(Icons.email_outlined, color: Colors.grey.shade600),
                const SizedBox(width: 12),
                Expanded(
                  child: Text(
                    widget.userEmail,
                    style: const TextStyle(fontSize: 16, color: Colors.black87),
                    overflow: TextOverflow.ellipsis,
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 15),
          TextField(
            controller: _controller.phoneCtl,
            enabled: _isEditing,
            keyboardType: TextInputType.phone,
            decoration: _fieldDecoration("Số điện thoại", Icons.phone_outlined),
          ),
          const SizedBox(height: 10),
          if (_isEditing) ...[
            const Divider(height: 30),
            const Text(
              "Đổi mật khẩu (Bỏ trống nếu không đổi)",
              style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 15),
            TextField(
              controller: _controller.passwordCtl,
              obscureText: true,
              decoration: _fieldDecoration("Mật khẩu mới", Icons.lock_outline),
            ),
            const SizedBox(height: 15),
            TextField(
              controller: _controller.cfPasswordCtl,
              obscureText: true,
              decoration: _fieldDecoration(
                  "Xác nhận mật khẩu", Icons.lock_person_outlined),
            ),
          ],
          const SizedBox(height: 30),
          _isEditing
              ? ElevatedButton.icon(
                  onPressed: () async {
                    await _controller.updateProfile(context);
                    setState(() {
                      _isEditing = false;
                    });
                  },
                  icon: const Icon(Icons.save, color: Colors.white),
                  label: const Text(
                    "Lưu thay đổi",
                    style: TextStyle(fontSize: 18, color: Colors.white),
                  ),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.green,
                    padding: const EdgeInsets.symmetric(vertical: 15),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(30),
                    ),
                  ),
                )
              : ElevatedButton.icon(
                  onPressed: () {
                    setState(() {
                      _isEditing = true;
                    });
                  },
                  icon: const Icon(Icons.edit, color: Colors.white),
                  label: const Text(
                    "Sửa thông tin",
                    style: TextStyle(fontSize: 18, color: Colors.white),
                  ),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.blueAccent,
                    padding: const EdgeInsets.symmetric(vertical: 15),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(30),
                    ),
                  ),
                ),
        ],
      ),
    );
  }
}
