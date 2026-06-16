import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../widgets/header.dart';
import '../../widgets/navigation_bar.dart';
import '../../widgets/app_sidebar.dart';
import '../../provider/attendance_provider.dart';
import 'edit_student_attendance.dart';
import '../../domain/attendance_record.dart';

class ViewStudentAttendance extends StatefulWidget {
  final int attendanceId;
  final String subjectName;
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
  // Boolean to toggle between Present and Not Present lists
  bool _showPresent = true;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      final provider = Provider.of<AttendanceProvider>(context, listen: false);
      // Fetch both lists from your backend
      provider.fetchClassPresentStudent(widget.attendanceId);
      provider.fetchClassNotPresentStudent(widget.attendanceId);
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
          return SingleChildScrollView(
            padding: const EdgeInsets.all(15.0),
            child: Column(
              children: [
                const Text(
                  "Attendance Records",
                  style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
                ),
                const SizedBox(height: 15),

                // Info Card
                _buildSessionHeader(),
                const SizedBox(height: 15),

                // Toggle Buttons
                Row(
                  children: [
                    Expanded(child: _toggleTab("Present", _showPresent)),
                    const SizedBox(width: 10),
                    Expanded(child: _toggleTab("Not Present", !_showPresent)),
                  ],
                ),
                const SizedBox(height: 15),

                // Student Table Container
                Container(
                  padding: const EdgeInsets.all(15),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(15),
                  ),
                  child: Column(
                    children: [
                      _buildSearchField(),
                      const SizedBox(height: 10),
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
          );
        },
      ),
    );
  }

  Widget _buildSessionHeader() {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(15),
      ),
      child: Column(
        children: [
          Text(
            widget.subjectName,
            textAlign: TextAlign.center,
            style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 15),
          ),
          const SizedBox(height: 8),
          Text("Date: ${widget.date}", style: const TextStyle(fontSize: 12)),
          Text("Time: ${widget.time}", style: const TextStyle(fontSize: 12)),
          Text(
            "Attendance Code: ${widget.code}",
            style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 12),
          ),
        ],
      ),
    );
  }

  Widget _buildStudentTable(AttendanceProvider provider) {
    // Switch data source based on toggle state
    final students = _showPresent 
        ? provider.presentStudents 
        : provider.notPresentStudents;

    if (students.isEmpty) {
      return const Padding(
        padding: EdgeInsets.all(20.0),
        child: Text("No student records found."),
      );
    }

    return SizedBox(
      width: double.infinity,
      child: DataTable(
        columnSpacing: 10,
        horizontalMargin: 0,
        columns: const [
          DataColumn(label: Text('No', style: TextStyle(fontSize: 12, fontWeight: FontWeight.bold))),
          DataColumn(label: Text('Student ID', style: TextStyle(fontSize: 12, fontWeight: FontWeight.bold))),
          DataColumn(label: Text('Name', style: TextStyle(fontSize: 12, fontWeight: FontWeight.bold))),
          DataColumn(label: Text('Action', style: TextStyle(fontSize: 12, fontWeight: FontWeight.bold))),
        ],
        rows: students.asMap().entries.map((entry) {
          int idx = entry.key + 1;
          var student = entry.value; 

          return DataRow(cells: [
            DataCell(Text(idx.toString(), style: const TextStyle(fontSize: 11))),
            DataCell(Text(student.studentId, style: const TextStyle(fontSize: 11))),
            DataCell(SizedBox(
              width: 110,
              child: Text(student.studentName, overflow: TextOverflow.ellipsis, style: const TextStyle(fontSize: 11)),
            )),
            DataCell(_editButton(student)), 
          ]);
        }).toList(),
      ),
    );
  }

  Widget _toggleTab(String label, bool active) {
    return GestureDetector(
      onTap: () {
        setState(() {
          _showPresent = (label == "Present");
        });
      },
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 10),
        decoration: BoxDecoration(
          color: active ? const Color(0xFFC6D9F1) : Colors.white,
          borderRadius: BorderRadius.circular(8),
          border: Border.all(color: Colors.grey.shade300),
        ),
        child: Center(
          child: Text(
            label,
            style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 12),
          ),
        ),
      ),
    );
  }

  Widget _editButton(AttendanceRecord student) {
    return SizedBox(
      height: 25,
      child: ElevatedButton(
        style: ElevatedButton.styleFrom(
          backgroundColor: Colors.blue,
          padding: const EdgeInsets.symmetric(horizontal: 10),
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(5)),
        ),
        onPressed: () {
          debugPrint("Navigate to edit record ID: ${student.id}");

          Navigator.push(
            context,
            MaterialPageRoute(
              builder: (context) => EditStudentAttendance(
                attendanceId: widget.attendanceId, // 🔑 Fixed: Passed parent session state ID forward
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
        },
        child: const Text("Edit", style: TextStyle(color: Colors.white, fontSize: 10)),
      ),
    );
  }

  Widget _buildSearchField() {
    return Container(
      height: 35,
      decoration: BoxDecoration(
        color: Colors.grey[100],
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: Colors.grey.shade300),
      ),
      child: const TextField(
        decoration: InputDecoration(
          hintText: "Search",
          prefixIcon: Icon(Icons.search, size: 18),
          border: InputBorder.none,
          contentPadding: EdgeInsets.only(bottom: 12),
        ),
      ),
    );
  }
}