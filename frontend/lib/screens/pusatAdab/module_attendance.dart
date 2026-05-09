import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:intl/intl.dart';
import '../../provider/attendance_provider.dart';
import '../../domain/module.dart';
import 'attendance_record_list.dart';
import '../../widgets/header.dart';
import '../../widgets/app_sidebar.dart';
import '../../widgets/navigation_bar.dart';

class ModuleAttendanceSelectionPage extends StatefulWidget {
  const ModuleAttendanceSelectionPage({super.key});

  @override
  State<ModuleAttendanceSelectionPage> createState() => _ModuleAttendanceSelectionPageState();
}

class _ModuleAttendanceSelectionPageState extends State<ModuleAttendanceSelectionPage> {
  DateTime? selectedDate;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      Provider.of<AttendanceProvider>(context, listen: false).fetchPusatAdabModules();
    });
  }

  @override
  Widget build(BuildContext context) {
    final provider = Provider.of<AttendanceProvider>(context);

    // Filter Logic using your Module class properties
    final displayedModules = provider.pusatAdabModules.where((module) {
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
        ],
      ),
    );
  }

  Widget _buildModuleCard(Module module) {
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
          // FIX for image_9fc158.png: Use activityName instead of name
          Text(
            module.activityName.toUpperCase(),
            style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
          ),
          const SizedBox(height: 5),
          Text(
            "Class Date: ${module.dateTime} | Venue: ${module.venue}",
            style: const TextStyle(fontSize: 12, color: Colors.grey),
          ),
          const SizedBox(height: 15),
          Row(
            mainAxisAlignment: MainAxisAlignment.end,
            children: [
              _actionButton("View Attendance", const Color(0xFF007AFF), () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => AttendanceRecordListPage(
                      bookingId: module.id ?? 0, 
                      module: module,
                    ),
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
        ),
        onPressed: onTap,
        child: Text(label, style: const TextStyle(color: Colors.white, fontSize: 11)),
      ),
    );
  }
}