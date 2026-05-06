import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';

class StudentFeeDetailPage extends StatefulWidget {
  final int studentId;
  final String studentName;

  const StudentFeeDetailPage({
    Key? key,
    required this.studentId,
    required this.studentName,
  }) : super(key: key);

  @override
  State<StudentFeeDetailPage> createState() => _StudentFeeDetailPageState();
}

class _StudentFeeDetailPageState extends State<StudentFeeDetailPage> {
  bool isLoading = true;
  Map<String, dynamic>? studentData;
  String errorMessage = '';

  @override
  void initState() {
    super.initState();
    _fetchStudentDetail();
  }

  Future<void> _fetchStudentDetail() async {
    setState(() {
      isLoading = true;
      errorMessage = '';
    });

    try {
      final response = await http.get(
        Uri.parse('http://10.0.2.2:8000/api/treasurer/student-fee-detail/${widget.studentId}'),
        headers: {
          'Content-Type': 'application/json',
          'Accept': 'application/json',
        },
      );

      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        setState(() {
          studentData = data;
          isLoading = false;
        });
      } else {
        setState(() {
          errorMessage = 'Failed to load student details';
          isLoading = false;
        });
      }
    } catch (e) {
      setState(() {
        errorMessage = 'Network error: ${e.toString()}';
        isLoading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(widget.studentName),
        backgroundColor: Colors.blue.shade700,
        foregroundColor: Colors.white,
      ),
      body: isLoading
          ? const Center(child: CircularProgressIndicator())
          : errorMessage.isNotEmpty
              ? _buildErrorView()
              : _buildDetailView(),
    );
  }

