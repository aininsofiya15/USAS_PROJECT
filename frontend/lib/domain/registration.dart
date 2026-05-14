class Registration {

  final int registrationId;
  final String subjectCode;
  final String subjectName;
  final int creditHours;
  final String sectionNo;

  Registration({

    required this.registrationId,

    required this.subjectCode,

    required this.subjectName,

    required this.creditHours,

    required this.sectionNo,
  });

  factory Registration.fromJson(
    Map<String, dynamic> json,
  ) {

    return Registration(

      registrationId:
          json['registration_id'],

      subjectCode:
          json['subject_code'],

      subjectName:
          json['subject_name'],

      creditHours:
          json['credit_hours'],

      sectionNo:
          json['section_no'],
    );
  }
}