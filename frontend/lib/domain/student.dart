class Subject {

  final int subjectId;
  final String subjectCode;
  final String subjectName;
  final int creditHours;

  final List<Section> sections;

  Subject({
    required this.subjectId,
    required this.subjectCode,
    required this.subjectName,
    required this.creditHours,
    required this.sections,
  });

  factory Subject.fromJson(
    Map<String, dynamic> json,
  ) {

    return Subject(

      subjectId: json['subject_id'],

      subjectCode: json['subject_code'],

      subjectName: json['subject_name'],

      creditHours: json['credit_hours'],

      sections: (json['sections'] as List)
          .map(
            (section) =>
                Section.fromJson(section),
          )
          .toList(),
    );
  }
}

class Section {

  final int sectionId;
  final String sectionNo;
  final int capacity;

  Section({
    required this.sectionId,
    required this.sectionNo,
    required this.capacity,
  });

  factory Section.fromJson(
    Map<String, dynamic> json,
  ) {

    return Section(

      sectionId: json['section_id'],

      sectionNo: json['section_no'],

      capacity: json['capacity'],
    );
  }
}