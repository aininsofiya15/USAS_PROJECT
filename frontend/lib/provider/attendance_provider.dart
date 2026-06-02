import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import '../config/api.dart';
import '../domain/attendance.dart';
import '../domain/attendance_record.dart';
import '../../domain/module.dart';
import 'dart:io';
import 'dart:async'; // for TimeoutException

class AttendanceProvider with ChangeNotifier {

  bool _isLoading = false;
  bool get isLoading => _isLoading;

  bool _isSubmitting = false;
  bool get isSubmitting => _isSubmitting;

  String? _errorMessage;
  String? get errorMessage => _errorMessage;

    // --- Pusat ADAB & Grading - AININ ---------------------------
    List<Module> _pusatAdabModules = [];
    List<Module> get pusatAdabModules => _pusatAdabModules;

    // ── Attendance Detail Screen State Variables ──
    Map<String, dynamic>? _currentModuleDetails;
    Map<String, dynamic>? get currentModuleDetails => _currentModuleDetails;

    // FIX: Custom name applied to the state list array and its public getter window
    List<dynamic> _presentModuleStudent = [];
    List<dynamic> get presentModuleStudent => _presentModuleStudent;
    
    //------------------------------------------------------------

  // --- Academic Subjects  ---
  List<Subject> _subjects = [];
  List<Subject> get subjects => _subjects;

  List<Lab> _availableLabs = []; // Store fetched labs
  List<Lab> get availableLabs => _availableLabs;

  List<AttendanceRecord> _studentRecords = []; 
  List<AttendanceRecord> get studentRecords => _studentRecords;

  List<dynamic> _attendanceHistory = [];
  List<dynamic> get attendanceHistory => _attendanceHistory;

  List<AcademicAttendanceRecord> _currentClassStudents = [];
  List<AcademicAttendanceRecord> get currentClassStudents => _currentClassStudents;

  List<AttendanceRecord> _presentStudents = [];
  List<AttendanceRecord> get presentStudents => _presentStudents;

  List<AttendanceRecord> _notPresentStudents = [];
  List<AttendanceRecord> get notPresentStudents => _notPresentStudents;

