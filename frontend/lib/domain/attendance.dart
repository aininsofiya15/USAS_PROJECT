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

  factory Subject.fromJson(Map<String, dynamic> json) {
    return Subject(
      // 1. Convert to string first, then parse to int, fallback to 0
      subjectId: int.tryParse(json['subject_id']?.toString() ?? '0') ?? 0,
      // 2. Use ?.toString() ?? '' to ensure it's never a Null type
      subjectCode: json['subject_code']?.toString() ?? 'N/A',
      subjectName: json['subject_name']?.toString() ?? 'Unknown Subject',
      sectionId: int.tryParse(json['section_id']?.toString() ?? '0') ?? 0,
      sectionNo: json['section_no']?.toString() ?? '00',
    );
  }
}

class Lab {
  final int labId;
  final String labName;

  Lab({required this.labId, required this.labName});

  factory Lab.fromJson(Map<String, dynamic> json) {
    return Lab(
      labId: int.tryParse(json['lab_id']?.toString() ?? '0') ?? 0,
      labName: json['lab_name']?.toString() ?? 'Unknown Lab',
    );
  }
}

class AttendanceSection {
  final int sectionId;
  final String sectionNo;

  AttendanceSection({required this.sectionId, required this.sectionNo});

  factory AttendanceSection.fromJson(Map<String, dynamic> json) {
    return AttendanceSection(
      sectionId: int.tryParse(json['section_id']?.toString() ?? '0') ?? 0,
      sectionNo: json['section_no']?.toString() ?? 'N/A',
    );
  }
}