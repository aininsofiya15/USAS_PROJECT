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
  State<AttendanceSubmissionPage> createState() =>
      _AttendanceSubmissionPageState();
}

class _AttendanceSubmissionPageState extends State<AttendanceSubmissionPage> {
  final TextEditingController _codeController = TextEditingController();
  String _errorMessage = '';

  @override
  void dispose() {
    _codeController.dispose();
    super.dispose();
  }

  // ── Main submit handler ─────────────────────────────────────────────────
  void _handleSubmit() async {
    final code = _codeController.text.trim().toUpperCase();
    if (code.isEmpty) {
      setState(() => _errorMessage = 'Please enter the verification code.');
      return;
    }
    setState(() => _errorMessage = '');

    final provider = Provider.of<AttendanceProvider>(context, listen: false);
    final studentId =
        Provider.of<UserProvider>(context, listen: false).userId.toString();

    int attendanceId =
        int.tryParse(widget.sessionData['attendance_id'].toString()) ??
        int.tryParse(widget.sessionData['id'].toString()) ??
        int.tryParse(widget.sessionData['session_id'].toString()) ??
        0;

    if (attendanceId == 0) {
      setState(
          () => _errorMessage = 'Missing target attendance session ID identifier.');
      return;
    }

    // ── Pre-check 1: Already submitted? ──────────────────────────────────
    final bool alreadySubmitted = await provider.checkAlreadySubmitted(
      attendanceId: attendanceId,
      studentId: studentId,
    );
    if (!mounted) return;
    if (alreadySubmitted) {
      _showAlreadySubmittedDialog();
      return;
    }

    // ── Pre-check 2: Session expired? ────────────────────────────────────
    final bool isExpired = await provider.checkSessionExpired(
      attendanceId: attendanceId,
    );
    if (!mounted) return;
    if (isExpired) {
      _showExpiredDialog();
      return;
    }

    // ── Show location verification loading dialog ─────────────────────────
    _showVerifyingDialog(code);

    try {
      LocationPermission permission = await Geolocator.checkPermission();
      if (permission == LocationPermission.denied) {
        permission = await Geolocator.requestPermission();
      }
      if (permission == LocationPermission.deniedForever) {
        if (mounted) Navigator.pop(context);
        setState(() =>
            _errorMessage = 'Location permissions are permanently denied.');
        return;
      }

      Position position = await Geolocator.getCurrentPosition(
        desiredAccuracy: LocationAccuracy.high,
        timeLimit: const Duration(seconds: 10),
      );

      final result = await provider.submitAttendance(
        attendanceId: attendanceId,
        studentId: studentId,
        code: code,
        lat: position.latitude,
        lng: position.longitude,
      );

      if (!mounted) return;
      Navigator.pop(context); // dismiss verifying dialog

      if (result['success'] == true) {
        final int distance = (result['distance'] as num?)?.toInt() ?? 0;
        _showSuccessDialog(distance, result['message'] ?? 'Attendance recorded successfully!');
        await provider.getAttendanceSubmission(widget.sectionId, studentId);
      } else {
        // ── Wrong code or out of range ──────────────────────────────────
        final String msg = result['message'] ?? 'Invalid verification code.';
        final int distance = (result['distance'] as num?)?.toInt() ?? 0;
        final bool inRange = result['in_range'] == true;

        if (inRange == false && distance > 0) {
          // Out of range — show distance result dialog
          _showFailDialog(distance, msg);
        } else {
          // Wrong code
          _showWrongCodeDialog();
        }
      }
    } catch (e) {
      if (mounted) Navigator.pop(context);
      setState(() => _errorMessage = 'Location error: $e');
    }
  }

