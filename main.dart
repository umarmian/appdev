import 'package:flutter/material.dart';

void main() => runApp(MaterialApp(home: HomeScreen()));

class HomeScreen extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text('Home')),
      body: Center(
        child: ElevatedButton(
          child: Text('Show Flag'),
          onPressed: () {
            Navigator.push(
              context,
              MaterialPageRoute(builder: (_) => FlagScreen()),
            );
          },
        ),
      ),
    );
  }
}

class FlagScreen extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text('Pakistan Flag')),
      body: Center(
        child: Image.asset('assets/images/flag.png', width: 200),
      ),
    );
  }
}
