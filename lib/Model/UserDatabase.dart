import 'dart:async';
import 'package:path/path.dart';
import 'package:sqflite/sqflite.dart';

class UserDatabase {
  // singleton
  static final UserDatabase instance = UserDatabase._init();

  static Database? _database;

  UserDatabase._init();

  Future<Database> get database async {
    if (_database != null) return _database!;
    _database = await _initDB("user_database.db");
    return _database!;
  }

  Future<Database> _initDB(String filePath) async {
    final dbPath = await getDatabasesPath();
    final path = join(dbPath, filePath);

    return await openDatabase(path, version: 1, onCreate: _createDB);
  }

  Future _createDB(Database db, int version) async {
    await db.execute('''
      CREATE TABLE users(
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        email TEXT NOT NULL,
        phone TEXT NOT NULL,
        password TEXT NOT NULL
      )
    ''');
  }

  Future<int> addUser(Map<String, dynamic> row) async {
    final db = await instance.database;
    return await db.insert("users", row);
  }

  Future<Map<String, dynamic>?> timbangEmail(String email) async {
    final db = await instance.database;
    final result = await db.query(
      "users",
      where: "email = ?",
      whereArgs: [email],
    );
    return result.isNotEmpty ? result.first : null;
  }
}
