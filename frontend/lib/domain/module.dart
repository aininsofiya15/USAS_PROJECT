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
  
  // Custom tracking fields injected via database joins
   String? attendanceStatus;   
   double? totalMarks; 
   int? isClaimed;
   int? bookingId;

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
    this.attendanceStatus,
    this.totalMarks,
    this.isClaimed,
    this.bookingId,
  });

  factory Module.fromJson(Map<String, dynamic> json) {
    return Module(
      id: json['id'] is int ? json['id'] : int.tryParse(json['id']?.toString() ?? ''),
      activityName: json['activity_name'] ?? json['activity_Name'] ?? '',
      dateTime: json['date_time'] ?? '',
      capacity: json['capacity'] is int ? json['capacity'] : (int.tryParse(json['capacity']?.toString() ?? '') ?? 0),
      venue: json['venue'] ?? '',
      lecturerName: json['lecturer_name'] ?? '',
      status: json['status'] ?? 'published',
      registeredCount: json['current_registration'] ?? 0, 
      description: json['description'],    
      whatsappLink: json['whatsapp_link'], 
      
      // 🎯 Safe database mapping lookups
      attendanceStatus: json['attendance_status'] ?? '-',    
      totalMarks: json['total_marks'] != null ? double.tryParse(json['total_marks'].toString()) : null,    
      isClaimed: json['is_claimed'] ?? 0, // Injected fix: Removed the duplicate duplicate key line item
      bookingId: json['booking_id'] ?? 0,
    );
  }
}