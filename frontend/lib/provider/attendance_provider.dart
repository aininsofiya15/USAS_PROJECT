import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import '../config/api.dart';
import '../domain/attendance.dart';
import '../domain/attendance_record.dart';



class AttendanceProvider with ChangeNotifier {
  List<Subject> _subjects = []; // Your flat Subject domain
  List<Subject> get subjects => _subjects;

  bool _isLoading = false;
  bool get isLoading => _isLoading;

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
        final data = json.decode(response.body);
        
        // Safety check: Access the 'data' key from your Laravel response
        if (data['data'] != null) {
          final List<dynamic> subjectList = data['data'];
          _subjects = subjectList.map((json) => Subject.fromJson(json)).toList();
          debugPrint("Successfully loaded ${_subjects.length} subject rows.");
        } else {
          _subjects = [];
        }
      } else {
        debugPrint("Server Error: ${response.statusCode}");
      }
    } catch (e) {
      debugPrint("Network Error: ${e.toString()}");
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }


  /// Generates attendance code using the new simplified store logic
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
          'date': date,
          'time': time,
        }),
      );

      if (response.statusCode == 201) {
        final resData = jsonDecode(response.body);
        return resData['code']; // Returns the 6-char code
      }
    } catch (e) {
      debugPrint("Error generating attendance: $e");
    } finally {
      _isLoading = false;
      notifyListeners();
    }
    return null;
  }

  // --- Pusat ADAB Extensions ---
  
  // Inside AttendanceProvider.dart

 // --- YOUR PART: PUSAT ADAB & GRADING (Project Lead) ---

  // 1. Define the student list (Fixes image_1bad16.png)
  List<AttendanceRecord> _attendanceRecords = []; 
  List<AttendanceRecord> get attendanceRecords => _attendanceRecords;

  // 2. Fetch Modules from Bookings (For image_1acc8f.png)
  Future<void> fetchPusatAdabSessions() async {
      _isLoading = true;
      notifyListeners();
      try {
        final response = await http.get(Uri.parse("${Api.baseUrl}/pusat-adab/modules"));
        
        if (response.statusCode == 200) {
          List data = json.decode(response.body);
          // This will now only contain 'published' modules
          _subjects = data.map((item) => Subject.fromJson(item)).toList();
        }
      } catch (e) {
        debugPrint("Error: $e");
      } finally {
        _isLoading = false;
        notifyListeners();
      }
  }
}