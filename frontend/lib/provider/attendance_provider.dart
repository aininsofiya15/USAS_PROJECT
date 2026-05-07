import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import '../config/api.dart';
import '../domain/attendance.dart';

class AttendanceProvider with ChangeNotifier {
  List<AttendanceSubject> _subjects = [];
  List<AttendanceSubject> get subjects => _subjects;

  bool _isLoading = false;
  bool get isLoading => _isLoading;

  /// Fetches the subjects and sections for the logged-in lecturer
  Future<void> fetchLecturerSubjects(int lecturerId) async {
    _isLoading = true;
    notifyListeners();

    try {
      // Use the URL you just tested in the browser
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
    }

    _isLoading = false;
    notifyListeners();
  }

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
        Uri.parse("http://10.0.2.2:8000/api/attendance/store"),
        headers: {"Content-Type": "application/json"},
        body: jsonEncode({
          'section_id': sectionId,
          'geo_lat': lat,
          'geo_long': lng,
          'date': date,
          'time': time,
        }),
      );

      if (response.statusCode == 201 || response.statusCode == 200) {
        final resData = jsonDecode(response.body);
        return resData['code']; // Returns the generated code (e.g., 'A7B2X9')
      }
    } catch (e) {
      print("Error generating attendance: $e");
    } finally {
      _isLoading = false;
      notifyListeners();
    }
    return null;
  }
}