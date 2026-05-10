import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:intl/intl.dart'; // Import this for currency formatting
import '../../provider/manage_fees_provider.dart';
import '../../widgets/header.dart';
import '../../widgets/navigation_bar.dart';
import '../payment_history.dart';

class StudentTuitionOverviewPage extends StatefulWidget {
  final int userId;
  const StudentTuitionOverviewPage({super.key, required this.userId});

  @override
  State<StudentTuitionOverviewPage> createState() => _StudentTuitionOverviewPageState();
}

class _StudentTuitionOverviewPageState extends State<StudentTuitionOverviewPage> {
  // Helper to format numbers to RM format
  String formatCurrency(dynamic amount) {
    final double value = double.tryParse(amount?.toString() ?? '0') ?? 0.0;
    return NumberFormat.currency(symbol: 'RM ', decimalDigits: 2).format(value);
  }

  @override
  void initState() {
    super.initState();
    Future.microtask(() => 
      Provider.of<FeesManagementProvider>(context, listen: false).fetchStudentDetail(widget.userId)
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFDCF8C6),
      appBar: const UsasHeader(),
      bottomNavigationBar: const UsasBottomNav(),
      body: Consumer<FeesManagementProvider>(
        builder: (context, provider, child) {
          if (provider.isLoading) return const Center(child: CircularProgressIndicator());
          
          final data = provider.selectedStudentDetail;
          if (data == null) return const Center(child: Text("Data not found"));

          return SingleChildScrollView(
            padding: const EdgeInsets.all(20),
            child: Column(
              children: [
                const Text("Tuition Fees", style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold)),
                const SizedBox(height: 20),
                
                // Card 1: Student Information
                _buildInfoCard("Student Information", [
                  _buildDetailRow("Name", data['name']),
                  _buildDetailRow("Course", data['course_name']),
                  _buildDetailRow("Program", data['program'] ?? "Bachelor's Degree"),
                  _buildDetailRow("Matric ID", data['student_id']),
                  _buildDetailRow("Email", data['email']),
                  _buildDetailRow("Telephone No.", data['phone_num']),
                ]),
                
                const SizedBox(height: 20),

                // Card 2: Fee Summary (DYNAMIC VERSION)
                _buildInfoCard("Fee Summary", [
                  // 1. Total Invoice from 'total_invoice' field
                  _buildDetailRow(
                    "Total Invoice", 
                    formatCurrency(data['total_invoice']), 
                    isBlue: false
                  ), 
                  
                  // 2. Total Payment from 'total_payment' field
                  _buildDetailRow(
                    "Total Payment", 
                    formatCurrency(data['total_payment']), 
                    isBlue: true,
                    onTap: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (context) => PaymentHistoryPage(
                            targetStudentId: widget.userId.toString(),
                          ),
                        ),
                      );
                    },
                  ), 
                  
                  // 3. Outstanding from 'outstanding_amount' field
                  _buildDetailRow(
                    "Outstanding", 
                    formatCurrency(data['outstanding_amount'])
                  ),

                  // 4. Status
                  _buildDetailRow(
                    "Status", 
                    data['status']?.toString().toUpperCase() ?? "UNKNOWN"
                  ),
                ]),
              ],
            ),
          );
        },
      ),
    );
  }

  // ... rest of your _buildInfoCard and _buildDetailRow methods stay the same
  Widget _buildInfoCard(String title, List<Widget> children) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(15),
        boxShadow: const [BoxShadow(color: Colors.black12, blurRadius: 10, offset: Offset(0, 5))],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(title, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
          const SizedBox(height: 15),
          ...children,
        ],
      ),
    );
  }

  Widget _buildDetailRow(String label, dynamic value, {bool isBlue = false, VoidCallback? onTap}) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 6),
      child: InkWell(
        onTap: onTap,
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            SizedBox(width: 110, child: Text(label, style: const TextStyle(color: Colors.black87, fontSize: 13))),
            Expanded(
              child: Text(
                value?.toString() ?? "N/A",
                style: TextStyle(
                  fontSize: 13,
                  fontWeight: isBlue ? FontWeight.bold : FontWeight.normal,
                  color: isBlue ? const Color(0xFF3F51B5) : Colors.black,
                  decoration: onTap != null ? TextDecoration.underline : TextDecoration.none,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}