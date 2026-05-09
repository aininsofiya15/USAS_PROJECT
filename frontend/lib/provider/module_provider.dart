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

  /// Fetches all modules from the Laravel backend api database
  Future<void> fetchModules() async {
    _isLoading = true;
    notifyListeners();

    try {
      final response = await http.get(Uri.parse("${Api.baseUrl}/modules"));

      if (response.statusCode == 200) {
        final Map<String, dynamic> responseData = jsonDecode(response.body);
        final List<dynamic> modulesList = responseData['data'];

        _modules = modulesList.map((json) => Module.fromJson(json)).toList();
      }
    } catch (e) {
      print("Error fetching modules data: $e");
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  /// Creates a new academic module record (Saves as Draft or Published)
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
    notifyListeners();

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
        await fetchModules(); 
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

  /// Updates an existing module record using a reliable body payload lookup mapping
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
    notifyListeners();

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
        await fetchModules(); 
        return true;
      } else {
        print("Backend Error Code: ${response.statusCode}");
        print("Backend Error Body: ${response.body}");
        notifyListeners();
        return false;
      }
    } catch (e) {
      print("Error updating module: $e");
      _isLoading = false;
      notifyListeners();
      return false;
    }
  }

  // --- STUDENT BOOKING METHODS ---

  /// Sends a registration application request to the Laravel backend database
  Future<bool> applyToModule({required int moduleId, required String studentId}) async {
    _isLoading = false;
    _errorMessage = null; // Clear old errors before starting
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
        await fetchModules(); 
        await fetchStudentBookings(studentId); 
        // notifyListeners is usually called inside the fetch methods above, 
        // so we just return true here.
        return true;
      } 
      else {
        // 🔥 NEW: Parse the error message from Laravel (e.g., "Already registered!")
        try {
          final data = jsonDecode(response.body);
            _errorMessage = data['message']; 
          } catch (_) {
            // If Laravel sends back something that isn't JSON, we use this fallback
            _errorMessage = "You are already registered for this module.";
          }
        
        notifyListeners(); 
        return false;
      }
      
    } catch (e) {
      print("Error during module application: $e");
      _errorMessage = "Network error. Check your connection.";
      _isLoading = false;
      notifyListeners();
      return false;
    }
  }

  /// Fetches all modules successfully booked by a specific student ID
  Future<void> fetchStudentBookings(String studentId) async {
    _isLoading = true;
    notifyListeners();

    try {
      final response = await http.get(Uri.parse("${Api.baseUrl}/students/$studentId/bookings"));

      if (response.statusCode == 200) {
        final List<dynamic> data = jsonDecode(response.body);
        _bookedModules = data.map((json) => Module.fromJson(json)).toList();
      }
    } catch (e) {
      print("Error fetching student bookings: $e");
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

//DROP MODULE

Future<bool> dropModule({required int bookingId, required String studentId}) async {
    _isLoading = true;
    notifyListeners();

    try {
      final response = await http.delete(
        Uri.parse("${Api.baseUrl}/bookings/$bookingId"),
      );

      if (response.statusCode == 200) {
        // 1. Physically remove it from the local list as a backup
        _bookedModules.removeWhere((item) => item.id == bookingId);
        
        // 2. 🔥 THE ULTIMATE FIX: Force a fresh pull from MySQL
        // This ensures the UI matches the database 100%
        await fetchStudentBookings(studentId); 
        
        _isLoading = false;
        notifyListeners(); 
        return true;
      }
      
      _isLoading = false;
      notifyListeners();
      return false;
    } catch (e) {
      print("Error dropping module: $e");
      _isLoading = false;
      notifyListeners();
      return false;
    }
  }

  //VIEW ALL REGISTERED STUDENTS FOR A MODULE (PUSAT ADAB)
  List<dynamic> _registeredStudents = [];
  List<dynamic> get registeredStudents => _registeredStudents;

  // lib/provider/module_provider.dart

Future<void> fetchRegisteredStudents(int moduleId) async {
    _isLoading = true;
    _registeredStudents = []; // Clear list for fresh start
    notifyListeners();

    try {
        final response = await http.get(Uri.parse("${Api.baseUrl}/modules/$moduleId/students"));
        
        if (response.statusCode == 200) {
            final data = jsonDecode(response.body);
            if (data is List) {
                _registeredStudents = data;
            }
            print("Fetched ${_registeredStudents.length} students");
        }
    } catch (e) {
        print("Error: $e");
    } finally {
        _isLoading = false;
        notifyListeners();
    }
}

Future<bool> removeStudentFromModule({required int bookingId, required int moduleId}) async {
    try {
        final response = await http.delete(Uri.parse("${Api.baseUrl}/bookings/$bookingId"));
        if (response.statusCode == 200) {
            await fetchRegisteredStudents(moduleId); // Refresh list
            return true;
        }
    } catch (e) {
        print("Delete error: $e");
    }
    return false;
}

  List<AttendanceRecord> _attendanceRecords = [];
  List<AttendanceRecord> get attendanceRecords => _attendanceRecords;

  // 1. Fetch the list for the Attendance Records screen
  Future<void> fetchAttendanceRecords(int attendanceId) async {
    _isLoading = true;
    notifyListeners();

    try {
      final response = await http.get(Uri.parse('$Api.baseUrl/attendance-records/$attendanceId'));
      if (response.statusCode == 200) {
        List data = json.decode(response.body);
        _attendanceRecords = data.map((item) => AttendanceRecord.fromJson(item)).toList();
      }
    } catch (e) {
      debugPrint("Fetch Error: $e");
    }

    _isLoading = false;
    notifyListeners();
  }

  // 2. Submit marks to Laravel (Your Grading Task)
  Future<bool> updateStudentGrade(int recordId, double marks) async {
    try {
      final response = await http.patch(
        Uri.parse('$Api.baseUrl/attendance-records/$recordId/grade'),
        headers: {'Content-Type': 'application/json'},
        body: json.encode({'marks': marks}),
      );

      if (response.statusCode == 200) {
        // Refresh local data so the UI updates immediately
        int index = _attendanceRecords.indexWhere((r) => r.id == recordId);
        if (index != -1) {
          _attendanceRecords[index].marks = marks;
          notifyListeners();
        }
        return true;
      }
    } catch (e) {
      debugPrint("Update Error: $e");
    }
    return false;
  }
}