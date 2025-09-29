import 'dart:async';
import 'package:path/path.dart';
import 'package:sqflite/sqflite.dart';
import 'package:intl/intl.dart';

class TaskDatabase {
  TaskDatabase._privateConstructor();
  static final TaskDatabase instance = TaskDatabase._privateConstructor();

  static Database? _database;
  static String? currentUserEmail;

  Future<Database> get database async {
    if (_database != null) return _database!;
    _database = await _initDB("task_database.db");
    return _database!;
  }

  Future<Database> _initDB(String filePath) async {
    final dbPath = await getDatabasesPath();
    final path = join(dbPath, filePath);

    return await openDatabase(path, version: 1, onCreate: _createDB);
  }

  Future _createDB(Database db, int version) async {
    await db.execute('''
      CREATE TABLE tasks(
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        userEmail TEXT NOT NULL,
        taskName TEXT NOT NULL,
        note TEXT,
        priority INTEGER NOT NULL, -- 1: Rất quan trọng, 2: Quan trọng, 3: Ít quan trọng
        isDone INTEGER NOT NULL,
        createdAt TEXT NOT NULL
      )
    ''');
  }

  static void setCurrentUser(String email) {
    currentUserEmail = email;
  }

  Future<int> addTask(Map<String, dynamic> task) async {
    final db = await instance.database;
    if (currentUserEmail == null) {
      throw Exception("Chưa xác định user hiện tại");
    }
    task["userEmail"] = currentUserEmail;
    return await db.insert("tasks", task);
  }

  Future<List<Map<String, dynamic>>> getTasks() async {
    final db = await instance.database;
    if (currentUserEmail == null) {
      throw Exception("Chưa xác định user hiện tại");
    }

    final todayDateKey = DateFormat("yyyy-MM-dd").format(DateTime.now());

    return await db.query(
      "tasks",
      where: "userEmail = ? AND createdAt = ?",
      whereArgs: [currentUserEmail, todayDateKey],
      orderBy:
          "priority ASC, createdAt DESC",
    );
  }
  Future<List<Map<String, dynamic>>> getTasksByDate(String dateKey) async {
    final db = await instance.database;
    if (currentUserEmail == null) {
      throw Exception("Chưa xác định user hiện tại");
    }
    return await db.query(
      "tasks",
      where: "userEmail = ? AND createdAt = ?",
      whereArgs: [currentUserEmail, dateKey],
      orderBy: "priority ASC, createdAt DESC",
    );
  }
  Future<double> getTaskProgressForDate(String dateKey) async {
    final tasks = await getTasksByDate(dateKey);
    
    if (tasks.isEmpty) return 0.0;
    
    final total = tasks.length;
    final done = tasks.where((t) => t["isDone"] == 1).length;
    
    // Trả về tỷ lệ hoàn thành (0.0 đến 1.0)
    return done / total; 
  }

  Future<int> updateTask(Map<String, dynamic> task) async {
    final db = await instance.database;
    return await db.update(
      "tasks",
      task,
      where: "id = ? AND userEmail = ?",
      whereArgs: [task["id"], currentUserEmail],
    );
  }

  Future<int> deleteTask(int id) async {
    final db = await instance.database;
    return await db.delete(
      "tasks",
      where: "id = ? AND userEmail = ?",
      whereArgs: [id, currentUserEmail],
    );
  }
}
