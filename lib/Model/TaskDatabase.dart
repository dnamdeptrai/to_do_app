import 'dart:async';
import 'package:path/path.dart';
import 'package:sqflite/sqflite.dart';

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
    return await db.query(
      "tasks",
      where: "userEmail = ?",
      whereArgs: [currentUserEmail],
      orderBy: "priority ASC, createdAt DESC",
    );
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
