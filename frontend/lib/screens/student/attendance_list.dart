import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../provider/attendance_provider.dart';
import '../../provider/user_provider.dart';
import '../../widgets/header.dart';
import '../../widgets/navigation_bar.dart';
import '../../widgets/app_sidebar.dart';
import 'attendance_submission.dart';

class AttendanceListPage extends StatefulWidget {
  final int sectionId;
  final String subjectCode;
  final String subjectName;

  const AttendanceListPage({
    super.key,
    required this.sectionId,
    required this.subjectCode,
    required this.subjectName,
  });

  @override
  State<AttendanceListPage> createState() => _AttendanceListPageState();
}

class _AttendanceListPageState extends State<AttendanceListPage> {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      final userId = Provider.of<UserProvider>(context, listen: false).userId;
      Provider.of<AttendanceProvider>(context, listen: false)
          .getAttendanceSubmission(widget.sectionId, userId.toString());
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
              const SizedBox(height: 20),
              const Center(
                child: Text(
                  "Attendance",
                  style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold),
                ),
              ),
              const SizedBox(height: 20),
              
              _buildSubjectHeader(),

              Expanded(
                child: Container(
                  margin: const EdgeInsets.all(20),
                  padding: const EdgeInsets.all(15),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(20),
                    boxShadow: [BoxShadow(color: Colors.black12, blurRadius: 10)],
                  ),
                  child: provider.isLoading
                      ? const Center(child: CircularProgressIndicator())
                      : Column(
                          children: [
                            _buildSearchField(),
                            const SizedBox(height: 10),
                            Expanded(child: _buildAttendanceTable(provider)),
                          ],
                        ),
                ),
              ),
            ],
          );
        },
      ),
    );
  }

  Widget _buildSubjectHeader() {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 20),
      padding: const EdgeInsets.all(20),
      width: double.infinity,
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
        boxShadow: [BoxShadow(color: Colors.black12, blurRadius: 5)],
      ),
      child: Column(
        children: [
          Text(
            "${widget.subjectCode} ${widget.subjectName}",
            textAlign: TextAlign.center,
            style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
          ),
          const SizedBox(height: 8),
          const Text("Section: 01A", style: TextStyle(fontSize: 12, color: Colors.black54)),
          const Text("Lecturer: Ts Dr. Fahmi", style: TextStyle(fontSize: 12, color: Colors.black54)),
        ],
      ),
    );
  }

  Widget _buildSearchField() {
    return Container(
      height: 40,
      decoration: BoxDecoration(
        color: Colors.grey[100],
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: Colors.grey.shade300),
      ),
      child: const TextField(
        decoration: InputDecoration(
          hintText: "Search",
          prefixIcon: Icon(Icons.search, size: 20),
          border: InputBorder.none,
          contentPadding: EdgeInsets.only(bottom: 8),
        ),
      ),
    );
  }

  Widget _buildAttendanceTable(AttendanceProvider provider) {
    if (provider.attendanceSubmissions.isEmpty) {
      return const Center(child: Text("No attendance history found."));
    }

    return SingleChildScrollView(
      scrollDirection: Axis.vertical,
      child: DataTable(
        columnSpacing: 10,
        horizontalMargin: 10,
        columns: const [
          DataColumn(label: Text('Lecture/Lab', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 11))),
          DataColumn(label: Text('Date', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 11))),
          DataColumn(label: Text('Time', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 11))),
          DataColumn(label: Text('Action', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 11))),
        ],
        rows: provider.attendanceSubmissions.map((session) {
          String status = session['status'] ?? 'Expired';

          return DataRow(cells: [
            DataCell(Text(session['class_type'] ?? "", style: const TextStyle(fontSize: 10))),
            DataCell(Text(session['date'] ?? "", style: const TextStyle(fontSize: 10))),
            DataCell(Text(session['time'] ?? "", style: const TextStyle(fontSize: 10))),
            DataCell(
              _buildActionButton(status, session),
            ),
          ]);
        }).toList(),
      ),
    );
  }

  Widget _buildActionButton(String status, Map<String, dynamic> session) {
    bool isActive = status == 'Active';
    bool isSubmitted = status == 'Submitted';

    return SizedBox(
      height: 25,
      child: ElevatedButton(
        style: ElevatedButton.styleFrom(
          backgroundColor: isActive ? Colors.blue : Colors.grey.shade400,
          elevation: 0,
          padding: const EdgeInsets.symmetric(horizontal: 8),
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(5)),
        ),
        onPressed: isActive
            ? () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => AttendanceSubmissionPage(
                      sessionData: session, // This is exactly what attendance_submission expects
                      sectionId: widget.sectionId,
                      subjectCode: widget.subjectCode,
                      subjectName: widget.subjectName,
                    ),
                  ),
                );
              }
            : null,
        child: Text(
          isSubmitted ? "Submitted" : "Submit",
          style: const TextStyle(color: Colors.white, fontSize: 9, fontWeight: FontWeight.bold),
        ),
      ),
    );
  }
}