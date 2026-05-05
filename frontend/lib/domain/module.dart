class Module {
  final String activityName;
  final String dateTime;
  final int capacity;
  final String venue;
  final String lecturerName;
  final String status;
  // 1. Add this field
  final int registeredCount; 

  Module({
    required this.activityName,
    required this.dateTime,
    required this.capacity,
    required this.venue,
    required this.lecturerName,
    required this.status,
    required this.registeredCount, // 2. Add to constructor
  });

  factory Module.fromJson(Map<String, dynamic> json) {
    return Module(
      activityName: json['activity_name'] ?? '',
      dateTime: json['date_time'] ?? '',
      capacity: json['capacity'] ?? 0,
      venue: json['venue'] ?? '',
      lecturerName: json['lecturer_name'] ?? '',
      status: json['status'] ?? 'published',
      registeredCount: json['current_registration'] ?? 0, 
    );
  }
}