class Subject {

  final int subjectId;
  final String subjectCode;
  final String subjectName;
  final int creditHours;
  final int totalSection;
  final int totalLab;

  Subject({
    required this.subjectId,
    required this.subjectCode,
    required this.subjectName,
    required this.creditHours,
    required this.totalSection,
    required this.totalLab,
  });

  factory Subject.fromJson(Map<String, dynamic> json) {

    return Subject(
      subjectId: json['subject_id'],
      subjectCode: json['subject_code'],
      subjectName: json['subject_name'],
      creditHours: json['credit_hours'],
      totalSection: json['total_section'],
      totalLab: json['total_lab'],
    );
  }
}