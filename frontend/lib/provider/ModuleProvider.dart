import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';

class ModuleProvider with ChangeNotifier {
  bool _isLoading = false;
  bool get isLoading => _isLoading;

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

    final url = Uri.parse("http://10.0.2.2:8000/api/modules");
    try {
      final response = await http.post(
        url,
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
      notifyListeners();
      return response.statusCode == 201;
    } catch (e) {
      _isLoading = false;
      notifyListeners();
      return false;
    }
  }
}