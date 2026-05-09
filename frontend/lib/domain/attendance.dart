class Subject {
  final int subjectId;
  final String subjectCode;
  final String subjectName;
  final int sectionId;
  final String sectionNo;

  Subject({
    required this.subjectId,
    required this.subjectCode,
    required this.subjectName,
    required this.sectionId,
    required this.sectionNo,
  });

  // Factory to convert JSON to Subject object
  factory Subject.fromJson(Map<String, dynamic> json) {
  return Subject(
    subjectId: json['subject_id'] ?? 0,
    subjectCode: json['subject_code'] ?? 'N/A',
    subjectName: json['subject_name'] ?? 'Unknown Subject',
    sectionId: json['section_id'] ?? 0,
    sectionNo: json['section_no']?.toString() ?? '00', // Ensure string
  );
}
}


class AttendanceSection {
  final int sectionId;
  final String sectionNo;

  AttendanceSection({required this.sectionId, required this.sectionNo});

  factory AttendanceSection.fromJson(Map<String, dynamic> json) {
    return AttendanceSection(
      sectionId: json['section_id'] ?? 0,
      sectionNo: json['section_no'] ?? '',
    );
  }
}
class Attendance {
  final int? sectionId;
  final String? attendanceCode;
  final String? type;
  final String? date;
  final String? time;
  final double? lat;
  final double? long;
  final int? radius; // Added to Domain
  

  Attendance({
    this.sectionId,
    this.attendanceCode,
    this.type,
    this.date,
    this.time,
    this.lat,
    this.long,
    this.radius,
  });

  Map<String, dynamic> toJson() => {
    'section_id': sectionId,
    'type': type,
    'date': date,
    'time': time,
    'geo_lat': lat,
    'geo_long': long,
    'radius': radius ?? 500, // Default in domain
  };

  
}
