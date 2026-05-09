class AttendanceSubject {
  final int subjectId;
  final String subjectCode;
  final String subjectName;
  //AININ
  final String dateTime; // Added to Domain
  final String venue; // Added to Domain
  final List<AttendanceSection> sections;

  AttendanceSubject({
    required this.subjectId,
    required this.subjectCode,
    required this.subjectName,
    //AININ
    required this.sections,
    required this.dateTime, // Added to Domain
    required this.venue, // Added to Domain 
  });

  factory AttendanceSubject.fromJson(Map<String, dynamic> json) {
    return AttendanceSubject(
      subjectId: json['subject_id'] ?? 0,
      subjectCode: json['subject_code'] ?? '',
      subjectName: json['subject_name'] ?? '',
      // Map the nested sections list
      sections: (json['sections'] as List? ?? [])
          .map((s) => AttendanceSection.fromJson(s))
          .toList(),
      dateTime: json['date_time'] ?? '',
      venue: json['venue'] ?? '',
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
  final String? dateTime; // Added to Domain
  final String? venue; // Added to Domain

  Attendance({
    this.sectionId,
    this.attendanceCode,
    this.type,
    this.date,
    this.time,
    this.lat,
    this.long,
    this.radius,
    this.dateTime,
    this.venue,
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