  /// Fetches subjects for academic classes
  Future<void> fetchLecturerSubjects(int lecturerId) async {
    // If ID is 0, don't even try the request
    if (lecturerId == 0) {
      debugPrint("Error: Lecturer ID is 0. Check Login/UserProvider.");
      return;
    }

    _isLoading = true;
    notifyListeners();

    try {
      final response = await http.get(
        Uri.parse("${Api.lecturerSubjects}?user_id=$lecturerId"),
        headers: {
          'Content-Type': 'application/json',
          'Accept': 'application/json',
        },
      );

      if (response.statusCode == 200) {
        final Map<String, dynamic> data = jsonDecode(response.body);
        final List<dynamic> subjectList = data['data'];
        _subjects = subjectList.map((json) => Subject.fromJson(json)).toList();
      }
    } catch (e) {
      debugPrint("Network Error: ${e.toString()}");
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<void> fetchLabsForSection(int sectionId) async {
    _isLoading = true;
    _availableLabs = [];
    notifyListeners();

    try {
      final response = await http.get(
        Uri.parse("${Api.baseUrl}/sections/$sectionId/labs")
      );

      if (response.statusCode == 200) {
        List<dynamic> data = jsonDecode(response.body);
        _availableLabs = data.map((json) => Lab.fromJson(json)).toList();
      }
    } catch (e) {
      debugPrint("Error fetching labs: $e");
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  /// Generates the 6-digit code for a session
  Future<String?> generateAttendance({
    required int sectionId,
    String? labName, 
    required double lat,
    required double lng,
    required String date,
    required String time,
  }) async {
    _isLoading = true;
    notifyListeners();

    try {
      final response = await http.post(
        Uri.parse(Api.generateAttendance), 
        headers: {"Content-Type": "application/json"},
        body: jsonEncode({
          'section_id': sectionId,
          'lab_name': labName, // <--- MAKE SURE THIS IS SENT
          'geo_lat': lat,
          'geo_long': lng,
          'radius': 500,
          'date': date,
          'time': time,
        }),
      );

      if (response.statusCode == 201) {
        final resData = jsonDecode(response.body);
        return resData['code'];
      }
    } catch (e) {
      debugPrint("Error generating attendance: $e");
    } finally {
      _isLoading = false;
      notifyListeners();
    }
    return null;
  }

  Future<void> fetchAttendanceHistory(int lecturerId) async {
    _isLoading = true;
    notifyListeners();

    try {
      final response = await http.get(
        Uri.parse("${Api.baseUrl}/lecturer/$lecturerId/attendance-history")
      );

      if (response.statusCode == 200) {
        _attendanceHistory = jsonDecode(response.body);
      }
    } catch (e) {
      debugPrint("History Error: $e");
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  // Function 1: Fetch Present Students
  Future<void> fetchClassPresentStudent(int attendanceId) async {
    _isLoading = true;
    notifyListeners();
    try {
      final response = await http.get(Uri.parse('${Api.baseUrl}/attendance/present/$attendanceId'));
      if (response.statusCode == 200) {
        final List<dynamic> data = json.decode(response.body)['data'];
        // Map JSON to AttendanceRecord objects
        _presentStudents = data.map((json) => AttendanceRecord.fromJson(json)).toList();
      }
    } catch (e) {
      debugPrint("Error fetching present students: $e");
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  // Function 2: Fetch Not Present Students
  Future<void> fetchClassNotPresentStudent(int attendanceId) async {
    _isLoading = true;
    notifyListeners();
    try {
      final response = await http.get(Uri.parse('${Api.baseUrl}/attendance/not-present/$attendanceId'));
      if (response.statusCode == 200) {
        final List<dynamic> data = json.decode(response.body)['data'];
        // Map JSON to AttendanceRecord objects
        _notPresentStudents = data.map((json) => AttendanceRecord.fromJson(json)).toList();
      }
    } catch (e) {
      debugPrint("Error fetching not present students: $e");
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  //PusatAdab

  Future<void> getAdabModules({String? selectedDate}) async {
    _isLoading = true;
    notifyListeners();

    try {
      // Endpoint matches the Laravel route we created
      String url = "${Api.baseUrl}/get-adab-modules";
      if (selectedDate != null) {
        url += "?date=$selectedDate";
      }

      final response = await http.get(Uri.parse(url));

      if (response.statusCode == 200) {
        final Map<String, dynamic> decodedResponse = jsonDecode(response.body);
        
        if (decodedResponse['success'] == true) {
          final List<dynamic> data = decodedResponse['data'];
          _pusatAdabModules = data.map((json) => Module.fromJson(json)).toList();
        }
      } else {
        _pusatAdabModules = [];
      }
    } catch (e) {
      debugPrint("Error fetching modules: $e");
      _pusatAdabModules = [];
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  // 1. Add a variable to store the fetched module details
  Map<String, dynamic>? _moduleDetails;
  Map<String, dynamic>? get moduleDetails => _moduleDetails;

  // 2. Add the fetch method
  Future<void> fetchModuleDetails(int moduleId) async {
    _isLoading = true;
    notifyListeners();

    try {
      final url = Uri.parse('${Api.baseUrl}/modules/$moduleId/details');      
      final response = await http.get(
        url,
        headers: {
          'Content-Type': 'application/json',
          'Accept': 'application/json',
          // 'Authorization': 'Bearer $_token', // Uncomment if your API needs a token
        },
      );

      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        
        // Update this based on how your JSON response is actually structured
        _moduleDetails = {
          'currentStudents': data['currentStudents'] ?? 0,
          'totalStudents': data['totalStudents'] ?? 0,
          'lecturerName': data['lecturerName'] ?? 'Sir / Madam',
        };
      } else {
        debugPrint("Failed to fetch module details. Status Code: ${response.statusCode}");
        _moduleDetails = null; // Reset on failure
      }
    } catch (e) {
      debugPrint("Error fetching module details: $e");
      _moduleDetails = null; // Reset on error
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

 /// Generates the 6-digit code for a module session
  Future<String?> generateModuleAttendance({
    required int moduleId,
    required double lat,
    required double lng,
    String? date, // Optional: your Laravel controller handles it if missing
    String? time, // Optional: your Laravel controller handles it if missing
  }) async {
    _isLoading = true;
    notifyListeners();

    try {
      final response = await http.post(
        Uri.parse(Api.generateModuleAttendance), // Make sure this is in your Api class!
        headers: {
          "Content-Type": "application/json",
          "Accept": "application/json",
        },
        body: jsonEncode({
          'module_id': moduleId,
          'geo_lat': lat,
          'geo_long': lng,
          // Only send date and time if they are provided
          if (date != null) 'date': date,
          if (time != null) 'time': time,
        }),
      );

      // 201 is Created, 200 is OK (standard Laravel success codes)
      if (response.statusCode == 201 || response.statusCode == 200) {
        final resData = jsonDecode(response.body);
        return resData['code']?.toString();
      } else {
        debugPrint("Server Error [${response.statusCode}]: ${response.body}");
      }
    } catch (e) {
      debugPrint("Error generating module attendance: $e");
    } finally {
      _isLoading = false;
      notifyListeners();
    }
    return null;
  }


  //Student

List<dynamic> _studentCurriculum = [];
List<dynamic> _studentCoCurriculum = [];

List<dynamic> get studentCurriculum => _studentCurriculum;
List<dynamic> get studentCoCurriculum => _studentCoCurriculum;

Future<void> fetchStudentClassModule(String studentId) async {
  _isLoading = true;
  notifyListeners();

  try {
    final response = await http.get(
      Uri.parse("${Api.baseUrl}/student/dashboard/$studentId")
    );

    if (response.statusCode == 200) {
      final jsonResponse = jsonDecode(response.body);
      
      if (jsonResponse['success'] == true) {
        // FIX: Access the 'data' key first
        final actualData = jsonResponse['data']; 
        
        _studentCurriculum = actualData['curriculum'] ?? [];
        _studentCoCurriculum = actualData['co_curriculum'] ?? [];
      }
    }
  } catch (e) {
    debugPrint("Dashboard Fetch Error: $e");
  } finally {
    _isLoading = false;
    notifyListeners();
  }
}

List<dynamic> _attendanceSubmissions = [];
List<dynamic> get attendanceSubmissions => _attendanceSubmissions;

Future<void> getAttendanceSubmission(int sectionId, String studentId) async {
  _isLoading = true;
  _attendanceSubmissions = []; 
  notifyListeners();

  try {
    final response = await http.get(
      Uri.parse("${Api.baseUrl}/attendance/submissions/$sectionId/$studentId")
    );

    if (response.statusCode == 200) {
      final jsonResponse = jsonDecode(response.body);
      
      // FIX: Access the 'data' key here
      if (jsonResponse['success'] == true) {
        _attendanceSubmissions = jsonResponse['data'];
      }
    }
  } catch (e) {
    debugPrint("Error fetching submissions: $e");
  } finally {
    _isLoading = false;
    notifyListeners();
  }
}

Future<Map<String, dynamic>> submitAttendance({
  required int attendanceId,
  required String studentId,
  required String code,
  required double lat,
  required double lng,
}) async {
  try {
    final response = await http.post(
      Uri.parse("${Api.baseUrl}/attendance/submit"),
      headers: {
        "Content-Type": "application/json",
        "Accept": "application/json", // Forces Laravel to return JSON errors instead of HTML pages
      },
      body: jsonEncode({
        'attendance_id': attendanceId,
        'student_id': studentId,
        'code': code,
        'student_lat': lat,
        'student_lng': lng,
      }),
    );

    debugPrint("Server Status Response Code: ${response.statusCode}");
    debugPrint("Server Response Payload Body: ${response.body}");

    if (response.statusCode == 200) {
      return jsonDecode(response.body);
    }
    
    // Decode the error message from the backend if available
    final errorData = jsonDecode(response.body);
    return {
      'success': false, 
      'message': errorData['message'] ?? 'Server error: ${response.statusCode}'
    };
  } catch (e) {
    debugPrint("Network Execution Exception: $e");
    return {'success': false, 'message': 'Network timeout or connection drop: $e'};
  }
}

List<dynamic> _historyRecords = [];
List<dynamic> get historyRecords => _historyRecords;

Future<void> fetchAttendanceRecord(String studentId, {String? dateFilter}) async {
  _isLoading = true;
  _historyRecords = [];
  notifyListeners();

  try {
    // Construct the endpoint URI dynamically with an optional date parameter string
    String url = "${Api.baseUrl}/student/attendance-history/$studentId";
    if (dateFilter != null) {
      url += "?date=$dateFilter";
    }

    final response = await http.get(
      Uri.parse(url),
      headers: {"Accept": "application/json"},
    );

    if (response.statusCode == 200) {
      final jsonResponse = jsonDecode(response.body);
      if (jsonResponse['success'] == true) {
        _historyRecords = jsonResponse['data'] ?? [];
      }
    }
  } catch (e) {
    debugPrint("Failed executing history state map stream filter: $e");
  } finally {
    _isLoading = false;
    notifyListeners();
  }
}


  /// Fetches student records for a specific module session
  /// AININ
  /// 
  Future<void> fetchPusatAdabModules({String? selectedDate}) async {
  _isLoading = true;
  notifyListeners();

  try {
    // FIX 1: Point to the exact backend endpoint that worked in your browser!
    String url = "${Api.baseUrl}/attendance/pusat-adab";
    if (selectedDate != null) {
      url += "?date=$selectedDate";
    }

    final response = await http.get(Uri.parse(url));

    if (response.statusCode == 200) {
      // FIX 2: Decode the response body as a Map object first
      final Map<String, dynamic> responseData = jsonDecode(response.body);
      
      // FIX 3: Extract the actual inner array from the 'data' key wrapper safely
      final List<dynamic> dataList = responseData['data'] ?? [];
      
      // Map the inner array rows to your Module model structure
      _pusatAdabModules = dataList.map((json) => Module.fromJson(json)).toList();
    } else {
      debugPrint("Server returned error code: ${response.statusCode}");
      _pusatAdabModules = [];
    }
  } catch (e) {
    // This will catch any missing field/parsing errors from your domain class
    debugPrint("Module Fetch Error caught in pipeline: $e");
    _pusatAdabModules = [];
  } finally {
    _isLoading = false;
    notifyListeners();
  }
}

  Future<void> fetchAttendanceDetails(int moduleId) async {
    _isLoading = true;
    notifyListeners();

    try {
      final String url = "${Api.baseUrl}/attendance/pusat-adab/$moduleId/present";
      final response = await http.get(Uri.parse(url));

      if (response.statusCode == 200) {
        final Map<String, dynamic> responseData = jsonDecode(response.body);
        final Map<String, dynamic> coreData = responseData['data'] ?? {};
        
        _currentModuleDetails = coreData['module'];
        
        // FIX: Extract and save data directly to your presentModuleStudent list layout
        _presentModuleStudent = coreData['students'] ?? [];
      } else {
        _presentModuleStudent = [];
        _currentModuleDetails = null;
      }
    } catch (e) {
      debugPrint("Details Fetch Error: $e");
      _presentModuleStudent = [];
      _currentModuleDetails = null;
    } finally {
      _isLoading = false;
      notifyListeners();
    }
}

  Future<bool> submitStudentGrade(int recordId, double marks) async {
    _isSubmitting = true;
    notifyListeners(); // Tells the UI to render the loading spinner immediately

    try {

      final String fullUrl = "${Api.pusatAdabAttendance}/grade/$recordId";
      
      final response = await http.post(
        Uri.parse(fullUrl),
        headers: {
          "Content-Type": "application/json",
          "Accept": "application/json",
        },
        body: jsonEncode({
          'marks': marks,
        }),
      );

      final responseData = jsonDecode(response.body);

      if (response.statusCode == 200) {
        _isSubmitting = false;
        notifyListeners();
        return true; // Operation successful
      } else {
        // Capture any custom verification error messages sent from Laravel validation rules
        String errorMessage = responseData['error'] ?? responseData['message'] ?? 'Failed to save grade.';
        throw Exception(errorMessage);
      }
    } catch (e) {
      _isSubmitting = false;
      notifyListeners(); // Turn off loading spin state even if request fails
      rethrow; // Pass error back to the UI view screen to handle the alert snackbar
    }
  }

  Future<Map<String, dynamic>?> fetchSingleAttendance(int attendanceId) async {
  try {
    final response = await http.get(
      Uri.parse("${Api.baseUrl}/attendance/$attendanceId"),
      headers: {'Accept': 'application/json'},
    );

    if (response.statusCode == 200) {
      return jsonDecode(response.body);
    }
  } catch (e) {
    debugPrint("Fetch Detail Error: $e");
  }
  return null;
}

Future<bool> updateAttendanceDetails({
  required int attendanceId,
  required String labName,
  required String date,
  required String time,
  required double lat,
  required double lng,
}) async {
  try {
    final response = await http.post(
      Uri.parse("${Api.baseUrl}/attendance/update/$attendanceId"),
      headers: {"Content-Type": "application/json", "Accept": "application/json"},
      body: jsonEncode({
        'lab_name': labName, // <--- MUST MATCH LARAVEL VALIDATION
        'date': date,
        'time': time,
        'geo_lat': lat,
        'geo_long': lng,
      }),
    );
    return response.statusCode == 200;
  } catch (e) {
    return false;
  }
}

}