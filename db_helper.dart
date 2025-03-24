import 'package:sqflite/sqflite.dart';
import 'package:path/path.dart';

class DBHelper {
  static Future<Database> _db() async => openDatabase(
    join(await getDatabasesPath(), 'users.db'),
    version: 1,
    onCreate:
        (db, version) => db.execute(
          "CREATE TABLE users (id INTEGER PRIMARY KEY, email TEXT, pass TEXT)",
        ),
  );

  static Future<void> addUser(String email, String pass) async =>
      (await _db()).insert('users', {'email': email, 'pass': pass});
  static Future<List<Map<String, dynamic>>> getUsers() async =>
      (await _db()).query('users');
}
