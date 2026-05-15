class LabModel {

  final int labId;

  final String labName;

  final int capacity;

  final int enrolled;

  final String scheduleDay;

  final String scheduleTime;

  LabModel({

    required this.labId,

    required this.labName,

    required this.capacity,

    required this.enrolled,

    required this.scheduleDay,

    required this.scheduleTime,
  });

  factory LabModel.fromJson(
      Map<String, dynamic> json) {

    return LabModel(

      labId: json['lab_id'] ?? 0,

      labName:
          json['lab_name'] ?? '',

      capacity:
          json['capacity'] ?? 0,

      enrolled:
          json['enrolled'] ?? 0,

      scheduleDay:
          json['schedule_day'] ?? '',

      scheduleTime:
          json['schedule_time'] ?? '',
    );
  }
}