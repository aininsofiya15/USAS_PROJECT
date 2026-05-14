class Lecturer {

  final int lecturerId;
  final String lecturerName;
  final String lecturerEmail;

  Lecturer({
    required this.lecturerId,
    required this.lecturerName,
    required this.lecturerEmail,
  });

  factory Lecturer.fromJson(Map<String, dynamic> json) {

    return Lecturer(
      lecturerId: json['lecturer_id'],
      lecturerName: json['lecturer_name'],
      lecturerEmail: json['lecturer_email'],
    );
  }
}