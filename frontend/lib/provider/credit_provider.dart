import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import '../config/api.dart';
import '../domain/credit.dart';

class CreditProvider with ChangeNotifier {
  // ── 👤 STUDENT STATES ──
  CreditClaim? _activeClaim;
  bool _hasClaim = false;

  // ── 🏢 ADMIN (PUSAT ADAB) STATES ──
  List<AdminCreditClaim> _adminClaims = [];
  String _currentAdminFilter = 'all'; // Tracks active view: 'all' or 'pending'

  // ── ⚡ SHARED STATES ──
  bool _isLoading = false;

  // ── 🔓 GETTERS ──
  CreditClaim? get activeClaim => _activeClaim;
  bool get hasClaim => _hasClaim;
  List<AdminCreditClaim> get adminClaims => _adminClaims;
  String get currentAdminFilter => _currentAdminFilter;
  bool get isLoading => _isLoading;


  // =========================================================================
  // 👤 STUDENT OPERATION METHODS
  // =========================================================================

  /// 🔄 FETCH LIVE STATUS FLOW (STUDENT)
  /// Asks Laravel if a database row exists for this student and parses it dynamically
  Future<void> fetchLiveClaimStatus(String studentId) async {
    _isLoading = true;
    notifyListeners();

    final url = Uri.parse(Api.checkCreditStatus(studentId));

    try {
      final response = await http.get(url);

      if (response.statusCode == 200) {
        final Map<String, dynamic> responseData = jsonDecode(response.body);

        if (responseData['data'] != null) {
          _activeClaim = CreditClaim.fromJson(responseData['data']);
          _hasClaim = true;
        } else if (responseData['status'] == 'exists' || responseData['status'] == 'success') {
          _activeClaim = CreditClaim.fromJson(responseData['data']);
          _hasClaim = true;
        } else {
          _activeClaim = null;
          _hasClaim = false;
        }
      } else {
        _activeClaim = null;
        _hasClaim = false;
      }
    } catch (e) {
      print("Error fetching dynamic claim metrics from database: $e");
      _activeClaim = null;
      _hasClaim = false;
    }

    _isLoading = false;
    notifyListeners();
  }

  /// 🟢 FINAL SUBMISSION FLOW (STUDENT)
  /// Dispatches the student_id to your automated submitFinalCredit Laravel method
  Future<String> submitFinalCredit({required String studentId}) async {
    _isLoading = true;
    notifyListeners();

    final url = Uri.parse(Api.submitCreditClaim);

    try {
      final response = await http.post(
         url,
         headers: {"Content-Type": "application/json"},
         body: jsonEncode({
           "student_id": int.parse(studentId),
         }),
      );

      _isLoading = false;
      notifyListeners();

      if (response.statusCode == 201) {
        await fetchLiveClaimStatus(studentId);
        return "success";
      } else if (response.statusCode == 409) {
        return "duplicate"; 
      } else {
        return "error";
      }
    } catch (e) {
      print("Network breakdown on credit submission execution context: $e");
      _isLoading = false;
      notifyListeners();
      return "network_failure";
    }
  }


  // =========================================================================
  // 🏢 ADMIN (PUSAT ADAB) OPERATION METHODS
  // =========================================================================

  /// 📋 FETCH ALL CLAIMS (ADMIN)
  /// Targets endpoints using the filter parameter to parse student applications
  Future<void> fetchAdminClaims(String filter) async {
    _isLoading = true;
    _currentAdminFilter = filter;
    notifyListeners();

    final url = Uri.parse(Api.getAdminClaims(filter));

    try {
      final response = await http.get(url);

      if (response.statusCode == 200) {
        final Map<String, dynamic> responseData = jsonDecode(response.body);
        if (responseData['data'] != null) {
          final List<dynamic> claimsList = responseData['data'];
          _adminClaims = claimsList.map((item) => AdminCreditClaim.fromJson(item)).toList();
        } else {
          _adminClaims = [];
        }
      } else {
        _adminClaims = [];
      }
    } catch (e) {
      print("Admin compilation network breakdown context: $e");
      _adminClaims = [];
    }

    _isLoading = false;
    notifyListeners();
  }

  /// ✅ APPROVE APPLICATION ACTION DISPATCHER (ADMIN)
  Future<bool> approveStudentApplication(int claimId) async {
    final url = Uri.parse(Api.approveAdminClaim(claimId));

    try {
      final response = await http.post(url);

      if (response.statusCode == 200) {
        // Automatically sync the workspace state right after a modification
        await fetchAdminClaims(_currentAdminFilter);
        return true;
      }
      return false;
    } catch (e) {
      print("Error processing approval transaction: $e");
      return false;
    }
  }

  /// ❌ REJECT APPLICATION ACTION DISPATCHER (ADMIN)
  Future<bool> rejectStudentApplication(int claimId) async {
    final url = Uri.parse(Api.rejectAdminClaim(claimId));

    try {
      final response = await http.post(url);

      if (response.statusCode == 200) {
        // Automatically sync the workspace state right after a modification
        await fetchAdminClaims(_currentAdminFilter);
        return true;
      }
      return false;
    } catch (e) {
      print("Error processing rejection transaction: $e");
      return false;
    }
  }
}