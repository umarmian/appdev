// import 'package:flutter/material.dart';
// import 'package:shared_preferences/shared_preferences.dart';
// import 'dart:convert';
// import 'login.dart';
// import 'signup.dart';
// import 'dart:io';

// class HomePage extends StatefulWidget {
//   final Map<String, dynamic> userData;
//   const HomePage({super.key, required this.userData});

//   @override
//   _HomePageState createState() => _HomePageState();
// }

// class _HomePageState extends State<HomePage> {
//   @override
//   Widget build(BuildContext context) {
//     return Scaffold(
//       appBar: AppBar(
//         title: const Text("Home"),
//       ),
//       drawer: Drawer(
//         child: ListView(
//           padding: EdgeInsets.zero,
//           children: [
//             UserAccountsDrawerHeader(
//               accountName: Text(widget.userData['name']),
//               accountEmail: Text(widget.userData['email']),
//               currentAccountPicture: widget.userData['image'] != null
//                   ? CircleAvatar(
//                       backgroundImage:
//                           FileImage(File(widget.userData['image'])),
//                     )
//                   : const CircleAvatar(
//                       child: Icon(Icons.person),
//                     ),
//             ),
//             ListTile(
//               title: const Text("Login"),
//               onTap: () {
//                 Navigator.pop(context);
//                 Navigator.pushReplacement(
//                   context,
//                   MaterialPageRoute(builder: (context) => const LoginPage()),
//                 );
//               },
//             ),
//             ListTile(
//               title: const Text("Sign Up"),
//               onTap: () {
//                 Navigator.pop(context);
//                 Navigator.pushReplacement(
//                   context,
//                   MaterialPageRoute(builder: (context) => const SignUpPage()),
//                 );
//               },
//             ),
//             const Divider(),
//             ListTile(
//               title: const Text("Logout"),
//               onTap: _logout,
//             ),
//           ],
//         ),
//       ),
//       body: Center(
//         child: Column(
//           mainAxisAlignment: MainAxisAlignment.center,
//           children: [
//             Text("Welcome, ${widget.userData['name']}!"),
//             const SizedBox(height: 20),
//             ElevatedButton(
//               onPressed: () {
//                 _showRecords(context);
//               },
//               child: const Text("View Records"),
//             ),
//           ],
//         ),
//       ),
//     );
//   }

//   Future<void> _logout() async {
//     final SharedPreferences prefs = await SharedPreferences.getInstance();
//     await prefs.remove('loggedInUser');
//     Navigator.pushReplacement(
//       context,
//       MaterialPageRoute(builder: (context) => const LoginPage()),
//     );
//   }

//   Future<void> _showRecords(BuildContext context) async {
//     final SharedPreferences prefs = await SharedPreferences.getInstance();
//     final String? usersData = prefs.getString('users');
//     if (usersData == null) {
//       ScaffoldMessenger.of(context).showSnackBar(
//         const SnackBar(content: Text("No records found.")),
//       );
//       return;
//     }

//     List<Map<String, dynamic>> usersList =
//         List<Map<String, dynamic>>.from(jsonDecode(usersData));

//     // Filter out users who haven't successfully signed up (optional, if needed)
//     // For example, you can check if they have a valid email or name
//     usersList = usersList
//         .where((user) => user['email'] != null && user['name'] != null)
//         .toList();

//     showDialog(
//       context: context,
//       builder: (context) {
//         return AlertDialog(
//           title: const Text("User Records"),
//           content: SingleChildScrollView(
//             child: Column(
//               children: usersList.map((user) {
//                 return Card(
//                   margin: const EdgeInsets.symmetric(vertical: 8),
//                   child: ListTile(
//                     title: Text(user['name'] ?? 'No Name'),
//                     subtitle: Column(
//                       crossAxisAlignment: CrossAxisAlignment.start,
//                       children: [
//                         Text("Email: ${user['email'] ?? 'No Email'}"),
//                         if (user['image'] != null)
//                           Text("Image Path: ${user['image']}"),
//                         // Add more fields here if needed
//                       ],
//                     ),
//                   ),
//                 );
//               }).toList(),
//             ),
//           ),
//           actions: [
//             TextButton(
//               onPressed: () {
//                 Navigator.pop(context);
//               },
//               child: const Text("Close"),
//             ),
//           ],
//         );
//       },
//     );
//   }
// }

