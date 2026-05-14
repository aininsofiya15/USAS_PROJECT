class CreditClaim {
  final int id;
  final int studentId;
  final int subjectId;
  final String status; // pending, approved, rejected
  final String subjectCode; // e.g., UQA2002
  final String subjectName; // e.g., Ko-Kurikulum

  CreditClaim({
    required this.id,
    required this.studentId,
    required this.subjectId,
    required this.status,
    required this.subjectCode,
    required this.subjectName,
  });

  factory CreditClaim.fromJson(Map<String, dynamic> json) {
    return CreditClaim(
      id: json['id'],
      studentId: json['student_id'],
      subjectId: json['subject_id'],
      status: json['status'] ?? 'pending',
      // Accessing nested subject info from Laravel join
      subjectCode: json['subject']?['subject_code'] ?? 'UQA2002',
      subjectName: json['subject']?['subject_name'] ?? 'Ko-Kurikulum',
    );
  }
}