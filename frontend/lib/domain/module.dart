class Module {
  final int? id; // Nullable because it doesn't exist until saved
  final String activityName;
  final String dateTime;
  final String capacity;
  final String venue;
  final String lecturerName;
  final String status; // 'published' or 'draft'

  Module({
    this.id,
    required this.activityName,
    required this.dateTime,
    required this.capacity,
    required this.venue,
    required this.lecturerName,
    required this.status,
  });

  // Converts the data into a Map to send to Laravel API
  Map<String, dynamic> toJson() {
    return {
      'activity_name': activityName,
      'date_time': dateTime,
      'capacity': capacity,
      'venue': venue,
      'lecturer_name': lecturerName,
      'status': status,
    };
  }
}