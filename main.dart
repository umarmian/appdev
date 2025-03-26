import 'package:flutter/material.dart';
import 'signup_page.dart';

void main() {
  runApp(
    MaterialApp(
      home: SignupPage(),
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        primarySwatch: Colors.blue,
        inputDecorationTheme: InputDecorationTheme(
          border: OutlineInputBorder(),
          contentPadding: EdgeInsets.symmetric(horizontal: 16, vertical: 12),
        ),
      ),
    ),
  );
}
