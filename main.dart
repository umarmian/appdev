.dart
+220
-40
Original file line number	Diff line number	Diff line change
@@ -1,63 +1,243 @@
import 'package:flutter/material.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_database/firebase_database.dart';
import 'package:intl/intl.dart';

void main() => runApp(const MyApp());
void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  try {
    await Firebase.initializeApp(
      options: const FirebaseOptions(
        apiKey: "YOUR_API_KEY",
        appId: "YOUR_APP_ID",
        messagingSenderId: "YOUR_SENDER_ID",
        projectId: "fireapp-97d4d",
        databaseURL: "https://fireapp-97d4d-default-rtdb.firebaseio.com",
      ),
    );
    // Remove await since setPersistenceEnabled is void
    FirebaseDatabase.instance.setPersistenceEnabled(true);
    runApp(const MyApp());
  } catch (e) {
    runApp(
      MaterialApp(
        home: Scaffold(
          body: Center(child: Text('Firebase init failed: $e')),
        ),
      ),
    );
  }
}
// [Rest of your code remains exactly the same...]
class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Simple App',
      home: const MainScreen(),
      title: 'Firebase Chat',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        useMaterial3: true,
        colorScheme: ColorScheme.fromSeed(seedColor: Colors.blue),
      ),
      home: const ChatScreen(),
    );
  }
}

class MainScreen extends StatelessWidget {
  const MainScreen({super.key});
class ChatScreen extends StatefulWidget {
  const ChatScreen({super.key});
  @override
  State<ChatScreen> createState() => _ChatScreenState();
}
class _ChatScreenState extends State<ChatScreen> {
  late final DatabaseReference _messagesRef;
  final TextEditingController _controller = TextEditingController();
  final ScrollController _scrollController = ScrollController();
  @override
  void initState() {
    super.initState();
    _messagesRef = FirebaseDatabase.instance.ref('messages');
  }
  @override
  void dispose() {
    _controller.dispose();
    _scrollController.dispose();
    super.dispose();
  }
  Future<void> _sendMessage() async {
    final text = _controller.text.trim();
    if (text.isEmpty) return;
    try {
      await _messagesRef.push().set({
        'text': text,
        'timestamp': ServerValue.timestamp,
        'createdAt': DateTime.now().toIso8601String(),
      });
      _controller.clear();
      _scrollToBottom();
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Failed to send message: $e'),
            backgroundColor: Colors.red,
          ),
        );
      }
    }
  }
  void _scrollToBottom() {
    Future.delayed(const Duration(milliseconds: 300), () {
      if (_scrollController.hasClients) {
        _scrollController.animateTo(
          _scrollController.position.maxScrollExtent,
          duration: const Duration(milliseconds: 300),
          curve: Curves.easeOut,
        );
      }
    });
  }
  Future<void> _deleteMessage(String key) async {
    try {
      await _messagesRef.child(key).remove();
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Failed to delete message: $e'),
            backgroundColor: Colors.red,
          ),
        );
      }
    }
  }
  String _formatTimestamp(dynamic timestamp) {
    if (timestamp == null) return 'Just now';
    try {
      if (timestamp is int) {
        return DateFormat('MMM d, h:mm a').format(
          DateTime.fromMillisecondsSinceEpoch(timestamp),
        );
      } else if (timestamp is String) {
        return DateFormat('MMM d, h:mm a').format(
          DateTime.parse(timestamp),
        );
      }
    } catch (e) {
      return 'Unknown time';
    }
    return 'Unknown time';
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('My Simple App'),
      ),
      drawer: Drawer(
        child: ListView(
          children: [
            const DrawerHeader(
              child: Text('Menu'),
            ),
            ListTile(
              leading: const Icon(Icons.home),
              title: const Text('Home'),
              onTap: () => Navigator.pop(context),
            ),
            ListTile(
              leading: const Icon(Icons.settings),
              title: const Text('Settings'),
              onTap: () => Navigator.pop(context),
            ),
          ],
        ),
      ),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Image.network(
              'https://picsum.photos/300/200',
              height: 200,
      appBar: AppBar(title: const Text('Firebase Chat')),
      body: Column(
        children: [
          Expanded(
            child: StreamBuilder<DatabaseEvent>(
              stream: _messagesRef.onValue,
              builder: (context, snapshot) {
                if (snapshot.hasError) {
                  return Center(child: Text('Error: ${snapshot.error}'));
                }
                if (snapshot.connectionState == ConnectionState.waiting) {
                  return const Center(child: CircularProgressIndicator());
                }
                if (!snapshot.hasData || snapshot.data!.snapshot.value == null) {
                  return const Center(child: Text('No messages yet.'));
                }
                final Map messagesMap =
                snapshot.data!.snapshot.value as Map<dynamic, dynamic>;
                final messages = messagesMap.entries.toList()
                  ..sort((a, b) {
                    // Handle different timestamp formats
                    dynamic aTime = a.value['timestamp'] ?? a.value['createdAt'];
                    dynamic bTime = b.value['timestamp'] ?? b.value['createdAt'];
                    if (aTime is int && bTime is int) {
                      return aTime.compareTo(bTime);
                    } else if (aTime is String && bTime is String) {
                      return aTime.compareTo(bTime);
                    }
                    return 0;
                  });
                return ListView.builder(
                  controller: _scrollController,
                  itemCount: messages.length,
                  itemBuilder: (context, index) {
                    final entry = messages[index];
                    final text = entry.value['text']?.toString() ?? '';
                    final time = entry.value['timestamp'] ?? entry.value['createdAt'];
                    return Dismissible(
                      key: Key(entry.key),
                      direction: DismissDirection.endToStart,
                      background: Container(
                        color: Colors.red,
                        alignment: Alignment.centerRight,
                        padding: const EdgeInsets.only(right: 20),
                        child: const Icon(Icons.delete, color: Colors.white),
                      ),
                      onDismissed: (_) => _deleteMessage(entry.key),
                      child: ListTile(
                        title: Text(text),
                        subtitle: Text(_formatTimestamp(time)),
                        trailing: IconButton(
                          icon: const Icon(Icons.delete),
                          onPressed: () => _deleteMessage(entry.key),
                        ),
                      ),
                    );
                  },
                );
              },
            ),
            const SizedBox(height: 20),
            const Text(
              'Welcome to my app!',
              style: TextStyle(fontSize: 24),
          ),
          Padding(
            padding: const EdgeInsets.all(8),
            child: Row(
              children: [
                Expanded(
                  child: TextField(
                    controller: _controller,
                    decoration: const InputDecoration(
                      hintText: 'Type your message...',
                      border: OutlineInputBorder(),
                    ),
                    onSubmitted: (_) => _sendMessage(),
                  ),
                ),
                const SizedBox(width: 8),
                FloatingActionButton.small(
                  onPressed: _sendMessage,
                  child: const Icon(Icons.send),
                ),
              ],
            ),
          ],
        ),
          )
        ],
      ),
    );
  }