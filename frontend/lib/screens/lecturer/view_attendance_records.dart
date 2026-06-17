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
  final TextEditingController _searchController = TextEditingController();
  String _searchQuery = "";

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      final userId = Provider.of<UserProvider>(context, listen: false).userId;
      Provider.of<AttendanceProvider>(context, listen: false).fetchAttendanceHistory(userId);
    });
    
    _searchController.addListener(() {
      setState(() {
        _searchQuery = _searchController.text.toLowerCase();
      });
    });
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFFDF2F2), // Lightest soft outer background canvas
      appBar: const UsasHeader(),
      drawer: const AppSidebar(),
      bottomNavigationBar: const UsasBottomNav(),
      body: Consumer<AttendanceProvider>(
        builder: (context, provider, child) {
          final filteredHistory = provider.attendanceHistory.where((item) {
            final subjectCode = (item['subject_code']?.toString() ?? '').toLowerCase();
            final classType = ((item['class_type'] ?? item['lecture_lab'])?.toString() ?? '').toLowerCase();
            final dateStr = (item['date']?.toString() ?? '').toLowerCase();
            
            return subjectCode.contains(_searchQuery) || 
                   classType.contains(_searchQuery) ||
                   dateStr.contains(_searchQuery);
          }).toList();

          return SingleChildScrollView(
            physics: const BouncingScrollPhysics(),
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 20.0),
              child: Column(
                children: [
                  // Outer Darker Pink Container Box Card
                  Container(
                    width: double.infinity,
                    padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 24.0),
                    decoration: BoxDecoration(
                      color: const Color(0xFFDEC3C3), // Darker pink wrapper background matching Screenshot 2026-06-17 214614.png
                      borderRadius: BorderRadius.circular(24),
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        // Title centered within the top pink block space
                        const Center(
                          child: Text(
                            "Attendance Records", 
                            style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold, color: Colors.black),
                          ),
                        ),
                        const SizedBox(height: 20),
                        
                        // "Recent History" placed outside, sitting directly above the white card
                        const Padding(
                          padding: EdgeInsets.only(left: 4.0, bottom: 12.0),
                          child: Text(
                            "Recent History", 
                            style: TextStyle(fontWeight: FontWeight.bold, fontSize: 15, color: Colors.black),
                          ),
                        ),

                        // Inner White Container Sheet Card (Starts right at the Search box)
                        Container(
                          width: double.infinity,
                          padding: const EdgeInsets.all(16),
                          decoration: BoxDecoration(
                            color: Colors.white, 
                            borderRadius: BorderRadius.circular(16),
                            boxShadow: [
                              BoxShadow(
                                color: Colors.black.withOpacity(0.05),
                                blurRadius: 10,
                                offset: const Offset(0, 4),
                              ),
                            ],
                          ),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              _buildSearchField(),
                              const SizedBox(height: 16),
                              
                              SingleChildScrollView(
                                scrollDirection: Axis.horizontal,
                                child: DataTable(
                                  columnSpacing: 25,
                                  headingRowHeight: 40,
                                  dataRowMaxHeight: 45,
                                  dataRowMinHeight: 35,
                                  columns: const [
                                    DataColumn(label: Text('Subject', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 13))),
                                    DataColumn(label: Text('Lecture/Lab', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 13))),
                                    DataColumn(label: Text('Date', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 13))),
                                    DataColumn(label: Text('Time', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 13))),
                                    DataColumn(label: Text('Action', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 13))),
                                  ],
                                  rows: filteredHistory.map((item) {
                                    return DataRow(cells: [
                                      DataCell(Text(
                                        item['subject_code']?.toString() ?? 'N/A',
                                        style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 12),
                                      )),
                                      DataCell(Text(
                                        (item['class_type'] ?? item['lecture_lab'])?.toString() ?? 'N/A',
                                        style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 12),
                                      )),
                                      DataCell(Text(
                                        item['date']?.toString() ?? 'N/A',
                                        style: const TextStyle(fontSize: 12),
                                      )),
                                      DataCell(Text(
                                        item['time']?.toString() ?? 'N/A',
                                        style: const TextStyle(fontSize: 12),
                                      )),
                                      DataCell(Row(
                                        mainAxisSize: MainAxisSize.min,
                                        children: [
                                          _actionButton("Edit", const Color(0xFF5CDB5C), () {
                                            Navigator.push(
                                              context,
                                              MaterialPageRoute(
                                                builder: (context) => EditAttendanceDetails(
                                                  attendanceId: int.tryParse(item['attendance_id']?.toString() ?? '0') ?? 0,
                                                  subjectName: item['subject_name']?.toString() ?? "Unknown",
                                                  sectionNo: item['section_no']?.toString() ?? "N/A",
                                                  sectionId: int.tryParse(item['section_id']?.toString() ?? '0') ?? 0,
                                                ),
                                              ),
                                            );
                                          }),
                                          const SizedBox(width: 6),
                                          _actionButton("View", const Color(0xFF1A73E8), () {
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
                  ),
                ],
              ),
            ),
          );
        },
      ),
    );
  }

  Widget _buildSearchField() {
    return Container(
      height: 42,
      decoration: BoxDecoration(
        color: Colors.white, 
        borderRadius: BorderRadius.circular(25), 
        border: Border.all(color: Colors.grey.shade400, width: 1),
      ),
      padding: const EdgeInsets.symmetric(horizontal: 12),
      child: Row(
        children: [
          Icon(Icons.search, color: Colors.grey.shade600, size: 20),
          const SizedBox(width: 8),
          Expanded(
            child: TextField(
              controller: _searchController,
              decoration: const InputDecoration(
                hintText: "Search", 
                hintStyle: TextStyle(color: Colors.grey, fontSize: 14),
                border: InputBorder.none, 
                isDense: true,
                contentPadding: EdgeInsets.zero,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _actionButton(String label, Color color, VoidCallback onTap) {
    return SizedBox(
      height: 24,
      child: ElevatedButton(
        style: ElevatedButton.styleFrom(
          backgroundColor: color, 
          padding: const EdgeInsets.symmetric(horizontal: 10), 
          elevation: 0,
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        ),
        onPressed: onTap,
        child: Text(label, style: const TextStyle(color: Colors.white, fontSize: 11, fontWeight: FontWeight.w600)),
      ),
    );
  }
}