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

  /// Fetches all modules from the Laravel backend api database
  Future<void> fetchModules() async {
    _isLoading = true;
    notifyListeners();

    try {
      final response = await http.get(Uri.parse(Api.modules));

      if (response.statusCode == 200) {
        final Map<String, dynamic> data = jsonDecode(response.body);
        final List<dynamic> moduleList = data['data']; 
        
        _modules = moduleList.map((json) => Module.fromJson(json)).toList();
      }
    } catch (e) {
      print("Error fetching modules: $e");
    }

    _isLoading = false;
    notifyListeners();
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
        await fetchModules(); // High Cohesion: Automatically syncs local collection state
        return true;
      }
      return false;
    } catch (e) {
      _isLoading = false;
      notifyListeners();
      return false;
    }
  }

  /// Updates an existing module record using a reliable body payload lookup mapping
  Future<bool> updateModule({
    required String id, // Holds the original activity name string
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
      // Clean POST route path avoiding dangerous URL wildcard string parsers
      final url = Uri.parse("${Api.modules}/update-existing");

      final response = await http.post(
        url,
        headers: {"Content-Type": "application/json"},
        body: jsonEncode({
          'current_name': id,            // Key identifier used by backend Eloquent query
          'activity_name': activityName,   // New string name to persist
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
        await fetchModules(); // Triggers live state sync across View panels instantly
        return true;
      } else {
        print("Backend Error Code: ${response.statusCode}");
        print("Backend Error Body: ${response.body}");
        return false;
      }
    } catch (e) {
      print("Error updating module: $e");
      _isLoading = false;
      notifyListeners();
      return false;
    }
  }
}