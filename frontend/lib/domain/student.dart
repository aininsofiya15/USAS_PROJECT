class Lab {

  final int labId;
  final int sectionId;
  final String labName;
  final int capacity;
  final int enrolled;

  Lab({
    required this.labId,
    required this.sectionId,
    required this.labName,
    required this.capacity,
    required this.enrolled,
  });

  factory Lab.fromJson(Map<String, dynamic> json) {

    return Lab(
      labId: json['lab_id'],
      sectionId: json['section_id'],
      labName: json['lab_name'],
      capacity: json['capacity'],
      enrolled: json['enrolled'],
    );
  }
}