import 'package:flutter/material.dart';
import 'db_helper.dart';

class RecordsPage extends StatefulWidget {
  @override
  _RecordsPageState createState() => _RecordsPageState();
}

class _RecordsPageState extends State<RecordsPage> {
  List<Map<String, dynamic>> users = [];

  void loadRecords() async {
    users = await DBHelper.getUsers();
    setState(() {});
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text("Records")),
      body: Column(
        children: [
          ElevatedButton(onPressed: loadRecords, child: Text("Show Records")),
          Expanded(
            child: ListView(
              children:
                  users
                      .map(
                        (u) => ListTile(
                          title: Text(u['email']),
                          subtitle: Text(u['pass']),
                        ),
                      )
                      .toList(),
            ),
          ),
        ],
      ),
    );
  }
}
