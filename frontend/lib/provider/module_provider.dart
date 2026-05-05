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

  Future<void> fetchModules() async {
    _isLoading = true;
    notifyListeners();

    try {
      final response = await http.get(Uri.parse(Api.modules));

      if (response.statusCode == 200) {
        final Map<String, dynamic> data = jsonDecode(response.body);
        final List<dynamic> moduleList = data['data']; 
        
        // Convert dynamic list to List<Module>
        _modules = moduleList.map((json) => Module.fromJson(json)).toList();
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