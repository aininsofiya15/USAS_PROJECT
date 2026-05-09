import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:intl/intl.dart';
import '../../provider/attendance_provider.dart';
import 'attendance_record_list.dart'; // Where you will do the grading
import '../../widgets/header.dart';
import '../../widgets/app_sidebar.dart';
import '../../widgets/navigation_bar.dart';

class ModuleAttendanceSelectionPage extends StatefulWidget {
  final dynamic module;
  const ModuleAttendanceSelectionPage({super.key, this.module});
  
  @override
  State<ModuleAttendanceSelectionPage> createState() => _ModuleAttendanceSelectionPageState();
}

class _ModuleAttendanceSelectionPageState extends State<ModuleAttendanceSelectionPage> {
  DateTime? selectedDate;

  @override
  void initState() {
    super.initState();
    // CALL YOUR PART: Fetch only the curriculum modules from bookings
    WidgetsBinding.instance.addPostFrameCallback((_) {
      Provider.of<AttendanceProvider>(context, listen: false).fetchPusatAdabSessions();
    });
  }

  @override
  Widget build(BuildContext context) {
    final provider = Provider.of<AttendanceProvider>(context);

    // Filter Logic: Show modules matching the selected date from the calendar
    final displayedModules = provider.subjects.where((module) {
      if (selectedDate == null) return true;
      String formattedDate = DateFormat('yyyy-MM-dd').format(selectedDate!);
      return module.dateTime.contains(formattedDate);
    }).toList();

    return Scaffold(
      backgroundColor: const Color(0xFFD1FFF3),
      appBar: const UsasHeader(),
      drawer: const AppSidebar(),
      bottomNavigationBar: const UsasBottomNav(),
      body: Column(
        children: [
          const SizedBox(height: 50),
          const Text(
            "Module Attendance Records",
            style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 15),

          // Date Selector Bar (image_1acc8f.png)
          _buildDateFilter(),

          Expanded(
            child: provider.isLoading
                ? const Center(child: CircularProgressIndicator())
                : ListView.builder(
                    padding: const EdgeInsets.symmetric(horizontal: 20),
                    itemCount: displayedModules.length,
                    itemBuilder: (context, index) {
                      return _buildModuleCard(displayedModules[index]);
                    },
                  ),
          ),
        ],
      ),
    );
  }

  Widget _buildDateFilter() {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 25, vertical: 10),
      padding: const EdgeInsets.symmetric(horizontal: 15, vertical: 5),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(15),
      ),
      child: Row(
        children: [
          const Text("DATE:", style: TextStyle(fontWeight: FontWeight.bold)),
          const Spacer(),
          Text(selectedDate == null 
              ? "Select Date" 
              : DateFormat('dd-MM-yyyy').format(selectedDate!)),
          IconButton(
            icon: const Icon(Icons.calendar_month_outlined),
            onPressed: () async {
              DateTime? picked = await showDatePicker(
                context: context,
                initialDate: DateTime.now(),
                firstDate: DateTime(2025),
                lastDate: DateTime(2030),
              );
              if (picked != null) setState(() => selectedDate = picked);
            },
          ),
          if (selectedDate != null)
            GestureDetector(
              onTap: () => setState(() => selectedDate = null),
              child: const Icon(Icons.close, size: 20, color: Colors.grey),
            )
        ],
      ),
    );
  }

  Widget _buildModuleCard(dynamic module) {
    return Container(
      margin: const EdgeInsets.only(bottom: 15),
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(25),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // module.name comes from activity_name in bookings table
          Text(
            module.name.toUpperCase(),
            style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
          ),
          const SizedBox(height: 5),
          // module.dateTime comes from booking_date
          Text(
            "Class Date: ${module.dateTime} 08:00 AM - 17:00 PM",
            style: const TextStyle(fontSize: 12, color: Colors.grey),
          ),
          const SizedBox(height: 15),
          Row(
            mainAxisAlignment: MainAxisAlignment.end,
            children: [
              _actionButton("Edit", Colors.green.shade400, () {
                // Future task: Edit the booking
              }),
              const SizedBox(width: 8),
              _actionButton("View Attendance", const Color(0xFF007AFF), () {
                // Navigate to your student record list with the module ID
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => AttendanceRecordListPage(module: module),
                  ),
                );
              }),
            ],
          )
        ],
      ),
    );
  }

  Widget _actionButton(String label, Color color, VoidCallback onTap) {
    return SizedBox(
      height: 30,
      child: ElevatedButton(
        style: ElevatedButton.styleFrom(
          backgroundColor: color,
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
          padding: const EdgeInsets.symmetric(horizontal: 15),
          elevation: 0,
        ),
        onPressed: onTap,
        child: Text(label, style: const TextStyle(color: Colors.white, fontSize: 11)),
      ),
    );
  }
}