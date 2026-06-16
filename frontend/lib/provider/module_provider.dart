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

  // Fetches all modules from the Laravel backend database
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
        return true;
      } 
      else {
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
      print("Error during module application: $e");
      _errorMessage = "Network error. Check your connection.";
      _isLoading = false;
      notifyListeners();
      return false;
    }
  }

  // Fetches all modules successfully booked by a specific student ID
  Future<void> fetchStudentBookings(String studentId) async {
    _isLoading = true;
    _bookedModules = []; // Reset the array list for a clean layout refresh
    notifyListeners();

    try {
      final response = await http.get(Uri.parse("${Api.baseUrl}/students/$studentId/bookings"));

      if (response.statusCode == 200) {
        final dynamic decodedResponse = jsonDecode(response.body);

        // Extract the raw list matrix safely out of your Laravel data wrapper
        List<dynamic> rawList = [];
        if (decodedResponse is Map && decodedResponse.containsKey('data')) {
          rawList = decodedResponse['data'] as List<dynamic>;
        } else if (decodedResponse is List) {
          rawList = decodedResponse as List<dynamic>;
        }

        // 🎯 FIXED OBJECT FACTORY MAPPING: Map fields directly to satisfy List<Module> type constraints
        _bookedModules = rawList.map((json) {
          Module moduleObj = Module.fromJson(json);
          
          // Inject our custom database join data on the fly!
          moduleObj.totalMarks = json['total_marks'] != null 
              ? double.tryParse(json['total_marks'].toString()) 
              : null;
          moduleObj.attendanceStatus = json['attendance_status'] ?? '-';
          moduleObj.isClaimed = json['is_claimed'] ?? 0;
          moduleObj.bookingId = json['booking_id'] ?? 0; 
          
          return moduleObj;
        }).toList();

        print("Successfully synchronized ${_bookedModules.length} active curriculum student bookings.");
      } else {
        print("Backend synchronization failed with response code status: ${response.statusCode}");
      }
    } catch (e) {
      print("Error fetching student bookings execution pipeline: $e");
    } finally {
      _isLoading = false;
      notifyListeners(); 
    }
  }

  /// Drop/Unregister a module
  Future<bool> dropModule({required int bookingId, required String studentId}) async {
    _isLoading = true;
    notifyListeners(); // Turns on the spinner spinner framework loaders

    try {
      final response = await http.delete(
        Uri.parse("${Api.baseUrl}/bookings/$bookingId"),
      );

      if (response.statusCode == 200) {
        // 1. 🎯 THE LOCAL CLEANUP: Physically eject the item from our active application memory array
        _bookedModules.removeWhere((item) => item.bookingId == bookingId || item.id == bookingId);
        
        // 2. 🔥 THE CRITICAL FIX: Explicitly notify the Flutter layout trees to repaint right away!
        _isLoading = false;
        notifyListeners(); 
        
        // 3. BACKGROUND SYNC: Re-fetch from MySQL to guarantee everything aligns completely
        await fetchStudentBookings(studentId); 
        return true;
      }
      
      _isLoading = false;
      notifyListeners();
      return false;
    } catch (e) {
      print("Error dropping module execution pipeline: $e");
      _isLoading = false;
      notifyListeners();
      return false;
    }
  }

  // Updates a specific module row state to claimed=1
  Future<bool> claimModule({required int bookingId, required String studentId}) async {
    _isLoading = true;
    notifyListeners();

    try {
      // 🎯 TARGET ENDPOINT: Adjust this string path pattern to match your Laravel routing setup
      final response = await http.post(
        Uri.parse("${Api.baseUrl}/bookings/$bookingId/claim"),
        headers: {
          "Content-Type": "application/json",
          "Accept": "application/json"
        },
      );

      if (response.statusCode == 200) {
        // 🔥 THE REAL SYNC: Instantly pull down fresh, real-time metrics directly from MySQL
        await fetchStudentBookings(studentId);
        return true;
      }
      
      print("Claim submission rejected by backend server. Status: ${response.statusCode}");
      return false;
    } catch (e) {
      print("Network pipeline error during module claim transaction execution: $e");
      return false;
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  // VIEW ALL REGISTERED STUDENTS FOR A MODULE (PUSAT ADAB)
  List<dynamic> _registeredStudents = [];
  List<dynamic> get registeredStudents => _registeredStudents;
  int? _registeredStudentsModuleId;
  int? get registeredStudentsModuleId => _registeredStudentsModuleId;

  Future<void> fetchRegisteredStudents(int moduleId) async {
    _isLoading = true;
    _registeredStudentsModuleId = moduleId;
    _registeredStudents = [];
    notifyListeners();

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
        await fetchRegisteredStudents(moduleId);
        await fetchModules();
        return true;
      }
    } catch (e) {
      print("Delete error: $e");
    }
    return false;
  }

  List<AttendanceRecord> _attendanceRecords = [];
  List<AttendanceRecord> get attendanceRecords => _attendanceRecords;

  // Fetch the list for the Attendance Records screen
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

}
