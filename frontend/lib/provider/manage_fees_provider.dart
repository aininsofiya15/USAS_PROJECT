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
  int unpaidCount = 0;
  DateTime selectedBlockDate = DateTime.now();

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
    selectedStudentDetail = null; // Clear old data to prevent showing wrong student
    notifyListeners();
    
    try {
      final response = await http.get(
        // FIX: Changed 'fees-details' to 'student-details' to match api.php
        Uri.parse('http://10.0.2.2:8000/api/treasurer/student-details/$userId'), 
      );

      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        // If the backend returns null, selectedStudentDetail remains null
        selectedStudentDetail = data; 
      }
    } catch (e) {
      print("Fetch Error: $e");
    } finally {
      isLoading = false;
      notifyListeners();
    }
  }

  // New: Fetch count of students with 'unpaid' status for preview
  Future<void> fetchUnpaidCount() async {
    try {
      final response = await http.get(
        Uri.parse('http://10.0.2.2:8000/api/treasurer/unpaid-count'),
      );
      if (response.statusCode == 200) {
        unpaidCount = json.decode(response.body)['unpaid_count'];
        notifyListeners();
      }
    } catch (e) {
      print("Error fetching unpaid count: $e");
    }
  }

  // New: Save the block date to the database
  Future<bool> saveBlockDate() async {
    isLoading = true;
    notifyListeners();
    try {
      final response = await http.post(
        Uri.parse('http://10.0.2.2:8000/api/treasurer/save-block-settings'),
        headers: {'Content-Type': 'application/json'},
        body: json.encode({
          'block_date': selectedBlockDate.toIso8601String().split('T')[0],
        }),
      );
      isLoading = false;
      notifyListeners();
      return response.statusCode == 200;
    } catch (e) {
      isLoading = false;
      notifyListeners();
      return false;
    }
  }
  
  // Method to update date from the UI
  void updateBlockDate(DateTime date) {
    selectedBlockDate = date;
    notifyListeners();
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