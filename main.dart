import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:fluttertoast/fluttertoast.dart';
import 'package:dropdown_search/dropdown_search.dart';

void main() {
  runApp(const FetchDataApp());
}

class FetchDataApp extends StatelessWidget {
  const FetchDataApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'FetchData',
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(
          seedColor: Colors.deepPurple,
          brightness: Brightness.light,
        ),
        useMaterial3: true,
        cardTheme: CardTheme(
          elevation: 2,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
          ),
          margin: const EdgeInsets.symmetric(vertical: 8),
        ),
        inputDecorationTheme: InputDecorationTheme(
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(12),
          ),
          filled: true,
          fillColor: Colors.grey[50],
        ),
      ),
      debugShowCheckedModeBanner: false,
      home: const MainScreen(),
    );
  }
}

class MainScreen extends StatefulWidget {
  const MainScreen({super.key});

  @override
  State<MainScreen> createState() => _MainScreenState();
}

class _MainScreenState extends State<MainScreen> {
  int _currentIndex = 0;
  final List<Widget> _screens = [
    const SubmitDataScreen(),
    const ViewDataScreen(),
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('FetchData',
            style: TextStyle(fontWeight: FontWeight.bold)),
        centerTitle: true,
        actions: [
          IconButton(
            icon: const Icon(Icons.info_outline),
            onPressed: () {
              showAboutDialog(
                context: context,
                applicationName: 'FetchData',
                applicationVersion: '1.0.0',
                applicationLegalese: '© 2023 FetchData App',
              );
            },
          ),
        ],
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: _screens[_currentIndex],
      ),
      bottomNavigationBar: NavigationBar(
        selectedIndex: _currentIndex,
        onDestinationSelected: (index) => setState(() => _currentIndex = index),
        destinations: const [
          NavigationDestination(
            icon: Icon(Icons.upload),
            label: 'Submit Data',
          ),
          NavigationDestination(
            icon: Icon(Icons.download),
            label: 'View Data',
          ),
        ],
      ),
    );
  }
}

class SubmitDataScreen extends StatefulWidget {
  const SubmitDataScreen({super.key});

  @override
  State<SubmitDataScreen> createState() => _SubmitDataScreenState();
}

class _SubmitDataScreenState extends State<SubmitDataScreen> {
  final _formKey = GlobalKey<FormState>();
  final _userIdController = TextEditingController();
  final _semesterNoController = TextEditingController();
  final _creditsController = TextEditingController();
  final _marksController = TextEditingController();
  bool _isSubmitting = false;

  List<Map<String, dynamic>> _courses = [];
  String? _selectedCourseId;
  String? _selectedCourseName;
  bool _isLoadingCourses = false;

  @override
  void initState() {
    super.initState();
    _loadCourses();
  }

