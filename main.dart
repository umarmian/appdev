import 'package:flutter/material.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_database/firebase_database.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp(
    options: const FirebaseOptions(
      apiKey: "YOUR_API_KEY",
      appId: "YOUR_APP_ID",
      messagingSenderId: "YOUR_SENDER_ID",
      projectId: "kanwal-3a599",
      databaseURL: "https://kanwal-3a599-default-rtdb.firebaseio.com/",
    ),
  );
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Firebase Demo',
      theme: ThemeData(
        primarySwatch: Colors.blue,
      ),
      home: const FirebaseDemoScreen(),
    );
  }
}

class FirebaseDemoScreen extends StatefulWidget {
  const FirebaseDemoScreen({super.key});

  @override
  State<FirebaseDemoScreen> createState() => _FirebaseDemoScreenState();
}

class _FirebaseDemoScreenState extends State<FirebaseDemoScreen> {
  final TextEditingController _textController = TextEditingController();
  final DatabaseReference _databaseRef = FirebaseDatabase.instance.ref();
  List<String> _submittedData = [];

  @override
  void initState() {
    super.initState();
    _loadData();
  }

  Future<void> _loadData() async {
    try {
      DatabaseEvent event = await _databaseRef.once();
      if (event.snapshot.value != null) {
        Map<dynamic, dynamic> values = event.snapshot.value as Map;
        setState(() {
          _submittedData = values.values.cast<String>().toList();
        });
      }
    } catch (error) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Error loading data: $error')),
      );
    }
  }

  Future<void> _submitData() async {
    if (_textController.text.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Please enter some text')),
      );
      return;
    }

    try {
      String newKey = _databaseRef.push().key!;
      await _databaseRef.child(newKey).set(_textController.text);

      setState(() {
        _submittedData.add(_textController.text);
        _textController.clear();
      });

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Data submitted successfully!')),
      );
    } catch (error) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Error submitting data: $error')),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Firebase Realtime Database'),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: [
            TextField(
              controller: _textController,
              decoration: const InputDecoration(
                labelText: 'Enter your data',
                border: OutlineInputBorder(),
              ),
            ),
            const SizedBox(height: 20),
            ElevatedButton(
              onPressed: _submitData,
              child: const Text('Submit'),
            ),
            const SizedBox(height: 20),
            const Text(
              'Submitted Data:',
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 10),
            Expanded(
              child: ListView.builder(
                itemCount: _submittedData.length,
                itemBuilder: (context, index) {
                  return Card(
                    child: ListTile(
                      title: Text(_submittedData[index]),
                    ),
                  );
                },
              ),
            ),
          ],
        ),
      ),
    );
  }

  @override
  void dispose() {
    _textController.dispose();
    super.dispose();
  }
}