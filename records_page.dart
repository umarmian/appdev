import 'package:flutter/material.dart';
import 'database_service.dart';

class RecordsPage extends StatefulWidget {
  @override
  _RecordsPageState createState() => _RecordsPageState();
}

class _RecordsPageState extends State<RecordsPage> {
  List<Map<String, dynamic>> users = [];

  void fetchUsers() async {
    final data = await DatabaseService.getUsers();
    setState(() {
      users = data;
    });
  }

  @override
  void initState() {
    super.initState();
    fetchUsers();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text("User Records")),
      body:
          users.isEmpty
              ? Center(child: CircularProgressIndicator())
              : ListView.builder(
                itemCount: users.length,
                itemBuilder: (context, index) {
                  return Card(
                    margin: EdgeInsets.all(10),
                    child: ListTile(
                      leading: Icon(Icons.person),
                      title: Text(users[index]['email']),
                    ),
                  );
                },
              ),
    );
  }
}
