import 'package:flutter/material.dart';
import 'main_screen.dart';

void main() => runApp(const MyApp());

class MyApp extends StatelessWidget {
  const MyApp({super.key}); // Added key parameter

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Student Courses',
      theme: ThemeData(primarySwatch: Colors.blue),
      home: const MainScreen(),
    );
  }
}
