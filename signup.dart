import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'dart:convert';
import 'login.dart';
import 'home.dart';
import 'package:image_picker/image_picker.dart'; // Add this import
import 'dart:io'; // Add this import

class SignUpPage extends StatefulWidget {
  const SignUpPage({super.key});

  @override
  _SignUpPageState createState() => _SignUpPageState();
}

class _SignUpPageState extends State<SignUpPage> {
  final TextEditingController _nameController = TextEditingController();
  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();
  final TextEditingController _addressController = TextEditingController();
  String _city = 'Nankana Sahib';
  bool _obscurePassword = true;
  File? _image;

  final _formKey = GlobalKey<FormState>();

  Future<void> _pickImage() async {
    final pickedFile =
        await ImagePicker().pickImage(source: ImageSource.gallery);
    if (pickedFile != null) {
      setState(() {
        _image = File(pickedFile.path);
      });
    }
  }

  Future<void> _saveUserData() async {
    if (_formKey.currentState!.validate()) {
      try {
        final SharedPreferences prefs = await SharedPreferences.getInstance();

        final newUser = {
          'name': _nameController.text,
          'email': _emailController.text,
          'password': _passwordController.text,
          'city': _city,
          'address': _addressController.text,
          'image': _image?.path,
        };

        final String? usersData = prefs.getString('users');
        List<Map<String, dynamic>> usersList = usersData != null
            ? List<Map<String, dynamic>>.from(jsonDecode(usersData))
            : [];

        bool emailExists =
            usersList.any((user) => user['email'] == _emailController.text);

        if (emailExists) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text("Email already exists!")),
          );
          return;
        }

        usersList.add(newUser);
        await prefs.setString('users', jsonEncode(usersList));

        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text("You are successfully registered!")),
        );

        Navigator.pushReplacement(
          context,
          MaterialPageRoute(builder: (context) => const LoginPage()),
        );
      } catch (e) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text("Error saving user data: $e")),
        );
      }
    }
  }

  bool _isValidName(String name) {
    final nameRegex = RegExp(r'^[A-Z][a-z]*$');
    return nameRegex.hasMatch(name);
  }

  bool _isValidPassword(String password) {
    final passwordRegex = RegExp(
        r'^(?=.*[a-z])(?=.*[A-Z])(?=.*\d)(?=.*[@$!%*?&])[A-Za-z\d@$!%*?&]{6,}$');
    return passwordRegex.hasMatch(password);
  }

  bool _isValidEmail(String email) {
    final emailRegex =
        RegExp(r'^[a-zA-Z0-9._%+-]+@[a-zA-Z0-9]+\.[a-zA-Z]{2,}$');
    return emailRegex.hasMatch(email);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Sign Up"),
      ),
      body: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.all(20.0),
          child: Form(
            key: _formKey,
            child: Column(
              children: [
                TextFormField(
                  controller: _nameController,
                  decoration: const InputDecoration(labelText: "Name"),
                  validator: (value) {
                    if (value == null || value.isEmpty) {
                      return 'Name is required';
                    } else if (!_isValidName(value)) {
                      return 'First letter must be capital, no numbers allowed';
                    }
                    return null;
                  },
                ),
                TextFormField(
                  controller: _emailController,
                  decoration: const InputDecoration(labelText: "Email"),
                  validator: (value) {
                    if (value == null || value.isEmpty) {
                      return 'Email is required';
                    } else if (!_isValidEmail(value)) {
                      return 'Enter a valid email address';
                    }
                    return null;
                  },
                ),
                TextFormField(
                  controller: _passwordController,
                  obscureText: _obscurePassword,
                  decoration: InputDecoration(
                    labelText: "Password",
                    suffixIcon: IconButton(
                      icon: Icon(_obscurePassword
                          ? Icons.visibility
                          : Icons.visibility_off),
                      onPressed: () {
                        setState(() {
                          _obscurePassword = !_obscurePassword;
                        });
                      },
                    ),
                  ),
                  validator: (value) {
                    if (value == null || value.isEmpty) {
                      return 'Password is required';
                    } else if (!_isValidPassword(value)) {
                      return 'Password must contain 6 characters, including uppercase, lowercase, number, and symbol';
                    }
                    return null;
                  },
                ),
                DropdownButtonFormField(
                  value: _city,
                  items: const [
                    DropdownMenuItem(
                        value: 'Nankana Sahib', child: Text('Nankana Sahib')),
                    DropdownMenuItem(value: 'Shahkot', child: Text('Shahkot')),
                    DropdownMenuItem(value: 'Lahore', child: Text('Lahore')),
                    DropdownMenuItem(
                        value: 'Faisalabad', child: Text('Faisalabad')),
                  ],
                  onChanged: (value) {
                    setState(() {
                      _city = value as String;
                    });
                  },
                  decoration: const InputDecoration(labelText: "City"),
                ),
                TextFormField(
                  controller: _addressController,
                  maxLines: 3,
                  maxLength: 400,
                  decoration: InputDecoration(
                    labelText: "Address",
                    counterText: '${_addressController.text.length}/400',
                  ),
                  validator: (value) {
                    if (value == null || value.isEmpty) {
                      return 'Address is required';
                    } else if (value.length > 400) {
                      return 'Address cannot exceed 400 characters';
                    }
                    return null;
                  },
                ),
                const SizedBox(height: 10),
                _image == null
                    ? ElevatedButton(
                        onPressed: _pickImage,
                        child: const Text("Pick Image from Gallery"),
                      )
                    : Image.file(_image!, height: 100),
                const SizedBox(height: 20),
                ElevatedButton(
                  onPressed: _saveUserData,
                  child: const Text("Sign Up"),
                ),
                const SizedBox(height: 10),
                TextButton(
                  onPressed: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                          builder: (context) => const LoginPage()),
                    );
                  },
                  child: const Text("Already have an account? Login"),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
