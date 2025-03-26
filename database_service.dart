import 'package:sqflite/sqflite.dart';
import 'package:path/path.dart';

class DatabaseService {
  static Database? _database;

  static Future<Database> _getDatabase() async {
    if (_database != null) return _database!;
    _database = await _initDB();
    return _database!;
  }

  static Future<Database> _initDB() async {
    String path = join(await getDatabasesPath(), 'users.db');
    return await openDatabase(
      path,
      version: 1,
      onCreate: (db, version) async {
        await db.execute(
          "CREATE TABLE users (id INTEGER PRIMARY KEY AUTOINCREMENT, email TEXT UNIQUE, pass TEXT)",
        );
      },
    );
  }

  static Future<void> addUser(String email, String pass) async {
    final db = await _getDatabase();
    await db.insert('users', {
      'email': email,
      'pass': pass,
    }, conflictAlgorithm: ConflictAlgorithm.replace);
  }

  static Future<bool> authenticateUser(String email, String pass) async {
    final db = await _getDatabase();
    final List<Map<String, dynamic>> users = await db.query(
      'users',
      where: 'email = ? AND pass = ?',
      whereArgs: [email, pass],
    );
    return users.isNotEmpty;
  }

  static Future<List<Map<String, dynamic>>> getUsers() async {
    final db = await _getDatabase();
    return await db.query('users');
  }
}