  // ── Dialog: Verifying location (loading) ────────────────────────────────
  void _showVerifyingDialog(String code) {
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (_) => Dialog(
        shape:
            RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 28),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              const SizedBox(
                width: 40,
                height: 40,
                child: CircularProgressIndicator(
                  strokeWidth: 3,
                  valueColor:
                      AlwaysStoppedAnimation<Color>(Color(0xFF007AFF)),
                ),
              ),
              const SizedBox(height: 20),
              const Text(
                "Location Verification Required",
                textAlign: TextAlign.center,
                style:
                    TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
              ),
              const SizedBox(height: 10),
              const Text(
                "To prevent fraudulent attendance, we need to verify you're physically present at:",
                textAlign: TextAlign.center,
                style: TextStyle(fontSize: 12, color: Colors.black54),
              ),
              const SizedBox(height: 12),
              Text(
                code,
                style: const TextStyle(
                  fontWeight: FontWeight.bold,
                  fontSize: 24,
                  letterSpacing: 4,
                  color: Colors.black87,
                ),
              ),
              const SizedBox(height: 16),
              const Align(
                alignment: Alignment.centerLeft,
                child: Text(
                  "Please ensure:",
                  style: TextStyle(
                      fontWeight: FontWeight.bold, fontSize: 12),
                ),
              ),
              const SizedBox(height: 6),
              _bulletPoint("Location/GPS is enabled on your device"),
              _bulletPoint(
                  "You are at the actual event venue (within 1KM)"),
              _bulletPoint(
                  "You are using a device with GPS capabilities"),
              const SizedBox(height: 20),
              SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  onPressed: null, // disabled — auto-processing
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color(0xFF007AFF),
                    disabledBackgroundColor: const Color(0xFF007AFF),
                    shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(10)),
                    padding: const EdgeInsets.symmetric(vertical: 13),
                  ),
                  child: const Text(
                    "Verify Location and Record Attendance",
                    style: TextStyle(color: Colors.white, fontSize: 12),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _bulletPoint(String text) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 4),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text("• ",
              style: TextStyle(fontSize: 12, color: Colors.black54)),
          Expanded(
            child: Text(
              text,
              style:
                  const TextStyle(fontSize: 12, color: Colors.black54),
            ),
          ),
        ],
      ),
    );
  }

  // ── Dialog: Wrong code ───────────────────────────────────────────────────
  void _showWrongCodeDialog() {
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (_) => Dialog(
        shape:
            RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 28, vertical: 28),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              const Icon(Icons.cancel_rounded,
                  color: Colors.red, size: 64),
              const SizedBox(height: 16),
              const Text(
                "Incorrect code. Please check with your lecturer.",
                textAlign: TextAlign.center,
                style: TextStyle(
                    fontWeight: FontWeight.bold, fontSize: 14),
              ),
              const SizedBox(height: 24),
              SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  onPressed: () => Navigator.pop(context),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color(0xFF22C55E),
                    shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(10)),
                    padding: const EdgeInsets.symmetric(vertical: 12),
                  ),
                  child: const Text("OK",
                      style: TextStyle(
                          color: Colors.white,
                          fontWeight: FontWeight.bold,
                          fontSize: 14)),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  // ── Dialog: Already submitted ────────────────────────────────────────────
  void _showAlreadySubmittedDialog() {
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (_) => Dialog(
        shape:
            RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 28, vertical: 28),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              const Icon(Icons.cancel_rounded,
                  color: Colors.red, size: 64),
              const SizedBox(height: 16),
              const Text(
                "Attendance has already been recorded for this session.",
                textAlign: TextAlign.center,
                style: TextStyle(
                    fontWeight: FontWeight.bold, fontSize: 14),
              ),
              const SizedBox(height: 24),
              SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  onPressed: () {
                    Navigator.pop(context); // close dialog
                    Navigator.pop(context); // go back
                  },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color(0xFF22C55E),
                    shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(10)),
                    padding: const EdgeInsets.symmetric(vertical: 12),
                  ),
                  child: const Text("Back to Dashboard",
                      style: TextStyle(
                          color: Colors.white,
                          fontWeight: FontWeight.bold,
                          fontSize: 14)),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  // ── Dialog: Session expired ──────────────────────────────────────────────
  void _showExpiredDialog() {
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (_) => Dialog(
        shape:
            RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 28, vertical: 28),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              const Icon(Icons.cancel_rounded,
                  color: Colors.red, size: 64),
              const SizedBox(height: 16),
              const Text(
                "Attendance code has expired. The submission time limit has passed.",
                textAlign: TextAlign.center,
                style: TextStyle(
                    fontWeight: FontWeight.bold, fontSize: 14),
              ),
              const SizedBox(height: 24),
              SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  onPressed: () {
                    Navigator.pop(context);
                    Navigator.pop(context);
                  },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color(0xFF22C55E),
                    shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(10)),
                    padding: const EdgeInsets.symmetric(vertical: 12),
                  ),
                  child: const Text("Back to Dashboard",
                      style: TextStyle(
                          color: Colors.white,
                          fontWeight: FontWeight.bold,
                          fontSize: 14)),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  // ── Dialog: Success ──────────────────────────────────────────────────────
  void _showSuccessDialog(int distance, String msg) {
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (_) => Dialog(
        shape:
            RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 28, vertical: 28),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              // Circular check icon
              Container(
                width: 64,
                height: 64,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  border: Border.all(
                      color: const Color(0xFF22C55E), width: 3),
                ),
                child: const Icon(Icons.check_rounded,
                    color: Color(0xFF22C55E), size: 40),
              ),
              const SizedBox(height: 16),
              // Location detected box
              Container(
                width: double.infinity,
                padding: const EdgeInsets.symmetric(
                    vertical: 10, horizontal: 14),
                decoration: BoxDecoration(
                  border: Border.all(color: const Color(0xFF22C55E)),
                  borderRadius: BorderRadius.circular(10),
                ),
                child: Column(
                  children: [
                    const Text(
                      "Location Detected.",
                      style: TextStyle(
                          color: Color(0xFF22C55E),
                          fontWeight: FontWeight.bold,
                          fontSize: 13),
                    ),
                    Text(
                      "Distance from venue: $distance meters",
                      style: const TextStyle(
                          color: Color(0xFF22C55E), fontSize: 12),
                    ),
                    const Text(
                      "You are within the allowed range!",
                      style: TextStyle(
                          color: Color(0xFF22C55E), fontSize: 12),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 16),
              Text(
                msg,
                textAlign: TextAlign.center,
                style: const TextStyle(
                    fontWeight: FontWeight.bold, fontSize: 14),
              ),
              const SizedBox(height: 24),
              SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  onPressed: () {
                    Navigator.pop(context);
                    Navigator.pop(context);
                  },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color(0xFF22C55E),
                    shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(10)),
                    padding: const EdgeInsets.symmetric(vertical: 12),
                  ),
                  child: const Text("OK",
                      style: TextStyle(
                          color: Colors.white,
                          fontWeight: FontWeight.bold,
                          fontSize: 14)),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  // ── Dialog: Failed (out of range) ────────────────────────────────────────
  void _showFailDialog(int distance, String msg) {
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (_) => Dialog(
        shape:
            RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 28, vertical: 28),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              const Icon(Icons.cancel_rounded,
                  color: Colors.red, size: 64),
              const SizedBox(height: 16),
              // Location detected box (red)
              Container(
                width: double.infinity,
                padding: const EdgeInsets.symmetric(
                    vertical: 10, horizontal: 14),
                decoration: BoxDecoration(
                  border: Border.all(color: Colors.red),
                  borderRadius: BorderRadius.circular(10),
                ),
                child: Column(
                  children: [
                    const Text(
                      "Location Detected.",
                      style: TextStyle(
                          color: Colors.red,
                          fontWeight: FontWeight.bold,
                          fontSize: 13),
                    ),
                    Text(
                      "Distance from venue: $distance meters",
                      style: const TextStyle(
                          color: Colors.red, fontSize: 12),
                    ),
                    const Text(
                      "You are outside the allowed range!",
                      style: TextStyle(
                          color: Colors.red, fontSize: 12),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 16),
              Text(
                msg,
                textAlign: TextAlign.center,
                style: const TextStyle(
                    fontWeight: FontWeight.bold, fontSize: 14),
              ),
              const SizedBox(height: 24),
              SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  onPressed: () => Navigator.pop(context),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color(0xFF22C55E),
                    shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(10)),
                    padding: const EdgeInsets.symmetric(vertical: 12),
                  ),
                  child: const Text("OK",
                      style: TextStyle(
                          color: Colors.white,
                          fontWeight: FontWeight.bold,
                          fontSize: 14)),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  // ── Build ────────────────────────────────────────────────────────────────
  @override
  Widget build(BuildContext context) {
    final provider = Provider.of<AttendanceProvider>(context);

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
            const Center(
              child: Text("Attendance",
                  style: TextStyle(
                      fontSize: 22, fontWeight: FontWeight.bold)),
            ),
            const SizedBox(height: 25),

            // ── Info Card ───────────────────────────────────────────
            Container(
              width: double.infinity,
              padding: const EdgeInsets.symmetric(
                  vertical: 30, horizontal: 20),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(20),
                boxShadow: [
                  BoxShadow(
                      color: Colors.black.withOpacity(0.05),
                      blurRadius: 10)
                ],
              ),
              child: renderCoCurriculumLayout
                  ? _buildCoCurriculumDetails()
                  : _buildClassDetails(),
            ),

            const SizedBox(height: 20),

            // ── Code Entry Card ─────────────────────────────────────
            Container(
              width: double.infinity,
              padding: const EdgeInsets.symmetric(
                  horizontal: 30, vertical: 35),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(20),
                boxShadow: [
                  BoxShadow(
                      color: Colors.black.withOpacity(0.05),
                      blurRadius: 10)
                ],
              ),
              child: Column(
                children: [
                  const Text("ENTER CODE:",
                      style: TextStyle(
                          fontWeight: FontWeight.w900, fontSize: 13)),
                  const SizedBox(height: 15),
                  Container(
                    height: 50,
                    decoration: BoxDecoration(
                      color: const Color(0xFFF0F0F0),
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: TextField(
                      controller: _codeController,
                      maxLength: 6,
                      textAlign: TextAlign.center,
                      textCapitalization: TextCapitalization.characters,
                      style: const TextStyle(
                          fontSize: 20,
                          fontWeight: FontWeight.bold,
                          letterSpacing: 8),
                      decoration: const InputDecoration(
                        counterText: "",
                        border: InputBorder.none,
                      ),
                    ),
                  ),
                  if (_errorMessage.isNotEmpty) ...[
                    const SizedBox(height: 12),
                    Text(
                      _errorMessage,
                      textAlign: TextAlign.center,
                      style: const TextStyle(
                          color: Colors.red,
                          fontSize: 12,
                          fontWeight: FontWeight.bold),
                    ),
                  ],
                  const SizedBox(height: 20),
                  SizedBox(
                    width: double.infinity,
                    height: 45,
                    child: ElevatedButton(
                      style: ElevatedButton.styleFrom(
                          backgroundColor: const Color(0xFF1CB55C)),
                      onPressed:
                          provider.isLoading ? null : _handleSubmit,
                      child: const Text("Submit Attendance",
                          style: TextStyle(color: Colors.white)),
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

  // ── Co-curriculum info layout ──────────────────────────────────────────
  Widget _buildCoCurriculumDetails() {
    String displayActivity =
        (widget.sessionData['activity_name'] ??
                widget.subjectName ??
                "CO-CURRICULUM")
            .toString()
            .toUpperCase();
    String displayDate = widget.sessionData['date'] ?? "N/A";
    String displayTime = widget.sessionData['time'] ?? "";
    String displayVenue = widget.sessionData['venue'] ?? "N/A";
    String displayLecturer = widget.sessionData['lecturer_name'] ?? "N/A";
    String enrolled =
        widget.sessionData['enrolled']?.toString() ?? "0";
    String capacity =
        widget.sessionData['capacity']?.toString() ?? "60";

    return Column(
      crossAxisAlignment: CrossAxisAlignment.center,
      children: [
        Text(displayActivity,
            textAlign: TextAlign.center,
            style: const TextStyle(
                fontWeight: FontWeight.w900, fontSize: 13)),
        const SizedBox(height: 15),
        Text("Number of Student: $enrolled / $capacity Students",
            textAlign: TextAlign.center,
            style: const TextStyle(
                fontSize: 11, color: Colors.black87, height: 1.5)),
        Text("Class Date: $displayDate $displayTime",
            textAlign: TextAlign.center,
            style: const TextStyle(
                fontSize: 11, color: Colors.black87, height: 1.5)),
        Text("Venue: $displayVenue",
            textAlign: TextAlign.center,
            style: const TextStyle(
                fontSize: 11, color: Colors.black87, height: 1.5)),
        Text("Lecturer Name: $displayLecturer",
            textAlign: TextAlign.center,
            style: const TextStyle(
                fontSize: 11, color: Colors.black87, height: 1.5)),
      ],
    );
  }

  // ── Regular class info layout ──────────────────────────────────────────
  Widget _buildClassDetails() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.center,
      children: [
        Text(
            "${widget.subjectCode} ${widget.subjectName}"
                .toUpperCase(),
            textAlign: TextAlign.center,
            style: const TextStyle(
                fontWeight: FontWeight.w900, fontSize: 13)),
        const SizedBox(height: 15),
        Text("Section: ${widget.sessionData['section_name'] ?? '01A'}",
            textAlign: TextAlign.center,
            style: const TextStyle(fontSize: 11, height: 1.5)),
        Text(
            "Lecturer: ${widget.sessionData['lecturer_name'] ?? 'N/A'}",
            textAlign: TextAlign.center,
            style: const TextStyle(fontSize: 11, height: 1.5)),
        Text("Date: ${widget.sessionData['date'] ?? ''}",
            textAlign: TextAlign.center,
            style: const TextStyle(fontSize: 11, height: 1.5)),
        Text("Time: ${widget.sessionData['time'] ?? ''}",
            textAlign: TextAlign.center,
            style: const TextStyle(fontSize: 11, height: 1.5)),
        Text(
            "Location: ${widget.sessionData['location_name'] ?? 'N/A'}",
            textAlign: TextAlign.center,
            style: const TextStyle(fontSize: 11, height: 1.5)),
      ],
    );
  }
}