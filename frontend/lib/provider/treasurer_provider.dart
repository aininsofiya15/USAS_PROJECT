import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';

class TreasuryProvider with ChangeNotifier {
  // State variables
  int _totalStudents = 0;
  int _paidStudents = 0;
  int _unpaidStudents = 0;
  int _blockedStudents = 0;
  double _totalCollectedToday = 0.0;
  double _totalCollectedThisWeek = 0.0;
  bool _isLoading = false;
  String _errorMessage = '';

  // Getters
  int get totalStudents => _totalStudents;
  int get paidStudents => _paidStudents;
  int get unpaidStudents => _unpaidStudents;
  int get blockedStudents => _blockedStudents;
  double get totalCollectedToday => _totalCollectedToday;
  double get totalCollectedThisWeek => _totalCollectedThisWeek;
  bool get isLoading => _isLoading;
  String get errorMessage => _errorMessage;

  // Base URL for API (adjust to your Laravel backend)
  final String baseUrl = 'http://10.0.2.2:8000/api/treasury';

  // Fetch dashboard summary data
  Future<void> fetchDashboardSummary() async {
    _isLoading = true;
    _errorMessage = '';
    notifyListeners();

    try {
      final response = await http.get(
        Uri.parse('$baseUrl/dashboard-summary'),
        headers: {'Accept': 'application/json'},
      );

      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        _totalStudents = data['total_students'] ?? 0;
        _paidStudents = data['paid_students'] ?? 0;
        _unpaidStudents = data['unpaid_students'] ?? 0;
        _blockedStudents = data['blocked_students'] ?? 0;
        _totalCollectedToday = (data['total_collected_today'] ?? 0).toDouble();
        _totalCollectedThisWeek = (data['total_collected_this_week'] ?? 0).toDouble();
      } else {
        _errorMessage = 'Failed to load dashboard data';
        _setDefaultValues();
      }
    } catch (e) {
      _errorMessage = 'Connection error: ${e.toString()}';
      _setDefaultValues();
    }

    _isLoading = false;
    notifyListeners();
  }

  void _setDefaultValues() {
    _totalStudents = 0;
    _paidStudents = 0;
    _unpaidStudents = 0;
    _blockedStudents = 0;
    _totalCollectedToday = 0.0;
    _totalCollectedThisWeek = 0.0;
  }

  // Refresh dashboard data (called when returning from other screens)
  Future<void> refreshDashboard() async {
    await fetchDashboardSummary();
  }
}