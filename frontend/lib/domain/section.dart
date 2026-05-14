class Section {

  final int sectionId;
  final int subjectId;
  final String sectionNo;
  final int capacity;

  Section({
    required this.sectionId,
    required this.subjectId,
    required this.sectionNo,
    required this.capacity,
  });

  factory Section.fromJson(Map<String, dynamic> json) {

    return Section(
      sectionId: json['section_id'],
      subjectId: json['subject_id'],
      sectionNo: json['section_no'],
      capacity: json['capacity'],
    );
  }
}