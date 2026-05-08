import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../provider/manage_fees_provider.dart';
import '../../widgets/header.dart';
import '../../widgets/navigation_bar.dart';

class StudentTuitionOverviewPage extends StatefulWidget {
  final int userId;
  const StudentTuitionOverviewPage({Key? key, required this.userId}) : super(key: key);

  @override
  State<StudentTuitionOverviewPage> createState() => _StudentTuitionOverviewPageState();
}

class _StudentTuitionOverviewPageState extends State<StudentTuitionOverviewPage> {
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
      backgroundColor: const Color(0xFFDCF8C6), // Prototype Light Green
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
                
                // Card 1: Student Information (Live DB Data)
                _buildInfoCard("Student Information", [
                  _buildDetailRow("Name", data['name']),
                  _buildDetailRow("Course", data['course_name']),
                  _buildDetailRow("Program", data['program'] ?? "Bachelor's Degree"),
                  _buildDetailRow("Matric ID", data['student_id']),
                  _buildDetailRow("Email", data['email']),
                  _buildDetailRow("Telephone No.", data['phone_num']),
                ]),
                
                const SizedBox(height: 20),

                // Card 2: Fee Summary (Mixed Data)
                _buildInfoCard("Fee Summary", [
                  _buildDetailRow("Total Invoice", "RM 7,500.00", isBlue: true), // Hardcoded
                  _buildDetailRow("Total Payment", "RM 7,500.00", isBlue: true), // Hardcoded
                  _buildDetailRow("Outstanding", "RM ${data['outstanding_amount']}"), // DB Data
                  _buildDetailRow("Status", data['status'].toString().toUpperCase()), // DB Data
                ]),
              ],
            ),
          );
        },
      ),
    );
  }

  Widget _buildInfoCard(String title, List<Widget> children) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(15),
        boxShadow: [BoxShadow(color: Colors.black12, blurRadius: 10, offset: Offset(0, 5))],
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

  Widget _buildDetailRow(String label, dynamic value, {bool isBlue = false}) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 6),
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
              ),
            ),
          ),
        ],
      ),
    );
  }
}