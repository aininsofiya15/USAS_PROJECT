import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../provider/attendance_provider.dart';
import '../../provider/user_provider.dart';
import '../../widgets/header.dart';
import '../../widgets/navigation_bar.dart';
import '../../widgets/app_sidebar.dart';

class AttendanceSubmissionPage extends StatefulWidget {
  final Map<String, dynamic> sessionData;
  final int sectionId;
  final String subjectCode;
  final String subjectName;

  const AttendanceSubmissionPage({
    super.key,
    required this.sessionData,
    required this.sectionId,
    required this.subjectCode,
    required this.subjectName,
  });

  @override
  State<AttendanceSubmissionPage> createState() => _AttendanceSubmissionPageState();
}

class _AttendanceSubmissionPageState extends State<AttendanceSubmissionPage> {
  final TextEditingController _codeController = TextEditingController();
  String _errorMessage = '';

  @override
  void dispose() {
    _codeController.dispose();
    super.dispose();
  }

  void _handleSubmit() async {
    final code = _codeController.text.trim();
    if (code.length < 6) {
      setState(() => _errorMessage = 'Please enter a valid 6-digit code.');
      return;
    }

    final studentId = Provider.of<UserProvider>(context, listen: false).userId.toString();
    final provider = Provider.of<AttendanceProvider>(context, listen: false);
    final int attendanceId = widget.sessionData['attendance_id'] ?? 0;

    bool success = await provider.submitStudentAttendance(
      attendanceId: attendanceId,
      studentId: studentId,
      code: code,
    );

    if (!mounted) return;

    if (success) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text("Attendance Submitted Successfully!"),
          backgroundColor: Colors.green,
        ),
      );
      
      // Refresh the attendance history list view
      await provider.getAttendanceSubmission(widget.sectionId, studentId);
      
      Navigator.pop(context);
    } else {
      setState(() {
        _errorMessage = provider.errorMessage ?? 'Invalid verification code.';
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    final provider = Provider.of<AttendanceProvider>(context);

    // Retrieve fields dynamically from the session map parameters
    String displaySubject = "${widget.subjectCode} ${widget.subjectName}".toUpperCase();
    String displaySection = widget.sessionData['section_name'] ?? "01A"; // Fallback to 01A if null
    String displayLecturer = widget.sessionData['lecturer_name'] ?? "Ts Dr. Fahmi";
    String displayDate = widget.sessionData['date'] ?? "";
    String displayTime = widget.sessionData['time'] ?? "";
    String displayLocation = widget.sessionData['location_name'] ?? widget.sessionData['venue'] ?? "N/A";

    return Scaffold(
      backgroundColor: const Color(0xFFD1E9F6),
      appBar: const UsasHeader(),
      drawer: const AppSidebar(),
      bottomNavigationBar: const UsasBottomNav(),
      body: SingleChildScrollView(
        padding: const EdgeInsets.symmetric(horizontal: 25.0, vertical: 30.0),
        child: Column(
          children: [
            const Center(
              child: Text(
                "Attendance",
                style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold),
              ),
            ),
            const SizedBox(height: 25),

            // Top Meta Information Container Card (Dynamic data source)
            Container(
              width: double.infinity,
              padding: const EdgeInsets.all(25),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(25),
                boxShadow: [
                  BoxShadow(color: Colors.black.withOpacity(0.05), blurRadius: 10, offset: const Offset(0, 4))
                ],
              ),
              child: Column(
                children: [
                  Text(
                    displaySubject,
                    textAlign: TextAlign.center,
                    style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 13, letterSpacing: 0.3),
                  ),
                  const SizedBox(height: 12),
                  _buildMetaRow("Section:", displaySection),
                  _buildMetaRow("Lecturer:", displayLecturer),
                  _buildMetaRow("Date:", displayDate),
                  _buildMetaRow("Time:", displayTime),
                  _buildMetaRow("Location:", displayLocation),
                ],
              ),
            ),
            const SizedBox(height: 20),

            // Bottom Entry Verification Interaction Box
            Container(
              width: double.infinity,
              padding: const EdgeInsets.symmetric(horizontal: 25, vertical: 35),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(25),
                boxShadow: [
                  BoxShadow(color: Colors.black.withOpacity(0.05), blurRadius: 10, offset: const Offset(0, 4))
                ],
              ),
              child: Column(
                children: [
                  const Text(
                    "ENTER CODE:",
                    style: TextStyle(fontWeight: FontWeight.bold, fontSize: 13, letterSpacing: 0.5),
                  ),
                  const SizedBox(height: 15),
                  
                  Container(
                    height: 50,
                    decoration: BoxDecoration(
                      color: const Color(0xFFF0F0F0),
                      borderRadius: BorderRadius.circular(10),
                    ),
                    child: TextField(
                      controller: _codeController,
                      maxLength: 6,
                      keyboardType: TextInputType.number,
                      textAlign: TextAlign.center,
                      style: const TextStyle(fontSize: 20, fontWeight: FontWeight.bold, letterSpacing: 8),
                      decoration: const InputDecoration(
                        counterText: "",
                        border: InputBorder.none,
                        contentPadding: EdgeInsets.zero,
                      ),
                    ),
                  ),
                  
                  if (_errorMessage.isNotEmpty) ...[
                    const SizedBox(height: 12),
                    Text(
                      _errorMessage,
                      style: const TextStyle(color: Colors.red, fontSize: 12, fontWeight: FontWeight.bold),
                    ),
                  ],
                  const SizedBox(height: 25),

                  SizedBox(
                    width: double.infinity,
                    height: 45,
                    child: ElevatedButton(
                      style: ElevatedButton.styleFrom(
                        backgroundColor: const Color(0xFF1BC467), 
                        elevation: 0,
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                      ),
                      onPressed: provider.isLoading ? null : _handleSubmit,
                      child: provider.isLoading
                          ? const SizedBox(
                              width: 20,
                              height: 20,
                              child: CircularProgressIndicator(color: Colors.white, strokeWidth: 2),
                            )
                          : const Text(
                              "Submit Attendance",
                              style: TextStyle(color: Colors.white, fontSize: 14, fontWeight: FontWeight.bold),
                            ),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildMetaRow(String label, String value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 2.0),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Text(label, style: const TextStyle(fontSize: 11, color: Colors.black54)),
          const SizedBox(width: 5),
          Text(value, style: const TextStyle(fontSize: 11, fontWeight: FontWeight.w500, color: Colors.black87)),
        ],
      ),
    );
  }
}