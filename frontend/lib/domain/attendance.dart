class AttendanceSubject {
  final int subjectId;
  final String subjectCode;
  final String subjectName;
  final List<AttendanceSection> sections;

  AttendanceSubject({
    required this.subjectId,
    required this.subjectCode,
    required this.subjectName,
    required this.sections,
  });

  factory AttendanceSubject.fromJson(Map<String, dynamic> json) {
    var list = json['sections'] as List? ?? [];
    List<AttendanceSection> sectionList = 
        list.map((i) => AttendanceSection.fromJson(i)).toList();

    return AttendanceSubject(
      subjectId: json['subject_id'] ?? 0,
      subjectCode: json['subject_code'] ?? '',
      subjectName: json['subject_name'] ?? '',
      sections: sectionList,
    );
  }
}

class AttendanceSection {
  final int sectionId;
  final String sectionNo;

  AttendanceSection({
    required this.sectionId,
    required this.sectionNo,
  });

  factory AttendanceSection.fromJson(Map<String, dynamic> json) {
    return AttendanceSection(
      sectionId: json['section_id'] ?? 0,
      sectionNo: json['section_no'] ?? '',
    );
  }
}