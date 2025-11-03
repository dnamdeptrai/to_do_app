import 'package:flutter/material.dart';
import '../Controller/CategoryController.dart';
import '../View/HomeView.dart';
import '../View/SettingView.dart';
import '../View/CalendarView.dart';
import '../View/ProfileDrawerView.dart'; 

class CategoryView extends StatefulWidget {
  final String userEmail;
  const CategoryView({super.key, required this.userEmail});

  @override
  State<CategoryView> createState() => _CategoryViewState();
}

class _CategoryViewState extends State<CategoryView> {
  late CategoryController _controller;
  late Future<void> _loadingFuture;
  String _progressText = "Đang tải tiến độ...";

  final TextEditingController _searchCtl = TextEditingController();

  @override
  void initState() {
    super.initState();
    _controller = CategoryController(userEmail: widget.userEmail);
    _loadingFuture = _loadTasksAndProgress();

    _searchCtl.addListener(_onSearchChanged);
  }

  void _onSearchChanged() {
    _controller.filterTasks(_searchCtl.text);
    setState(() {});
  }

  @override
  void dispose() {
    _searchCtl.removeListener(_onSearchChanged);
    _searchCtl.dispose();
    super.dispose();
  }

  Future<void> _loadTasksAndProgress() async {
    await _controller.loadAndGroupTasks();
    if (mounted) {
      setState(() {
        _progressText = _controller.getProgressText();
      });
    }
  }

  Future<void> _toggleTask(Map<String, dynamic> task) async {
    await _controller.toggleTaskCompletion(task);
    await _loadTasksAndProgress();
    _controller.filterTasks(_searchCtl.text);
    
    if (mounted) {
      setState(() {
        _progressText = _controller.getProgressText();
      });
    }
  }

  Widget _buildHeader(BuildContext context, String userEmail) { 
    final String firstLetter = userEmail.isNotEmpty ? userEmail[0].toUpperCase() : "?";
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text( 
          "Phân loại",
          style: Theme.of(context).textTheme.titleLarge?.copyWith(
            fontWeight: FontWeight.bold,
            fontSize: 32,
          ),
        ),
        GestureDetector( 
          onTap: () {
            Scaffold.of(context).openEndDrawer(); 
          },
          child: CircleAvatar(
            radius: 20,
            backgroundColor: Colors.blueAccent.shade700,
            child: Text(
              firstLetter,
              style: const TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.bold,
                color: Colors.white, 
              ),
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildDateAndProgress(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          _controller.getFormattedDate(),
          style: Theme.of(context).textTheme.bodyMedium?.copyWith(
            color: Theme.of(context).brightness == Brightness.dark ? Colors.white70 : Colors.grey,
          ),
        ),
        const SizedBox(height: 4),
        Text(
          _progressText,
          style: Theme.of(context).textTheme.bodySmall?.copyWith(
            color: Theme.of(context).brightness == Brightness.dark ? Colors.white60 : Colors.grey,
          ),
        ),
      ],
    );
  }
  Widget _buildTaskItem(BuildContext context, Map<String, dynamic> task) { 
    final isDone = task["isDone"] == 1;
    final theme = Theme.of(context);
    final isDarkMode = theme.brightness == Brightness.dark;

    return GestureDetector(
      onTap: () => _toggleTask(task),
      child: Container(
        margin: const EdgeInsets.symmetric(vertical: 4.0),
        padding: const EdgeInsets.all(16.0),
        decoration: BoxDecoration(
          color: isDarkMode ? Colors.grey[800] : Colors.white, 
          borderRadius: BorderRadius.circular(15.0),
          boxShadow: [
            BoxShadow(
              color: isDarkMode ? Colors.black.withOpacity(0.3) : Colors.grey.withOpacity(0.1),
              spreadRadius: 1,
              blurRadius: 5,
              offset: const Offset(0, 3),
            ),
          ],
        ),
        child: Row(
          children: [
            Icon(
              Icons.task,
              color: isDarkMode ? Colors.blueAccent.shade200 : Colors.blueAccent, 
            ),
            const SizedBox(width: 15),
            Expanded(
              child: Text(
                task["taskName"],
                style: TextStyle(
                  fontSize: 16,
                  decoration: isDone ? TextDecoration.lineThrough : null,
                  color: isDone 
                      ? (isDarkMode ? Colors.white54 : Colors.grey) 
                      : (isDarkMode ? Colors.white : Colors.black),
                ),
              ),
            ),
            Icon(
              isDone
                  ? Icons.check_circle 
                  : Icons.circle_outlined, 
              color: isDone ? Colors.green : (isDarkMode ? Colors.grey[600] : Colors.grey[400]), 
            ),
          ],
        ),
      ),
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
                color: selectedIndex == 0 ? Colors.blueAccent : Theme.of(context).iconTheme.color, 
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
                color: selectedIndex == 1 ? Colors.blueAccent : Theme.of(context).iconTheme.color, 
              ),
              iconSize: 30.0,
              onPressed: () {}, 
            ),

