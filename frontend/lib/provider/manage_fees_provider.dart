import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';

class StudentFeeStatus {
  final int userId; // Changed from studentId to userId for Inheritance
  final String name;
  final String matricId; // Matches your DB 'matric_id'
  final double outstandingAmount; // Matches your DB field
  final String status;
  final bool isBlocked;

  StudentFeeStatus({
    required this.userId,
    required this.name,
    required this.matricId,
    required this.outstandingAmount,
    required this.status,
    required this.isBlocked,
  });

  factory StudentFeeStatus.fromJson(Map<String, dynamic> json) {
    return StudentFeeStatus(
      userId: json['user_id'],
      name: json['name'] ?? 'N/A',
      matricId: json['matric_id'] ?? 'N/A',
      outstandingAmount: (json['outstanding_amount'] ?? 0).toDouble(),
      status: json['status'] ?? 'unpaid',
      isBlocked: (json['is_blocked'] == 1 || json['is_blocked'] == true),
    );
  }
}

class FeesManagementProvider extends ChangeNotifier {
  List<StudentFeeStatus> students = [];
  Map<String, int> summary = {'paid': 0, 'unpaid': 0, 'blocked': 0}; 
  
  bool isLoading = false;
  bool isLoadMore = false;
  String errorMessage = '';
  int currentPage = 1;
  int totalPages = 1;
  String currentFilter = 'all';
  String searchQuery = '';

  Future<void> fetchStudentsFeeStatus({bool refresh = false}) async {
    if (refresh) {
      currentPage = 1;
      students.clear();
    }
    
    isLoading = currentPage == 1;
    if (currentPage > 1) isLoadMore = true;
    
    errorMessage = '';
    notifyListeners();

    try {
      final response = await http.get(
        Uri.parse('http://10.0.2.2:8000/api/treasurer/fees-summary?page=$currentPage&status=$currentFilter&search=$searchQuery'),
        headers: {
          'Content-Type': 'application/json',
          'Accept': 'application/json',
        },
      );

      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        if (data['summary'] != null) {
          summary = Map<String, int>.from(data['summary']);
        }

        final List<dynamic> studentsJson = data['students'];
        final newStudents = studentsJson.map((json) => StudentFeeStatus.fromJson(json)).toList();
        
        if (refresh) {
          students = newStudents;
        } else {
          students.addAll(newStudents);
        }
        
        totalPages = data['total_pages'] ?? 1;
      } else {
        errorMessage = 'Failed to load students data';
      }
    } catch (e) {
      errorMessage = 'Network error: ${e.toString()}';
    } finally {
      isLoading = false;
      isLoadMore = false;
      notifyListeners();
    }
  }

  // RE-ADDED THESE METHODS FOR THE UI
  Future<void> loadMore() async {
    if (currentPage < totalPages && !isLoadMore && !isLoading) {
      currentPage++;
      await fetchStudentsFeeStatus();
    }
  }

  void setFilter(String filter) {
    currentFilter = filter;
    fetchStudentsFeeStatus(refresh: true);
  }

  void searchStudents(String query) {
    searchQuery = query;
    fetchStudentsFeeStatus(refresh: true);
  }
}