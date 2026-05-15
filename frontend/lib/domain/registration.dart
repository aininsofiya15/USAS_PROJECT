class Registration {

  final int registrationId;

  final String subjectCode;

  final String subjectName;

  final int creditHours;

  final String? labName;

  final String? scheduleDay;

  final String? scheduleTime;

  Registration({

    required this.registrationId,

    required this.subjectCode,

    required this.subjectName,

    required this.creditHours,

    required this.labName,

    required this.scheduleDay,

    required this.scheduleTime,
  });

  factory Registration.fromJson(
      Map<String, dynamic> json) {

    return Registration(

      registrationId:
          json['registration_id'] ?? 0,

      subjectCode:
          json['subject_code'] ?? '',

      subjectName:
          json['subject_name'] ?? '',

      creditHours:
          json['credit_hours'] ?? 0,

      labName:
          json['lab_name'],

      scheduleDay:
          json['schedule_day'],

      scheduleTime:
          json['schedule_time'],
    );
  }
}