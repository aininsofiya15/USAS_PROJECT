import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';

class StudentFeeStatus {
  final int studentId;
  final String name;
  final String matricNo;
  final double totalFees;
  final double paidAmount;
  final double balance;
  final String status;
  final bool isBlocked;

  StudentFeeStatus({
    required this.studentId,
    required this.name,
    required this.matricNo,
    required this.totalFees,
    required this.paidAmount,
    required this.balance,
    required this.status,
    required this.isBlocked,
  });

  factory StudentFeeStatus.fromJson(Map<String, dynamic> json) {
    return StudentFeeStatus(
      studentId: json['student_id'],
      name: json['name'],
      matricNo: json['matric_no'],
      totalFees: (json['total_fees'] ?? 0).toDouble(),
      paidAmount: (json['paid_amount'] ?? 0).toDouble(),
      balance: (json['balance'] ?? 0).toDouble(),
      status: json['status'] ?? 'unpaid',
      isBlocked: json['is_blocked'] ?? false,
    );
  }
}

class FeesManagementProvider extends ChangeNotifier {
  List<StudentFeeStatus> students = [];
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
    
    if (currentPage == 1) {
      isLoading = true;
    } else {
      isLoadMore = true;
    }
    
    errorMessage = '';
    notifyListeners();

    try {
      final response = await http.get(
        Uri.parse('http://10.0.2.2:8000/api/treasurer/students-fee-status?page=$currentPage&status=$currentFilter&search=$searchQuery'),
        headers: {
          'Content-Type': 'application/json',
          'Accept': 'application/json',
        },
      );

      if (response.statusCode == 200) {
        final data = json.decode(response.body);
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

  void clearSearch() {
    searchQuery = '';
    fetchStudentsFeeStatus(refresh: true);
  }
}