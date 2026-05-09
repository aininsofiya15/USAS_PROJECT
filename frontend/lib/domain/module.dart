class Module {
  final int? id;
  final String activityName;
  final String dateTime;
  final int capacity;
  final String venue;
  final String lecturerName;
  final String status;
  final int registeredCount; 
  final String? description;   
  final String? whatsappLink;  
  final String? attendance;   
  final String? total_marks; 
  final int? isClaimed;

  Module({
    this.id,
    required this.activityName,
    required this.dateTime,
    required this.capacity,
    required this.venue,
    required this.lecturerName,
    required this.status,
    required this.registeredCount,
    this.description,          
    this.whatsappLink, 
    this.attendance,
    this.total_marks,
    this.isClaimed,
  });

  factory Module.fromJson(Map<String, dynamic> json) {
    return Module(
      id: json['id'],
      activityName: json['activity_name'] ?? '',
      dateTime: json['date_time'] ?? '',
      capacity: json['capacity'] ?? 0,
      venue: json['venue'] ?? '',
      lecturerName: json['lecturer_name'] ?? '',
      status: json['status'] ?? 'published',
      registeredCount: json['current_registration'] ?? 0, 
      description: json['description'],    
      whatsappLink: json['whatsapp_link'], 
      attendance: json['attendance'],     
      total_marks: json['total_marks'],   
      isClaimed: json['is_claimed'],
    );
  }

  
}