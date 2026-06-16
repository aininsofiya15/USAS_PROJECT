import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../widgets/header.dart';
import '../../widgets/navigation_bar.dart';
import '../../widgets/app_sidebar.dart';
import '../../provider/user_provider.dart'; 
import '../../provider/attendance_provider.dart';
import 'edit_attendance_details.dart';
import 'view_student_attendance.dart';


class ViewAttendanceRecords extends StatefulWidget {
  const ViewAttendanceRecords({super.key});

  @override
  State<ViewAttendanceRecords> createState() => _ViewAttendanceRecordsState();
}

class _ViewAttendanceRecordsState extends State<ViewAttendanceRecords> {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      final userId = Provider.of<UserProvider>(context, listen: false).userId;
      Provider.of<AttendanceProvider>(context, listen: false).fetchAttendanceHistory(userId);
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF3D8DA),
      appBar: const UsasHeader(),
      drawer: const AppSidebar(),
      bottomNavigationBar: const UsasBottomNav(),
      body: Consumer<AttendanceProvider>(
        builder: (context, provider, child) {
          return Padding(
            padding: const EdgeInsets.all(15.0),
            child: Column(
              children: [
                const Text("Attendance Records", style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold)),
                const SizedBox(height: 15),
                Container(
                  padding: const EdgeInsets.all(15),
                  decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(15)),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text("Recent History", style: TextStyle(fontWeight: FontWeight.bold)),
                      const SizedBox(height: 10),
                      _buildSearchField(),
                      const SizedBox(height: 10),
                      
                      SingleChildScrollView(
                        scrollDirection: Axis.horizontal,
                        child: DataTable(
                          columnSpacing: 20,
                          columns: const [
                            DataColumn(label: Text('Subject', style: TextStyle(fontWeight: FontWeight.bold))),
                            DataColumn(label: Text('Lecture/Lab', style: TextStyle(fontWeight: FontWeight.bold))),
                            DataColumn(label: Text('Date', style: TextStyle(fontWeight: FontWeight.bold))),
                            DataColumn(label: Text('Time', style: TextStyle(fontWeight: FontWeight.bold))),
                            DataColumn(label: Text('Action', style: TextStyle(fontWeight: FontWeight.bold))),
                          ],
                          rows: provider.attendanceHistory.map((item) {
                            return DataRow(cells: [
                              // Safe Subject Code
                              DataCell(Text(item['subject_code']?.toString() ?? 'N/A')),
                              
                              // Check both class_type (from DB) and lecture_lab (from previous code)
                              DataCell(Text((item['class_type'] ?? item['lecture_lab'])?.toString() ?? 'N/A')),
                              
                              DataCell(Text(item['date']?.toString() ?? 'N/A')),
                              DataCell(Text(item['time']?.toString() ?? 'N/A')),
                              
                              DataCell(Row(
                                children: [
                                  _actionButton("Edit", Colors.green, () {
                                    Navigator.push(
                                      context,
                                      MaterialPageRoute(
                                        builder: (context) => EditAttendanceDetails(
                                          // SAFE PARSING: Prevents the red screen crash if the ID is missing
                                          attendanceId: int.tryParse(item['attendance_id']?.toString() ?? '0') ?? 0,
                                          
                                          // Safely pass the subject name and section
                                          subjectName: item['subject_name']?.toString() ?? "Unknown",
                                          sectionNo: item['section_no']?.toString() ?? "N/A",
                                          
                                          // SAFE PARSING: Prevents the red screen crash
                                          sectionId: int.tryParse(item['section_id']?.toString() ?? '0') ?? 0,
                                        ), // EditAttendanceDetails
                                      ), // MaterialPageRoute
                                    );
                                  }),
                                  const SizedBox(width: 5),
                                  _actionButton("View", Colors.blue, () {
                                    Navigator.push(
                                      context,
                                      MaterialPageRoute(
                                        builder: (context) => ViewStudentAttendance(
                                          attendanceId: int.tryParse(item['attendance_id']?.toString() ?? '0') ?? 0,
                                          subjectName: item['subject_code']?.toString() ?? 'N/A',
                                          date: item['date']?.toString() ?? 'N/A',
                                          time: item['time']?.toString() ?? 'N/A',
                                          code: item['attendance_code']?.toString() ?? '---',
                                        ),
                                      ),
                                    );
                                  }),
                                ],
                              )),
                            ]);
                          }).toList(),
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          );
        },
      ),
    );
  }

  Widget _buildSearchField() {
    return Container(
      height: 40,
      decoration: BoxDecoration(color: Colors.grey[100], borderRadius: BorderRadius.circular(20), border: Border.all(color: Colors.grey)),
      child: const TextField(
        decoration: InputDecoration(hintText: "Search", prefixIcon: Icon(Icons.search), border: InputBorder.none, contentPadding: EdgeInsets.only(bottom: 5)),
      ),
    );
  }

  Widget _actionButton(String label, Color color, VoidCallback onTap) {
    return SizedBox(
      height: 25,
      child: ElevatedButton(
        style: ElevatedButton.styleFrom(backgroundColor: color, padding: const EdgeInsets.symmetric(horizontal: 8), shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(5))),
        onPressed: onTap,
        child: Text(label, style: const TextStyle(color: Colors.white, fontSize: 10)),
      ),
    );
  }
}