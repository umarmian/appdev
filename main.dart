import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';

void main() => runApp(MyApp());

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Auth App',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(primarySwatch: Colors.blue),
      home: LoginPage(),
    );
  }
}

/// =================== LOGIN PAGE ===================
class LoginPage extends StatefulWidget {
  @override
  _LoginPageState createState() => _LoginPageState();
}

class _LoginPageState extends State<LoginPage> {
  final emailController = TextEditingController();
  final passwordController = TextEditingController();
  bool isLoading = false;

  Future<void> loginUser() async {
    setState(() => isLoading = true);

    final url = Uri.parse('https://devtechtop.com/store/public/login');

    try {
      final response = await http.post(
        url,
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode({
          "email": emailController.text.trim(),
          "password": passwordController.text.trim(),
        }),
      );

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);

        if (data['status'] == 'success') {
          final userData = data['data'][0];

          final prefs = await SharedPreferences.getInstance();
          await prefs.setString('name', userData['name'] ?? 'N/A');
          await prefs.setString(
            'email',
            userData['email'] ?? emailController.text.trim(),
          );
          await prefs.setString('cell_no', userData['cell_no'] ?? 'N/A');
          await prefs.setString('shift', userData['shift'] ?? 'N/A');
          await prefs.setString('degree', userData['degree'] ?? 'N/A');
          await prefs.setString('user_id', userData['id'].toString());

          ScaffoldMessenger.of(
            context,
          ).showSnackBar(SnackBar(content: Text("Login Successful")));
          Navigator.pushReplacement(
            context,
            MaterialPageRoute(builder: (_) => ProfilePage()),
          );
        } else {
          ScaffoldMessenger.of(
            context,
          ).showSnackBar(SnackBar(content: Text("Invalid email or password")));
        }
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text("Server error: ${response.statusCode}")),
        );
      }
    } catch (e) {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text("Error: ${e.toString()}")));
    } finally {
      setState(() => isLoading = false);
    }
  }

  @override
  void dispose() {
    emailController.dispose();
    passwordController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Padding(
        padding: const EdgeInsets.all(24.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            SizedBox(height: 40),
            Text(
              'Welcome Back',
              style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
              textAlign: TextAlign.center,
            ),
            SizedBox(height: 30),
            TextField(
              controller: emailController,
              decoration: InputDecoration(labelText: 'Email'),
              keyboardType: TextInputType.emailAddress,
            ),
            SizedBox(height: 16),
            TextField(
              controller: passwordController,
              decoration: InputDecoration(labelText: 'Password'),
              obscureText: true,
            ),
            SizedBox(height: 24),
            ElevatedButton(
              onPressed: isLoading ? null : loginUser,
              child:
                  isLoading
                      ? CircularProgressIndicator(color: Colors.white)
                      : Text('LOGIN'),
            ),
            SizedBox(height: 16),
            TextButton(
              onPressed: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(builder: (_) => RegisterPage()),
                );
              },
              child: Text("Don't have an account? Sign Up"),
            ),
            SizedBox(height: 16),
            TextButton(
              onPressed: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(builder: (_) => UserSearchPage()),
                );
              },
              child: Text("Search Users"),
            ),
          ],
        ),
      ),
    );
  }
}

/// =================== REGISTER PAGE ===================
class RegisterPage extends StatefulWidget {
  @override
  _RegisterPageState createState() => _RegisterPageState();
}

class _RegisterPageState extends State<RegisterPage> {
  final nameController = TextEditingController();
  final emailController = TextEditingController();
  final passwordController = TextEditingController();
  final cellNoController = TextEditingController();
  final shiftController = TextEditingController();
  final degreeController = TextEditingController();
  bool isLoading = false;

