import 'lab.dart';

class SectionModel {

  final int sectionId;

  final String sectionNo;

  final int capacity;

  final int registeredCount;

  final List<LabModel> labs;

  SectionModel({

    required this.sectionId,

    required this.sectionNo,

    required this.capacity,

    required this.registeredCount,

    required this.labs,
  });

  factory SectionModel.fromJson(
      Map<String, dynamic> json) {

    return SectionModel(

      sectionId:
          json['section_id'] ?? 0,

      sectionNo:
          json['section_no'] ?? '',

      capacity:
          json['capacity'] ?? 0,

      registeredCount:
          json['registered_count'] ?? 0,

      labs:
          (json['labs'] as List?)

                  ?.map(
                    (lab) =>
                        LabModel.fromJson(
                      lab,
                    ),
                  )

                  .toList()

              ??

              [],
    );
  }
}