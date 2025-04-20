import 'package:flutter/material.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_database/firebase_database.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp(
    options: const FirebaseOptions(
      apiKey: "AIzaSyCfrV...your_key...",
      authDomain: "fir-afc36.firebaseapp.com",
      databaseURL: "https://fir-afc36-default-rtdb.firebaseio.com",
      projectId: "fir-afc36",
      storageBucket: "fir-afc36.appspot.com",
      messagingSenderId: "9441xxxxxxx",
      appId: "1:9441xxxxxxx:web:xxxxxx",
    ),
  );
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'Firebase Chat',
      theme: ThemeData(
        useMaterial3: true,
        colorSchemeSeed: Colors.blue,
      ),
      home: const HomePage(),
    );
  }
}

class HomePage extends StatefulWidget {
  const HomePage({super.key});
  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  final TextEditingController _messageController = TextEditingController();
  final DatabaseReference _messagesRef =
  FirebaseDatabase.instance.ref().child('messages');

  void _sendMessage() {
    final text = _messageController.text.trim();
    if (text.isNotEmpty) {
      _messagesRef.push().set({
        'text': text,
        'timestamp': DateTime.now().toIso8601String(),
      });
      _messageController.clear();
    }
  }

  void _deleteMessage(String key) {
    _messagesRef.child(key).remove();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Firebase Chat')),
      body: Column(
        children: [
          Padding(
            padding: const EdgeInsets.all(12.0),
            child: Row(
              children: [
                Expanded(
                  child: TextField(
                    controller: _messageController,
                    decoration: const InputDecoration(
                      border: OutlineInputBorder(),
                      labelText: 'Type your message',
                    ),
                  ),
                ),
                const SizedBox(width: 10),
                ElevatedButton(
                  onPressed: _sendMessage,
                  child: const Icon(Icons.send),
                ),
              ],
            ),
          ),
          const Divider(),
          Expanded(
            child: StreamBuilder(
              stream: _messagesRef.orderByChild('timestamp').onValue,
              builder: (context, snapshot) {
                if (snapshot.hasData &&
                    snapshot.data!.snapshot.value != null) {
                  final Map<String, dynamic> data =
                  Map<String, dynamic>.from(snapshot.data!.snapshot.value as Map);
                  final messages = data.entries.toList()
                    ..sort((a, b) =>
                        a.value['timestamp'].compareTo(b.value['timestamp']));
                  return ListView.builder(
                    itemCount: messages.length,
                    itemBuilder: (context, index) {
                      final entry = messages[index];
                      return ListTile(
                        title: Text(entry.value['text']),
                        trailing: IconButton(
                          icon: const Icon(Icons.delete),
                          onPressed: () => _deleteMessage(entry.key),
                        ),
                      );
                    },
                  );
                } else {
                  return const Center(child: Text("No messages yet."));
                }
              },
            ),
          ),
        ],
      ),
    );
  }
}

