import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import '../config/api.dart'; 
import '../domain/module.dart';

class ModuleProvider with ChangeNotifier {
  List<Module> _modules = [];
  List<Module> get modules => _modules;

  bool _isLoading = false;
  bool get isLoading => _isLoading;

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
          'current_name': id,            
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
    _isLoading = true;
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

      // 🔥 FIXED: Turning off loading state here ensures it drops the spinner on both success AND failure routes
      _isLoading = false;

      if (response.statusCode == 200) {
        await fetchModules(); 
        await fetchStudentBookings(studentId); 
        return true;
      }
      
      // 🔥 FIXED: Notify the UI that loading stopped when status code isn't 200 (e.g. slots full)
      notifyListeners(); 
      return false;
    } catch (e) {
      print("Error during module application: $e");
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
}