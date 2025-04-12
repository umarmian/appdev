import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';

class StudentDataScreen extends StatefulWidget {
  const StudentDataScreen({super.key});

  @override
  State<StudentDataScreen> createState() => _StudentDataScreenState();
}

class _StudentDataScreenState extends State<StudentDataScreen> {
  final _formKey = GlobalKey<FormState>();
  final _userIdController = TextEditingController();
  final _courseNameController = TextEditingController();
  final _creditHourController = TextEditingController();
  final _marksController = TextEditingController();
  final _semesterNoController = TextEditingController();

  List<dynamic> _studentsData = [];
  bool _isLoading = false;

  Future<void> _fetchStudentData() async {
    if (_userIdController.text.isEmpty) {
      _showSnackbar('Please enter a User ID first');
      return;
    }

    setState(() {
      _isLoading = true;
      _studentsData.clear();
    });

    try {
      final response = await http.get(
        Uri.parse(
          'https://devtechtop.com/management/public/api/select_data?user_id=${_userIdController.text}',
        ),
      );

      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        setState(() {
          _studentsData =
              (data['data'] ?? [])
                  .where(
                    (record) =>
                        record['user_id'].toString() == _userIdController.text,
                  )
                  .toList();
        });

        if (_studentsData.isEmpty) {
          _showSnackbar('No records found for this User ID');
        }
      } else {
        throw Exception('Failed with status: ${response.statusCode}');
      }
    } catch (e) {
      _showSnackbar('Error fetching data: $e');
    } finally {
      setState(() {
        _isLoading = false;
      });
    }
  }

  Future<void> _submitStudentData() async {
    if (!_formKey.currentState!.validate()) return;

    setState(() {
      _isLoading = true;
    });

    try {
      final url = Uri.parse(
        'https://devtechtop.com/management/public/api/grades',
      ).replace(
        queryParameters: {
          'user_id': _userIdController.text,
          'course_name': _courseNameController.text,
          'credit_hours': _creditHourController.text,
          'marks': _marksController.text,
          'semester_no': _semesterNoController.text,
        },
      );

      final response = await http.get(url);

      if (response.statusCode == 200 || response.statusCode == 201) {
        _showSnackbar('Data added successfully!');
        _formKey.currentState!.reset();
        await _fetchStudentData();
      } else {
        throw Exception('Failed to add data');
      }
    } catch (e) {
      _showSnackbar('Error submitting data: $e');
    } finally {
      setState(() {
        _isLoading = false;
      });
    }
  }

  void _showSnackbar(String message) {
    ScaffoldMessenger.of(
      context,
    ).showSnackBar(SnackBar(content: Text(message)));
  }

  Widget _buildTextInput(
    String label,
    TextEditingController controller,
    TextInputType type,
  ) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 6),
      child: TextFormField(
        controller: controller,
        decoration: InputDecoration(
          labelText: label,
          border: const OutlineInputBorder(),
        ),
        keyboardType: type,
        validator:
            (value) => value == null || value.isEmpty ? 'Enter $label' : null,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Student Data Management'),
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh),
            onPressed: _fetchStudentData,
            tooltip: 'Fetch Data',
          ),
        ],
      ),
      body:
          _isLoading
              ? const Center(child: CircularProgressIndicator())
              : SingleChildScrollView(
                padding: const EdgeInsets.all(16),
                child: Column(
                  children: [
                    Card(
                      elevation: 3,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: Padding(
                        padding: const EdgeInsets.all(16),
                        child: Form(
                          key: _formKey,
                          child: Column(
                            children: [
                              const Text(
                                'Enter Student Data',
                                style: TextStyle(
                                  fontWeight: FontWeight.bold,
                                  fontSize: 16,
                                ),
                              ),
                              const SizedBox(height: 12),
                              _buildTextInput(
                                'User ID',
                                _userIdController,
                                TextInputType.number,
                              ),
                              _buildTextInput(
                                'Course Name',
                                _courseNameController,
                                TextInputType.text,
                              ),
                              _buildTextInput(
                                'Credit Hours',
                                _creditHourController,
                                TextInputType.number,
                              ),
                              _buildTextInput(
                                'Marks',
                                _marksController,
                                TextInputType.number,
                              ),
                              _buildTextInput(
                                'Semester No',
                                _semesterNoController,
                                TextInputType.number,
                              ),
                              const SizedBox(height: 12),
                              Row(
                                children: [
                                  Expanded(
                                    child: ElevatedButton.icon(
                                      icon: const Icon(Icons.cloud_upload),
                                      label: const Text('Submit'),
                                      onPressed: _submitStudentData,
                                    ),
                                  ),
                                  const SizedBox(width: 10),
                                  Expanded(
                                    child: OutlinedButton.icon(
                                      icon: const Icon(Icons.search),
                                      label: const Text('Fetch'),
                                      onPressed: _fetchStudentData,
                                    ),
                                  ),
                                ],
                              ),
                            ],
                          ),
                        ),
                      ),
                    ),
                    const SizedBox(height: 20),
                    _buildStudentList(),
                  ],
                ),
              ),
    );
  }

  Widget _buildStudentList() {
    return _studentsData.isEmpty
        ? const Text('No records found.')
        : ListView.builder(
          shrinkWrap: true,
          physics: const NeverScrollableScrollPhysics(),
          itemCount: _studentsData.length,
          itemBuilder: (context, index) {
            final student = _studentsData[index];
            return Card(
              margin: const EdgeInsets.symmetric(vertical: 6),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(10),
              ),
              elevation: 2,
              child: ListTile(
                title: Text(student['course_name'] ?? ''),
                subtitle: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text('User ID: ${student['user_id']}'),
                    Text('Credit Hours: ${student['credit_hours']}'),
                    Text('Marks: ${student['marks']}'),
                    Text('Semester: ${student['semester_no']}'),
                  ],
                ),
              ),
            );
          },
        );
  }

  @override
  void dispose() {
    _userIdController.dispose();
    _courseNameController.dispose();
    _creditHourController.dispose();
    _marksController.dispose();
    _semesterNoController.dispose();
    super.dispose();
  }
}
