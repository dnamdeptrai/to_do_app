import 'package:flutter/material.dart';

class HomeView extends StatelessWidget {
  const HomeView({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF0F5F9), // Background color
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 20.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const SizedBox(height: 20),
              // Header section
              _buildHeader(),
              const SizedBox(height: 10),
              // Date and progress information
              _buildDateAndProgress(),
              const SizedBox(height: 20),
              // Task list
              Expanded(
                child: ListView(
                  children: [
                    _buildTaskItem(
                      icon: Icons.description,
                      title: 'Finish project proposal',
                      isCompleted: true,
                    ),
                    _buildTaskItem(
                      icon: Icons.phone,
                      title: 'Call client for feedback',
                      isCompleted: false,
                    ),
                    _buildTaskItem(
                      icon: Icons.refresh,
                      title: 'Reschedule team meeting',
                      isCompleted: false,
                    ),
                    _buildTaskItem(
                      icon: Icons.shopping_cart,
                      title: 'Buy groceries (milk, eggs, bread)',
                      isCompleted: false,
                    ),
                    _buildTaskItem(
                      icon: Icons.run_circle_outlined,
                      title: 'Go for a 30-minute run',
                      isCompleted: false,
                    ),
                    _buildTaskItem(
                      icon: Icons.book,
                      title: "Read a chapter of 'Atomic Habits'",
                      isCompleted: false,
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
      bottomNavigationBar: _buildBottomNavigationBar(),
      floatingActionButton: FloatingActionButton(
        onPressed: () {},
        backgroundColor: const Color(0xFF4285F4),
        child: const Icon(Icons.add, size: 30),
      ),
      floatingActionButtonLocation: FloatingActionButtonLocation.centerDocked,
    );
  }

  // A reusable widget for the header.
  Widget _buildHeader() {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        const Text(
          'Today',
          style: TextStyle(
            fontSize: 32,
            fontWeight: FontWeight.bold,
          ),
        ),
        Row(
          children: [
            CircleAvatar(
              radius: 20,
              backgroundImage: const NetworkImage(
                'https://i.pravatar.cc/300', // Example image URL
              ),
              backgroundColor: Colors.grey[200],
            ),
            const SizedBox(width: 10),
            Icon(Icons.menu, color: Colors.grey[600]),
          ],
        ),
      ],
    );
  }

  // A reusable widget for the date and progress information.
  Widget _buildDateAndProgress() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: const [
        Text(
          'Wednesday, June 26',
          style: TextStyle(
            fontSize: 16,
            color: Colors.grey,
          ),
        ),
        SizedBox(height: 4),
        Text(
          '2/7 tasks completed',
          style: TextStyle(
            fontSize: 14,
            color: Colors.grey,
          ),
        ),
      ],
    );
  }

  // A reusable widget for each task item.
  Widget _buildTaskItem({
    required IconData icon,
    required String title,
    required bool isCompleted,
  }) {
    return Container(
      margin: const EdgeInsets.symmetric(vertical: 8.0),
      padding: const EdgeInsets.all(16.0),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(15.0),
        boxShadow: [
          BoxShadow(
            color: Colors.grey.withOpacity(0.1),
            spreadRadius: 1,
            blurRadius: 5,
            offset: const Offset(0, 3),
          ),
        ],
      ),
      child: Row(
        children: [
          Icon(icon, color: Colors.grey[600]),
          const SizedBox(width: 15),
          Expanded(
            child: Text(
              title,
              style: TextStyle(
                fontSize: 16,
                decoration: isCompleted ? TextDecoration.lineThrough : null,
                color: isCompleted ? Colors.grey : Colors.black,
              ),
            ),
          ),
          Icon(
            isCompleted ? Icons.check_circle : Icons.circle_outlined,
            color: isCompleted ? Colors.green : Colors.grey[400],
          ),
        ],
      ),
    );
  }

  // A reusable widget for the bottom navigation bar.
  Widget _buildBottomNavigationBar() {
    return BottomAppBar(
      shape: const CircularNotchedRectangle(),
      notchMargin: 8.0,
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceAround,
        children: <Widget>[
          _buildNavItem(Icons.home, 'Today', true),
          _buildNavItem(Icons.folder, 'Projects', false),
          const SizedBox(width: 40), // Space for the FAB
          _buildNavItem(Icons.calendar_today, 'Calendar', false),
          _buildNavItem(Icons.settings, 'Settings', false),
        ],
      ),
    );
  }

  // A reusable widget for each bottom navigation item.
  Widget _buildNavItem(IconData icon, String label, bool isActive) {
    return InkWell(
      onTap: () {},
      child: Padding(
        padding: const EdgeInsets.symmetric(vertical: 10.0),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(
              icon,
              color: isActive ? const Color(0xFF4285F4) : Colors.grey,
            ),
            const SizedBox(height: 4),
            Text(
              label,
              style: TextStyle(
                fontSize: 12,
                color: isActive ? const Color(0xFF4285F4) : Colors.grey,
              ),
            ),
          ],
        ),
      ),
    );
  }
}