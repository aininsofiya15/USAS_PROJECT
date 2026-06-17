import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:intl/intl.dart';
import '../../widgets/header.dart';
import '../../widgets/navigation_bar.dart';
import '../../widgets/app_sidebar.dart';
import '../../provider/attendance_provider.dart';
import 'edit_student_attendance.dart';
import '../../domain/attendance_record.dart';

class ViewStudentAttendance extends StatefulWidget {
  final int attendanceId;
  final String subjectName; // Will display full concatenated header text or subject name directly
  final String date;
  final String time;
  final String code;

  const ViewStudentAttendance({
    super.key,
    required this.attendanceId,
    required this.subjectName,
    required this.date,
    required this.time,
    required this.code,
  });

  @override
  State<ViewStudentAttendance> createState() => _ViewStudentAttendanceState();
}

class _ViewStudentAttendanceState extends State<ViewStudentAttendance> {
  bool _showPresent = true;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      final provider = Provider.of<AttendanceProvider>(context, listen: false);
      provider.fetchClassPresentStudent(widget.attendanceId);
      provider.fetchClassNotPresentStudent(widget.attendanceId);
    });
  }

  String _getTwoHoursLaterTime(String originalTime) {
    try {
      DateTime parsedTime;
      if (originalTime.contains(':') && !originalTime.toLowerCase().contains('am') && !originalTime.toLowerCase().contains('pm')) {
        List<String> parts = originalTime.split(':');
        final now = DateTime.now();
        parsedTime = DateTime(now.year, now.month, now.day, int.parse(parts[0]), int.parse(parts[1]));
        final laterTime = parsedTime.add(const Duration(hours: 2));
        return "${DateFormat('HH:mm').format(parsedTime)} - ${DateFormat('HH:mm').format(laterTime)}";
      } else {
        parsedTime = DateFormat.jm().parse(originalTime.trim());
        final laterTime = parsedTime.add(const Duration(hours: 2));
        return "${DateFormat('h:mm a').format(parsedTime)} - ${DateFormat('h:mm a').format(laterTime)}";
      }
    } catch (e) {
      return originalTime;
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFFDF2F2), 
      appBar: const UsasHeader(),
      drawer: const AppSidebar(),
      bottomNavigationBar: const UsasBottomNav(),
      body: Consumer<AttendanceProvider>(
        builder: (context, provider, child) {
          return SingleChildScrollView(
            physics: const BouncingScrollPhysics(),
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 20.0),
              child: Column(
                children: [
                  Container(
                    width: double.infinity,
                    padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 24.0),
                    decoration: BoxDecoration(
                      color: const Color(0xFFDEC3C3), 
                      borderRadius: BorderRadius.circular(24),
                    ),
                    child: Column(
                      children: [
                        const Text(
                          "Attendance Records",
                          style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold, color: Colors.black),
                        ),
                        const SizedBox(height: 20),

                        // Formatted dynamic database header block
                        _buildSessionHeader(),
                        const SizedBox(height: 20),

                        Container(
                          padding: const EdgeInsets.all(4),
                          decoration: BoxDecoration(
                            color: Colors.white,
                            borderRadius: BorderRadius.circular(12),
                          ),
                          child: Row(
                            children: [
                              Expanded(child: _toggleTab("Present", _showPresent)),
                              Expanded(child: _toggleTab("Not Present", !_showPresent)),
                            ],
                          ),
                        ),
                        const SizedBox(height: 20),

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
                            children: [
                              _buildSearchField(),
                              const SizedBox(height: 16),
                              provider.isLoading
                                  ? const Center(
                                      child: Padding(
                                        padding: EdgeInsets.all(20.0),
                                        child: CircularProgressIndicator(),
                                      ),
                                    )
                                  : _buildStudentTable(provider),
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

  Widget _buildSessionHeader() {
    String displayTitle = widget.subjectName;

    // If the string passed contains just the course code (e.g., "BCI1093"),
    // check if it matches your specific database subject item to append the name correctly.
    if (displayTitle.trim() == "BCI1093") {
      displayTitle = "BCI1093 Algorithm";
    } else if (displayTitle.trim() == "BCY3083") {
      displayTitle = "BCY3083 SECURE SOFTWARE DEVELOPMENT";
    } else if (displayTitle.trim() == "BCY3073") {
      displayTitle = "BCY3073 PENETRATION TESTING";
    }

    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.04),
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        children: [
          Text(
            displayTitle, 
            textAlign: TextAlign.center,
            style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16, color: Colors.black),
          ),
          const SizedBox(height: 8),
          Text(
            "Date: ${widget.date}", 
            style: const TextStyle(fontSize: 13, color: Colors.black87, fontWeight: FontWeight.w500)
          ),
          const SizedBox(height: 2),
          Text(
            "Time: ${_getTwoHoursLaterTime(widget.time)}", 
            style: const TextStyle(fontSize: 13, color: Colors.black87, fontWeight: FontWeight.w500)
          ),
          const SizedBox(height: 4),
          Text(
            "Attendance Code: ${widget.code}",
            style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 13, color: Colors.black),
          ),
        ],
      ),
    );
  }

  Widget _buildStudentTable(AttendanceProvider provider) {
    final students = _showPresent 
        ? provider.presentStudents 
        : provider.notPresentStudents;

    if (students.isEmpty) {
      return const Padding(
        padding: EdgeInsets.all(20.0),
        child: Text("No student records found.", style: TextStyle(color: Colors.black54)),
      );
    }

    return SizedBox(
      width: double.infinity,
      child: DataTable(
        columnSpacing: 12,
        horizontalMargin: 0,
        headingRowHeight: 35,
        dataRowMaxHeight: 45,
        dataRowMinHeight: 35,
        columns: const [
          DataColumn(label: Text('No', style: TextStyle(fontSize: 13, fontWeight: FontWeight.bold))),
          DataColumn(label: Text('Student ID', style: TextStyle(fontSize: 13, fontWeight: FontWeight.bold))),
          DataColumn(label: Text('Name', style: TextStyle(fontSize: 13, fontWeight: FontWeight.bold))),
          DataColumn(label: Text('', style: TextStyle(fontSize: 13, fontWeight: FontWeight.bold))), 
        ],
        rows: students.asMap().entries.map((entry) {
          int idx = entry.key + 1;
          var student = entry.value; 

          return DataRow(cells: [
            DataCell(Text(idx.toString(), style: const TextStyle(fontSize: 12, color: Colors.black87))),
            DataCell(Text(student.studentId, style: const TextStyle(fontSize: 12, fontWeight: FontWeight.w600, color: Colors.black87))),
            DataCell(SizedBox(
              width: 110,
              child: Text(student.studentName, overflow: TextOverflow.ellipsis, style: const TextStyle(fontSize: 12, color: Colors.black87)),
            )),
            DataCell(_editButton(student)), 
          ]);
        }).toList(),
      ),
    );
  }

  Widget _toggleTab(String label, bool active) {
    final isPresentTab = (label == "Present");
    
    Color backgroundColor = Colors.white;
    Color textColor = Colors.black54;

    if (active) {
      if (isPresentTab) {
        backgroundColor = const Color(0xFFE3F2FD); 
        textColor = const Color(0xFF1A73E8);       
      } else {
        backgroundColor = const Color(0xFFFFEBEE); 
        textColor = const Color(0xFFD32F2F);       
      }
    }

    return GestureDetector(
      onTap: () {
        setState(() {
          _showPresent = isPresentTab;
        });
      },
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 10),
        decoration: BoxDecoration(
          color: backgroundColor,
          borderRadius: BorderRadius.circular(8),
        ),
        child: Center(
          child: Text(
            label,
            style: TextStyle(
              fontWeight: FontWeight.bold, 
              fontSize: 13,
              color: textColor,
            ),
          ),
        ),
      ),
    );
  }

  Widget _editButton(AttendanceRecord student) {
    return SizedBox(
      height: 24,
      child: ElevatedButton(
        style: ElevatedButton.styleFrom(
          backgroundColor: const Color(0xFF007BFF),
          padding: const EdgeInsets.symmetric(horizontal: 12),
          elevation: 0,
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        ),
        onPressed: () async {
          final bool? shouldRefresh = await Navigator.push<bool>(
            context,
            MaterialPageRoute(
              builder: (context) => EditStudentAttendance(
                attendanceId: widget.attendanceId,
                recordId: student.id,
                matricNo: student.studentId,
                studentName: student.studentName,
                subjectName: widget.subjectName,
                date: widget.date,
                time: widget.time,
                currentStatus: student.status,
              ),
            ),
          );

          if ((shouldRefresh == true || shouldRefresh == null) && mounted) {
            final provider = Provider.of<AttendanceProvider>(context, listen: false);
            await Future.wait([
              provider.fetchClassPresentStudent(widget.attendanceId),
              provider.fetchClassNotPresentStudent(widget.attendanceId),
            ]);
          }
        },
        child: const Text("Edit", style: TextStyle(color: Colors.white, fontSize: 11, fontWeight: FontWeight.bold)),
      ),
    );
  }

  Widget _buildSearchField() {
    return Container(
      height: 40,
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
          const Expanded(
            child: TextField(
              decoration: InputDecoration(
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
}