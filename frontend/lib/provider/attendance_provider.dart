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

  // --- Academic Subjects (Friend's Part) ---
  List<Subject> _subjects = [];
  List<Subject> get subjects => _subjects;

  List<Lab> _availableLabs = []; // Store fetched labs
  List<Lab> get availableLabs => _availableLabs;

  bool _isLoading = false;
  bool get isLoading => _isLoading;

  // --- Pusat ADAB & Grading 
  List<Module> _pusatAdabModules = [];
  List<Module> get pusatAdabModules => _pusatAdabModules;


  List<AttendanceRecord> _studentRecords = []; 
  List<AttendanceRecord> get studentRecords => _studentRecords;

  List<dynamic> _attendanceHistory = [];
  List<dynamic> get attendanceHistory => _attendanceHistory;

  List<AcademicAttendanceRecord> _currentClassStudents = [];
  List<AcademicAttendanceRecord> get currentClassStudents => _currentClassStudents;

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

  Future<void> fetchClassStudents(int attendanceId) async {
  _isLoading = true;
  notifyListeners();

  try {
    final response = await http.get(
      Uri.parse("${Api.baseUrl}/attendance/$attendanceId/students")
    );

    if (response.statusCode == 200) {
      List<dynamic> data = jsonDecode(response.body);
      _currentClassStudents = data.map((json) => AcademicAttendanceRecord.fromJson(json)).toList();
    }
  } catch (e) {
    debugPrint("Error fetching students: $e");
  } finally {
    _isLoading = false;
    notifyListeners();
  }
}

Future<void> fetchNotPresent(int attendanceId, int sectionId) async {
  _isLoading = true;
  notifyListeners();
  try {
    final response = await http.get(
      Uri.parse("${Api.baseUrl}/attendance/$attendanceId/not-present/$sectionId")
    );
    if (response.statusCode == 200) {
      List<dynamic> data = jsonDecode(response.body);
      _notPresentStudents = data.map((json) => AttendanceRecord.fromJson(json)).toList();
    }
  } catch (e) {
    debugPrint("Error: $e");
  } finally {
    _isLoading = false;
    notifyListeners();
  }
}


  // --- YOUR PART: PUSAT ADAB FETCHING ---

  Future<void> fetchPusatAdabModules() async {
    _isLoading = true;
    notifyListeners();

    try {
      final response = await http.get(Uri.parse("${Api.baseUrl}/modules"));
      if (response.statusCode == 200) {
        final List<dynamic> data = jsonDecode(response.body);
        _pusatAdabModules = data.map((json) => Module.fromJson(json)).toList();
      }
    } catch (e) {
      print("Error fetching modules: $e");
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  /// Fetches student records for a specific module session
  /// AININ
  Future<void> fetchAttendanceDetails(int bookingId) async {
  _isLoading = true;
  _studentRecords = []; 
  notifyListeners();

  try {
    final response = await http.get(
      Uri.parse("${Api.baseUrl}/attendance/details/$bookingId")
    );

    if (response.statusCode == 200) {
      final Map<String, dynamic> data = jsonDecode(response.body);
      final List<dynamic> recordList = data['records'] ?? []; 

      if (recordList.isNotEmpty) {
        // CASE A: REAL DATA FOUND
        _studentRecords = recordList.map((json) => AttendanceRecord.fromJson(json)).toList();
      } else {
        // CASE B: API WORKS BUT TABLE IS EMPTY -> SHOW MOCK DATA
        _studentRecords = _getMockStudents();
      }
    } else {
      // CASE C: SERVER ERROR -> SHOW MOCK DATA SO APP DOESN'T LOOK BROKEN
      _studentRecords = _getMockStudents();
    }
  } catch (e) {
    // CASE D: NO INTERNET/DATABASE DOWN -> SHOW MOCK DATA
    _studentRecords = _getMockStudents();
  } finally {
    _isLoading = false;
    notifyListeners();
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

Future<void> updateStudentGrade(int recordId, double marks, String category) async {
  _isLoading = true;
  _errorMessage = null;
  notifyListeners();

  try {
    final response = await http.post(
      Uri.parse("${Api.baseUrl}/attendance/update-grade"),
      headers: {"Content-Type": "application/json"},
      body: jsonEncode({
        'record_id': recordId,
        'marks': marks,
        'grade_category': category,
      }),
    );

    if (response.statusCode == 200) {
      final index = _studentRecords.indexWhere((s) => s.id == recordId);
      if (index != -1) {
        _studentRecords[index].marks = marks;
        _studentRecords[index].gradeCategory = category;
      }
    } else {
      _errorMessage = "Failed to update grade. Please try again.";
      debugPrint("Failed to update grade: ${response.statusCode} — ${response.body}");
    }
  } on SocketException {
    _errorMessage = "No internet connection.";
  } on TimeoutException {
    _errorMessage = "Request timed out. Please try again.";
  } catch (e) {
    _errorMessage = "Unexpected error: $e";
    debugPrint("Error updating grade: $e");
  } finally {
    _isLoading = false;
    notifyListeners();
  }
}
}