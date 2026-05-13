class Registration {

  final int registrationId;
  final int studentId;
  final int sectionId;
  final String status;

  Registration({
    required this.registrationId,
    required this.studentId,
    required this.sectionId,
    required this.status,
  });

  factory Registration.fromJson(Map<String, dynamic> json) {

    return Registration(
      registrationId: json['registration_id'],
      studentId: json['student_id'],
      sectionId: json['section_id'],
      status: json['status'],
    );
  }
}