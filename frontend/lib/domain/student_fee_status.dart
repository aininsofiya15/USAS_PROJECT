class StudentFeeStatus {
  final int userId;
  final String matricId;
  final String name;
  final double outstandingAmount;
  final String status;
  final bool isBlocked;

  StudentFeeStatus({
    required this.userId,
    required this.matricId,
    required this.name,
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