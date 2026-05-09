class AttendanceSubject {
  final int id;
  final String activityName; // Maps to 'activity_name' in DB
  final String name;
  final String dateTime;
  final int subjectId;
  final String venue;
  final String lecturerName;
  final String subjectCode;
  final String subjectName;
  final List<AttendanceSection> sections;

  AttendanceSubject({
    required this.id,
    required this.activityName,
    required this.name,
    required this.subjectId,
    required this.subjectCode,
    required this.subjectName,
    required this.dateTime,
    required this.sections,
    required this.venue,
    required this.lecturerName,
  });

  factory AttendanceSubject.fromJson(Map<String, dynamic> json) {
      return AttendanceSubject(
        // Match 'id' from image_19f63e.png
        id: json['id'] ?? 0,
        
        // Match 'activity_name' from image_19f63e.png
        name: json['activity_name'] ?? 'Pusat ADAB Module',
        venue: json['venue'] ?? 'Dewan Serbaguna',
        lecturerName: json['lecturer_name'] ?? 'Staff',
        // Match 'date_time' from image_19f63e.png
        dateTime: json['date_time'] ?? 'No Date', 
        activityName: json['activity_name'] ?? 'Pusat ADAB Module', // For consistency with your DB field
        // Standard fields for your teammate's academic subject logic
        subjectId: json['id'] ?? 0,
        subjectCode: 'ADAB',
        subjectName: json['activity_name'] ?? '',
        sections: [], 
      );
    }
}

// Keep AttendanceSection and Attendance classes exactly as they are below...

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