class AcademicAttendanceRecord {
  final int recordId;
  final String studentId;
  final String studentName;
  final String status;

  AcademicAttendanceRecord({
    required this.recordId,
    required this.studentId,
    required this.studentName,
    required this.status,
  });

  factory AcademicAttendanceRecord.fromJson(Map<String, dynamic> json) {
    return AcademicAttendanceRecord(
      recordId: int.tryParse(json['record_id']?.toString() ?? '0') ?? 0,
      studentId: json['matric_no']?.toString() ?? 'N/A',
      studentName: json['student_name']?.toString() ?? 'Unknown',
      status: json['status']?.toString() ?? 'Present',
    );
  }
}

class AttendanceRecord {
  final int id;
  final String studentId;
  final String name;
  final String studentName;
  final String matricId;
  final String status;
  double? marks;
  String? gradeCategory;

  AttendanceRecord({
    required this.id,
    required this.studentName,
    required this.studentId,
    required this.name,
    required this.matricId,
    required this.status,
    this.marks,
    this.gradeCategory,
  });

  factory AttendanceRecord.fromJson(Map<String, dynamic> json) {
    return AttendanceRecord(
      id: json['id'],
      // Accessing the nested student and user data from your controller
      studentName: json['student']?['user']?['name'] ?? "Unknown",
      studentId: json['student']?['student_id'] ?? "N/A",
      name: json['student']?['name'] ?? "Unknown",
      matricId: json['student']?['matric_id'] ?? "N/A",
      status: json['status'] ?? "Absent",
      marks: json['marks'] != null ? double.parse(json['marks'].toString()) : null,
      gradeCategory: json['grade_category'],
    );
  }
}