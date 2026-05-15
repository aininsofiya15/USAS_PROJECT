import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:intl/intl.dart';
import '../../provider/attendance_provider.dart';
import '../../domain/module.dart';
import 'attendance_record_list.dart';
import '../../widgets/header.dart';
import '../../widgets/app_sidebar.dart';
import '../../widgets/navigation_bar.dart';

class AddModuleAttendancePage extends StatefulWidget {
  const AddModuleAttendancePage({super.key});

  @override
  State<AddModuleAttendancePage> createState() => _ModuleAttendanceSelectionPageState();
}

class _ModuleAttendanceSelectionPageState extends State<AddModuleAttendancePage> {
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
    
    // Filter modules by selected date
    final displayedModules = selectedDate == null
        ? provider.pusatAdabModules
        : provider.pusatAdabModules.where((module) =>
            module.dateTime.contains(DateFormat('yyyy-MM-dd').format(selectedDate!))).toList();

    return Scaffold(
      backgroundColor: const Color(0xFFD1FFF3),
      appBar: const UsasHeader(),
      drawer: const AppSidebar(),
      bottomNavigationBar: const UsasBottomNav(),
      body: Column(
        children: [
          const SizedBox(height: 50),
          const Text(
            "Module Attendance",
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
        borderRadius: BorderRadius.circular(10),
        border: Border.all(color: Colors.black12)
      ),
      child: Row(
        children: [
          const Text("DATE:", style: TextStyle(fontWeight: FontWeight.bold)),
          const SizedBox(width: 15),
          Expanded(
            child: Text(selectedDate == null
                ? DateFormat('dd-MM-yyyy').format(DateTime.now())
                : DateFormat('dd-MM-yyyy').format(selectedDate!)),
          ),
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
    // Check if module is today
    String todayStr = DateFormat('yyyy-MM-dd').format(DateTime.now());
    bool isToday = module.dateTime.contains(todayStr);

    return Container(
      margin: const EdgeInsets.only(bottom: 15),
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(color: Colors.black.withOpacity(0.05), blurRadius: 10, offset: const Offset(0, 4))
        ]
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            module.activityName.toUpperCase(),
            style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
          ),
          const SizedBox(height: 5),
          const Text("Active", style: TextStyle(color: Colors.green, fontSize: 12, fontWeight: FontWeight.bold)),
          const SizedBox(height: 8),
          Text(
            "Class Date: ${module.dateTime}",
            style: const TextStyle(fontSize: 12, color: Colors.black87),
          ),
          Text(
            "Venue: ${module.venue}",
            style: const TextStyle(fontSize: 12, color: Colors.black87),
          ),
          const SizedBox(height: 15),
          Row(
            mainAxisAlignment: MainAxisAlignment.end,
            children: [
              isToday 
                ? _actionButton("Generate Attendance", const Color(0xFF007AFF), () {
                    // Logic to navigate to generate code
                  })
                : _actionButton("View Records", Colors.grey, () {
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
          ),
        ],
      ),
    );
  }

  Widget _actionButton(String label, Color color, VoidCallback onTap) {
    return SizedBox(
      height: 35,
      child: ElevatedButton(
        style: ElevatedButton.styleFrom(
          backgroundColor: color,
          elevation: 0,
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
          padding: const EdgeInsets.symmetric(horizontal: 20),
        ),
        onPressed: onTap,
        child: Text(label, style: const TextStyle(color: Colors.white, fontSize: 11, fontWeight: FontWeight.bold)),
      ),
    );
  }
}