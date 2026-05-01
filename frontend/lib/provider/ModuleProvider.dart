import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';

class ModuleProvider with ChangeNotifier {
  // 1. Storage for the module list
  List<dynamic> _modules = [];
  List<dynamic> get modules => _modules;

  bool _isLoading = false;
  bool get isLoading => _isLoading;

  // URL configuration
  final String _baseUrl = "http://127.0.0.1:8000/api/modules";

  // 2. Function to FETCH modules from Laravel
  Future<void> fetchModules() async {
    _isLoading = true;
    notifyListeners();

    try {
      final response = await http.get(Uri.parse(_baseUrl));

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        _modules = data['data']; // Assuming your Laravel controller returns ['data' => $modules]
      } else {
        print("Failed to load modules: ${response.statusCode}");
      }
    } catch (e) {
      print("Error fetching modules: $e");
    }

    _isLoading = false;
    notifyListeners();
  }

  // 3. Function to CREATE a new module (Existing code)
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
        Uri.parse(_baseUrl),
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
        await fetchModules(); // Refresh the list automatically after adding!
        return true;
      }
      return false;
    } catch (e) {
      _isLoading = false;
      notifyListeners();
      return false;
    }
  }
}