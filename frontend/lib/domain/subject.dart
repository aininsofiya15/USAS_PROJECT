class SubjectModel {

  final int subjectId;
  final String subjectCode;
  final String subjectName;
  final int creditHours;

  final List<Section> sections;

  SubjectModel({
    required this.subjectId,
    required this.subjectCode,
    required this.subjectName,
    required this.creditHours,
    required this.sections,
  });

  factory SubjectModel.fromJson(
    Map<String, dynamic> json,
  ) {

    return SubjectModel(

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
  final int registeredCount;

  Section({

    required this.sectionId,

    required this.sectionNo,

    required this.capacity,

    required this.registeredCount,
  });

  factory Section.fromJson(
    Map<String, dynamic> json,
  ) {

    return Section(

      sectionId:
          json['section_id'],

      sectionNo:
          json['section_no'],

      capacity:
          json['capacity'],

      registeredCount:
          json['registered_count'] ?? 0,
    );
  }
}