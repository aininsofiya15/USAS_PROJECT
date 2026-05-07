class Api {
  // Emulator: http://10.0.2.2:8000/api
  // Chrome: http://127.0.0.1:8000/api
  static const String baseUrl = "http://127.0.0.1:8000/api";

  // Auth 
  static  String login = "$baseUrl/login";

  // Pusat Adab Module
  static  String modules = "$baseUrl/modules";
  

  // Student
  static String applyModule = "$baseUrl/modules/apply";
  static String studentBookings(String studentId) => "$baseUrl/students/$studentId/bookings";

  // Attendance 
  static const String lecturerSubjects = "$baseUrl/lecturer/subjects";
  //static const String attendance = "$baseUrl/attendance";
  //static const String creditClaim = "$baseUrl/credit-claim";
}