import 'package:flutter/material.dart';
import 'output.dart';

void main() {
  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        primarySwatch: Colors.deepPurple,
      ),
      home: RegistrationPage(),
    );
  }
}

class RegistrationPage extends StatefulWidget {
  @override
  _RegistrationPageState createState() => _RegistrationPageState();
}

class _RegistrationPageState extends State<RegistrationPage> {
  final _formKey = GlobalKey<FormState>();
  final _nameController = TextEditingController();
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  bool _isActive = false;
  List<Map<String, dynamic>> users = [];

  void _submitData() {
    if (_formKey.currentState!.validate()) {
      final newUser = {
        'name': _nameController.text,
        'email': _emailController.text,
        'password': _passwordController.text,
        'isActive': _isActive,
      };

      setState(() => users.add(newUser));

      _nameController.clear();
      _emailController.clear();
      _passwordController.clear();
      setState(() => _isActive = false);

      Navigator.push(
        context,
        MaterialPageRoute(
          builder: (context) => Output(
            users: users,
            onDelete: _deleteUser,
          ),
        ),
      );
    }
  }

  void _deleteUser(int index) => setState(() => users.removeAt(index));

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text('User Registration')),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Form(
          key: _formKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              _buildTextField(_nameController, 'Name', Icons.person),
              _buildTextField(_emailController, 'Email', Icons.email),
              _buildTextField(_passwordController, 'Password', Icons.lock,
                  obscure: true),
              SizedBox(height: 10),
              Text("Status", style: TextStyle(fontWeight: FontWeight.bold)),
              Row(
                children: [
                  _buildRadioButton("Active", true),
                  _buildRadioButton("Inactive", false),
                ],
              ),
              SizedBox(height: 20),
              Center(
                child: ElevatedButton(
                  onPressed: _submitData,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.deepPurple,
                    foregroundColor: Colors.white,
                    shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(10)),
                  ),
                  child: Text('Register'),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildTextField(
      TextEditingController controller, String label, IconData icon,
      {bool obscure = false}) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 12.0),
      child: TextFormField(
        controller: controller,
        decoration: InputDecoration(
          labelText: label,
          prefixIcon: Icon(icon, color: Colors.deepPurple),
          border: OutlineInputBorder(borderRadius: BorderRadius.circular(10)),
          filled: true,
          fillColor: Colors.deepPurple.shade50,
        ),
        obscureText: obscure,
        validator: (value) =>
            value == null || value.isEmpty ? 'Please enter your $label' : null,
      ),
    );
  }

  Widget _buildRadioButton(String text, bool value) {
    return Row(
      children: [
        Radio(
          value: value,
          groupValue: _isActive,
          activeColor: Colors.deepPurple,
          onChanged: (bool? newValue) => setState(() => _isActive = newValue!),
        ),
        Text(text),
      ],
    );
  }
}
