import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import '../config/api.dart'; 
import 'package:intl/intl.dart';

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
  DateTime? _currentBlockDate;
  List<dynamic> paymentHistory = [];
  double totalCollectedToday = 1250.50; 
  double totalCollectedThisWeek = 8400.00; 
  int totalStudents = 0;
  double totalPaidReport = 0.0;
  double totalOutstandingReport = 0.0;
  double onlineBankingTotal = 0.0;
  double cardPaymentTotal = 0.0;
  int? lastNotificationsSent = 0;
  bool _isBlocked = false;
  String _blockMessage = '';
  
  // --- STUDENT CORE RECENT UPDATES PORTAL STATE VARIABLES ---
  bool studentIsBlocked = false;
  String upcomingDueDateStr = "Loading...";
  double curriculumProgress = 0.7;
  int totalCreditsCurrentSem = 12;

  // Getter for selectedBlockDate
  DateTime get selectedBlockDate => _currentBlockDate ?? DateTime.now();
  bool get isBlocked => _isBlocked;
  String get blockMessage => _blockMessage;
  double get totalPaidAmount => summary['paid']?.toDouble() ?? 0.0; 
  double get totalOutstandingBalance {
    return students.fold(0.0, (sum, item) => sum + item.outstandingAmount);
  }

  int get paidCount => summary['paid'] ?? 0;
  int get unpaidCountStatus => summary['unpaid'] ?? 0;

  Map<String, String> get _headers => {
    'Content-Type': 'application/json',
    'Accept': 'application/json',
  };

  // Fetch block date from database
  Future<void> fetchBlockDate() async {
    try {
      final response = await http.get(
        Uri.parse('${Api.baseUrl}/treasurer/block-settings/latest'),
        headers: _headers,
      );

      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        if (data['success'] == true && data['block_date'] != null) {
          _currentBlockDate = DateTime.parse(data['block_date']);
          _updateUpcomingDueDate(_currentBlockDate!);
        } else {
          _currentBlockDate = DateTime.now();
          _updateUpcomingDueDate(_currentBlockDate!);
        }
      } else {
        _currentBlockDate = DateTime.now();
        _updateUpcomingDueDate(_currentBlockDate!);
      }
    } catch (e) {
      print('Error fetching block date: $e');
      _currentBlockDate = DateTime.now();
      _updateUpcomingDueDate(_currentBlockDate!);
    }
  }

  // Helper method to update upcomingDueDateStr
  void _updateUpcomingDueDate(DateTime date) {
    try {
      upcomingDueDateStr = "${DateFormat('d MMMM yyyy').format(date)}\n12:00 AM";
    } catch (e) {
      upcomingDueDateStr = "Date not set";
    }
    notifyListeners();
  }

  Future<void> fetchStudentPortalDashboardData(String studentId) async {
  isLoading = true;
  errorMessage = '';
  notifyListeners();

  try {
    final url = '${Api.baseUrl}/student/dashboard-status/$studentId';
    debugPrint("Hitting dynamic student platform status pipeline via url context: $url");

    final response = await http.get(
      Uri.parse(url),
      headers: _headers,
    );

    if (response.statusCode == 200) {
      final data = json.decode(response.body);

      if (data['success'] == true) {
        String blockDateRaw = data['block_date'] ?? "2026-05-18"; 
        String paymentStatus = data['payment_status']?.toString().toLowerCase() ?? 'unpaid';
        
        totalCreditsCurrentSem = int.tryParse(data['total_credits']?.toString() ?? '12') ?? 12;
        curriculumProgress = double.tryParse(data['curriculum_progress']?.toString() ?? '0.7') ?? 0.7;

        DateTime parsedBlockDate = DateTime.parse("$blockDateRaw 00:00:00");
        upcomingDueDateStr = "${DateFormat('d MMMM').format(parsedBlockDate)}\n12:00 AM";

        DateTime currentSystemTime = DateTime.now();
        if (paymentStatus == 'unpaid' && currentSystemTime.isAfter(parsedBlockDate)) {
          studentIsBlocked = true;
          _isBlocked = true;
          _blockMessage = 'Your academic access has been blocked due to unpaid tuition fees.';
        } else {
          studentIsBlocked = false;
          _isBlocked = false;
          _blockMessage = '';
        }
        notifyListeners();
      } else {
        errorMessage = data['message'] ?? 'Backend operation failed validation.';
        upcomingDueDateStr = "Sync Error";
      }
    } else {
      errorMessage = 'Server Error Status Code context: ${response.statusCode}';
      upcomingDueDateStr = "Sync Error";
    }
  } catch (e) {
    errorMessage = 'Network connection thread failure: ${e.toString()}';
    upcomingDueDateStr = "Offline";
    debugPrint("Student Dashboard System Engine Sync Error trace: $e");
  } finally {
    isLoading = false;
    notifyListeners();
  }
}

  Future<void> refreshBlockStatus(String userId) async {
    await checkBlockStatus(userId);
    await fetchStudentPortalDashboardData(userId);
  }

  Future<void> fetchDashboardSummary() async {
    isLoading = true;
    errorMessage = '';
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

  Future<String?> generateStripePaymentIntent({
    required String studentId, 
    required double amount,
  }) async {
    isLoading = true;
    errorMessage = '';
    notifyListeners();

    try {
      final response = await http.post(
        Uri.parse('${Api.baseUrl}/tuition/payment-intent'),
        headers: _headers,
        body: jsonEncode({
          'amount': amount,
          'user_id': studentId,
        }),
      );

      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        if (data['success'] == true && data['paymentIntentClientSecret'] != null) {
          return data['paymentIntentClientSecret'];
        } else {
          errorMessage = data['error'] ?? 'Failed to initialize payment intent.';
          return null;
        }
      } else {
        final errorData = json.decode(response.body);
        errorMessage = errorData['error'] ?? 'Server Error: ${response.statusCode}';
        return null;
      }
    } catch (e) {
      errorMessage = 'Network connection failure: ${e.toString()}';
      debugPrint("Stripe Payment Intent Generation Error: $e");
      return null;
    } finally {
      isLoading = false;
      notifyListeners();
    }
  }

  Future<void> refreshDashboard() async {
    await fetchDashboardSummary();
  }

  Future<void> fetchStudentsFeeStatus({int page = 1}) async {
    currentPage = page;
    isLoading = true;
    errorMessage = '';
    notifyListeners();

    try {
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

        final dynamic studentData = data['students'];
        List<dynamic> studentsList = [];
        
        if (studentData is Map && studentData['data'] != null) {
          studentsList = studentData['data'];
          totalStudents = studentData['total'] ?? 0;
          totalPages = studentData['last_page'] ?? 1;
        } else {
          studentsList = (studentData as List).take(10).toList(); 
          totalStudents = studentData.length;
          totalPages = (totalStudents / 10).ceil();
        }

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
        final data = json.decode(response.body);
        if (data != null && data.isNotEmpty) {
          selectedStudentDetail = data;
        } else {
          errorMessage = 'No data found for this student';
          selectedStudentDetail = null;
        }
      } else {
        errorMessage = 'Failed to load student details';
        selectedStudentDetail = null;
      }
    } catch (e) {
      debugPrint("Fetch Error: $e");
      errorMessage = 'Network error: ${e.toString()}';
      selectedStudentDetail = null;
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
        headers: _headers,
        body: json.encode({
          'treasurer_id': treasurerId,
          'block_start_date': _currentBlockDate?.toIso8601String() ?? DateTime.now().toIso8601String(),
        }),
      );

      if (response.statusCode == 200) {
        final responseData = json.decode(response.body);
        lastNotificationsSent = responseData['notifications_sent'] ?? 0;
        await fetchBlockDate();
        return responseData['success'] == true;
      } else {
        return false;
      }
    } catch (e) {
      print('Error saving block date: $e');
      return false;
    }
  }

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
    isLoading = true; 
    notifyListeners();

    try {
      final response = await http.post(
        Uri.parse('${Api.baseUrl}/student/update-bank'),
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
        isLoading = false;
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
    _currentBlockDate = date;
    _updateUpcomingDueDate(date);
    notifyListeners();
  }

  Future<void> fetchPaymentHistory(String studentId) async {
    isLoading = true;
    paymentHistory = []; 
    notifyListeners();

    try {
      final response = await http.get(
        Uri.parse('${Api.baseUrl}/student/payment-history/$studentId'),
        headers: _headers,
      );

      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        
        paymentHistory = data.where((payment) {
          final status = payment['status']?.toString().toLowerCase() ?? '';
          return status == 'success';
        }).toList();
        
        print('Payment History fetched: ${paymentHistory.length} records');
      } else {
        errorMessage = 'Failed to load payment history';
        paymentHistory = [];
      }
    } catch (e) {
      errorMessage = 'Network error: ${e.toString()}';
      paymentHistory = [];
    } finally {
      isLoading = false;
      notifyListeners();
    }
  }

  Future<void> fetchReportTotals({DateTime? startDate, DateTime? endDate}) async {
    isLoading = true;
    errorMessage = '';
    notifyListeners();

    try {
      String url = '${Api.baseUrl}/treasurer/report-totals';
      Map<String, String> queryParams = {};
      
      if (startDate != null && endDate != null) {
        queryParams['start_date'] = DateFormat('yyyy-MM-dd').format(startDate);
        queryParams['end_date'] = DateFormat('yyyy-MM-dd').format(endDate);
      }
      
      if (queryParams.isNotEmpty) {
        url += '?' + queryParams.entries.map((e) => '${e.key}=${e.value}').join('&');
      }

      final response = await http.get(
        Uri.parse(url),
        headers: _headers,
      );

      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        totalPaidReport = (data['total_paid'] ?? 0.0).toDouble();
        totalOutstandingReport = (data['total_outstanding'] ?? 0.0).toDouble();
        summary['blocked'] = data['blocked_count'] ?? 0;
        summary['bank_count'] = data['online_banking_count'] ?? 0;
        summary['card_count'] = data['card_payment_count'] ?? 0;
      }
    } catch (e) {
      errorMessage = "Failed to synchronize remote metrics.";
    } finally {
      isLoading = false;
      notifyListeners();
    }
  }

  void setFilter(String filter) {
    currentFilter = filter;
    fetchStudentsFeeStatus(page: 1);
  }

  void searchStudents(String query) {
    searchQuery = query;
    fetchStudentsFeeStatus(page: 1);
  }

  Future<void> checkBlockStatus(String userId) async {
    try {
      final response = await http.get(
        Uri.parse('${Api.baseUrl}/student/check-block/$userId'),
        headers: _headers,
      );

      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        _isBlocked = data['is_blocked'] ?? false;
        _blockMessage = data['message'] ?? '';
        notifyListeners();
      }
    } catch (e) {
      print('Error checking block status: $e');
      _isBlocked = false;
      _blockMessage = '';
      notifyListeners();
    }
  }

}