import 'package:flutter/material.dart';
import 'studPaymentHistory.dart';

class StudTuitionOverviewPage extends StatelessWidget {
  final Map<String, String> studentData;

  const StudTuitionOverviewPage({super.key, required this.studentData});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Student Tuition Overview"),
        backgroundColor: const Color(0xFFE8F8E3),
      ),
      body: Padding(
        padding: const EdgeInsets.all(20.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Student Info Header
            Card(
              elevation: 0,
              color: Colors.blue.withOpacity(0.05),
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(15)),
              child: Padding(
                padding: const EdgeInsets.all(20.0),
                child: Row(
                  children: [
                    const CircleAvatar(radius: 30, child: Icon(Icons.person, size: 35)),
                    const SizedBox(width: 15),
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(studentData['name']!, style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
                        Text("ID: ${studentData['id']}", style: const TextStyle(color: Colors.black54)),
                      ],
                    ),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 25),
            
            // Financial Summary Sections (UI-404)
            const Text("Financial Summary", style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
            const SizedBox(height: 10),
            _buildDetailRow("Outstanding Balance", studentData['balance']!, isBold: true, color: Colors.red),
            _buildDetailRow("Payment Status", studentData['status']!, color: studentData['status'] == "Paid" ? Colors.green : Colors.orange),
            const Divider(height: 40),
            
            const Spacer(),
            
            // Action Button to History (UI-405)
            SizedBox(
              width: double.infinity,
              height: 55,
              child: ElevatedButton(
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.blue.shade800,
                  foregroundColor: Colors.white,
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10))
                ),
                onPressed: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(builder: (context) => StudPaymentHistoryPage()),
                  );
                },
                child: const Text("VIEW PAYMENT HISTORY"),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildDetailRow(String label, String value, {bool isBold = false, Color? color}) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8.0),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(label, style: const TextStyle(fontSize: 16)),
          Text(
            value, 
            style: TextStyle(
              fontSize: 16, 
              fontWeight: isBold ? FontWeight.bold : FontWeight.normal,
              color: color ?? Colors.black
            )
          ),
        ],
      ),
    );
  }
}