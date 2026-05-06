class Api {
  // Emulator: http://10.0.2.2:8000/api
  // Chrome: http://127.0.0.1:8000/api
  static const String baseUrl = "http://127.0.0.1:8000/api";

  // Auth 
  static const String login = "$baseUrl/login";

  // Pusat Adab Module
  static const String modules = "$baseUrl/modules";

  // Attendance 
  static const String lecturerSubjects = "$baseUrl/lecturer/subjects";
  //static const String attendance = "$baseUrl/attendance";
  //static const String creditClaim = "$baseUrl/credit-claim";
}