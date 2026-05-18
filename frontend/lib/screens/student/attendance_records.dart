import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../provider/attendance_provider.dart';
import '../../provider/user_provider.dart';
import '../../widgets/header.dart';
import '../../widgets/navigation_bar.dart';
import '../../widgets/app_sidebar.dart';

class AttendanceRecordsPage extends StatefulWidget {
  const AttendanceRecordsPage({super.key});

  @override
  State<AttendanceRecordsPage> createState() => _AttendanceRecordsPageState();
}

class _AttendanceRecordsPageState extends State<AttendanceRecordsPage> {
  // Dynamic visual layout display tracker variables
  late String _selectedDateDisplay;
  late String _backendFilterDate;

  @override
  void initState() {
    super.initState();
    
    // 1. Capture and format real-time "now" system clock dates on page initialization
    final now = DateTime.now();
    
    // Format for text container layout view (e.g., 18-05-2026)
    _selectedDateDisplay = "${now.day.toString().padLeft(2, '0')}-${now.month.toString().padLeft(2, '0')}-${now.year}";
    
    // Format for backend API query expectations (e.g., 2026-05-18)
    _backendFilterDate = "${now.year}-${now.month.toString().padLeft(2, '0')}-${now.day.toString().padLeft(2, '0')}";

    // 2. Fetch records filtered specifically to today's date on load
    WidgetsBinding.instance.addPostFrameCallback((_) {
      final studentId = Provider.of<UserProvider>(context, listen: false).userId.toString();
      Provider.of<AttendanceProvider>(context, listen: false)
          .fetchAttendanceRecord(studentId, dateFilter: _backendFilterDate);
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFD1E9F6),
      appBar: const UsasHeader(),
      drawer: const AppSidebar(),
      bottomNavigationBar: const UsasBottomNav(),
      body: Consumer<AttendanceProvider>(
        builder: (context, provider, child) {
          return Column(
            children: [
              const SizedBox(height: 25),
              const Center(
                child: Text(
                  "Attendance History",
                  style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold, color: Colors.black87),
                ),
              ),
              const SizedBox(height: 20),

              // White table container panel background sheet
              Expanded(
                child: Container(
                  margin: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
                  padding: const EdgeInsets.all(20),
                  width: double.infinity,
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(25),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withOpacity(0.05), 
                        blurRadius: 10, 
                        offset: const Offset(0, 4)
                      )
                    ],
                  ),
                  child: provider.isLoading
                      ? const Center(child: CircularProgressIndicator())
                      : Column(
                          children: [
                            _buildDatePickerHeader(),
                            const SizedBox(height: 20),
                            Expanded(child: _buildHistoryTable(provider.historyRecords)),
                          ],
                        ),
                ),
              ),
              const SizedBox(height: 15),
            ],
          );
        },
      ),
    );
  }

  /// Builds the interactive Date Picker Bar container card linked to current device date
  Widget _buildDatePickerHeader() {
    return Row(
      children: [
        const Text(
          "DATE:",
          style: TextStyle(fontWeight: FontWeight.bold, fontSize: 14, color: Colors.black87),
        ),
        const SizedBox(width: 15),
        Expanded(
          child: InkWell(
            onTap: () async {
              // Open date selection overlay contextual tracking layout frame
              DateTime? pickedDate = await showDatePicker(
                context: context,
                initialDate: DateTime.now(), // Sets initial highlight block context to exact current clock time
                firstDate: DateTime(2020),
                lastDate: DateTime(2030),
                builder: (context, child) {
                  return Theme(
                    data: Theme.of(context).copyWith(
                      colorScheme: const ColorScheme.light(
                        primary: Color(0xFF3F51B5),
                        onPrimary: Colors.white,
                        onSurface: Colors.black87,
                      ),
                    ),
                    child: child!,
                  );
                },
              );

              if (pickedDate != null) {
                String formattedDate = "${pickedDate.year}-${pickedDate.month.toString().padLeft(2, '0')}-${pickedDate.day.toString().padLeft(2, '0')}";
                String displayDate = "${pickedDate.day.toString().padLeft(2, '0')}-${pickedDate.month.toString().padLeft(2, '0')}-${pickedDate.year}";

                setState(() {
                  _selectedDateDisplay = displayDate;
                  _backendFilterDate = formattedDate;
                });

                // Re-fetch historical logs based on new choice selection matrix parameters
                final studentId = Provider.of<UserProvider>(context, listen: false).userId.toString();
                Provider.of<AttendanceProvider>(context, listen: false)
                    .fetchAttendanceRecord(studentId, dateFilter: _backendFilterDate);
              }
            },
            borderRadius: BorderRadius.circular(10),
            child: Container(
              height: 40,
              padding: const EdgeInsets.symmetric(horizontal: 15),
              decoration: BoxDecoration(
                color: const Color(0xFFF0F0F0),
                borderRadius: BorderRadius.circular(10),
                border: Border.all(color: Colors.black12, width: 0.5),
              ),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    _selectedDateDisplay,
                    style: const TextStyle(fontSize: 13, fontWeight: FontWeight.w500, color: Colors.black87),
                  ),
                  const Icon(Icons.calendar_month_outlined, size: 20, color: Color(0xFF3F51B5)),
                ],
              ),
            ),
          ),
        ),
      ],
    );
  }

  /// Builds structural columns maps mapping sets data indices matching layout parameters
  Widget _buildHistoryTable(List<dynamic> records) {
    if (records.isEmpty) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Icon(Icons.assignment_turned_in_outlined, size: 40, color: Colors.black26),
            const SizedBox(height: 10),
            Text(
              "No attendance logs found\nfor $_selectedDateDisplay.",
              textAlign: TextAlign.center,
              style: const TextStyle(color: Colors.black54, fontSize: 13, height: 1.3),
            ),
          ],
        ),
      );
    }

    return SingleChildScrollView(
      scrollDirection: Axis.vertical,
      child: SizedBox(
        width: double.infinity,
        child: DataTable(
          headingRowHeight: 40,
          dataRowMinHeight: 40,
          dataRowMaxHeight: 55,
          columnSpacing: 10,
          horizontalMargin: 0,
          columns: const [
            DataColumn(label: Text('Subject / Activity', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 11, color: Colors.black87))),
            DataColumn(label: Text('Lecture/Lab', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 11, color: Colors.black87))),
            DataColumn(label: Text('Date', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 11, color: Colors.black87))),
            DataColumn(label: Text('Time', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 11, color: Colors.black87))),
          ],
          rows: records.map((record) {
            bool isCurriculum = record['attendance_type'] == 'Curriculum';

            return DataRow(cells: [
              DataCell(
                SizedBox(
                  width: 95,
                  child: Text(
                    record['display_name'] ?? "",
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                    style: TextStyle(
                      fontSize: 10, 
                      fontWeight: FontWeight.bold,
                      color: isCurriculum ? const Color(0xFF3F51B5) : Colors.green.shade700,
                    ),
                  ),
                ),
              ),
              DataCell(
                Center(
                  child: Text(
                    record['lecture_lab'] ?? "", 
                    style: TextStyle(
                      fontSize: 10, 
                      color: isCurriculum ? Colors.black87 : Colors.black54,
                      fontStyle: isCurriculum ? FontStyle.normal : FontStyle.italic,
                    )
                  )
                )
              ),
              DataCell(Text(record['date'] ?? "", style: const TextStyle(fontSize: 10, color: Colors.black87))),
              DataCell(Text(record['time'] ?? "", style: const TextStyle(fontSize: 10, color: Colors.black87))),
            ]);
          }).toList(),
        ),
      ),
    );
  }
}