  Future<void> registerUser() async {
    setState(() => isLoading = true);

    final url = Uri.parse('https://devtechtop.com/store/public/insert_user');

    try {
      final response = await http.post(
        url,
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode({
          "name": nameController.text.trim(),
          "email": emailController.text.trim(),
          "password": passwordController.text.trim(),
          "cell_no": cellNoController.text.trim(),
          "shift": shiftController.text.trim(),
          "degree": degreeController.text.trim(),
        }),
      );

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        if (data['status'] == 'success') {
          final prefs = await SharedPreferences.getInstance();
          await prefs.setString('name', nameController.text.trim());
          await prefs.setString('email', emailController.text.trim());
          await prefs.setString('cell_no', cellNoController.text.trim());
          await prefs.setString('shift', shiftController.text.trim());
          await prefs.setString('degree', degreeController.text.trim());
          await prefs.setString('user_id', data['data']['id'].toString());

          ScaffoldMessenger.of(
            context,
          ).showSnackBar(SnackBar(content: Text("Registration Successful")));
          Navigator.pushReplacement(
            context,
            MaterialPageRoute(builder: (_) => ProfilePage()),
          );
        } else {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text(data['message'] ?? 'Registration Failed')),
          );
        }
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text("Registration Failed: ${response.statusCode}"),
          ),
        );
      }
    } catch (e) {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text("Error: ${e.toString()}")));
    } finally {
      setState(() => isLoading = false);
    }
  }

  @override
  void dispose() {
    nameController.dispose();
    emailController.dispose();
    passwordController.dispose();
    cellNoController.dispose();
    shiftController.dispose();
    degreeController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text('Create Account')),
      body: Padding(
        padding: const EdgeInsets.all(24.0),
        child: Column(
          children: [
            TextField(
              controller: nameController,
              decoration: InputDecoration(labelText: 'Full Name'),
            ),
            SizedBox(height: 16),
            TextField(
              controller: emailController,
              decoration: InputDecoration(labelText: 'Email'),
              keyboardType: TextInputType.emailAddress,
            ),
            SizedBox(height: 16),
            TextField(
              controller: passwordController,
              decoration: InputDecoration(labelText: 'Password'),
              obscureText: true,
            ),
            SizedBox(height: 16),
            TextField(
              controller: cellNoController,
              decoration: InputDecoration(labelText: 'Phone Number'),
              keyboardType: TextInputType.phone,
            ),
            SizedBox(height: 16),
            TextField(
              controller: shiftController,
              decoration: InputDecoration(labelText: 'Shift'),
            ),
            SizedBox(height: 16),
            TextField(
              controller: degreeController,
              decoration: InputDecoration(labelText: 'Degree'),
            ),
            SizedBox(height: 24),
            ElevatedButton(
              onPressed: isLoading ? null : registerUser,
              child:
                  isLoading
                      ? CircularProgressIndicator(color: Colors.white)
                      : Text('REGISTER'),
            ),
          ],
        ),
      ),
    );
  }
}

/// =================== USER SEARCH PAGE ===================
class UserSearchPage extends StatefulWidget {
  @override
  _UserSearchPageState createState() => _UserSearchPageState();
}

class _UserSearchPageState extends State<UserSearchPage> {
  final _userIdController = TextEditingController();
  List<dynamic> users = [];
  bool isLoading = false;
  String error = '';
  String? currentUserId;
  Map<String, String> requestStatus = {}; // 'pending', 'accepted', or empty

  @override
  void initState() {
    super.initState();
    _loadCurrentUserId();
  }

  Future<void> _loadCurrentUserId() async {
    final prefs = await SharedPreferences.getInstance();
    setState(() {
      currentUserId = prefs.getString('user_id');
    });
  }

