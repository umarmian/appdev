class Course {
  final String studentname;
  final String fathername;
  final String progname;
  final String shift;
  final String rollno;
  final String coursecode;
  final String coursetitle;
  final String credithours;
  final String obtainedmarks;
  final String mysemester;
  final String considerStatus;

  Course({
    required this.studentname,
    required this.fathername,
    required this.progname,
    required this.shift,
    required this.rollno,
    required this.coursecode,
    required this.coursetitle,
    required this.credithours,
    required this.obtainedmarks,
    required this.mysemester,
    required this.considerStatus,
  });

  factory Course.fromJson(Map<String, dynamic> json) => Course(
    studentname: json['studentname'] ?? '',
    fathername: json['fathername'] ?? '',
    progname: json['progname'] ?? '',
    shift: json['shift'] ?? '',
    rollno: json['rollno'] ?? '',
    coursecode: json['coursecode'] ?? '',
    coursetitle: json['coursetitle'] ?? '',
    credithours: json['credithours'] ?? '',
    obtainedmarks: json['obtainedmarks'] ?? '',
    mysemester: json['mysemester'] ?? '',
    considerStatus: json['consider_status'] ?? '',
  );

  Map<String, dynamic> toJson() => {
    'studentname': studentname,
    'fathername': fathername,
    'progname': progname,
    'shift': shift,
    'rollno': rollno,
    'coursecode': coursecode,
    'coursetitle': coursetitle,
    'credithours': credithours,
    'obtainedmarks': obtainedmarks,
    'mysemester': mysemester,
    'consider_status': considerStatus,
  };
}
