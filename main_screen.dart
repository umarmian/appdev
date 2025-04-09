import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';
import 'course.dart';

class MainScreen extends StatefulWidget {
  const MainScreen({super.key});

  @override
  MainScreenState createState() => MainScreenState();
}

class MainScreenState extends State<MainScreen> {
  List<Course> courses = [];
  List<Course> customCourses = [];
  bool isLoading = false;

  String selectedSemester = '1';
  String? selectedSubject;
  String enteredMarks = '';
  String creditHours = '';

  @override
  void initState() {
    super.initState();
    _loadLocalData();
  }

  Future<void> _loadLocalData() async {
    final prefs = await SharedPreferences.getInstance();
    final data = prefs.getString('courses');
    final customData = prefs.getString('custom_courses');

    if (data != null) {
      courses =
          (json.decode(data) as List)
              .map((item) => Course.fromJson(item))
              .toList();
    }

    if (customData != null) {
      customCourses =
          (json.decode(customData) as List)
              .map((item) => Course.fromJson(item))
              .toList();
    }

    setState(() {});
  }

  Future<void> _fetchData() async {
    setState(() => isLoading = true);
    try {
      final response = await http.get(
        Uri.parse('https://bgnuerp.online/api/gradeapi'),
      );

      if (response.statusCode == 200) {
        final List<dynamic> data = json.decode(response.body);
        final prefs = await SharedPreferences.getInstance();
        await prefs.setString('courses', json.encode(data));
        courses = data.map((item) => Course.fromJson(item)).toList();
      }
    } catch (e) {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text('Error fetching data: $e')));
    } finally {
      setState(() => isLoading = false);
    }
  }

  Future<void> _deleteData() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove('courses');
    await prefs.remove('custom_courses');
    setState(() {
      courses.clear();
      customCourses.clear();
    });
  }

  Map<String, List<Course>> _groupBySemester(List<Course> list) {
    return list.fold(<String, List<Course>>{}, (map, course) {
      map.putIfAbsent(course.mysemester, () => []).add(course);
      return map;
    });
  }

  List<Course> getSubjectsForSemester(String semester) {
    return courses.where((c) => c.mysemester == semester).toList();
  }

  void _submitCourse() async {
    if (selectedSubject == null || enteredMarks.isEmpty) return;

    final selected = getSubjectsForSemester(
      selectedSemester,
    ).firstWhere((c) => c.coursetitle == selectedSubject);

    final newCourse = Course(
      studentname: 'Manual',
      fathername: 'Entry',
      progname: '',
      shift: '',
      rollno: '',
      coursecode: selected.coursecode,
      coursetitle: selectedSubject!,
      credithours: selected.credithours,
      obtainedmarks: enteredMarks,
      mysemester: selectedSemester,
      considerStatus: '',
    );

    setState(() {
      customCourses.add(newCourse);
    });

    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(
      'custom_courses',
      json.encode(customCourses.map((e) => e.toJson()).toList()),
    );

    enteredMarks = '';
    creditHours = '';
    selectedSubject = null;
  }

  @override
  Widget build(BuildContext context) {
    final semesterGroups = _groupBySemester(courses);
    final customSemesterGroups = _groupBySemester(customCourses);
    final availableSubjects = getSubjectsForSemester(selectedSemester);

    return Scaffold(
      appBar: AppBar(title: const Text('Student Courses')),
      body: SingleChildScrollView(
        child: Column(
          children: [
            // Buttons
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: [
                ElevatedButton(
                  onPressed: isLoading ? null : _fetchData,
                  child: const Text('Load Data'),
                ),
                ElevatedButton(
                  onPressed: _deleteData,
                  child: const Text('Erase Data'),
                ),
              ],
            ),

            const SizedBox(height: 20),
            // Form
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16),
              child: Column(
                children: [
                  DropdownButton<String>(
                    value: selectedSemester,
                    onChanged: (value) {
                      setState(() {
                        selectedSemester = value!;
                        selectedSubject = null;
                        creditHours = '';
                      });
                    },
                    items: List.generate(
                      8,
                      (index) => DropdownMenuItem(
                        value: '${index + 1}',
                        child: Text('Semester ${index + 1}'),
                      ),
                    ),
                  ),
                  DropdownButton<String>(
                    value: selectedSubject,
                    hint: const Text('Select Subject'),
                    onChanged: (value) {
                      setState(() {
                        selectedSubject = value!;
                        creditHours =
                            availableSubjects
                                .firstWhere((c) => c.coursetitle == value)
                                .credithours;
                      });
                    },
                    items:
                        availableSubjects
                            .map(
                              (c) => DropdownMenuItem(
                                value: c.coursetitle,
                                child: Text(c.coursetitle),
                              ),
                            )
                            .toList(),
                  ),
                  TextFormField(
                    decoration: const InputDecoration(labelText: 'Marks'),
                    keyboardType: TextInputType.number,
                    onChanged: (value) => enteredMarks = value,
                  ),
                  TextFormField(
                    decoration: InputDecoration(labelText: 'Credit Hours'),
                    readOnly: true,
                    controller: TextEditingController(text: creditHours),
                  ),
                  ElevatedButton(
                    onPressed: _submitCourse,
                    child: const Text('Submit'),
                  ),
                ],
              ),
            ),

            const Divider(),

            // Show API Data
            Text("Fetched Data", style: Theme.of(context).textTheme.titleLarge),
            ...semesterGroups.entries.map(
              (entry) => ExpansionTile(
                title: Text('Semester ${entry.key}'),
                children:
                    entry.value
                        .map(
                          (course) => ListTile(
                            title: Text(course.coursetitle),
                            subtitle: Text('Marks: ${course.obtainedmarks}'),
                          ),
                        )
                        .toList(),
              ),
            ),

            const Divider(),

            // Show Manually Added Data
            Text(
              "Custom Submitted Data",
              style: Theme.of(context).textTheme.titleLarge,
            ),
            ...customSemesterGroups.entries.map(
              (entry) => ExpansionTile(
                title: Text('Semester ${entry.key}'),
                children:
                    entry.value
                        .map(
                          (course) => ListTile(
                            title: Text(course.coursetitle),
                            subtitle: Text('Marks: ${course.obtainedmarks}'),
                          ),
                        )
                        .toList(),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
