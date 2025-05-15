import 'package:flutter/material.dart';
import 'package:sqflite/sqflite.dart';
import 'package:path/path.dart';

void main() =>
    runApp(MaterialApp(home: MyApp(), debugShowCheckedModeBanner: false));

class MyApp extends StatefulWidget {
  @override
  State<MyApp> createState() => _MyAppState();
}

class _MyAppState extends State<MyApp> {
  TextEditingController ctrl = TextEditingController();
  List<String> items = [];
  late Database db;

  @override
  void initState() {
    super.initState();
    initDb();
  }

  Future<void> initDb() async {
    String path = join(await getDatabasesPath(), 'my.db');
    db = await openDatabase(
      path,
      version: 1,
      onCreate:
          (db, v) => db.execute(
            'CREATE TABLE data (id INTEGER PRIMARY KEY, text TEXT)',
          ),
    );
    fetchData();
  }

  Future<void> save(String text) async {
    if (text.isEmpty) return;
    await db.insert('data', {'text': text});
    ctrl.clear();
    fetchData();
  }

  Future<void> fetchData() async {
    final data = await db.query('data');
    setState(() {
      items = data.map((e) => e['text'].toString()).toList();
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text('Save Text to SQLite')),
      body: Padding(
        padding: EdgeInsets.all(16),
        child: Column(
          children: [
            TextField(
              controller: ctrl,
              decoration: InputDecoration(hintText: 'Enter text'),
            ),
            ElevatedButton(
              onPressed: () => save(ctrl.text),
              child: Text('Save'),
            ),
            Expanded(
              child: ListView.builder(
                itemCount: items.length,
                itemBuilder: (_, i) => ListTile(title: Text(items[i])),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
