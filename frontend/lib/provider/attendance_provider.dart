import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import '../config/api.dart';
import '../domain/attendance.dart';
import '../domain/attendance_record.dart';
import '../../domain/module.dart';

class AttendanceProvider with ChangeNotifier {

  // --- Academic Subjects (Friend's Part) ---
  List<Subject> _subjects = [];
  List<Subject> get subjects => _subjects;

  bool _isLoading = false;
  bool get isLoading => _isLoading;

  // --- Pusat ADAB & Grading 
  List<Module> _pusatAdabModules = [];
  List<Module> get pusatAdabModules => _pusatAdabModules;


  List<AttendanceRecord> _studentRecords = []; 
  List<AttendanceRecord> get studentRecords => _studentRecords;

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

  /// Generates the 6-digit code for a session
  Future<String?> generateAttendance({
    required int sectionId,
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
        final List<dynamic> recordList = data['records'];
        _studentRecords = recordList
            .map((json) => AttendanceRecord.fromJson(json))
            .toList();
      }
    } catch (e) {
      print("Error fetching details: $e");
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }


Future<void> updateStudentGrade(int recordId, double marks, String category) async {
  _isLoading = true;
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
      // Refresh the local student list so the UI updates with the new grade
      final index = _studentRecords.indexWhere((s) => s.id == recordId);
      if (index != -1) {
        // Assuming your AttendanceRecord has a 'copyWith' or you can update fields
        _studentRecords[index].marks = marks; 
       // _studentRecords[index].status = "Present"; // Ensure status stays correct
      }
      print("Grade updated successfully!");
    } else {
      print("Failed to update grade: ${response.body}");
    }
  } catch (e) {
    print("Error updating grade: $e");
  } finally {
    _isLoading = false;
    notifyListeners();
  }
}
}