import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import '../config/api.dart'; 
import 'dart:io';

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
  List<dynamic> paymentHistory = [];
  double totalCollectedToday = 1250.50; 
  double totalCollectedThisWeek = 8400.00; 
  int totalStudents = 0;
  double totalPaidReport = 0.0;
  double totalOutstandingReport = 0.0;
  double onlineBankingTotal = 0.0;
  double cardPaymentTotal = 0.0;

    // Add these getters to FeesManagementProvider
  double get totalPaidAmount => summary['paid']?.toDouble() ?? 0.0; 
  double get totalOutstandingBalance {
    return students.fold(0.0, (sum, item) => sum + item.outstandingAmount);
  }

// Data for the Pie Chart
int get paidCount => summary['paid'] ?? 0;
int get unpaidCountStatus => summary['unpaid'] ?? 0;

  // Helper for headers to keep code clean
  Map<String, String> get _headers => {
    'Content-Type': 'application/json',
    'Accept': 'application/json',
  };


Future<void> fetchDashboardSummary() async {
    isLoading = true;
    errorMessage = '';
    // Re-confirm hardcoded values immediately
    totalCollectedToday = 1250.50;
    totalCollectedThisWeek = 8400.00;
    notifyListeners();

    try {
      final response = await http.get(
        Uri.parse('${Api.baseUrl}/treasurer/fees-summary?page=1&per_page=1'),
        headers: _headers,
      );

      if (response.statusCode == 200) {
        final data = json.decode(response.body);

        if (data['students'] != null && data['students']['total'] != null) {
          totalStudents = data['students']['total'];
        } else if (data['total_students'] != null) {
          totalStudents = data['total_students'];
        }
      } else {
        errorMessage = 'Server Error: ${response.statusCode}';
      }
    } catch (e) {
      errorMessage = 'Could not sync total students.';
      debugPrint("Dashboard Fetch Error: $e");
    } finally {
      isLoading = false;
      notifyListeners();
    }
  }

  // Helper to trigger refresh from UI
  Future<void> refreshDashboard() async {
    await fetchDashboardSummary();
  }

  // Update your fetch method to handle 10 items per page
Future<void> fetchStudentsFeeStatus({int page = 1}) async {
  currentPage = page;
  isLoading = true;
  errorMessage = '';
  notifyListeners();

  try {
    // Explicitly add per_page=10 to the query string
    final url = '${Api.baseUrl}/treasurer/fees-summary?'
        'page=$currentPage'
        '&per_page=10' 
        '&status=$currentFilter'
        '&search=$searchQuery';

    final response = await http.get(Uri.parse(url), headers: _headers);

    if (response.statusCode == 200) {
      final data = json.decode(response.body);
      
      if (data['summary'] != null) {
        summary = Map<String, int>.from(data['summary']);
      }

      // Check if data is nested under 'students' -> 'data' (common in Laravel pagination)
      final dynamic studentData = data['students'];
      List<dynamic> studentsList = [];
      
      if (studentData is Map && studentData['data'] != null) {
        // This is the correct path for Laravel Pagination
        studentsList = studentData['data'];
        totalStudents = studentData['total'] ?? 0;
        totalPages = studentData['last_page'] ?? 1;
    } else {
        // If you reach here, your backend is NOT paginating correctly.
        // It is sending a plain List, so we force-limit it to 10 for the UI.
        studentsList = (studentData as List).take(10).toList(); 
        totalStudents = studentData.length;
        totalPages = (totalStudents / 10).ceil();
    }

      // Mapping the list to our model
      students = studentsList.map((json) => StudentFeeStatus.fromJson(json)).toList();
      
    } else {
      errorMessage = 'Failed to load data';
    }
  } catch (e) {
    errorMessage = 'Error: ${e.toString()}';
  } finally {
    isLoading = false;
    notifyListeners();
  }
}

  void goToPage(int page) {
    if (page >= 1 && page <= totalPages) {
      fetchStudentsFeeStatus(page: page);
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

  Future<bool> saveBlockDate(int treasurerId) async {
    try {
      final response = await http.post(
        Uri.parse('${Api.baseUrl}/treasurer/block-settings'),
        headers: _headers, // Verifies 'Content-Type': 'application/json' is active
        body: json.encode({
          'treasurer_id': treasurerId,
          'block_start_date': selectedBlockDate.toIso8601String(),
        }),
      );

      if (response.statusCode == 200) {
        final responseData = json.decode(response.body);
        return responseData['success'] == true;
      } else {
        debugPrint("API rejected request parameters with code: ${response.statusCode}");
        debugPrint("Server Response payload summary: ${response.body}");
        return false;
      }
    } catch (e) {
      debugPrint("Failed to execute saveBlockDate routine network thread: $e");
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

  Future<void> fetchPaymentHistory(String studentId) async {
    isLoading = true;
    paymentHistory = []; // Clear old data
    notifyListeners();

    try {
      final response = await http.get(
        Uri.parse('${Api.baseUrl}/student/payment-history/$studentId'),
        headers: _headers,
      );

      if (response.statusCode == 200) {
        paymentHistory = json.decode(response.body);
      } else {
        errorMessage = 'Failed to load payment history';
      }
    } catch (e) {
      errorMessage = 'Network error: ${e.toString()}';
    } finally {
      isLoading = false;
      notifyListeners();
    }
  }

  Future<void> fetchReportTotals() async {
    isLoading = true;
    errorMessage = '';
    notifyListeners();

    try {
      final response = await http.get(
        Uri.parse('${Api.baseUrl}/treasurer/report-totals'),
        headers: _headers,
      );

      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        
        // Update dynamic dashboard card numeric metrics
        totalPaidReport = (data['total_paid'] ?? 0.0).toDouble();
        totalOutstandingReport = (data['total_outstanding'] ?? 0.0).toDouble();
        
        // Assign specific blocked counters safely inside your existing summary mapping
        summary['blocked'] = data['blocked_count'] ?? 0;

        // Map incoming bar chart values 
        summary['bank_count'] = data['online_banking_count'] ?? (onlineBankingTotal > 0 ? (onlineBankingTotal / 150).round() : 0);
        summary['card_count'] = data['card_payment_count'] ?? (cardPaymentTotal > 0 ? (cardPaymentTotal / 150).round() : 0);
      }
    } catch (e) {
      errorMessage = "Failed to synchronize remote metrics pipeline.";
      debugPrint("Fetch Report Error: $e");
    } finally {
      isLoading = false;
      notifyListeners();
    }
  }

  void setFilter(String filter) {
    currentFilter = filter;
    // Instead of refresh: true, we just go back to page 1
    fetchStudentsFeeStatus(page: 1);
  }

  void searchStudents(String query) {
    searchQuery = query;
    // Instead of refresh: true, we just go back to page 1
    fetchStudentsFeeStatus(page: 1);
  }
}