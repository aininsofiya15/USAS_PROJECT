import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import '../config/api.dart'; 
import '../domain/module.dart';
import '../domain/attendance_record.dart'; 

class ModuleProvider with ChangeNotifier {
  List<Module> _modules = [];
  List<Module> get modules => _modules;

  bool _isLoading = false;
  bool get isLoading => _isLoading;

  String? _errorMessage;
  String? get errorMessage => _errorMessage;

  List<Module> _bookedModules = [];
  List<Module> get bookedModules => _bookedModules;

  // 1. Fetch all available modules catalog from Laravel
  Future<void> fetchModules() async {
    _isLoading = true;
    notifyListeners(); // Turn on loading spinner

    try {
      final response = await http.get(Uri.parse("${Api.baseUrl}/modules"));

      if (response.statusCode == 200) {
        final Map<String, dynamic> responseData = jsonDecode(response.body);
        final List<dynamic> modulesList = responseData['data'];

        // Map the backend data directly into our local Module model list
        _modules = modulesList.map((json) => Module.fromJson(json)).toList();
      }
    } catch (e) {
      debugPrint("Error fetching modules data: $e");
    } finally {
      _isLoading = false;
      notifyListeners(); // Turn off loading spinner
    }
  }

  // 2. Create and publish a new module 
  Future<bool> createModule({
    required String activityName,
    required String dateTime,
    required int capacity,
    required String venue,
    required String lecturerName,
    String? description,
    String? whatsappLink,
    String status = 'published',
  }) async {
    _isLoading = true;
    notifyListeners(); // Turn on loading spinner

    try {
      final response = await http.post(
        Uri.parse(Api.modules),
        headers: {"Content-Type": "application/json"},
        body: jsonEncode({
          'activity_name': activityName,
          'date_time': dateTime,
          'capacity': capacity,
          'venue': venue,
          'lecturer_name': lecturerName,
          'description': description,
          'whatsapp_link': whatsappLink,
          'status': status,
        }),
      );

      _isLoading = false;
      
      if (response.statusCode == 201) {
        await fetchModules(); // Re-fetch the list so the new module shows up right away
        return true;
      }
      notifyListeners();
      return false;
    } catch (e) {
      _isLoading = false;
      notifyListeners();
      return false;
    }
  }

  // 3. Update an existing module's details
  Future<bool> updateModule({
    required String id, 
    required String activityName,
    required String dateTime,
    required int capacity,
    required String venue,
    required String lecturerName,
    String? description,
    String? whatsappLink,
    required String status,
  }) async {
    _isLoading = true;
    notifyListeners(); // Turn on loading spinner

    try {
      final url = Uri.parse("${Api.modules}/update-existing");

      final response = await http.post(
        url,
        headers: {"Content-Type": "application/json"},
        body: jsonEncode({
          'id': id,            
          'activity_name': activityName,   
          'date_time': dateTime,
          'capacity': capacity,
          'venue': venue,
          'lecturer_name': lecturerName,
          'description': description,
          'whatsapp_link': whatsappLink,
          'status': status,
        }),
      );

      _isLoading = false;

      if (response.statusCode == 200) {
        await fetchModules(); // Re-fetch list to show edited changes instantly
        return true;
      } else {
        debugPrint("Backend Error Code: ${response.statusCode}");
        notifyListeners();
        return false;
      }
    } catch (e) {
      debugPrint("Error updating module: $e");
      _isLoading = false;
      notifyListeners();
      return false;
    }
  }

  // 4. Let a student register/join a specific module 
  Future<bool> applyToModule({required int moduleId, required String studentId}) async {
    _isLoading = false;
    _errorMessage = null; // Reset old error messages before running
    notifyListeners();

    try {
      final response = await http.post(
        Uri.parse(Api.applyModule),
        headers: {"Content-Type": "application/json"},
        body: jsonEncode({
          'module_id': moduleId,
          'student_id': studentId,
        }),
      );

      _isLoading = false;

      if (response.statusCode == 200) {
        await fetchModules(); // Re-fetch catalogs to update total counter metrics
        await fetchStudentBookings(studentId); // Sync the student's personal calendar list
        return true;
      } 
      else {
        // Read the message if student hits a duplicate booking boundary rule
        try {
          final data = jsonDecode(response.body);
          _errorMessage = data['message']; 
        } catch (_) {
          _errorMessage = "You are already registered for this module.";
        }
        
        notifyListeners(); 
        return false;
      }
      
    } catch (e) {
      debugPrint("Error during module application: $e");
      _errorMessage = "Network error. Check your connection.";
      _isLoading = false;
      notifyListeners();
      return false;
    }
  }

