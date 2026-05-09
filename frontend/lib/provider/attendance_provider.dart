import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import '../config/api.dart';
import '../domain/attendance.dart';
import '../domain/attendance_record.dart';

class AttendanceProvider with ChangeNotifier {

  // --- Academic Subjects (Friend's Part) ---
  List<AttendanceSubject> _subjects = [];
  List<AttendanceSubject> get subjects => _subjects;

  bool _isLoading = false;
  bool get isLoading => _isLoading;

  // --- Pusat ADAB & Grading 
  AttendanceSubject? _currentActivityHeader;
  AttendanceSubject? get currentActivityHeader => _currentActivityHeader;

  List<AttendanceRecord> _studentRecords = []; 
  List<AttendanceRecord> get studentRecords => _studentRecords;

  /// Fetches subjects for academic classes
  Future<void> fetchLecturerSubjects(int lecturerId) async {
    _isLoading = true;
    notifyListeners();

    try {
      final response = await http.get(
        Uri.parse("${Api.lecturerSubjects}?user_id=$lecturerId")
      );

      if (response.statusCode == 200) {
        final Map<String, dynamic> data = jsonDecode(response.body);
        final List<dynamic> subjectList = data['data'];
        _subjects = subjectList.map((json) => AttendanceSubject.fromJson(json)).toList();
      }
    } catch (e) {
      print("Error fetching attendance data: $e");
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

      if (response.statusCode == 201 || response.statusCode == 200) {
        final resData = jsonDecode(response.body);
        return resData['code'];
      }
    } catch (e) {
      print("Error generating attendance: $e");
    } finally {
      _isLoading = false;
      notifyListeners();
    }
    return null;
  }

  // --- YOUR PART: PUSAT ADAB FETCHING ---

  Future<void> fetchPusatAdabSessions(int bookingId) async {
    _isLoading = true;
    _studentRecords = []; // Successfully clear list
    notifyListeners();

    try {
      final response = await http.get(
        Uri.parse("${Api.baseUrl}/attendance/details/$bookingId")
      );

      if (response.statusCode == 200) {
        final Map<String, dynamic> data = jsonDecode(response.body);
        
        // Fixes image_a10ff5.png: The variable name now exists at the top
        _currentActivityHeader = AttendanceSubject.fromJson(data['header']);

        final List<dynamic> recordList = data['records'];
        _studentRecords = recordList
            .map((json) => AttendanceRecord.fromJson(json))
            .toList();
      } else {
        print("Error: ${response.statusCode}");
      }
    } catch (e) {
      print("Fetch Error: $e");
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  /// Updates student marks in the attendance_records table
  Future<bool> updateStudentGrade(int recordId, double marks, String gradeCategory) async {
    try {
      final response = await http.put(
        Uri.parse("${Api.baseUrl}/attendance-records/$recordId"),
        headers: {"Content-Type": "application/json"},
        body: jsonEncode({
          'marks': marks,
          'grade_category': gradeCategory,
        }),
      );

      if (response.statusCode == 200) {
        int index = _studentRecords.indexWhere((record) => record.id == recordId);
        if (index != -1) {
          _studentRecords[index].marks = marks;
          _studentRecords[index].gradeCategory = gradeCategory;
          notifyListeners();
        }
        return true;
      }
    } catch (e) {
      print("Error updating grade: $e");
    }
    return false;
  }
}