  Future<void> fetchUsers() async {
    setState(() {
      isLoading = true;
      error = '';
    });

    try {
      String enteredUserId = _userIdController.text.trim();

      final response = await http.post(
        Uri.parse('https://devtechtop.com/store/public/api/all_user'),
        headers: {
          'Content-Type': 'application/json',
          'Accept': 'application/json',
        },
        body: json.encode({
          if (enteredUserId.isNotEmpty) 'user_id': enteredUserId,
        }),
      );

      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        setState(() {
          users = data['data'] ?? [];
        });
        await _checkFriendRequests();
      } else {
        setState(() {
          error = 'Error ${response.statusCode}: ${response.reasonPhrase}';
        });
      }
    } catch (e) {
      setState(() {
        error = 'Network error: $e';
      });
    } finally {
      setState(() {
        isLoading = false;
      });
    }
  }

  Future<void> _checkFriendRequests() async {
    if (currentUserId == null) return;

    try {
      final response = await http.post(
        Uri.parse(
          'https://devtechtop.com/store/public/api/scholar_request/my_requests',
        ),
        headers: {
          'Content-Type': 'application/json',
          'Accept': 'application/json',
        },
        body: json.encode({'sender_id': currentUserId}),
      );

      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        if (data['status'] == 'success') {
          Map<String, String> newStatus = {};
          for (var request in data['data']) {
            newStatus[request['receiver_id'].toString()] =
                request['status'] ?? 'pending';
          }
          setState(() {
            requestStatus = newStatus;
          });
        }
      }
    } catch (e) {
      print('Error checking friend requests: $e');
    }
  }

  Future<void> sendFriendRequest(String receiverId) async {
    if (currentUserId == null) return;

    try {
      final response = await http.post(
        Uri.parse(
          'https://devtechtop.com/store/public/api/scholar_request/insert',
        ),
        headers: {
          'Content-Type': 'application/json',
          'Accept': 'application/json',
        },
        body: json.encode({
          'sender_id': currentUserId,
          'receiver_id': receiverId,
          'status': 'pending', // Explicitly set status
        }),
      );

      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        if (data['status'] == 'success') {
          setState(() {
            requestStatus[receiverId] = 'pending';
          });
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text("Friend request sent successfully")),
          );
        } else {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text(data['message'] ?? 'Failed to send request'),
            ),
          );
        }
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text("Error: ${response.statusCode}")),
        );
      }
    } catch (e) {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text("Error: ${e.toString()}")));
    }
  }

  @override
  void dispose() {
    _userIdController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Search Users'),
        actions: [
          IconButton(
            icon: Icon(Icons.group),
            onPressed: () {
              Navigator.push(
                context,
                MaterialPageRoute(builder: (_) => MyRequestsPage()),
              );
            },
          ),
        ],
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: [
            TextField(
              controller: _userIdController,
              decoration: InputDecoration(
                labelText: 'Enter User ID (optional)',
                border: OutlineInputBorder(),
              ),
              keyboardType: TextInputType.number,
            ),
            SizedBox(height: 16),
            ElevatedButton(onPressed: fetchUsers, child: Text('Search Users')),
            SizedBox(height: 16),
            if (error.isNotEmpty)
              Text(error, style: TextStyle(color: Colors.red)),
            if (isLoading)
              CircularProgressIndicator()
            else
              Expanded(
                child: ListView.builder(
                  itemCount: users.length,
                  itemBuilder: (context, index) {
                    final user = users[index];
                    final status = requestStatus[user['id'].toString()];
                    return Card(
                      margin: EdgeInsets.symmetric(vertical: 8),
                      child: ListTile(
                        leading: CircleAvatar(
                          child: Text(user['id']?.toString() ?? '?'),
                        ),
                        title: Text(user['name'] ?? 'No Name'),
                        subtitle: Text(user['email'] ?? 'No Email'),
                        trailing: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            if (user['id'].toString() != currentUserId)
                              _buildRequestStatus(
                                status,
                                user['id'].toString(),
                              ),
                            IconButton(
                              icon: Icon(Icons.arrow_forward),
                              onPressed: () {
                                Navigator.push(
                                  context,
                                  MaterialPageRoute(
                                    builder:
                                        (_) => UserDetailsPage(
                                          user: user,
                                          requestStatus: status,
                                        ),
                                  ),
                                );
                              },
                            ),
                          ],
                        ),
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

  Widget _buildRequestStatus(String? status, String receiverId) {
    switch (status) {
      case 'pending':
        return Chip(
          label: Text('Pending'),
          backgroundColor: Colors.orange[100],
        );
      case 'accepted':
        return Chip(
          label: Text('Accepted'),
          backgroundColor: Colors.green[100],
        );
      default:
        return IconButton(
          icon: Icon(Icons.person_add),
          onPressed: () => sendFriendRequest(receiverId),
        );
    }
  }
}

/// =================== MY REQUESTS PAGE ===================
class MyRequestsPage extends StatefulWidget {
  @override
  _MyRequestsPageState createState() => _MyRequestsPageState();
}

class _MyRequestsPageState extends State<MyRequestsPage> {
  List<dynamic> requests = [];
  bool isLoading = false;
  String error = '';
  String? currentUserId;

  @override
  void initState() {
    super.initState();
    _loadCurrentUserId();
    _fetchMyRequests();
  }

  Future<void> _loadCurrentUserId() async {
    final prefs = await SharedPreferences.getInstance();
    setState(() {
      currentUserId = prefs.getString('user_id');
    });
  }

  Future<void> _fetchMyRequests() async {
    if (currentUserId == null) return;

    setState(() {
      isLoading = true;
      error = '';
    });

    try {
      final response = await http.post(
        Uri.parse(
          'https://devtechtop.com/store/public/api/scholar_request/my_requests',
        ),
        headers: {
          'Content-Type': 'application/json',
          'Accept': 'application/json',
        },
        body: json.encode({'sender_id': currentUserId}),
      );

      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        if (data['status'] == 'success') {
          setState(() {
            requests = data['data'];
          });
        } else {
          setState(() {
            error = data['message'] ?? 'Failed to fetch requests';
          });
        }
      } else {
        setState(() {
          error = 'Error ${response.statusCode}: ${response.reasonPhrase}';
        });
      }
    } catch (e) {
      setState(() {
        error = 'Network error: $e';
      });
    } finally {
      setState(() {
        isLoading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text('My Friend Requests')),
      body:
          isLoading
              ? Center(child: CircularProgressIndicator())
              : error.isNotEmpty
              ? Center(child: Text(error))
              : requests.isEmpty
              ? Center(child: Text('No friend requests found'))
              : ListView.builder(
                itemCount: requests.length,
                itemBuilder: (context, index) {
                  final request = requests[index];
                  return Card(
                    margin: EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                    child: ListTile(
                      leading: CircleAvatar(
                        child: Text(request['receiver_id']?.toString() ?? '?'),
                      ),
                      title: Text(request['receiver_name'] ?? 'Unknown User'),
                      subtitle: Text(
                        'Status: ${request['status'] ?? 'pending'}',
                      ),
                      trailing: Chip(
                        label: Text(
                          request['status'] ?? 'pending',
                          style: TextStyle(
                            color:
                                request['status'] == 'accepted'
                                    ? Colors.green
                                    : Colors.orange,
                          ),
                        ),
                        backgroundColor:
                            request['status'] == 'accepted'
                                ? Colors.green[100]
                                : Colors.orange[100],
                      ),
                    ),
                  );
                },
              ),
    );
  }
}

/// =================== USER DETAILS PAGE ===================
class UserDetailsPage extends StatefulWidget {
  final dynamic user;
  final String? requestStatus;

  const UserDetailsPage({Key? key, required this.user, this.requestStatus})
    : super(key: key);

  @override
  _UserDetailsPageState createState() => _UserDetailsPageState();
}

class _UserDetailsPageState extends State<UserDetailsPage> {
  late String? requestStatus;
  String? currentUserId;

  @override
  void initState() {
    super.initState();
    requestStatus = widget.requestStatus;
    _loadCurrentUserId();
  }

  Future<void> _loadCurrentUserId() async {
    final prefs = await SharedPreferences.getInstance();
    setState(() {
      currentUserId = prefs.getString('user_id');
    });
  }

  Future<void> sendFriendRequest() async {
    if (currentUserId == null) return;

    try {
      final response = await http.post(
        Uri.parse(
          'https://devtechtop.com/store/public/api/scholar_request/insert',
        ),
        headers: {
          'Content-Type': 'application/json',
          'Accept': 'application/json',
        },
        body: json.encode({
          'sender_id': currentUserId,
          'receiver_id': widget.user['id'].toString(),
          'status': 'pending',
        }),
      );

      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        if (data['status'] == 'success') {
          setState(() {
            requestStatus = 'pending';
          });
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text("Friend request sent successfully")),
          );
        } else {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text(data['message'] ?? 'Failed to send request'),
            ),
          );
        }
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text("Error: ${response.statusCode}")),
        );
      }
    } catch (e) {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text("Error: ${e.toString()}")));
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text('User Details')),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Center(
              child: CircleAvatar(
                radius: 50,
                child: Icon(Icons.person, size: 50),
              ),
            ),
            SizedBox(height: 20),
            _buildDetailRow('ID', widget.user['id']?.toString() ?? 'N/A'),
            _buildDetailRow('Name', widget.user['name'] ?? 'N/A'),
            _buildDetailRow('Email', widget.user['email'] ?? 'N/A'),
            _buildDetailRow('Phone', widget.user['cell_no'] ?? 'N/A'),
            _buildDetailRow('Shift', widget.user['shift'] ?? 'N/A'),
            _buildDetailRow('Degree', widget.user['degree'] ?? 'N/A'),
            SizedBox(height: 20),
            if (widget.user['id'].toString() != currentUserId)
              Center(
                child:
                    requestStatus != null
                        ? Chip(
                          label: Text(
                            requestStatus == 'accepted'
                                ? 'Accepted'
                                : 'Pending',
                            style: TextStyle(
                              color:
                                  requestStatus == 'accepted'
                                      ? Colors.green
                                      : Colors.orange,
                            ),
                          ),
                          backgroundColor:
                              requestStatus == 'accepted'
                                  ? Colors.green[100]
                                  : Colors.orange[100],
                          padding: EdgeInsets.symmetric(
                            horizontal: 16,
                            vertical: 8,
                          ),
                        )
                        : ElevatedButton.icon(
                          icon: Icon(Icons.person_add),
                          label: Text('Send Friend Request'),
                          onPressed: sendFriendRequest,
                        ),
              ),
          ],
        ),
      ),
    );
  }

  Widget _buildDetailRow(String label, String value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8.0),
      child: Row(
        children: [
          Text(
            '$label: ',
            style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
          ),
          Text(value, style: TextStyle(fontSize: 16)),
        ],
      ),
    );
  }
}

