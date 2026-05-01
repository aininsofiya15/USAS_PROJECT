import 'package:flutter/material.dart';

class FeesManagementPage extends StatefulWidget {
  const FeesManagementPage({super.key});

  @override
  State<FeesManagementPage> createState() => _FeesManagementPageState();
}

class _FeesManagementPageState extends State<FeesManagementPage> {
  // Student data as per SRS documentation
  final List<Map<String, String>> students = [
    {"id": "20001", "name": "Ahmad Bin Zaki", "status": "Paid", "balance": "RM 0.00"},
    {"id": "20002", "name": "Siti Aminah", "status": "Unpaid", "balance": "RM 1,200.00"},
    {"id": "20003", "name": "John Doe", "status": "Unpaid", "balance": "RM 450.00"},
    {"id": "20004", "name": "Nurul Izzah", "status": "Paid", "balance": "RM 0.00"},
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      // USAS Header Style
      appBar: AppBar(
        title: const Text(
          "Tuition Fees Management",
          style: TextStyle(color: Colors.black, fontSize: 20, fontWeight: FontWeight.w600),
        ),
        backgroundColor: const Color(0xFFE8F8E3), 
        elevation: 0,
        centerTitle: true,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Colors.black),
          onPressed: () => Navigator.pop(context),
        ),
      ),
      body: Column(
        children: [
          // Search/Filter Bar - Matching Document Specification
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 15),
            child: Container(
              height: 50,
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(10),
                border: Border.all(color: Colors.grey.shade300),
              ),
              child: const TextField(
                decoration: InputDecoration(
                  hintText: "Search Student ID or Name...",
                  hintStyle: TextStyle(color: Colors.grey, fontSize: 14),
                  prefixIcon: Icon(Icons.search, color: Colors.grey),
                  border: InputBorder.none,
                  contentPadding: EdgeInsets.symmetric(vertical: 12),
                ),
              ),
            ),
          ),

          // Student List Header Labels
          const Padding(
            padding: EdgeInsets.symmetric(horizontal: 25, vertical: 5),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text("Student Info", style: TextStyle(fontWeight: FontWeight.bold, color: Colors.black54)),
                Text("Status", style: TextStyle(fontWeight: FontWeight.bold, color: Colors.black54)),
              ],
            ),
          ),
          const Divider(indent: 20, endIndent: 20),

          // List implementation matching UI-403 mockup
          Expanded(
            child: ListView.separated(
              itemCount: students.length,
              separatorBuilder: (context, index) => const Divider(height: 1, indent: 20, endIndent: 20),
              itemBuilder: (context, index) {
                final student = students[index];
                bool isPaid = student['status'] == "Paid";

                return ListTile(
                  contentPadding: const EdgeInsets.symmetric(horizontal: 20, vertical: 8),
                  leading: CircleAvatar(
                    backgroundColor: Colors.grey.shade200,
                    child: Text(
                      student['id']!.substring(3),
                      style: const TextStyle(color: Colors.black, fontWeight: FontWeight.bold),
                    ),
                  ),
                  title: Text(
                    student['name']!,
                    style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 15),
                  ),
                  subtitle: Text(
                    "ID: ${student['id']}\nBalance: ${student['balance']}",
                    style: const TextStyle(fontSize: 13, color: Colors.black87),
                  ),
                  trailing: Container(
                    padding: const EdgeInsets.symmetric(horizontal: 15, vertical: 6),
                    decoration: BoxDecoration(
                      color: isPaid ? const Color(0xFFC8E6C9) : const Color(0xFFFFCDD2),
                      borderRadius: BorderRadius.circular(5),
                    ),
                    child: Text(
                      student['status']!,
                      style: TextStyle(
                        color: isPaid ? Colors.green.shade900 : Colors.red.shade900,
                        fontWeight: FontWeight.bold,
                        fontSize: 12,
                      ),
                    ),
                  ),
                );
              },
            ),
          ),
        ],
      ),
    );
  }
}