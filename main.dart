import 'package:flutter/material.dart';
import 'dart:math'; // Import for Random class

void main() {
  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'Multi-Feature App',
      theme: ThemeData(primarySwatch: Colors.blue, brightness: Brightness.dark),
      home: HomeScreen(),
    );
  }
}

class HomeScreen extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text('Multi-Feature App')),
      drawer: Drawer(
        child: ListView(
          padding: EdgeInsets.zero,
          children: [
            DrawerHeader(
              decoration: BoxDecoration(
                color: Colors.blue,
              ),
              child: Text(
                'Features',
                style: TextStyle(color: Colors.white, fontSize: 24),
              ),
            ),
            ListTile(
              title: Text('Calculator'),
              onTap: () {
                Navigator.pop(context);
                Navigator.push(
                  context,
                  MaterialPageRoute(builder: (context) => CalculatorScreen()),
                );
              },
            ),
            ListTile(
              title: Text('GPA Calculator'),
              onTap: () {
                Navigator.pop(context);
                Navigator.push(
                  context,
                  MaterialPageRoute(
                      builder: (context) => GPACalculatorScreen()),
                );
              },
            ),
          ],
        ),
      ),
      body: Center(
        child: Text('Select a feature from the drawer'),
      ),
    );
  }
}

class CalculatorScreen extends StatefulWidget {
  @override
  _CalculatorScreenState createState() => _CalculatorScreenState();
}

class _CalculatorScreenState extends State<CalculatorScreen> {
  final TextEditingController num1Controller = TextEditingController();
  final TextEditingController num2Controller = TextEditingController();
  String selectedOperator = "+"; // Default operator
  String result = "Result: ";

  void calculate() {
    FocusScope.of(context).unfocus(); // Hide keyboard
    setState(() {
      double? num1 = double.tryParse(num1Controller.text);
      double? num2 = double.tryParse(num2Controller.text);

      if (num1 == null || num2 == null) {
        result = "Please enter valid numbers";
        return;
      }

      switch (selectedOperator) {
        case '+':
          result = "Result: ${(num1 + num2).toStringAsFixed(2)}";
          break;
        case '-':
          result = "Result: ${(num1 - num2).toStringAsFixed(2)}";
          break;
        case '*':
          result = "Result: ${(num1 * num2).toStringAsFixed(2)}";
          break;
        case '/':
          result = num2 == 0
              ? "Error: Cannot divide by zero"
              : "Result: ${(num1 / num2).toStringAsFixed(2)}";
          break;
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text('Calculator')),
      body: Padding(
        padding: const EdgeInsets.all(20.0),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            TextField(
              controller: num1Controller,
              decoration: InputDecoration(
                labelText: 'Enter Number 1',
                border: OutlineInputBorder(),
              ),
              keyboardType: TextInputType.number,
            ),
            SizedBox(height: 10),
            TextField(
              controller: num2Controller,
              decoration: InputDecoration(
                labelText: 'Enter Number 2',
                border: OutlineInputBorder(),
              ),
              keyboardType: TextInputType.number,
            ),
            SizedBox(height: 20),
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                DropdownButton<String>(
                  value: selectedOperator,
                  onChanged: (value) {
                    FocusScope.of(context).unfocus(); // Hide keyboard
                    setState(() => selectedOperator = value!);
                  },
                  items: ['+', '-', '*', '/']
                      .map((op) => DropdownMenuItem(
                          value: op,
                          child: Text(op, style: TextStyle(fontSize: 20))))
                      .toList(),
                ),
                SizedBox(width: 20),
                ElevatedButton(
                  onPressed: calculate,
                  child: Text('Calculate', style: TextStyle(fontSize: 18)),
                  style: ElevatedButton.styleFrom(
                      padding:
                          EdgeInsets.symmetric(horizontal: 20, vertical: 10)),
                ),
              ],
            ),
            SizedBox(height: 20),
            Text(
              result,
              style: TextStyle(
                  fontSize: 22,
                  fontWeight: FontWeight.bold,
                  color: Colors.yellowAccent),
            ),
          ],
        ),
      ),
    );
  }
}

class GPACalculatorScreen extends StatefulWidget {
  @override
  _GPACalculatorScreenState createState() => _GPACalculatorScreenState();
}

class _GPACalculatorScreenState extends State<GPACalculatorScreen> {
  final List<String> subjects = [
    'DB',
    'Info Security',
    'Translation of Holy Qurran',
    'App Development'
  ];
  List<int> marks = [];
  List<double> gradePoints = [];
  double gpa = 0.0;

  @override
  void initState() {
    super.initState();
    // Generate random marks between 50 and 100 for each subject
    marks =
        List.generate(subjects.length, (index) => 50 + Random().nextInt(51));
    calculateGPA();
  }

  void calculateGPA() {
    setState(() {
      gradePoints = marks.map((mark) {
        if (mark >= 85) {
          return 4.0;
        } else if (mark >= 75) {
          return 3.0;
        } else if (mark >= 65) {
          return 2.0;
        } else if (mark >= 50) {
          return 1.0;
        } else {
          return 0.0;
        }
      }).toList();
      gpa = gradePoints.reduce((a, b) => a + b) / gradePoints.length;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text('GPA Calculator')),
      body: Padding(
        padding: const EdgeInsets.all(20.0),
        child: Column(
          children: [
            // Table for GPA Calculation
            Table(
              border: TableBorder.all(color: Colors.white),
              children: [
                TableRow(
                  decoration: BoxDecoration(color: Colors.blue),
                  children: [
                    Padding(
                      padding: const EdgeInsets.all(8.0),
                      child: Text('Subject',
                          style: TextStyle(
                              fontSize: 18,
                              fontWeight: FontWeight.bold,
                              color: Colors.white)),
                    ),
                    Padding(
                      padding: const EdgeInsets.all(8.0),
                      child: Text('Marks',
                          style: TextStyle(
                              fontSize: 18,
                              fontWeight: FontWeight.bold,
                              color: Colors.white)),
                    ),
                    Padding(
                      padding: const EdgeInsets.all(8.0),
                      child: Text('Grade Points',
                          style: TextStyle(
                              fontSize: 18,
                              fontWeight: FontWeight.bold,
                              color: Colors.white)),
                    ),
                  ],
                ),
                for (int i = 0; i < subjects.length; i++)
                  TableRow(
                    children: [
                      Padding(
                        padding: const EdgeInsets.all(8.0),
                        child:
                            Text(subjects[i], style: TextStyle(fontSize: 16)),
                      ),
                      Padding(
                        padding: const EdgeInsets.all(8.0),
                        child: Text(marks[i].toString(),
                            style: TextStyle(fontSize: 16)),
                      ),
                      Padding(
                        padding: const EdgeInsets.all(8.0),
                        child: Text(gradePoints[i].toStringAsFixed(1),
                            style: TextStyle(fontSize: 16)),
                      ),
                    ],
                  ),
              ],
            ),
            SizedBox(height: 20),
            ElevatedButton(
              onPressed: calculateGPA,
              child: Text('Recalculate GPA', style: TextStyle(fontSize: 18)),
              style: ElevatedButton.styleFrom(
                  padding: EdgeInsets.symmetric(horizontal: 20, vertical: 10)),
            ),
            SizedBox(height: 20),
            Text(
              'GPA: ${gpa.toStringAsFixed(2)}',
              style: TextStyle(
                  fontSize: 22,
                  fontWeight: FontWeight.bold,
                  color: Colors.yellowAccent),
            ),
          ],
        ),
      ),
    );
  }
}
