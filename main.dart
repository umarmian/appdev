import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'dart:convert';
import 'login.dart';
import 'home.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized(); // Ensure Flutter is initialized
  final SharedPreferences prefs = await SharedPreferences.getInstance();
  final String? loggedInUser = prefs.getString('loggedInUser');
  runApp(MyApp(loggedInUser: loggedInUser));
}

class MyApp extends StatelessWidget {
  final String? loggedInUser;
  const MyApp({super.key, this.loggedInUser});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'Flutter App',
      theme: ThemeData(
        primarySwatch: Colors.blue,
      ),
      home: loggedInUser != null
          ? HomePage(userData: jsonDecode(loggedInUser!))
          : const LoginPage(),
    );
  }
}
