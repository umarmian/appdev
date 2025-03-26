import 'package:flutter/material.dart';
import 'package:fluttertoast/fluttertoast.dart';

void main() {
  runApp(const StudentProfileApp());
}

class StudentProfileApp extends StatelessWidget {
  const StudentProfileApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        primarySwatch: Colors.blue,
        fontFamily: 'Roboto',
        inputDecorationTheme: InputDecorationTheme(
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(12),
          ),
        ),
      ),
      home: const StudentProfileScreen(),
    );
  }
}

class StudentProfileScreen extends StatefulWidget {
  const StudentProfileScreen({super.key});

  @override
  State<StudentProfileScreen> createState() => _StudentProfileScreenState();
}

class _StudentProfileScreenState extends State<StudentProfileScreen> {
  final List<String> _subjects = ['Mathematics', 'Physics', 'Chemistry'];
  final List<Map<String, dynamic>> _selectedSubjects = [];
  final TextEditingController _subjectController = TextEditingController();
  final TextEditingController _marksController = TextEditingController();
  String? _selectedSubject;
  double _percentage = 0.0;
  String _grade = 'N/A';

  void _addSubject() {
    if (_selectedSubject == null) {
      _showError('Please select a subject');
      return;
    }

    if (_marksController.text.isEmpty) {
      _showError('Please enter marks');
      return;
    }

    final marks = int.tryParse(_marksController.text);
    if (marks == null || marks < 0 || marks > 100) {
      _showError('Invalid marks (0-100 only)');
      return;
    }

    setState(() {
      _selectedSubjects.add({
        'subject': _selectedSubject,
        'marks': marks,
      });
      _calculatePercentageAndGrade();
      _marksController.clear();
      _selectedSubject = null;
    });
  }

  void _calculatePercentageAndGrade() {
    if (_selectedSubjects.isEmpty) {
      setState(() {
        _percentage = 0.0;
        _grade = 'N/A';
      });
      return;
    }

    final total = _selectedSubjects.fold<int>(
        0, (sum, item) => sum + (item['marks'] as int));
    final percentage = (total / (_selectedSubjects.length * 100)) * 100;

    String grade;
    if (percentage >= 90) {
      grade = 'A+';
    } else if (percentage >= 80) {
      grade = 'A';
    } else if (percentage >= 70) {
      grade = 'B';
    } else if (percentage >= 60) {
      grade = 'C';
    } else if (percentage >= 50) {
      grade = 'D';
    } else if (percentage >= 40) {
      grade = 'E';
    } else {
      grade = 'F';
    }

    setState(() {
      _percentage = percentage;
      _grade = grade;
    });
  }

