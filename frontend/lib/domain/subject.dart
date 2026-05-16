import 'section.dart';

class SubjectModel {

  final int subjectId;

  final String subjectCode;

  final String subjectName;

  final int creditHours;

  final List<SectionModel> sections;

  SubjectModel({

    required this.subjectId,

    required this.subjectCode,

    required this.subjectName,

    required this.creditHours,

    required this.sections,
  });

  factory SubjectModel.fromJson(
      Map<String, dynamic> json) {

    return SubjectModel(

      subjectId:
          json['subject_id'] ?? 0,

      subjectCode:
          json['subject_code'] ?? '',

      subjectName:
          json['subject_name'] ?? '',

      creditHours:
          json['credit_hours'] ?? 0,

      sections:
          (json['sections'] as List?)

                  ?.map(
                    (section) =>
                        SectionModel.fromJson(
                      section,
                    ),
                  )

                  .toList()

              ??

              [],
    );
  }
}