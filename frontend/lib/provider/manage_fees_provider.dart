import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import '../config/api.dart'; // Make sure this path to your api.dart is correct

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
      matricId: json['student_id'] ?? 'N/A', 
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

  // Helper for headers to keep code clean
  Map<String, String> get _headers => {
    'Content-Type': 'application/json',
    'Accept': 'application/json',
  };

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
        Uri.parse('${Api.baseUrl}/treasurer/fees-summary?page=$currentPage&status=$currentFilter&search=$searchQuery'),
        headers: _headers,
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
    selectedStudentDetail = null; 
    notifyListeners();
    
    try {
      final response = await http.get(
        Uri.parse('${Api.baseUrl}/treasurer/student-details/$userId'),
        headers: _headers,
      );

      if (response.statusCode == 200) {
        selectedStudentDetail = json.decode(response.body); 
      }
    } catch (e) {
      debugPrint("Fetch Error: $e");
    } finally {
      isLoading = false;
      notifyListeners();
    }
  }

  Future<void> fetchUnpaidCount() async {
    try {
      final response = await http.get(
        Uri.parse('${Api.baseUrl}/treasurer/unpaid-count'),
        headers: _headers,
      );
      if (response.statusCode == 200) {
        unpaidCount = json.decode(response.body)['unpaid_count'];
        notifyListeners();
      }
    } catch (e) {
      debugPrint("Error fetching unpaid count: $e");
    }
  }

  Future<bool> saveBlockDate() async {
    isLoading = true;
    notifyListeners();
    try {
      final response = await http.post(
        Uri.parse('${Api.baseUrl}/treasurer/save-block-settings'),
        headers: _headers,
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

  // --- NEW STUDENT PORTAL METHOD ---
  Future<void> fetchStudentFinancialProfile(String studentId) async {
    isLoading = true;
    errorMessage = '';
    notifyListeners();
    
    try {
      final response = await http.get(
        Uri.parse('${Api.baseUrl}/student/financial-details/$studentId'),
        headers: _headers,
      );

      if (response.statusCode == 200) {
        selectedStudentDetail = json.decode(response.body); 
      } else {
        errorMessage = 'Failed to load financial records';
      }
    } catch (e) {
      errorMessage = 'Network error: ${e.toString()}';
    } finally {
      isLoading = false;
      notifyListeners();
    }
  }

  // lib/provider/manage_fees_provider.dart

Future<bool> updateBankAccount(String studentId, String accNo, String bankName) async {
  isLoading = true; // Use 'isLoading' to match your class variable
  notifyListeners();

  try {
    // 1. SEND DATA TO BACKEND
    final response = await http.post(
      Uri.parse('${Api.baseUrl}/student/update-bank'), // Your actual API endpoint
      headers: _headers,
      body: json.encode({
        'student_id': studentId,
        'acc_no': accNo,
        'bank_name': bankName,
      }),
    );

    // Inside updateBankAccount in manage_fees_provider.dart
    if (response.statusCode == 200) {
        if (selectedStudentDetail != null) {
            selectedStudentDetail!['acc_no'] = accNo;
            selectedStudentDetail!['bank_name'] = bankName;
        }
        notifyListeners();
        return true;
    } else {
      errorMessage = 'Failed to update database';
      isLoading = false;
      notifyListeners();
      return false;
    }
  } catch (e) {
    errorMessage = 'Network error: ${e.toString()}';
    isLoading = false;
    notifyListeners();
    return false;
  }
}

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