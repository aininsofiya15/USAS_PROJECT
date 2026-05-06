import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';

class TreasuryProvider with ChangeNotifier {
  int _totalStudents = 0;
  double _totalCollectedToday = 0.0;
  double _totalCollectedThisWeek = 0.0;
  bool _isLoading = false;
  String _errorMessage = "";

  // Getters
  int get totalStudents => _totalStudents;
  double get totalCollectedToday => _totalCollectedToday;
  double get totalCollectedThisWeek => _totalCollectedThisWeek;
  bool get isLoading => _isLoading;
  String get errorMessage => _errorMessage;

  Future<void> fetchDashboardSummary() async {
    _isLoading = true;
    _errorMessage = "";
    notifyListeners();

    try {
      // Use 10.0.2.2 for Android Emulator
      final response = await http.get(
        Uri.parse('http://10.0.2.2:8000/api/treasurer/dashboard-summary'),
      );

      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        
        // Ensure these keys match TreasurerController.php exactly
        _totalStudents = data['total_students'] ?? 0;
        _totalCollectedToday = (data['total_collected_today'] ?? 0).toDouble();
        _totalCollectedThisWeek = (data['total_collected_this_week'] ?? 0).toDouble();
      } else {
        _errorMessage = "Server Error: ${response.statusCode}";
      }
    } catch (e) {
      _errorMessage = "Connection Failed. Ensure Laravel is running.";
      print("Provider Error: $e");
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  void refreshDashboard() => fetchDashboardSummary();
}