import 'package:flutter/material.dart';
import 'login_page.dart';
import 'database_service.dart';

class HomePage extends StatefulWidget {
  @override
  _HomePageState createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  String userEmail = "";

  void getUserData() async {
    final users = await DatabaseService.getUsers();
    if (users.isNotEmpty) {
      setState(() {
        userEmail = users.last['email']; // Display the last registered user
      });
    }
  }

  @override
  void initState() {
    super.initState();
    getUserData();
  }

  void logout() {
    Navigator.pushReplacement(
      context,
      MaterialPageRoute(builder: (_) => LoginPage()),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text("Home"),
        actions: [IconButton(icon: Icon(Icons.logout), onPressed: logout)],
      ),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Text(
              "Welcome!",
              style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
            ),
            SizedBox(height: 10),
            Text(
              userEmail.isNotEmpty
                  ? "Logged in as: $userEmail"
                  : "No user data",
              style: TextStyle(fontSize: 16),
            ),
            SizedBox(height: 20),
            ElevatedButton(onPressed: logout, child: Text("Logout")),
          ],
        ),
      ),
    );
  }
}