/// =================== PROFILE PAGE ===================
class ProfilePage extends StatefulWidget {
  @override
  _ProfilePageState createState() => _ProfilePageState();
}

class _ProfilePageState extends State<ProfilePage> {
  Map<String, String> userData = {
    'name': 'N/A',
    'email': 'N/A',
    'cell_no': 'N/A',
    'shift': 'N/A',
    'degree': 'N/A',
  };
  String? userId;

  @override
  void initState() {
    super.initState();
    loadUserData();
  }

  Future<void> loadUserData() async {
    final prefs = await SharedPreferences.getInstance();
    setState(() {
      userData['name'] = prefs.getString('name') ?? 'N/A';
      userData['email'] = prefs.getString('email') ?? 'N/A';
      userData['cell_no'] = prefs.getString('cell_no') ?? 'N/A';
      userData['shift'] = prefs.getString('shift') ?? 'N/A';
      userData['degree'] = prefs.getString('degree') ?? 'N/A';
      userId = prefs.getString('user_id');
    });
  }

  Future<void> logout() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.clear();
    Navigator.pushAndRemoveUntil(
      context,
      MaterialPageRoute(builder: (_) => LoginPage()),
      (route) => false,
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('My Profile'),
        actions: [
          IconButton(
            icon: Icon(Icons.search),
            onPressed: () {
              Navigator.push(
                context,
                MaterialPageRoute(builder: (_) => UserSearchPage()),
              );
            },
          ),
          IconButton(
            icon: Icon(Icons.group),
            onPressed: () {
              Navigator.push(
                context,
                MaterialPageRoute(builder: (_) => MyRequestsPage()),
              );
            },
          ),
          IconButton(icon: Icon(Icons.logout), onPressed: logout),
        ],
      ),
      body: Padding(
        padding: const EdgeInsets.all(24.0),
        child: Column(
          children: [
            CircleAvatar(radius: 60, child: Icon(Icons.person, size: 60)),
            SizedBox(height: 20),
            Text(userData['name']!, style: TextStyle(fontSize: 24)),
            SizedBox(height: 5),
            Text(userData['email']!),
            SizedBox(height: 30),
            Column(
              children: [
                ListTile(
                  leading: Icon(Icons.phone),
                  title: Text('Phone'),
                  subtitle: Text(userData['cell_no']!),
                ),
                Divider(),
                ListTile(
                  leading: Icon(Icons.schedule),
                  title: Text('Shift'),
                  subtitle: Text(userData['shift']!),
                ),
                Divider(),
                ListTile(
                  leading: Icon(Icons.school),
                  title: Text('Degree'),
                  subtitle: Text(userData['degree']!),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