  Widget _buildErrorView() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(Icons.error_outline, size: 64, color: Colors.red.shade300),
          const SizedBox(height: 16),
          Text(errorMessage),
          const SizedBox(height: 16),
          ElevatedButton(
            onPressed: _fetchStudentDetail,
            child: const Text('Retry'),
          ),
        ],
      ),
    );
  }

  Widget _buildDetailView() {
    final student = studentData!['student'];
    final feeSummary = studentData!['fee_summary'];
    final paymentHistory = studentData!['payment_history'] as List;
    final bankAccount = studentData!['bank_account'];

    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Student Information Card
          Card(
            elevation: 2,
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      CircleAvatar(
                        radius: 30,
                        backgroundColor: Colors.blue.shade100,
                        child: Text(
                          widget.studentName.isNotEmpty ? widget.studentName[0].toUpperCase() : 'S',
                          style: TextStyle(fontSize: 24, color: Colors.blue.shade800),
                        ),
                      ),
                      const SizedBox(width: 16),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              student['name'],
                              style: const TextStyle(
                                fontSize: 20,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                            const SizedBox(height: 4),
                            Text('Matric: ${student['matric_no']}'),
                            Text('Email: ${student['email']}'),
                          ],
                        ),
                      ),
                    ],
                  ),
                  const Divider(height: 24),
                  Row(
                    children: [
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text('Faculty', style: TextStyle(color: Colors.grey.shade600)),
                            const SizedBox(height: 4),
                            Text(student['faculty'] ?? 'N/A'),
                          ],
                        ),
                      ),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text('Course', style: TextStyle(color: Colors.grey.shade600)),
                            const SizedBox(height: 4),
                            Text(student['course'] ?? 'N/A'),
                          ],
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 12),
                  Row(
                    children: [
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text('Semester', style: TextStyle(color: Colors.grey.shade600)),
                            const SizedBox(height: 4),
                            Text(student['semester']?.toString() ?? 'N/A'),
                          ],
                        ),
                      ),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text('Year', style: TextStyle(color: Colors.grey.shade600)),
                            const SizedBox(height: 4),
                            Text(student['year']?.toString() ?? 'N/A'),
                          ],
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ),
          const SizedBox(height: 16),

          // Fee Summary Card
          Card(
            elevation: 2,
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text(
                    'Fee Summary',
                    style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                  ),
                  const SizedBox(height: 16),
                  _buildFeeRow('Total Fees', feeSummary['total_fees'], Colors.blue),
                  _buildFeeRow('Paid Amount', feeSummary['paid_amount'], Colors.green),
                  _buildFeeRow('Balance', feeSummary['balance'], 
                      feeSummary['balance'] > 0 ? Colors.red : Colors.green),
                  const SizedBox(height: 12),
                  Container(
                    padding: const EdgeInsets.all(12),
                    decoration: BoxDecoration(
                      color: feeSummary['status'] == 'paid'
                          ? Colors.green.shade50
                          : feeSummary['status'] == 'blocked'
                              ? Colors.red.shade50
                              : Colors.orange.shade50,
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: Row(
                      children: [
                        Icon(
                          feeSummary['status'] == 'paid'
                              ? Icons.check_circle
                              : feeSummary['status'] == 'blocked'
                                  ? Icons.block
                                  : Icons.warning,
                          color: feeSummary['status'] == 'paid'
                              ? Colors.green
                              : feeSummary['status'] == 'blocked'
                                  ? Colors.red
                                  : Colors.orange,
                        ),
                        const SizedBox(width: 12),
                        Text(
                          feeSummary['status'] == 'paid'
                              ? 'Fully Paid - All good!'
                              : feeSummary['status'] == 'blocked'
                                  ? 'Blocked - Payment required'
                                  : 'Pending Payment',
                          style: TextStyle(
                            fontWeight: FontWeight.w500,
                            color: feeSummary['status'] == 'paid'
                                ? Colors.green.shade800
                                : feeSummary['status'] == 'blocked'
                                    ? Colors.red.shade800
                                    : Colors.orange.shade800,
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ),
          const SizedBox(height: 16),

          // Bank Account Card
          if (bankAccount != null)
            Card(
              elevation: 2,
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
              child: Padding(
                padding: const EdgeInsets.all(16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text(
                      'Bank Account',
                      style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                    ),
                    const SizedBox(height: 12),
                    Row(
                      children: [
                        Icon(Icons.account_balance, color: Colors.grey.shade700),
                        const SizedBox(width: 12),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text('${bankAccount['bank_name']} - ${bankAccount['account_number']}'),
                              Text(
                                'Holder: ${bankAccount['account_holder_name']}',
                                style: TextStyle(color: Colors.grey.shade600, fontSize: 12),
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ),
          const SizedBox(height: 16),

          // Payment History Card
          Card(
            elevation: 2,
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text(
                    'Payment History',
                    style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                  ),
                  const SizedBox(height: 12),
                  if (paymentHistory.isEmpty)
                    Center(
                      child: Padding(
                        padding: const EdgeInsets.all(32),
                        child: Text(
                          'No payment records found',
                          style: TextStyle(color: Colors.grey.shade600),
                        ),
                      ),
                    )
                  else
                    ListView.separated(
                      shrinkWrap: true,
                      physics: const NeverScrollableScrollPhysics(),
                      itemCount: paymentHistory.length,
                      separatorBuilder: (context, index) => const Divider(),
                      itemBuilder: (context, index) {
                        final payment = paymentHistory[index];
                        return ListTile(
                          leading: CircleAvatar(
                            backgroundColor: Colors.green.shade100,
                            child: Icon(Icons.payment, color: Colors.green.shade800, size: 20),
                          ),
                          title: Text('RM ${payment['amount']?.toStringAsFixed(2) ?? '0.00'}'),
                          subtitle: Text(_formatPaymentMethod(payment['payment_method'])),
                          trailing: Column(
                            mainAxisAlignment: MainAxisAlignment.center,
                            crossAxisAlignment: CrossAxisAlignment.end,
                            children: [
                              Text(
                                payment['paid_at'] != null
                                    ? DateTime.parse(payment['paid_at']).toString().split(' ')[0]
                                    : 'N/A',
                                style: const TextStyle(fontSize: 12),
                              ),
                              const SizedBox(height: 2),
                              Container(
                                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                                decoration: BoxDecoration(
                                  color: payment['status'] == 'completed'
                                      ? Colors.green.shade100
                                      : Colors.orange.shade100,
                                  borderRadius: BorderRadius.circular(12),
                                ),
                                child: Text(
                                  payment['status'] ?? 'pending',
                                  style: TextStyle(
                                    fontSize: 10,
                                    color: payment['status'] == 'completed'
                                        ? Colors.green.shade800
                                        : Colors.orange.shade800,
                                  ),
                                ),
                              ),
                            ],
                          ),
                        );
                      },
                    ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildFeeRow(String label, double amount, Color color) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(label, style: const TextStyle(fontSize: 16)),
          Text(
            'RM ${amount.toStringAsFixed(2)}',
            style: TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.bold,
              color: color,
            ),
          ),
        ],
      ),
    );
  }

  String _formatPaymentMethod(String method) {
    if (method == 'internet_banking') return 'Internet Banking';
    if (method == 'credit_card') return 'Credit / Debit Card';
    return method;
  }
}