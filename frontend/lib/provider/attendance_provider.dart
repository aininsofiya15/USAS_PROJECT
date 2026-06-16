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

  // Inside your AttendanceProvider file:
  Future<void> fetchClassPresentStudent(int attendanceId) async {
    _isLoading = true;
    notifyListeners();
    try {
      final response = await http.get(Uri.parse('${Api.baseUrl}/attendance/present/$attendanceId'));
      if (response.statusCode == 200) {
        final List<dynamic> data = json.decode(response.body)['data'];
        
        // Clean parsing without changing your list type declaration
        _presentStudents = data.map((json) {
          return AttendanceRecord(
            id: int.tryParse(json['record_id']?.toString() ?? '0') ?? 0,
            studentName: json['student_name']?.toString() ?? "Unknown",
            studentId: json['matric_no']?.toString() ?? "N/A",
            name: json['student_name']?.toString() ?? "Unknown",
            matricId: json['matric_no']?.toString() ?? "N/A",
            status: json['status'] ?? "Absent",
          );
        }).toList();
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
  
  _notPresentStudents = data.map((json) {
    return AttendanceRecord(
      // Ensure IDs map safely to 0 for fallback records
      id: int.tryParse(json['id']?.toString() ?? json['record_id']?.toString() ?? '0') ?? 0,
      studentName: json['student_name']?.toString() ?? "Unknown",
      studentId: json['matric_no']?.toString() ?? "N/A",
      name: json['student_name']?.toString() ?? "Unknown",
      matricId: json['matric_no']?.toString() ?? "N/A",
      status: json['status'] ?? "absent",
    );
  }).toList();
      }
    } catch (e) {
      debugPrint("Error fetching not present students: $e");
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<void> fetchModuleSingleAttendance({
    required int recordId, 
    required String status, 
    required String remark
  }) async {
    final url = Uri.parse('${Api.baseUrl}/attendance/update/$recordId');
    
    final response = await http.post(
      url,
      headers: {'Content-Type': 'application/json'},
      body: json.encode({
        'status': status,
        'remark': remark,
      }),
    );

    if (response.statusCode == 200) {
      // Optional: Re-fetch dashboard list datasets here if you have global access to the active session ID
    } else {
      throw Exception('Failed to synchronize status update to backend controller.');
    }
  }

  Future<bool> updateAttendanceDetails({
  required int attendanceId,
  required String date,
  required String time,
  required String classType,
  required double lat, 
  required double lng,
}) async {
  try {
    // Using the URL we set up in Step 1
    final url = Uri.parse(Api.updateAttendance);
    
    final response = await http.post(
      url,
      headers: {
        'Accept': 'application/json',
        'Content-Type': 'application/json',
      },
      body: jsonEncode({
        'attendance_id': attendanceId,
        'date': date,
        'time': time,
        'class_type': classType, // Keep this for your database
        'lab_name': classType,   // ADD THIS: Send it as lab_name to satisfy Laravel's validation
      }),
    );

    if (response.statusCode == 200 || response.statusCode == 201) {
      print("Update Successful!");
      return true;
    } else {
      print("Failed to update. Status: ${response.statusCode}");
      print("Response: ${response.body}");
      return false;
    }
  } catch (e) {
    print("Error during update: $e");
    return false;
  }
}

Future<bool> syncStatusToBackend({
  required int attendanceId,
  required String matricNo,
  required String status,
  required int recordId,
}) async {
  try {
    final response = await http.post(
      Uri.parse('${Api.baseUrl}/attendance/update-status'),
      headers: {
        'Content-Type': 'application/json',
        'Accept': 'application/json',
      },
      body: json.encode({
        'attendance_id': attendanceId,
        'matric_no': matricNo,   // Pass the student's matric number string
        'status': status,        // 'present', 'late', 'absent', 'medical'
        'record_id': recordId,    // Will be 0 for students who haven't checked in yet
      }),
    );

    if (response.statusCode == 200) {
      final responseData = json.decode(response.body);
      return responseData['success'] == true;
    }
    return false;
  } catch (e) {
    debugPrint("Network synchronization error: $e");
    return false;
  }
}


Future<bool> updateStudentAttendance({
  required int attendanceId,
  required String matricNo,
  required String status,
  required int recordId,
}) async {
  try {
    // Make sure your Api.baseUrl maps correctly to http://127.0.0.1:8000/api or your local device IP
    final response = await http.post(
      Uri.parse('${Api.baseUrl}/attendance/update-status'),
      headers: {
        'Content-Type': 'application/json',
        'Accept': 'application/json',
      },
      body: json.encode({
        'attendance_id': attendanceId, // 🔑 Must match backend: $request->input('attendance_id')
        'matric_no': matricNo,         // 🔑 Must match backend: $request->input('matric_no')
        'status': status,              // 🔑 Must match backend: $request->input('status')
        'record_id': recordId,          // 🔑 Must match backend: $request->input('record_id')
      }),
    );

    if (response.statusCode == 200) {
      final responseData = json.decode(response.body);
      return responseData['success'] == true;
    }
    
    debugPrint("Server returned error status code: ${response.statusCode}");
    debugPrint("Response body: ${response.body}");
    return false;
  } catch (e) {
    debugPrint("Exception caught during sync: $e");
    return false;
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


// ------------------------------------------------------------------------------
  // AININ
// ------------------------------------------------------------------------------


  // 1. Fetch all published modules for the admin selection page
  Future<void> fetchPusatAdabModules({String? selectedDate}) async {
    _isLoading = true;
    notifyListeners(); // Tell the UI to show the loading spinner

    try {
      // Set up the API URL endpoint
      String url = "${Api.baseUrl}/attendance/pusat-adab";
      if (selectedDate != null) {
        url += "?date=$selectedDate";
      }

      // Send the GET request to our Laravel backend
      final response = await http.get(Uri.parse(url));

      if (response.statusCode == 200) {
        // Decode the raw response text into a readable Map structure
        final Map<String, dynamic> responseData = jsonDecode(response.body);
        
        // Grab the inner list out of the 'data' key wrapper safely
        final List<dynamic> dataList = responseData['data'] ?? [];
        
        // Map the database rows directly into our local Module model list
        _pusatAdabModules = dataList.map((json) => Module.fromJson(json)).toList();
      } else {
        // If the server returns an error code, reset the modules list to empty
        debugPrint("Server returned error code: ${response.statusCode}");
        _pusatAdabModules = [];
      }
    } catch (e) {
      // Catch any data mapping or parsing bugs safely
      debugPrint("Module Fetch Error caught in pipeline: $e");
      _pusatAdabModules = [];
    } finally {
      _isLoading = false;
      notifyListeners(); // Turn off the loading spinner and refresh the screen
    }
  }

  // 2. Fetch the module details and the student attendance list
  Future<void> fetchAttendanceDetails(int moduleId) async {
    _isLoading = true;
    notifyListeners(); // Tell the UI to show the loading spinner

    try {
      // Put the module ID directly into the API endpoint path
      final String url = "${Api.baseUrl}/attendance/pusat-adab/$moduleId/present";
      final response = await http.get(Uri.parse(url));

      // Check if the response is successful 
      if (response.statusCode == 200) {
        final Map<String, dynamic> responseData = jsonDecode(response.body);
        final Map<String, dynamic> coreData = responseData['data'] ?? {};
        
        // Save the module details
        _currentModuleDetails = coreData['module'];
        
        // Save the list of present students into our local array
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
      notifyListeners(); // Turn off the loading spinner
    }
  }

  // 3. Update student marks and grade category
  Future<bool> updateStudentGrade(int recordId, double marks) async {
    _isSubmitting = true;
    notifyListeners(); // Show the submission loading spinner right away

    try {
      final String fullUrl = "${Api.pusatAdabAttendance}/grade/$recordId";
      
      // Send the marks payload data to the backend server
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
        notifyListeners(); // Turn off submission loading state
        return true; // Let the UI dialog know it was a success
      } else {
        // If Laravel validation fails, read the specific error message text
        String errorMessage = responseData['error'] ?? responseData['message'] ?? 'Failed to save grade.';
        throw Exception(errorMessage);
      }
    } catch (e) {
      _isSubmitting = false;
      notifyListeners(); // Close the loading state even if the request fails
      rethrow; // Pass the error back up so the UI page can display an alert snackbar
    }
  }

  // 4. Fetch a single attendance record details 
  Future<Map<String, dynamic>?> fetchSingleAttendance(int attendanceId) async {

    try {
      // Send GET request for one specific attendance ID
      final response = await http.get(
        Uri.parse("${Api.baseUrl}/attendance/$attendanceId"),
        headers: {'Accept': 'application/json'},
      );

      if (response.statusCode == 200) {
        return jsonDecode(response.body); // Return decoded map object directly
      }
    } catch (e) {
      debugPrint("Fetch Detail Error: $e");
    }
    return null; // Return null if anything goes wrong
  }
}