import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:intl/intl.dart';
import '../../provider/attendance_provider.dart';
import '../../domain/module.dart';
import 'attendance_record_list.dart';
import 'generate_module_attendance_code.dart'; 
import '../../widgets/header.dart';
import '../../widgets/app_sidebar.dart';
import '../../widgets/navigation_bar.dart';

class AddModuleAttendancePage extends StatefulWidget {
  const AddModuleAttendancePage({super.key});

  @override
  State<AddModuleAttendancePage> createState() => _AddModuleAttendancePageState();
}

class _AddModuleAttendancePageState extends State<AddModuleAttendancePage> {
  DateTime? selectedDate;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _loadData();
    });
  }

  void _loadData() {
    String? dateParam;
    if (selectedDate != null) {
      dateParam = DateFormat('yyyy-MM-dd').format(selectedDate!);
    }
    Provider.of<AttendanceProvider>(context, listen: false)
        .getAdabModules(selectedDate: dateParam);
  }

  @override
  Widget build(BuildContext context) {
    final provider = Provider.of<AttendanceProvider>(context);
    final modules = provider.pusatAdabModules;

    return Scaffold(
      backgroundColor: const Color(0xFFD1FFF3), // Mint background
      appBar: const UsasHeader(),
      drawer: const AppSidebar(),
      bottomNavigationBar: const UsasBottomNav(),
      body: Column(
        children: [
          const SizedBox(height: 30),
          const Text(
            "Module Attendance",
            style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 15),
          
          _buildDateFilter(),

          Expanded(
            child: provider.isLoading
                ? const Center(child: CircularProgressIndicator())
                : modules.isEmpty
                    ? _buildEmptyState()
                    : ListView.builder(
                        padding: const EdgeInsets.fromLTRB(20, 0, 20, 20),
                        itemCount: modules.length,
                        itemBuilder: (context, index) {
                          return _buildModuleCard(modules[index]);
                        },
                      ),
          ),
        ],
      ),
    );
  }

  Widget _buildDateFilter() {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 25, vertical: 10),
      child: Row(
        children: [
          const Text(
            "DATE:",
            style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
          ),
          const SizedBox(width: 15),
          Expanded(
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(10),
                border: Border.all(color: Colors.black12),
              ),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    selectedDate == null
                        ? "Select Date"
                        : DateFormat('dd-MM-yyyy').format(selectedDate!),
                    style: const TextStyle(fontSize: 14),
                  ),
                  IconButton(
                    icon: const Icon(Icons.edit_calendar, size: 22, color: Colors.black87),
                    onPressed: () async {
                      DateTime? picked = await showDatePicker(
                        context: context,
                        initialDate: DateTime.now(),
                        firstDate: DateTime(2024),
                        lastDate: DateTime(2030),
                      );
                      if (picked != null) {
                        setState(() => selectedDate = picked);
                        _loadData();
                      }
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

  Widget _buildModuleCard(Module module) {
    // Logic for Action Button Function
    String todayStr = DateFormat('yyyy-MM-dd').format(DateTime.now());
    bool isToday = module.dateTime.contains(todayStr);

    // Color logic for status
    Color statusColor;
    String statusText = module.status ?? 'Active';
    switch (statusText.toLowerCase()) {
      case 'active': statusColor = const Color(0xFF00C853); break; // Brighter green match
      case 'cancelled': statusColor = Colors.red; break;
      case 'postpone': statusColor = Colors.orange; break;
      default: statusColor = Colors.grey;
    }

    return Container(
      margin: const EdgeInsets.only(top: 15),
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20), // Matched rounding
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.08),
            blurRadius: 10,
            offset: const Offset(0, 5),
          )
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            module.activityName.toUpperCase(),
            style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 15),
          ),
          const SizedBox(height: 4),
          Text(
            statusText,
            style: TextStyle(
              color: statusColor,
              fontSize: 12,
              fontWeight: FontWeight.w600,
            ),
          ),
          const SizedBox(height: 12),
          Text(
            "Class Date: ${module.dateTime}",
            style: const TextStyle(fontSize: 12, color: Colors.black87),
          ),
          const SizedBox(height: 4),
          Text(
            "Venue: ${module.venue}",
            style: const TextStyle(fontSize: 12, color: Colors.black87),
          ),
          
          // Matches the screenshot: Buttons are blue and say "Generate Attendance". 
          // The Postpone module has no button.
          if (statusText.toLowerCase() != 'postpone') ...[
            const SizedBox(height: 12),
            Align(
              alignment: Alignment.centerRight,
              child: SizedBox(
                height: 32,
                child: ElevatedButton(
                  onPressed: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) => GenerateModuleAttendanceCode(
                          module: module,
                        ),
                      ),
                    );
                  },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color(0xFF0d6efd), // Solid Blue matching screenshot
                    elevation: 0, 
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(20), // Stadium shape button
                    ),
                    padding: const EdgeInsets.symmetric(horizontal: 16),
                  ),
                  child: const Text(
                    "Generate Attendance",
                    style: TextStyle(
                      color: Colors.white, 
                      fontSize: 11, 
                      fontWeight: FontWeight.bold
                    ),
                  ),
                ),
              ),
            ),
          ],
        ],
      ),
    );
  }

  Widget _buildEmptyState() {
    return Column(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        const Icon(Icons.search_off, size: 70, color: Colors.black26),
        const SizedBox(height: 10),
        const Text(
          "No modules found for this selection.",
          style: TextStyle(color: Colors.black45),
        ),
        TextButton(
          onPressed: () {
            setState(() => selectedDate = null);
            _loadData();
          },
          child: const Text("Reset Filter"),
        ),
      ],
    );
  }
}