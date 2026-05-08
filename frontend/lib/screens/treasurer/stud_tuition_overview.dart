import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../provider/manage_fees_provider.dart';
import '../../provider/user_provider.dart';
import '../../widgets/app_sidebar.dart';
import '../../widgets/header.dart';
import '../../widgets/navigation_bar.dart';

class StudentTuitionOverviewPage extends StatefulWidget {
  final int userId;
  const StudentTuitionOverviewPage({Key? key, required this.userId}) : super(key: key);

  @override
  State<StudentTuitionOverviewPage> createState() => _StudentTuitionOverviewPageState();
  
}

  Widget build(BuildContext context) {
    final user = Provider.of<UserProvider>(context);
    final String role = user.role;

    return Scaffold(
      backgroundColor: const Color(0xFFE8F5E9), // Or getBackgroundColor(role) if defined globally
      appBar: const UsasHeader(),
      drawer: const AppSidebar(),
      bottomNavigationBar: const UsasBottomNav(),
      
      body: Consumer<FeesManagementProvider>(
        builder: (context, provider, child) {
          return SingleChildScrollView(
          );
        },
      ),
    );
  }

class _StudentTuitionOverviewPageState extends State<StudentTuitionOverviewPage> {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      Provider.of<FeesManagementProvider>(context, listen: false).fetchStudentDetail(widget.userId);
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFE8F5E9), // Light green background from prototype
      appBar: AppBar(
        title: const Text("Tuition Fees", style: TextStyle(color: Colors.black)),
        backgroundColor: Colors.transparent,
        elevation: 0,
        centerTitle: true,
        leading: IconButton(
          icon: const Icon(Icons.menu, color: Colors.black),
          onPressed: () {},
        ),
      ),
      body: Consumer<FeesManagementProvider>(
        builder: (context, provider, child) {
          if (provider.isLoading) return const Center(child: CircularProgressIndicator());
          final data = provider.selectedStudentDetail;
          if (data == null) return const Center(child: Text("No data found"));

          return SingleChildScrollView(
            padding: const EdgeInsets.all(16),
            child: Column(
              children: [
                _buildInfoCard("Student Information", [
                  _buildDetailRow("Name", data['name']),
                  _buildDetailRow("Course", data['course_name']),
                  _buildDetailRow("Program", data['program'] ?? "Bachelor's Degree"),
                  _buildDetailRow("Matric ID", data['matric_id']),
                  _buildDetailRow("Email", data['email']),
                  _buildDetailRow("Telephone No.", data['phone_num'] ?? "N/A"),
                ]),
                const SizedBox(height: 20),
                _buildInfoCard("Fee Summary", [
                  _buildDetailRow("Total Invoice", "RM ${data['total_fee']}", isBold: true, valueColor: Colors.indigo.shade900),
                  _buildDetailRow("Total Payment", "RM ${data['paid_amount']}", isBold: true, valueColor: Colors.indigo.shade900),
                  _buildDetailRow("Outstanding", "RM ${data['outstanding_amount']}"),
                  _buildDetailRow("Status", data['status'].toString().toUpperCase()),
                ]),
              ],
            ),
          );
        },
      ),
    );
  }

  Widget _buildInfoCard(String title, List<Widget> children) {
    return Card(
      elevation: 2,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(title, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
            const Divider(height: 24),
            ...children,
          ],
        ),
      ),
    );
  }

  Widget _buildDetailRow(String label, String value, {bool isBold = false, Color? valueColor}) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 6),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(width: 110, child: Text(label, style: const TextStyle(color: Colors.grey, fontSize: 13))),
          Expanded(
            child: Text(
              value,
              style: TextStyle(
                fontSize: 13,
                fontWeight: isBold ? FontWeight.bold : FontWeight.normal,
                color: valueColor ?? Colors.black87,
              ),
            ),
          ),
        ],
      ),
    );
  }
}