  void _addNewSubject() async {
    await showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text("New Subject"),
        content: TextField(
          controller: _subjectController,
          decoration: const InputDecoration(
            labelText: "Subject Name",
            hintText: "Enter new subject name",
          ),
          autofocus: true,
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text("Cancel"),
          ),
          ElevatedButton(
            onPressed: () {
              if (_subjectController.text.trim().isNotEmpty) {
                setState(() {
                  _subjects.add(_subjectController.text.trim());
                  _subjectController.clear();
                });
                Navigator.pop(context);
              }
            },
            child: const Text("Add"),
          ),
        ],
      ),
    );
  }

  void _showError(String message) {
    Fluttertoast.showToast(
      msg: message,
      backgroundColor: Colors.red[700],
      textColor: Colors.white,
      fontSize: 14.0,
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(20),
          child: Column(
            children: [
              _buildProfileHeader(),
              const SizedBox(height: 30),
              _buildSubjectInputCard(),
              const SizedBox(height: 30),
              _buildResultsCard(),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildProfileHeader() {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [Colors.blue[800]!, Colors.blue[400]!],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
            color: Colors.blue.withAlpha(51), // 0.2 opacity equivalent
            spreadRadius: 3,
            blurRadius: 10,
          ),
        ],
      ),
      child: Row(
        children: [
          const CircleAvatar(
            radius: 40,
            backgroundColor: Colors.white,
            child: Icon(Icons.person, size: 40, color: Colors.blue),
          ),
          const SizedBox(width: 20),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text(
                  "Umar Farooq",
                  style: TextStyle(
                    fontSize: 24,
                    fontWeight: FontWeight.bold,
                    color: Colors.white,
                  ),
                ),
                const SizedBox(height: 8),
                Text(
                  "BSCS| Roll No: 01",
                  style: TextStyle(
                    fontSize: 16,
                    color:
                        Colors.white.withAlpha(229), // 0.9 opacity equivalent
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSubjectInputCard() {
    return Card(
      elevation: 4,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(20),
      ),
      child: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          children: [
            Row(
              children: [
                const Icon(Icons.add_circle, color: Colors.blue, size: 28),
                const SizedBox(width: 10),
                Text(
                  "Add Subjects",
                  style: Theme.of(context).textTheme.titleLarge?.copyWith(
                        color: Colors.blue[800],
                        fontWeight: FontWeight.bold,
                      ),
                ),
              ],
            ),
            const SizedBox(height: 20),
            DropdownButtonFormField<String>(
              value: _selectedSubject,
              decoration: const InputDecoration(
                labelText: "Select Subject",
                prefixIcon: Icon(Icons.menu_book),
              ),
              items: _subjects
                  .map((subject) => DropdownMenuItem(
                        value: subject,
                        child: Text(subject),
                      ))
                  .toList(),
              onChanged: (value) => setState(() => _selectedSubject = value),
              isExpanded: true,
            ),
            const SizedBox(height: 15),
            TextField(
              controller: _marksController,
              keyboardType: TextInputType.number,
              decoration: const InputDecoration(
                labelText: "Marks Obtained",
                prefixIcon: Icon(Icons.score),
                suffixText: "/100",
              ),
            ),
            const SizedBox(height: 25),
            Row(
              children: [
                Expanded(
                  child: OutlinedButton.icon(
                    icon: const Icon(Icons.add_box),
                    label: const Text("New Subject"),
                    onPressed: _addNewSubject,
                    style: OutlinedButton.styleFrom(
                      padding: const EdgeInsets.symmetric(vertical: 15),
                    ),
                  ),
                ),
                const SizedBox(width: 15),
                Expanded(
                  child: ElevatedButton.icon(
                    icon: const Icon(Icons.add_chart),
                    label: const Text("Add Marks"),
                    onPressed: _addSubject,
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.blue[800],
                      padding: const EdgeInsets.symmetric(vertical: 15),
                    ),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildResultsCard() {
    return Card(
      elevation: 4,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(20),
      ),
      child: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  "Academic Performance",
                  style: Theme.of(context).textTheme.titleLarge?.copyWith(
                        color: Colors.blue[800],
                        fontWeight: FontWeight.bold,
                      ),
                ),
                Column(
                  crossAxisAlignment: CrossAxisAlignment.end,
                  children: [
                    Container(
                      padding: const EdgeInsets.symmetric(
                          horizontal: 16, vertical: 8),
                      decoration: BoxDecoration(
                        color: Colors.blue[50],
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: Text(
                        "${_percentage.toStringAsFixed(1)}%",
                        style: TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                          color: Colors.blue[800],
                        ),
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      "Grade: $_grade",
                      style: TextStyle(
                        fontSize: 14,
                        color: Colors.grey[600],
                      ),
                    ),
                  ],
                ),
              ],
            ),
            const SizedBox(height: 20),
            if (_selectedSubjects.isEmpty)
              _buildEmptyState()
            else
              Column(
                children: [
                  _buildPerformanceSummary(),
                  const SizedBox(height: 20),
                  ..._selectedSubjects
                      .map((subject) => _buildSubjectTile(subject)),
                  const SizedBox(height: 20),
                  _buildSubjectAverages(),
                ],
              ),
          ],
        ),
      ),
    );
  }

  Widget _buildPerformanceSummary() {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.grey[50],
        borderRadius: BorderRadius.circular(12),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceAround,
        children: [
          _buildStatItem("Total Subjects", _selectedSubjects.length.toString()),
          _buildStatItem("Average", "${_percentage.toStringAsFixed(1)}%"),
          _buildStatItem("Grade", _grade),
        ],
      ),
    );
  }

  Widget _buildSubjectAverages() {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.blue[50],
        borderRadius: BorderRadius.circular(12),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            "Subject Averages",
            style: TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.bold,
              color: Colors.blue[800],
            ),
          ),
          const SizedBox(height: 10),
          Column(
            children: _subjects.map((subject) {
              final subjectMarks = _selectedSubjects
                  .where((item) => item['subject'] == subject)
                  .toList();

              if (subjectMarks.isEmpty) {
                return const SizedBox.shrink();
              }

              final avg = subjectMarks
                      .map((item) => item['marks'] as int)
                      .reduce((a, b) => a + b) /
                  subjectMarks.length;

              return Padding(
                padding: const EdgeInsets.symmetric(vertical: 8),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      subject,
                      style: const TextStyle(fontWeight: FontWeight.w500),
                    ),
                    Container(
                      padding: const EdgeInsets.symmetric(
                          horizontal: 12, vertical: 6),
                      decoration: BoxDecoration(
                        color: Color.alphaBlend(
                          _getMarksColor(avg.round())
                              .withAlpha(51), // 0.2 opacity
                          Colors.white,
                        ),
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: Text(
                        "${avg.toStringAsFixed(1)}%",
                        style: TextStyle(
                          fontWeight: FontWeight.bold,
                          color: _getMarksColor(avg.round()),
                        ),
                      ),
                    ),
                  ],
                ),
              );
            }).toList(),
          ),
        ],
      ),
    );
  }

  Widget _buildStatItem(String label, String value) {
    return Column(
      children: [
        Text(
          label,
          style: TextStyle(
            fontSize: 12,
            color: Colors.grey[600],
          ),
        ),
        const SizedBox(height: 4),
        Text(
          value,
          style: const TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.bold,
          ),
        ),
      ],
    );
  }

  Widget _buildEmptyState() {
    return Container(
      padding: const EdgeInsets.symmetric(vertical: 40),
      child: Column(
        children: [
          Icon(Icons.auto_graph, size: 60, color: Colors.grey[400]),
          const SizedBox(height: 15),
          Text(
            "No subjects added yet",
            style: TextStyle(color: Colors.grey[600], fontSize: 16),
          ),
        ],
      ),
    );
  }

  Widget _buildSubjectTile(Map<String, dynamic> subject) {
    final marks = subject['marks'] as int;
    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: ListTile(
        contentPadding:
            const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(12),
          side: BorderSide(
            color: Colors.grey[200]!,
            width: 1,
          ),
        ),
        leading: Container(
          padding: const EdgeInsets.all(10),
          decoration: BoxDecoration(
            color: Colors.blue[50],
            shape: BoxShape.circle,
          ),
          child: Icon(
            Icons.school,
            color: Colors.blue[800],
          ),
        ),
        title: Text(
          subject['subject'],
          style: const TextStyle(fontWeight: FontWeight.w500),
        ),
        trailing: Container(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
          decoration: BoxDecoration(
            color: Color.alphaBlend(
              _getMarksColor(marks).withAlpha(51), // 0.2 opacity
              Colors.white,
            ),
            borderRadius: BorderRadius.circular(20),
          ),
          child: Text(
            "$marks/100",
            style: TextStyle(
              color: _getMarksColor(marks),
              fontWeight: FontWeight.bold,
            ),
          ),
        ),
      ),
    );
  }

  Color _getMarksColor(int marks) {
    if (marks < 40) return Colors.red;
    if (marks < 75) return Colors.orange;
    return Colors.green;
  }
}
