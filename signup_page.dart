import 'package:flutter/material.dart';
import 'db_helper.dart';
import 'records_page.dart';

class SignupPage extends StatelessWidget {
  final email = TextEditingController(), pass = TextEditingController();

  void saveData(BuildContext context) async {
    await DBHelper.addUser(email.text, pass.text);
    Navigator.push(
      context,
      MaterialPageRoute(builder: (_) => RecordsPage()),
    ); // Redirect
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text("Signup")),
      body: Column(
        children: [
          TextField(
            controller: email,
            decoration: InputDecoration(labelText: "Email"),
          ),
          TextField(
            controller: pass,
            decoration: InputDecoration(labelText: "Password"),
            obscureText: true,
          ),
          ElevatedButton(
            onPressed: () => saveData(context),
            child: Text("Submit"),
          ),
        ],
      ),
    );
  }
}
