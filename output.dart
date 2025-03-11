import 'package:flutter/material.dart';

class Output extends StatelessWidget {
  final List<Map<String, dynamic>> users;
  final Function(int) onDelete;

  Output({required this.users, required this.onDelete});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('User Data', style: TextStyle(color: Colors.white)),
        backgroundColor: Colors.blueAccent,
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: users.isEmpty
            ? Center(
                child: Text(
                  "No Data Available",
                  style: TextStyle(fontSize: 18, color: Colors.grey),
                ),
              )
            : Card(
                elevation: 5,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(15),
                ),
                child: SingleChildScrollView(
                  scrollDirection: Axis.horizontal,
                  child: DataTable(
                    columnSpacing: 20,
                    headingRowColor:
                        MaterialStateProperty.all(Colors.blue.shade100),
                    dataRowColor:
                        MaterialStateProperty.all(Colors.blue.shade50),
                    border: TableBorder.all(color: Colors.blueAccent),
                    columns: [
                      DataColumn(
                        label: Text('Name',
                            style: TextStyle(fontWeight: FontWeight.bold)),
                      ),
                      DataColumn(
                        label: Text('Email',
                            style: TextStyle(fontWeight: FontWeight.bold)),
                      ),
                      DataColumn(
                        label: Text('Password',
                            style: TextStyle(fontWeight: FontWeight.bold)),
                      ),
                      DataColumn(
                        label: Text('Status',
                            style: TextStyle(fontWeight: FontWeight.bold)),
                      ),
                      DataColumn(
                        label: Text('Actions',
                            style: TextStyle(fontWeight: FontWeight.bold)),
                      ),
                    ],
                    rows: List.generate(users.length, (index) {
                      var user = users[index];
                      return DataRow(
                        cells: [
                          DataCell(Text(user['name']!)),
                          DataCell(Text(user['email']!)),
                          DataCell(Text(user['password']!)),
                          DataCell(
                            Icon(
                              user['isActive']
                                  ? Icons.check_circle
                                  : Icons.cancel,
                              color:
                                  user['isActive'] ? Colors.green : Colors.red,
                            ),
                          ),
                          DataCell(
                            IconButton(
                              icon: Icon(Icons.delete, color: Colors.redAccent),
                              onPressed: () {
                                onDelete(index);
                                Navigator.pop(context);
                              },
                            ),
                          ),
                        ],
                      );
                    }),
                  ),
                ),
              ),
      ),
    );
  }
}
