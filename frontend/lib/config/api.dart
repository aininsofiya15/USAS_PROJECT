class Api {
  // Emulator: http://10.0.2.2:8000/api
  // Chrome: http://127.0.0.1:8000/api
  static const String baseUrl = "http://10.0.2.2:8000/api";

  // Auth 
  static  String login = "$baseUrl/login";

  // Pusat Adab Module
  static  String modules = "$baseUrl/modules";
  static String pusatAdabAttendance = "$baseUrl/attendance/pusat-adab";
  static String getAdminClaims(String filter) => "$baseUrl/pusat-adab/credit-claims?filter=$filter";
  static String approveAdminClaim(int claimId) => "$baseUrl/pusat-adab/credit-claims/$claimId/approve";
  static String rejectAdminClaim(int claimId) => "$baseUrl/pusat-adab/credit-claims/$claimId/reject";

  
  // Faculty Registrar
  static String registerSubject ="$baseUrl/register-subject";
  static String subjects ="$baseUrl/subjects";
  static String lecturers ="$baseUrl/lecturers";

  // Student
  static String applyModule = "$baseUrl/modules/apply";
  static String moduleStudents(int moduleId) => "$baseUrl/modules/$moduleId/students";
  static String studentBookings(String studentId) => "$baseUrl/students/$studentId/bookings";

  static const String submitCreditClaim = "$baseUrl/credit-claims/submit";
  static String checkCreditStatus(String studentId) => "$baseUrl/credit-claims/status/$studentId";
  
  // Attendance 
static String lecturerSubjects(int lecturerId) => "$baseUrl/lecturer/subjects/$lecturerId";
  static const String generateAttendance = "$baseUrl/attendance/store";
  static const String updateAttendance = "$baseUrl/update-attendance";
  static String moduleDetails(int moduleId) => "$baseUrl/modules/$moduleId/details";
  static const String generateModuleAttendance = "$baseUrl/module-attendance/store";  
  static String releaseAdabCode(int moduleId) => "$baseUrl/modules/$moduleId/release-code";
  
  
  //static const String attendance = "$baseUrl/attendance";
  //static const String creditClaim = "$baseUrl/credit-claim";
}