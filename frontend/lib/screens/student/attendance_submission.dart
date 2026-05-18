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
    final code = _codeController.text.trim().toUpperCase();
    if (code.isEmpty) {
      setState(() => _errorMessage = 'Please enter the verification code.');
      return;
    }

    setState(() => _errorMessage = '');

    // 1. Display the "Location Verification Required" Loading Modal Dialog
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20.0)),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const SizedBox(height: 10),
            const CircularProgressIndicator(
              valueColor: AlwaysStoppedAnimation<Color>(Color(0xFF007AFF)),
            ),
            const SizedBox(height: 25),
            const Text(
              "Location Verification Required", 
              style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
            ),
            const SizedBox(height: 10),
            const Text(
              "To prevent fraudulent attendance, we need to verify you're physically present at the event venue.",
              textAlign: TextAlign.center,
              style: TextStyle(fontSize: 12, color: Colors.black54, height: 1.4),
            ),
            const SizedBox(height: 20),
            Text(
              code,
              style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 22, color: Colors.black87, letterSpacing: 2),
            ),
            const SizedBox(height: 15),
            const Align(
              alignment: Alignment.centerLeft,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text("Please ensure:", style: TextStyle(fontSize: 11, fontWeight: FontWeight.bold, color: Colors.black54)),
                  SizedBox(height: 6),
                  Text("• Location/GPS is enabled on your device", style: TextStyle(fontSize: 11, color: Colors.black54)),
                  Text("• You are at the actual event venue", style: TextStyle(fontSize: 11, color: Colors.black54)),
                  Text("• You are using a device with GPS capabilities", style: TextStyle(fontSize: 11, color: Colors.black54)),
                ],
              ),
            ),
            const SizedBox(height: 10),
          ],
        ),
      ),
    );

    try {
      // 2. Resolve Core System GPS Permissions
      LocationPermission permission = await Geolocator.checkPermission();
      if (permission == LocationPermission.denied) {
        permission = await Geolocator.requestPermission();
      }

      if (permission == LocationPermission.deniedForever) {
        if (mounted) Navigator.pop(context); // Remove loading modal
        setState(() => _errorMessage = 'Location permissions are permanently denied.');
        return;
      }

      // 3. Capture Real-Time Coordinate Metrics
      Position position = await Geolocator.getCurrentPosition(
        desiredAccuracy: LocationAccuracy.high,
        timeLimit: const Duration(seconds: 10),
      );

      final studentId = Provider.of<UserProvider>(context, listen: false).userId.toString();
      final provider = Provider.of<AttendanceProvider>(context, listen: false);
      final int attendanceId = widget.sessionData['attendance_id'] ?? 0;

      // 4. Send Code + Coordinates directly to Backend via unified method
      final result = await provider.submitAttendance(
        attendanceId: attendanceId,
        studentId: studentId,
        code: code,
        lat: position.latitude,
        lng: position.longitude,
      );

      if (!mounted) return;
      Navigator.pop(context); // Close loading dialog tracking context frame

      // 5. Evaluate response data maps and display explicit status modal components
      if (result['success'] == true) {
        // Handle physical inclusion range verification match state matches
        int calculatedDistance = (result['distance'] as num?)?.toInt() ?? 0;
        
        _showStatusResultDialog(
          success: true,
          distance: calculatedDistance,
          msg: result['message'] ?? "Success! Attendance recorded successfully!",
        );
        
        // Quietly reload the background history listings indices mapping tables array
        await provider.getAttendanceSubmission(widget.sectionId, studentId);
      } else {
        // Verify if backend successfully ran calculation but flagged out-of-bounds error
        if (result['in_range'] == false && result['distance'] != null) {
          int calculatedDistance = (result['distance'] as num?)?.toInt() ?? 0;
          _showStatusResultDialog(
            success: false,
            distance: calculatedDistance,
            msg: result['message'] ?? "Failed! Attendance could not be recorded.",
          );
        } else {
          // Fallback UI rendering tracking error loops for validation code mismatch items
          setState(() {
            _errorMessage = result['message'] ?? 'Invalid payload or incorrect verification code.';
          });
        }
      }
    } catch (e) {
      if (mounted) Navigator.pop(context); // Handle popping dialog framework safely on failures
      setState(() {
        _errorMessage = "System failed capturing hardware coordinates: $e";
      });
    }
  }

  /// Displays the explicit Status Validation Alert Card panels
  void _showStatusResultDialog({required bool success, required int distance, required String msg}) {
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20.0)),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const SizedBox(height: 10),
            Icon(
              success ? Icons.check_circle_outline_rounded : Icons.cancel_outlined,
              color: success ? const Color(0xFF1BC467) : Colors.red,
              size: 60,
            ),
            const SizedBox(height: 20),
            Container(
              width: double.infinity,
              padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 15),
              decoration: BoxDecoration(
                color: success ? const Color(0xFFE8F7EE) : const Color(0xFFFDEBEB),
                border: Border.all(color: success ? const Color(0xFF1BC467).withOpacity(0.5) : Colors.red.withOpacity(0.5)),
                borderRadius: BorderRadius.circular(12),
              ),
              child: Column(
                children: [
                  Text(
                    "Location Detected.",
                    style: TextStyle(color: success ? const Color(0xFF1BC467) : Colors.red, fontWeight: FontWeight.bold, fontSize: 13),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    "Distance from venue: $distance meters",
                    style: TextStyle(color: success ? const Color(0xFF1BC467) : Colors.red, fontSize: 12),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    success ? "You are within the allowed range!" : "You are outside the allowed range!",
                    style: TextStyle(color: success ? const Color(0xFF1BC467) : Colors.red, fontSize: 11, fontWeight: FontWeight.bold),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 20),
            Text(
              msg, 
              textAlign: TextAlign.center, 
              style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 14, color: Colors.black87)
            ),
            const SizedBox(height: 25),
            SizedBox(
              width: double.infinity,
              height: 40,
              child: ElevatedButton(
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color(0xFF1BC467),
                  elevation: 0,
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                ),
                onPressed: () {
                  Navigator.pop(context); // Dismount alert dialogue view
                  if (success) {
                    Navigator.pop(context); // Pop current UI and push user backward to updated tracking history listings
                  }
                },
                child: const Text("OK", style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
              ),
            ),
          ],
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final provider = Provider.of<AttendanceProvider>(context);

    String displaySubject = "${widget.subjectCode} ${widget.subjectName}".toUpperCase();
    String displaySection = widget.sessionData['section_name'] ?? "01A"; 
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

            // Top Meta Information Container Card
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
                      keyboardType: TextInputType.text,
                      autocorrect: false,
                      enableSuggestions: false,
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
                      textAlign: TextAlign.center,
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