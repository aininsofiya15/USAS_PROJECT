import 'package:flutter/material.dart';

class CreditClaim {
  final int id;
  final int studentId;
  final int subjectId;
  final String subjectCode;
  final String subjectName;
  final String status; // Tracks 'pending', 'approved', or 'rejected'

  CreditClaim({
    required this.id,
    required this.studentId,
    required this.subjectId,
    required this.subjectCode,
    required this.subjectName,
    required this.status,
  });

  factory CreditClaim.fromJson(Map<String, dynamic> json) {
    return CreditClaim(
      id: json['id'] ?? 0,
      studentId: json['student_id'] ?? 0,
      subjectId: json['subject_id'] ?? 0,
      subjectCode: json['subject_code'] ?? 'UQA2002',
      subjectName: json['subject_name'] ?? 'Ko-Kurikulum',
      status: json['status'] ?? 'pending',
    );
  }

  String get actionMessage {
    switch (status.toLowerCase()) {
      case 'pending':
        return 'Wait for Pusat Adab Approval';
      case 'approved':
        return '-';
      case 'rejected':
        return 'Claim rejected. Please contact Pusat Adab.';
      default:
        return '-';
    }
  }
}

//  PUSAT ADAB ADMINISTRATIVE CREDIT MODEL ──
class AdminCreditClaim {
  final int claimId;
  final int studentId;
  final String studentName;
  final String matricId;
  final String claimStatus;
  final List<String> completedModules;

  AdminCreditClaim({
    required this.claimId,
    required this.studentId,
    required this.studentName,
    required this.matricId,
    required this.claimStatus,
    required this.completedModules,
  });

  factory AdminCreditClaim.fromJson(Map<String, dynamic> json) {
    return AdminCreditClaim(
      claimId: json['claim_id'] ?? 0,
      studentId: json['student_id'] ?? 0,
      studentName: json['student_name'] ?? 'Unknown Student',
      matricId: json['matric_id']?.toString() ?? '-', 
      claimStatus: json['claim_status'] ?? 'pending',
      completedModules: List<String>.from(json['completed_modules'] ?? []),
    );
  }
}