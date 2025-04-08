import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';
import 'course.dart';

class MainScreen extends StatefulWidget {
  const MainScreen({super.key}); // Fixed super parameter

  @override
  MainScreenState createState() => MainScreenState();
}

class MainScreenState extends State<MainScreen> {
  List<Course> courses = [];
  bool isLoading = false;

  @override
  void initState() {
    super.initState();
    _loadLocalData();
  }

  Future<void> _loadLocalData() async {
    final prefs = await SharedPreferences.getInstance();
    final data = prefs.getString('courses');

    if (data != null) {
      setState(() {
        courses =
            (json.decode(data) as List)
                .map((item) => Course.fromJson(item))
                .toList();
      });
    }
  }

  Future<void> _fetchData() async {
    if (!mounted) return;
    setState(() => isLoading = true);

    try {
      final response = await http.get(
        Uri.parse('https://bgnuerp.online/api/gradeapi'),
      );

      if (response.statusCode == 200) {
        final List<dynamic> data = json.decode(response.body);
        final prefs = await SharedPreferences.getInstance();

        await prefs.setString('courses', json.encode(data));

        if (mounted) {
          setState(() {
            courses = data.map((item) => Course.fromJson(item)).toList();
          });
        }
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(SnackBar(content: Text('Error fetching data: $e')));
      }
    } finally {
      if (mounted) {
        setState(() => isLoading = false);
      }
    }
  }

  Future<void> _deleteData() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove('courses');
    if (mounted) {
      setState(() => courses.clear());
    }
  }

  Map<String, List<Course>> _groupBySemester() {
    return courses.fold(<String, List<Course>>{}, (
      Map<String, List<Course>> map,
      course,
    ) {
      map.putIfAbsent(course.mysemester, () => []).add(course);
      return map;
    });
  }

  @override
  Widget build(BuildContext context) {
    final semesterGroups = _groupBySemester();

    return Scaffold(
      appBar: AppBar(title: const Text('Student Courses')),
      body: Column(
        children: [
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
          Expanded(
            child:
                courses.isEmpty
                    ? const Center(child: Text('No data available'))
                    : ListView.builder(
                      itemCount: semesterGroups.length,
                      itemBuilder: (context, index) {
                        final semester = semesterGroups.keys.elementAt(index);
                        return ExpansionTile(
                          title: Text('Semester $semester'),
                          children:
                              semesterGroups[semester]!
                                  .map(
                                    (course) => ListTile(
                                      title: Text(course.coursetitle),
                                      subtitle: Text(
                                        'Marks: ${course.obtainedmarks}',
                                      ),
                                    ),
                                  )
                                  .toList(),
                        );
                      },
                    ),
          ),
        ],
      ),
    );
  }
}