  // 5. Fetch all module sessions successfully joined by a student ID
  Future<void> fetchStudentBookings(String studentId) async {
    _isLoading = true;
    _bookedModules = []; // Reset the array list for a clean layout refresh
    notifyListeners();

    try {
      final response = await http.get(Uri.parse("${Api.baseUrl}/students/$studentId/bookings"));

      if (response.statusCode == 200) {
        final dynamic decodedResponse = jsonDecode(response.body);

        List<dynamic> rawList = [];
        if (decodedResponse is Map && decodedResponse.containsKey('data')) {
          rawList = decodedResponse['data'] as List<dynamic>;
        } else if (decodedResponse is List) {
          rawList = decodedResponse as List<dynamic>;
        }

        // Map fields directly and inject database join values on the fly
        _bookedModules = rawList.map((json) {
          Module moduleObj = Module.fromJson(json);
          
          moduleObj.totalMarks = json['total_marks'] != null 
              ? double.tryParse(json['total_marks'].toString()) 
              : null;
          moduleObj.attendanceStatus = json['attendance_status'] ?? '-';
          moduleObj.isClaimed = json['is_claimed'] ?? 0;
          moduleObj.bookingId = json['booking_id'] ?? 0; 
          
          return moduleObj;
        }).toList();

        debugPrint("Synchronized ${_bookedModules.length} student curriculum bookings.");
      } else {
        debugPrint("Backend synchronization failed with status: ${response.statusCode}");
      }
    } catch (e) {
      debugPrint("Error fetching student bookings: $e");
    } finally {
      _isLoading = false;
      notifyListeners(); // Repaint UI lists with fresh sync elements
    }
  }

  // 6. Student rop an booking session
  Future<bool> dropModule({required int bookingId, required String studentId}) async {
    _isLoading = true;
    notifyListeners(); // Turn on loading spinner

    try {
      final response = await http.delete(
        Uri.parse("${Api.baseUrl}/bookings/$bookingId"),
      );

      if (response.statusCode == 200) {
        // Eject the row item out of local phone memory instantly so UI cards disappear immediately
        _bookedModules.removeWhere((item) => item.bookingId == bookingId || item.id == bookingId);
        
        _isLoading = false;
        notifyListeners(); // Refresh layouts right away
        
        await fetchStudentBookings(studentId); // Pull raw values from MySQL to double check alignment
        return true;
      }
      
      _isLoading = false;
      notifyListeners();
      return false;
    } catch (e) {
      debugPrint("Error dropping module: $e");
      _isLoading = false;
      notifyListeners();
      return false;
    }
  }

  // 7. Student claim a completed module
  Future<bool> claimModule({required int bookingId, required String studentId}) async {
    _isLoading = true;
    notifyListeners(); // Turn on loading spinner

    try {
      final response = await http.post(
        Uri.parse("${Api.baseUrl}/bookings/$bookingId/claim"),
        headers: {
          "Content-Type": "application/json",
          "Accept": "application/json"
        },
      );

      if (response.statusCode == 200) {
        await fetchStudentBookings(studentId); // Re-fetch data to reflect the changes instantly
        return true;
      }
      
      debugPrint("Claim rejected by server. Status: ${response.statusCode}");
      return false;
    } catch (e) {
      debugPrint("Network error during module claim transaction: $e");
      return false;
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  List<dynamic> _registeredStudents = [];
  List<dynamic> get registeredStudents => _registeredStudents;
  int? _registeredStudentsModuleId;
  int? get registeredStudentsModuleId => _registeredStudentsModuleId;

  // 8. Fetch the list of all registered students for a chosen module ID
  Future<void> fetchRegisteredStudents(int moduleId) async {
    _isLoading = true;
    _registeredStudentsModuleId = moduleId;
    _registeredStudents = [];
    notifyListeners(); // Clear old lists and show loading state spinner

    try {
      final response = await http.get(Uri.parse("${Api.baseUrl}/modules/$moduleId/students"));
      
      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);

        if (_registeredStudentsModuleId != moduleId) return;
        
        if (data is Map && data.containsKey('data')) {
          _registeredStudents = data['data'];
        } else if (data is List) {
          _registeredStudents = data;
        }
        debugPrint("Fetched ${_registeredStudents.length} students");
      }
    } catch (e) {
      debugPrint("Error fetching roster: $e");
    } finally {
      _isLoading = false;
      notifyListeners(); // Turn off loading state and render student roster table rows
    }
  }

  // 9. Kick or remove a student from an active module 
  Future<bool> removeStudentFromModule({required int bookingId, required int moduleId}) async {
    try {
      final response = await http.delete(Uri.parse("${Api.baseUrl}/bookings/$bookingId"));
      if (response.statusCode == 200) {
        await fetchRegisteredStudents(moduleId); // Refresh admin roster screen right away
        await fetchModules(); // Refresh global seat capacity counts
        return true;
      }
    } catch (e) {
      debugPrint("Delete student from roster error: $e");
    }
    return false;
  }

  List<AttendanceRecord> _attendanceRecords = [];
  List<AttendanceRecord> get attendanceRecords => _attendanceRecords;

  // 10. Fetch the attendance record for a specific module session
  Future<void> fetchAttendanceRecords(int attendanceId) async {
    _isLoading = true;
    notifyListeners(); // Turn on loading spinner

    try {
      final response = await http.get(Uri.parse('$Api.baseUrl/attendance-records/$attendanceId'));
      if (response.statusCode == 200) {
        List data = json.decode(response.body);
        _attendanceRecords = data.map((item) => AttendanceRecord.fromJson(item)).toList();
      }
    } catch (e) {
      debugPrint("Fetch attendance record logs failed: $e");
    }

    _isLoading = false;
    notifyListeners(); // Turn off loading spinner and repaint logs state
  }
}