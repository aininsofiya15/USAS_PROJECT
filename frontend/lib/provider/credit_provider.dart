import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import '../config/api.dart';
import '../domain/credit.dart';

class CreditProvider with ChangeNotifier {

  // ── Student STATES ──
  CreditClaim? _activeClaim;
  bool _hasClaim = false;

  // ── Pusat Adab STATES ──
  List<AdminCreditClaim> _adminClaims = [];
  String _currentAdminFilter = 'all'; // Tracks if view shows 'all' or 'pending' claims

  // ── Shared STATES ──
  bool _isLoading = false;

  // ── Getters ──
  CreditClaim? get activeClaim => _activeClaim;
  bool get hasClaim => _hasClaim;
  List<AdminCreditClaim> get adminClaims => _adminClaims;
  String get currentAdminFilter => _currentAdminFilter;
  bool get isLoading => _isLoading;


  // =========================================================================
  // STUDENT OPERATION METHODS
  // =========================================================================

  // 1. Check if the student has already submitted a credit claim
  Future<void> fetchClaimStatus(String studentId) async {
    _isLoading = true;
    notifyListeners(); // Show loading spinner on student screen

    final url = Uri.parse(Api.checkCreditStatus(studentId));

    try {

      // Send GET request to check if there's an active claim for the student
      final response = await http.get(url);
      // If the server returns a successful response, parse the data
      if (response.statusCode == 200) {
        final Map<String, dynamic> responseData = jsonDecode(response.body);

        // Save data if the student has an active claim record 
        if (responseData['data'] != null) {
          _activeClaim = CreditClaim.fromJson(responseData['data']);
          _hasClaim = true;
        // If the server returns a 'exists' status, it means the student has already submitted a claim
        } else if (responseData['status'] == 'exists' || responseData['status'] == 'success') {
          _activeClaim = CreditClaim.fromJson(responseData['data']);
          _hasClaim = true;
          // If the server returns a 'no_record' status, it means the student has not submitted any claim yet
        } else {
          _activeClaim = null;
          _hasClaim = false;
        }
      } else {
        _activeClaim = null;
        _hasClaim = false;
      }
    } catch (e) {
      debugPrint("Error fetching student claim status: $e");
      _activeClaim = null;
      _hasClaim = false;
    }
    _isLoading = false;
    notifyListeners(); // Turn off loading spinner
  }

  // 2. Let a student submit their final credit claims
  Future<String> submitCreditClaim({required String studentId}) async {
    _isLoading = true;
    notifyListeners(); // Show loading spinner

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
        await fetchClaimStatus(studentId); // Re-fetch status to show 'pending' view immediately
        return "success";
      } else if (response.statusCode == 409) {
        return "duplicate"; // Blocks user if they try to click submit twice
      } else {
        return "error";
      }
    } catch (e) {
      debugPrint("Network error during credit submission: $e");
      _isLoading = false;
      notifyListeners();
      return "network_failure";
    }
  }

  // 3. Fetch all student applications for the Pusat Adab dashboard list
  Future<void> fetchAllClaims(String filter) async {
    _isLoading = true;
    _currentAdminFilter = filter; // Save if view is filtered by 'all' or 'pending'
    notifyListeners(); // Show loading spinner on admin dashboard

    final url = Uri.parse(Api.getAdminClaims(filter));

    try {
      final response = await http.get(url);

      if (response.statusCode == 200) {
        final Map<String, dynamic> responseData = jsonDecode(response.body);
        if (responseData['data'] != null) {
          final List<dynamic> claimsList = responseData['data'];
          // Map database array elements to our local Admin model array list
          _adminClaims = claimsList.map((item) => AdminCreditClaim.fromJson(item)).toList();
        } else {
          _adminClaims = [];
        }
      } else {
        _adminClaims = [];
      }
    } catch (e) {
      debugPrint("Admin claims load error: $e");
      _adminClaims = [];
    }

    _isLoading = false;
    notifyListeners(); // Turn off loading spinner and refresh dashboard cards
  }

  // 4. Approve/Reject student credit claim application 
  Future<bool> processReview(int claimId) async {
    final url = Uri.parse(Api.approveAdminClaim(claimId));

    try {
      final response = await http.post(url);

      if (response.statusCode == 200) {
        // Automatically re-fetch list right away so approved card disappears from 'pending' list
        await fetchAllClaims(_currentAdminFilter);
        return true;
      }
      return false;
    } catch (e) {
      debugPrint("Error processing claim approval: $e");
      return false;
    }
  }

  // 5. Reject button to deny application status
  Future<bool> rejectStudentApplication(int claimId) async {
    final url = Uri.parse(Api.rejectAdminClaim(claimId));

    try {
      final response = await http.post(url);

      if (response.statusCode == 200) {
        // Automatically re-fetch list right away to show updated application statuses
        await fetchAllClaims(_currentAdminFilter);
        return true;
      }
      return false;
    } catch (e) {
      debugPrint("Error processing claim rejection: $e");
      return false;
    }
  }
}