  Future<void> _loadCourses() async {
    setState(() => _isLoadingCourses = true);

    try {
      final response = await http.get(
        Uri.parse('https://bgnuerp.online/api/get_courses?user_id=12122'),
      );

      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        if (data is List) {
          setState(() {
            _courses = List<Map<String, dynamic>>.from(data);
          });
        }
      } else {
        _showError('Failed to load courses (Error ${response.statusCode})');
      }
    } catch (e) {
      _showError('Failed to load courses: ${e.toString()}');
    } finally {
      setState(() => _isLoadingCourses = false);
    }
  }

  Future<void> _submitGrade() async {
    if (!_formKey.currentState!.validate()) return;
    if (_selectedCourseId == null) {
      _showError('Please select a course');
      return;
    }

    setState(() => _isSubmitting = true);

    try {
      final response = await http.post(
        Uri.parse('https://devtechtop.com/management/public/api/grades'),
        headers: {'Content-Type': 'application/json'},
        body: json.encode({
          'user_id': _userIdController.text,
          'course_id': _selectedCourseId,
          'course_name': _selectedCourseName,
          'semester_no': _semesterNoController.text,
          'credit_hours': _creditsController.text,
          'marks': _marksController.text,
        }),
      );

      if (response.statusCode == 200 || response.statusCode == 201) {
        _showSuccess('Data submitted successfully');
        _formKey.currentState?.reset();
        setState(() {
          _selectedCourseId = null;
          _selectedCourseName = null;
        });
      } else {
        _handleErrorResponse(response);
      }
    } catch (e) {
      _showError('Failed to connect to server. Please try again.');
    } finally {
      setState(() => _isSubmitting = false);
    }
  }

  void _handleErrorResponse(http.Response response) {
    try {
      final errorData = json.decode(response.body);
      if (errorData.containsKey('errors')) {
        final errors = errorData['errors'] as Map<String, dynamic>;
        final errorMessage = errors.entries
            .map((e) => '${e.key}: ${e.value.join(', ')}')
            .join('\n');
        _showError(errorMessage);
      } else {
        _showError(
            errorData['message'] ?? 'Submission failed. Please try again.');
      }
    } catch (e) {
      _showError('Server returned an unexpected response');
    }
  }

  void _showSuccess(String message) {
    Fluttertoast.showToast(
      msg: message,
      toastLength: Toast.LENGTH_LONG,
      backgroundColor: Colors.green,
      textColor: Colors.white,
    );
  }

  void _showError(String message) {
    Fluttertoast.showToast(
      msg: message,
      toastLength: Toast.LENGTH_LONG,
      backgroundColor: Colors.red,
      textColor: Colors.white,
    );
  }

  Widget _buildCourseDropdown() {
    return _isLoadingCourses
        ? const Center(child: CircularProgressIndicator())
        : DropdownSearch<Map<String, dynamic>>(
            items: _courses,
            itemAsString: (course) =>
                "${course['subject_code']} - ${course['subject_name']}",
            selectedItem: _selectedCourseId != null
                ? _courses.firstWhere(
                    (course) => course['id'].toString() == _selectedCourseId,
                    orElse: () => {},
                  )
                : null,
            onChanged: (course) {
              if (course != null) {
                setState(() {
                  _selectedCourseId = course['id'].toString();
                  _selectedCourseName = course['subject_name'];
                });
              }
            },
            popupProps: PopupProps.menu(
              showSearchBox: true,
              searchFieldProps: TextFieldProps(
                decoration: InputDecoration(
                  hintText: 'Search course...',
                  prefixIcon: const Icon(Icons.search),
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                ),
              ),
              menuProps: MenuProps(
                borderRadius: BorderRadius.circular(12),
                elevation: 4,
              ),
              itemBuilder: (context, item, isSelected) => ListTile(
                title:
                    Text("${item['subject_code']} - ${item['subject_name']}"),
              ),
            ),
            dropdownDecoratorProps: DropDownDecoratorProps(
              dropdownSearchDecoration: InputDecoration(
                labelText: 'Select Course',
                hintText: 'Select a course',
                prefixIcon: const Icon(Icons.school),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
              ),
            ),
            validator: (value) =>
                value == null ? 'Please select a course' : null,
          );
  }

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      child: Column(
        children: [
          Card(
            child: Padding(
              padding: const EdgeInsets.all(16.0),
              child: Column(
                children: [
                  const Text(
                    'Submit New Data',
                    style: TextStyle(
                      fontSize: 20,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 16),
                  Form(
                    key: _formKey,
                    child: Column(
                      children: [
                        TextFormField(
                          controller: _userIdController,
                          decoration: const InputDecoration(
                            labelText: 'User ID',
                            prefixIcon: Icon(Icons.person),
                          ),
                          validator: (value) => value?.isEmpty ?? true
                              ? 'User ID is required'
                              : null,
                        ),
                        const SizedBox(height: 16),
                        _buildCourseDropdown(),
                        const SizedBox(height: 16),
                        TextFormField(
                          controller: _semesterNoController,
                          decoration: const InputDecoration(
                            labelText: 'Semester Number',
                            prefixIcon: Icon(Icons.format_list_numbered),
                          ),
                          validator: (value) => value?.isEmpty ?? true
                              ? 'Semester is required'
                              : null,
                        ),
                        const SizedBox(height: 16),
                        TextFormField(
                          controller: _creditsController,
                          decoration: const InputDecoration(
                            labelText: 'Credit Hours',
                            prefixIcon: Icon(Icons.credit_score),
                          ),
                          keyboardType: TextInputType.number,
                          validator: (value) {
                            if (value?.isEmpty ?? true) {
                              return 'Credit hours are required';
                            }
                            if (double.tryParse(value!) == null) {
                              return 'Enter valid number';
                            }
                            return null;
                          },
                        ),
                        const SizedBox(height: 16),
                        TextFormField(
                          controller: _marksController,
                          decoration: const InputDecoration(
                            labelText: 'Marks',
                            prefixIcon: Icon(Icons.score),
                          ),
                          keyboardType: TextInputType.number,
                          validator: (value) {
                            if (value?.isEmpty ?? true)
                              return 'Marks are required';
                            if (double.tryParse(value!) == null) {
                              return 'Enter valid number';
                            }
                            return null;
                          },
                        ),
                        const SizedBox(height: 24),
                        SizedBox(
                          width: double.infinity,
                          child: FilledButton(
                            onPressed: _isSubmitting ? null : _submitGrade,
                            child: _isSubmitting
                                ? const CircularProgressIndicator()
                                : const Text('SUBMIT DATA'),
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  @override
  void dispose() {
    _userIdController.dispose();
    _semesterNoController.dispose();
    _creditsController.dispose();
    _marksController.dispose();
    super.dispose();
  }
}

class ViewDataScreen extends StatefulWidget {
  const ViewDataScreen({super.key});

  @override
  State<ViewDataScreen> createState() => _ViewDataScreenState();
}

class _ViewDataScreenState extends State<ViewDataScreen> {
  final _userIdController = TextEditingController();
  List<dynamic> _grades = [];
  bool _isLoading = false;

  Future<void> _fetchGrades() async {
    if (_userIdController.text.isEmpty) {
      _showError('Please enter User ID');
      return;
    }

    setState(() {
      _isLoading = true;
      _grades = [];
    });

    try {
      final response = await http.post(
        Uri.parse('https://devtechtop.com/management/public/api/select_data'),
        headers: {'Content-Type': 'application/json'},
        body: json.encode({'user_id': _userIdController.text}),
      );

      _handleFetchResponse(response);
    } catch (e) {
      _showError('Failed to connect to server. Please try again.');
    } finally {
      setState(() => _isLoading = false);
    }
  }

  void _handleFetchResponse(http.Response response) {
    debugPrint('Response status: ${response.statusCode}');
    debugPrint('Response body: ${response.body}');

    if (response.statusCode == 200) {
      try {
        final data = json.decode(response.body);
        if (data is List) {
          setState(() => _grades = data);
        } else if (data is Map && data.containsKey('data')) {
          final gradesData = data['data'];
          if (gradesData is List) {
            setState(() => _grades = gradesData);
          } else {
            _showError('Unexpected data format in response');
            return;
          }
        } else {
          _showError('Server returned unexpected format');
          return;
        }

        if (_grades.isEmpty) {
          _showInfo('No data found for this user');
        }
      } catch (e) {
        _showError('Failed to parse server response');
      }
    } else {
      _showError('Server error: ${response.statusCode}');
    }
  }

  Future<void> _fetchLastUserId() async {
    setState(() => _isLoading = true);
    try {
      final response = await http.get(
        Uri.parse('https://devtechtop.com/management/public/api/grades'),
      );

      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        if (data is List && data.isNotEmpty) {
          _userIdController.text = data.last['user_id'].toString();
        } else if (data is Map && data.containsKey('data')) {
          final grades = data['data'] as List;
          if (grades.isNotEmpty) {
            _userIdController.text = grades.last['user_id'].toString();
          }
        }
      }
    } catch (e) {
      _showError('Failed to fetch last user ID');
    } finally {
      setState(() => _isLoading = false);
    }
  }

  void _showError(String message) {
    Fluttertoast.showToast(
      msg: message,
      toastLength: Toast.LENGTH_LONG,
      backgroundColor: Colors.red,
      textColor: Colors.white,
    );
  }

  void _showInfo(String message) {
    Fluttertoast.showToast(
      msg: message,
      toastLength: Toast.LENGTH_LONG,
      backgroundColor: Colors.blue,
      textColor: Colors.white,
    );
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Card(
          child: Padding(
            padding: const EdgeInsets.all(16.0),
            child: Column(
              children: [
                const Text(
                  'View Data',
                  style: TextStyle(
                    fontSize: 20,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 16),
                Row(
                  children: [
                    Expanded(
                      child: TextField(
                        controller: _userIdController,
                        decoration: const InputDecoration(
                          labelText: 'User ID',
                          prefixIcon: Icon(Icons.person),
                        ),
                      ),
                    ),
                    const SizedBox(width: 8),
                    IconButton.filled(
                      onPressed: _fetchGrades,
                      icon: const Icon(Icons.search),
                      tooltip: 'Fetch Data',
                    ),
                    IconButton.filledTonal(
                      onPressed: _fetchLastUserId,
                      icon: const Icon(Icons.history),
                      tooltip: 'Last User ID',
                    ),
                  ],
                ),
              ],
            ),
          ),
        ),
        const SizedBox(height: 16),
        Expanded(
          child: _isLoading
              ? const Center(child: CircularProgressIndicator())
              : _grades.isEmpty
                  ? const Center(
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Icon(Icons.data_exploration,
                              size: 64, color: Colors.grey),
                          SizedBox(height: 16),
                          Text(
                            'No data to display',
                            style: TextStyle(fontSize: 18, color: Colors.grey),
                          ),
                        ],
                      ),
                    )
                  : ListView.builder(
                      itemCount: _grades.length,
                      itemBuilder: (context, index) {
                        final grade = _grades[index];
                        return Card(
                          child: Padding(
                            padding: const EdgeInsets.all(16.0),
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  grade['course_name']?.toString() ??
                                      'Unknown Course',
                                  style: const TextStyle(
                                    fontWeight: FontWeight.bold,
                                    fontSize: 18,
                                  ),
                                ),
                                const SizedBox(height: 8),
                                Row(
                                  children: [
                                    Chip(
                                      label: Text(
                                          'Semester: ${grade['semester_no'] ?? 'N/A'}'),
                                    ),
                                    const SizedBox(width: 8),
                                    Chip(
                                      label: Text(
                                          'Credits: ${grade['credit_hours'] ?? 'N/A'}'),
                                    ),
                                  ],
                                ),
                                const SizedBox(height: 8),
                                LinearProgressIndicator(
                                  value: (double.tryParse(
                                              grade['marks']?.toString() ??
                                                  '0') ??
                                          0) /
                                      100,
                                  backgroundColor: Colors.grey[200],
                                  color: Theme.of(context).primaryColor,
                                ),
                                const SizedBox(height: 4),
                                Align(
                                  alignment: Alignment.centerRight,
                                  child: Text(
                                    'Marks: ${grade['marks'] ?? 'N/A'}',
                                    style: const TextStyle(
                                      fontWeight: FontWeight.bold,
                                    ),
                                  ),
                                ),
                              ],
                            ),
                          ),
                        );
                      },
                    ),
        ),
      ],
    );
  }

  @override
  void dispose() {
    _userIdController.dispose();
    super.dispose();
  }
}