import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'dart:convert';
import 'login.dart';
import 'signup.dart';
import 'dart:io';

class HomePage extends StatefulWidget {
  final Map<String, dynamic> userData;
  const HomePage({super.key, required this.userData});

  @override
  _HomePageState createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Home"),
      ),
      drawer: Drawer(
        child: ListView(
          padding: EdgeInsets.zero,
          children: [
            UserAccountsDrawerHeader(
              accountName: Text(widget.userData['name'] ?? 'No Name'),
              accountEmail: Text(widget.userData['email'] ?? 'No Email'),
              currentAccountPicture: widget.userData['image'] != null
                  ? CircleAvatar(
                      backgroundImage:
                          FileImage(File(widget.userData['image'])),
                    )
                  : const CircleAvatar(
                      child: Icon(Icons.person),
                    ),
            ),
            ListTile(
              title: const Text("Login"),
              onTap: () {
                Navigator.pop(context);
                Navigator.pushReplacement(
                  context,
                  MaterialPageRoute(builder: (context) => const LoginPage()),
                );
              },
            ),
            ListTile(
              title: const Text("Sign Up"),
              onTap: () {
                Navigator.pop(context);
                Navigator.pushReplacement(
                  context,
                  MaterialPageRoute(builder: (context) => const SignUpPage()),
                );
              },
            ),
            const Divider(),
            ListTile(
              title: const Text("Logout"),
              onTap: _logout,
            ),
          ],
        ),
      ),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Text("Welcome, ${widget.userData['name'] ?? 'User'}!"),
            const SizedBox(height: 20),
            ElevatedButton(
              onPressed: () {
                _showRecords(context);
              },
              child: const Text("View Records"),
            ),
            const SizedBox(height: 20),
            // Display additional user data
            if (widget.userData['city'] != null)
              Text("City: ${widget.userData['city']}"),
            if (widget.userData['address'] != null)
              Text("Address: ${widget.userData['address']}"),
            if (widget.userData['image'] != null)
              Image.file(File(widget.userData['image']), height: 100),
          ],
        ),
      ),
    );
  }

  Future<void> _logout() async {
    final SharedPreferences prefs = await SharedPreferences.getInstance();
    await prefs.remove('loggedInUser');
    Navigator.pushReplacement(
      context,
      MaterialPageRoute(builder: (context) => const LoginPage()),
    );
  }

  Future<void> _showRecords(BuildContext context) async {
    final SharedPreferences prefs = await SharedPreferences.getInstance();
    final String? usersData = prefs.getString('users');
    if (usersData == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("No records found.")),
      );
      return;
    }

    List<Map<String, dynamic>> usersList =
        List<Map<String, dynamic>>.from(jsonDecode(usersData));

    // Filter out users who haven't successfully signed up (optional, if needed)
    usersList = usersList
        .where((user) => user['email'] != null && user['name'] != null)
        .toList();

    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: const Text("User Records"),
          content: SingleChildScrollView(
            child: Column(
              children: usersList.map((user) {
                return Card(
                  margin: const EdgeInsets.symmetric(vertical: 8),
                  child: ListTile(
                    title: Text(user['name'] ?? 'No Name'),
                    subtitle: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text("Email: ${user['email'] ?? 'No Email'}"),
                        if (user['city'] != null) Text("City: ${user['city']}"),
                        if (user['address'] != null)
                          Text("Address: ${user['address']}"),
                        if (user['image'] != null)
                          Text("Image Path: ${user['image']}"),
                      ],
                    ),
                  ),
                );
              }).toList(),
            ),
          ),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.pop(context);
              },
              child: const Text("Close"),
            ),
          ],
        );
      },
    );
  }
}