            IconButton(
              icon: Icon(
                Icons.calendar_today,
                color: selectedIndex == 2 ? Colors.blueAccent : Theme.of(context).iconTheme.color, 
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
                color: selectedIndex == 3 ? Colors.blueAccent : Theme.of(context).iconTheme.color, 
              ),
              iconSize: 30.0,
              onPressed: () {
                Navigator.pushAndRemoveUntil(
                  context,
                  MaterialPageRoute(
                    builder: (context) =>
                        SettingsView(userEmail: widget.userEmail),
                  ),
                  (route) => false,
                );
              },
            ),
          ],
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDarkMode = theme.brightness == Brightness.dark;

    return Scaffold(
      backgroundColor: theme.scaffoldBackgroundColor,
      endDrawer: ProfileDrawerView(userEmail: widget.userEmail), 
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 20.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const SizedBox(height: 20),
              _buildHeader(context, widget.userEmail), 
              const SizedBox(height: 10),
              _buildDateAndProgress(context), 
              Padding(
                padding: const EdgeInsets.symmetric(vertical: 12.0),
                child: TextField(
                  controller: _searchCtl,
                  decoration: InputDecoration(
                    hintText: "Tìm kiếm task...",
                    hintStyle: TextStyle(color: isDarkMode ? Colors.white54 : Colors.grey), 
                    prefixIcon: Icon(Icons.search, color: isDarkMode ? Colors.white70 : Colors.grey), 
                    suffixIcon: _searchCtl.text.isNotEmpty
                        ? IconButton(
                            icon: Icon(Icons.clear, color: isDarkMode ? Colors.white70 : Colors.grey), 
                            onPressed: () {
                              _searchCtl.clear();
                            },
                          )
                        : null,
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(30.0),
                      borderSide: BorderSide.none,
                    ),
                    filled: true,
                    fillColor: isDarkMode ? Colors.grey[800] : Colors.white, 
                    contentPadding: const EdgeInsets.symmetric(vertical: 0, horizontal: 20),
                  ),
                  style: TextStyle(color: isDarkMode ? Colors.white : Colors.black), 
                ),
              ),

              Expanded(
                child: FutureBuilder(
                  future: _loadingFuture,
                  builder: (context, snapshot) {
                    if (snapshot.connectionState == ConnectionState.waiting) {
                      return const Center(child: CircularProgressIndicator());
                    }
                    if (_controller.activeCategories.isEmpty) {
                      return Center(
                        child: Text(
                          "Chưa có công việc nào cần hoàn thành hôm nay.",
                          style: theme.textTheme.bodyMedium?.copyWith(
                            color: isDarkMode ? Colors.white70 : Colors.grey,
                          ),
                        ),
                      );
                    }

                    if (_controller.filteredGroupedTasks.isEmpty && _searchCtl.text.isNotEmpty) {
                       return Center(
                        child: Text(
                          "Không tìm thấy task nào.",
                          style: theme.textTheme.bodyMedium?.copyWith(
                            color: isDarkMode ? Colors.white70 : Colors.grey,
                          ),
                        ),
                      );
                    }

                    final filteredCategories = _controller.filteredGroupedTasks.keys.toList();

                    return ListView.builder(
                      itemCount: filteredCategories.length,
                      itemBuilder: (context, index) {
                        final category = filteredCategories[index];
                        final tasks = _controller.filteredGroupedTasks[category]!;

                        return Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Padding(
                              padding: const EdgeInsets.only(
                                top: 16.0,
                                bottom: 8.0,
                              ),
                              child: Text(
                                "$category:",
                                style: theme.textTheme.titleMedium?.copyWith( 
                                  fontWeight: FontWeight.bold,
                                  color: isDarkMode ? Colors.white : Colors.black87,
                                ),
                              ),
                            ),
                            ...tasks
                                .map((task) => _buildTaskItem(context, task)) 
                          ],
                        );
                      },
                    );
                  },
                ),
              ),
            ],
          ),
        ),
      ),
      bottomNavigationBar: _buildBottomNavigationBar(context, 1),
    );
  }
}