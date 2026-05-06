class Module {
  final String activityName;
  final String dateTime;
  final int capacity;
  final String venue;
  final String lecturerName;
  final String status;
  final int registeredCount; 
  final String? description;   // Add this
  final String? whatsappLink;  // Add this

  Module({
    required this.activityName,
    required this.dateTime,
    required this.capacity,
    required this.venue,
    required this.lecturerName,
    required this.status,
    required this.registeredCount,
    this.description,          // Add this
    this.whatsappLink,         // Add this
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
      description: json['description'],    // Add this
      whatsappLink: json['whatsapp_link'], // Add this
    );
  }
}