import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:geolocator/geolocator.dart';
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
  final bool isCoCurriculum;

  const AttendanceSubmissionPage({
    super.key,
    required this.sessionData,
    required this.sectionId,
    required this.subjectCode,
    required this.subjectName,
    this.isCoCurriculum = false,
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
    final code = _codeController.text.trim().toUpperCase();
    if (code.isEmpty) {
      setState(() => _errorMessage = 'Please enter the verification code.');
      return;
    }

    setState(() => _errorMessage = '');

    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20.0)),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const SizedBox(height: 10),
            const CircularProgressIndicator(valueColor: AlwaysStoppedAnimation<Color>(Color(0xFF007AFF))),
            const SizedBox(height: 25),
            const Text("Location Verification Required", style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
            const SizedBox(height: 10),
            const Text(
              "Verifying device coordinates match physical venue constraints...",
              textAlign: TextAlign.center,
              style: TextStyle(fontSize: 12, color: Colors.black54),
            ),
            const SizedBox(height: 20),
            Text(code, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 22, letterSpacing: 2)),
          ],
        ),
      ),
    );

    try {
      LocationPermission permission = await Geolocator.checkPermission();
      if (permission == LocationPermission.denied) {
        permission = await Geolocator.requestPermission();
      }

      if (permission == LocationPermission.deniedForever) {
        if (mounted) Navigator.pop(context);
        setState(() => _errorMessage = 'Location permissions are permanently denied.');
        return;
      }

      Position position = await Geolocator.getCurrentPosition(
        desiredAccuracy: LocationAccuracy.high,
        timeLimit: const Duration(seconds: 10),
      );

      final studentId = Provider.of<UserProvider>(context, listen: false).userId.toString();
      final provider = Provider.of<AttendanceProvider>(context, listen: false);

      // Safe integer extraction
      int attendanceId = int.tryParse(widget.sessionData['attendance_id'].toString()) ?? 
                         int.tryParse(widget.sessionData['id'].toString()) ?? 
                         int.tryParse(widget.sessionData['session_id'].toString()) ?? 0;

      if (attendanceId == 0) {
        if (mounted) Navigator.pop(context);
        setState(() => _errorMessage = 'Missing target attendance session ID identifier.');
        return;
      }

      final result = await provider.submitAttendance(
        attendanceId: attendanceId,
        studentId: studentId,
        code: code,
        lat: position.latitude,
        lng: position.longitude,
      );

      if (!mounted) return;
      Navigator.pop(context); 

      if (result['success'] == true) {
        int calculatedDistance = (result['distance'] as num?)?.toInt() ?? 0;
        _showStatusResultDialog(
          success: true,
          distance: calculatedDistance,
          msg: result['message'] ?? "Success! Attendance recorded successfully!",
        );
        await provider.getAttendanceSubmission(widget.sectionId, studentId);
      } else {
        setState(() {
          _errorMessage = result['message'] ?? 'Invalid verification code.';
        });
      }
    } catch (e) {
      if (mounted) Navigator.pop(context);
      setState(() => _errorMessage = "Hardware resolution failure: $e");
    }
  }

  void _showStatusResultDialog({required bool success, required int distance, required String msg}) {
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20.0)),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(success ? Icons.check_circle_outline_rounded : Icons.cancel_outlined, color: success ? Colors.green : Colors.red, size: 60),
            const SizedBox(height: 20),
            Text("Distance from venue: $distance meters", style: const TextStyle(fontSize: 12)),
            const SizedBox(height: 20),
            Text(msg, textAlign: TextAlign.center, style: const TextStyle(fontWeight: FontWeight.bold)),
            const SizedBox(height: 25),
            ElevatedButton(
              onPressed: () {
                Navigator.pop(context);
                if (success) Navigator.pop(context);
              },
              child: const Text("OK"),
            )
          ],
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final provider = Provider.of<AttendanceProvider>(context);
    
    // Auto layout switch logic
    bool renderCoCurriculumLayout = widget.isCoCurriculum || 
                                    widget.sessionData.containsKey('activity_name') || 
                                    !widget.sessionData.containsKey('section_name');

    return Scaffold(
      backgroundColor: const Color(0xFFD9EDF7),
      appBar: const UsasHeader(),
      drawer: const AppSidebar(),
      bottomNavigationBar: const UsasBottomNav(),
      body: SingleChildScrollView(
        padding: const EdgeInsets.symmetric(horizontal: 30.0, vertical: 30.0),
        child: Column(
          children: [
            const Center(child: Text("Attendance", style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold))),
            const SizedBox(height: 25),
            Container(
              width: double.infinity,
              padding: const EdgeInsets.symmetric(vertical: 30, horizontal: 20),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(20),
                boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.05), blurRadius: 10)],
              ),
              child: renderCoCurriculumLayout ? _buildCoCurriculumDetails() : _buildClassDetails(),
            ),
            const SizedBox(height: 20),
            Container(
              width: double.infinity,
              padding: const EdgeInsets.symmetric(horizontal: 30, vertical: 35),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(20),
                boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.05), blurRadius: 10)],
              ),
              child: Column(
                children: [
                  const Text("ENTER CODE:", style: TextStyle(fontWeight: FontWeight.w900, fontSize: 13)),
                  const SizedBox(height: 15),
                  Container(
                    height: 50,
                    decoration: BoxDecoration(color: const Color(0xFFF0F0F0), borderRadius: BorderRadius.circular(8)),
                    child: TextField(
                      controller: _codeController,
                      maxLength: 6,
                      textAlign: TextAlign.center,
                      style: const TextStyle(fontSize: 20, fontWeight: FontWeight.bold, letterSpacing: 8),
                      decoration: const InputDecoration(counterText: "", border: InputBorder.none),
                    ),
                  ),
                  if (_errorMessage.isNotEmpty) ...[
                    const SizedBox(height: 12),
                    Text(_errorMessage, textAlign: TextAlign.center, style: const TextStyle(color: Colors.red, fontSize: 12, fontWeight: FontWeight.bold)),
                  ],
                  const SizedBox(height: 20),
                  SizedBox(
                    width: double.infinity,
                    height: 45,
                    child: ElevatedButton(
                      style: ElevatedButton.styleFrom(backgroundColor: const Color(0xFF1CB55C)),
                      onPressed: provider.isLoading ? null : _handleSubmit,
                      child: const Text("Submit Attendance", style: TextStyle(color: Colors.white)),
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

  // --- HERE IS THE METHOD YOU NEEDED ---
  Widget _buildCoCurriculumDetails() {
    String displayActivity = (widget.sessionData['activity_name'] ?? widget.subjectName ?? "CO-CURRICULUM").toString().toUpperCase();
    String displayDate = widget.sessionData['date'] ?? "N/A";
    String displayTime = widget.sessionData['time'] ?? "";
    String displayVenue = widget.sessionData['venue'] ?? "N/A";
    String displayLecturer = widget.sessionData['lecturer_name'] ?? "N/A";
    String enrolled = widget.sessionData['enrolled']?.toString() ?? "0";
    String capacity = widget.sessionData['capacity']?.toString() ?? "60";
    
    dynamic rawId = widget.sessionData['attendance_id'] ?? widget.sessionData['id'] ?? 0;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.center,
      children: [
        // Visual confirmation element showing target ID
        Text("DEBUG ACTIVE TARGET ID: $rawId", style: const TextStyle(color: Colors.red, fontWeight: FontWeight.bold, fontSize: 12)),
        const SizedBox(height: 10),
        Text(displayActivity, textAlign: TextAlign.center, style: const TextStyle(fontWeight: FontWeight.w900, fontSize: 13)),
        const SizedBox(height: 15),
        Text("Number of Student: $enrolled / $capacity Students", textAlign: TextAlign.center, style: const TextStyle(fontSize: 11, color: Colors.black87, height: 1.5)),
        Text("Class Date: $displayDate $displayTime", textAlign: TextAlign.center, style: const TextStyle(fontSize: 11, color: Colors.black87, height: 1.5)),
        Text("Venue: $displayVenue", textAlign: TextAlign.center, style: const TextStyle(fontSize: 11, color: Colors.black87, height: 1.5)),
        Text("Lecturer Name: $displayLecturer", textAlign: TextAlign.center, style: const TextStyle(fontSize: 11, color: Colors.black87, height: 1.5)),
      ],
    );
  }

  Widget _buildClassDetails() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.center,
      children: [
        Text("${widget.subjectCode} ${widget.subjectName}".toUpperCase(), textAlign: TextAlign.center, style: const TextStyle(fontWeight: FontWeight.w900, fontSize: 13)),
        const SizedBox(height: 15),
        Text("Section: ${widget.sessionData['section_name'] ?? '01A'}", textAlign: TextAlign.center, style: const TextStyle(fontSize: 11, height: 1.5)),
        Text("Lecturer: ${widget.sessionData['lecturer_name'] ?? 'N/A'}", textAlign: TextAlign.center, style: const TextStyle(fontSize: 11, height: 1.5)),
        Text("Date: ${widget.sessionData['date'] ?? ''}", textAlign: TextAlign.center, style: const TextStyle(fontSize: 11, height: 1.5)),
        Text("Time: ${widget.sessionData['time'] ?? ''}", textAlign: TextAlign.center, style: const TextStyle(fontSize: 11, height: 1.5)),
        Text("Location: ${widget.sessionData['location_name'] ?? 'N/A'}", textAlign: TextAlign.center, style: const TextStyle(fontSize: 11, height: 1.5)),
      ],
    );
  }
}