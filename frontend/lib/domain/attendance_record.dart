// This defines the data models for attendance records 
class AcademicAttendanceRecord {
  final int recordId;
  final String studentId;
  final String studentName;
  final String status;

  // Constructor for the AcademicAttendanceRecord class
  AcademicAttendanceRecord({
    required this.recordId,
    required this.studentId,
    required this.studentName,
    required this.status,
  });

  // Factory method to create an instance of AcademicAttendanceRecord from JSON data
  factory AcademicAttendanceRecord.fromJson(Map<String, dynamic> json) {
    return AcademicAttendanceRecord(
      recordId: int.tryParse(json['record_id']?.toString() ?? '0') ?? 0,
      studentId: json['matric_no']?.toString() ?? 'N/A',
      studentName: json['student_name']?.toString() ?? 'Unknown',
      status: json['status']?.toString() ?? 'Present',
    );
  }
}

// This defines the data model for attendance records specific to Pusat Adab
class AttendanceRecord {
  final int id;
  final String studentId;
  final String name;
  final String studentName;
  final String matricId;
  final String status;
  double? marks;
  String? gradeCategory;

  // Constructor for the AttendanceRecord class
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

  // Factory method to create an instance of AttendanceRecord from JSON data
  factory AttendanceRecord.fromJson(Map<String, dynamic> json) {
    return AttendanceRecord(
      id: json['id'],
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