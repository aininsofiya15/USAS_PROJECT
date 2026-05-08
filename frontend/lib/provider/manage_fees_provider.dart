import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';

class StudentFeeStatus {
  final int userId;
  final String name;
  final String matricId; 
  final double outstandingAmount;
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
      userId: json['id'] ?? 0,
      name: json['name'] ?? 'N/A',
      matricId: json['student_id'] ?? 'N/A', // Must match 'students.student_id' from SQL
      outstandingAmount: double.tryParse(json['outstanding_amount']?.toString() ?? '0') ?? 0.0,
      status: json['status'] ?? 'unpaid',
      isBlocked: json['is_blocked'] == 1 || json['is_blocked'] == true,
    );
  }
}

class FeesManagementProvider extends ChangeNotifier {
  List<StudentFeeStatus> students = [];
  Map<String, int> summary = {'paid': 0, 'unpaid': 0, 'blocked': 0}; 
  Map<String, dynamic>? selectedStudentDetail;
  
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

  Future<void> fetchStudentDetail(int userId) async {
    isLoading = true;
    notifyListeners();
    try {
      final response = await http.get(
        Uri.parse('http://10.0.2.2:8000/api/treasurer/student-detail/$userId'),
      );
      if (response.statusCode == 200) {
        selectedStudentDetail = json.decode(response.body);
      }
    } catch (e) {
      errorMessage = e.toString();
    } finally {
      isLoading = false;
      notifyListeners();
    }
  }

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