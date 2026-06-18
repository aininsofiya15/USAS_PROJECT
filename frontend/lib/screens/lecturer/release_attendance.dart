import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import '../../widgets/header.dart';
import '../../widgets/navigation_bar.dart';
import '../../widgets/app_sidebar.dart';

class ReleaseAttendanceCodePage extends StatelessWidget {
  final String subjectName;
  final String sectionNo;
  final String date;
  final String time;
  final String code;
  final String labName;        // ✅ add
  final String geolocation;    // ✅ add

  const ReleaseAttendanceCodePage({
    super.key,
    required this.subjectName,
    required this.sectionNo,
    required this.date,
    required this.time,
    required this.code,
    required this.labName,       // ✅ add
    required this.geolocation,   
  });

  String _generateValidityWindow() {
    try {
      // Parse time — supports both "HH:mm" and "h:mm AM/PM" formats
      DateTime startTime;
      if (time.toLowerCase().contains('am') || time.toLowerCase().contains('pm')) {
        startTime = DateFormat('h:mm a').parse(time.trim());
      } else {
        final parts = time.split(':');
        final now = DateTime.now();
        startTime = DateTime(now.year, now.month, now.day,
            int.parse(parts[0]), int.parse(parts[1]));
      }
      final endTime = startTime.add(const Duration(hours: 2));
      final fmt = DateFormat('h:mm a');
      return "${fmt.format(startTime)} - ${fmt.format(endTime)}";
    } catch (e) {
      return time;
    }
  }

  void _showSuccessPopup(BuildContext context) {
    final String validityRange = _generateValidityWindow();

    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (BuildContext context) {
        return Dialog(
          shape:
              RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
          child: Padding(
            padding:
                const EdgeInsets.symmetric(horizontal: 20, vertical: 25),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Container(
                  padding: const EdgeInsets.all(8),
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    border: Border.all(color: Colors.black, width: 2),
                  ),
                  child:
                      const Icon(Icons.check, color: Colors.black, size: 32),
                ),
                const SizedBox(height: 20),
                const Text(
                  "Code released successfully!",
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                    color: Colors.black,
                  ),
                ),
                const SizedBox(height: 12),
                Text(
                  "Attendance code validity:\n$validityRange",
                  textAlign: TextAlign.center,
                  style: const TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.w600,
                    color: Colors.black,
                    height: 1.4,
                  ),
                ),
                const SizedBox(height: 25),
                SizedBox(
                  width: double.infinity,
                  child: ElevatedButton(
                    onPressed: () {
                      Navigator.pop(context);
                      Navigator.popUntil(context, (route) => route.isFirst);
                    },
                    style: ElevatedButton.styleFrom(
                      backgroundColor: const Color(0xFF24D163),
                      padding: const EdgeInsets.symmetric(vertical: 12),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(10),
                      ),
                    ),
                    child: const Text(
                      "OK",
                      style: TextStyle(
                        color: Colors.white,
                        fontWeight: FontWeight.bold,
                        fontSize: 15,
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    final String validityRange = _generateValidityWindow();

    return Scaffold(
      backgroundColor: const Color(0xFFFDF2F2),
      appBar: const UsasHeader(),
      drawer: const AppSidebar(),
      bottomNavigationBar: const UsasBottomNav(),
      body: SingleChildScrollView(
        padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 24),
        child: Column(
          children: [
            // ── Page Title ─────────────────────────────────────────────
            const Text(
              "Attendance",
              style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 20),

            // ── Card 1: Subject Info ───────────────────────────────────
            Container(
              width: double.infinity,
              padding:
                  const EdgeInsets.symmetric(vertical: 20, horizontal: 20),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(20),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withOpacity(0.06),
                    blurRadius: 10,
                    offset: const Offset(0, 4),
                  ),
                ],
              ),
              child: Column(
                children: [
                  Text(
                    subjectName.toUpperCase(),
                    textAlign: TextAlign.center,
                    style: const TextStyle(
                      fontSize: 15,
                      fontWeight: FontWeight.bold,
                      color: Colors.black87,
                    ),
                  ),
                  const SizedBox(height: 10),
                  _buildCenteredInfoRow("Section: $sectionNo"),
                  _buildCenteredInfoRow("Lecture/Lab: $labName"),           // ✅
                  _buildCenteredInfoRow("Class Date: $date $validityRange"),
                  _buildCenteredInfoRow("Geolocation: $geolocation"),       // ✅
                ],
              ),
            ),

            const SizedBox(height: 16),

            // ── Card 2: Attendance Code + Release Button ───────────────
            Container(
              width: double.infinity,
              padding: const EdgeInsets.symmetric(vertical: 28, horizontal: 20),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(20),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withOpacity(0.06),
                    blurRadius: 10,
                    offset: const Offset(0, 4),
                  ),
                ],
              ),
              child: Column(
                children: [
                  // ── "Attendance Code:" label ─────────────────────────
                  const Text(
                    "Attendance Code:",
                    style: TextStyle(
                      fontSize: 15,
                      fontWeight: FontWeight.w600,
                      color: Colors.black87,
                    ),
                  ),
                  const SizedBox(height: 12),

                  // ── Large bold code ──────────────────────────────────
                  Text(
                    code,
                    textAlign: TextAlign.center,
                    style: const TextStyle(
                      fontSize: 48,
                      fontWeight: FontWeight.bold,
                      color: Colors.black87,
                      letterSpacing: 6,
                    ),
                  ),
                  const SizedBox(height: 24),

                  // ── Release Code button ──────────────────────────────
                  ElevatedButton(
                    onPressed: () => _showSuccessPopup(context),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: const Color(0xFF28A745),
                      padding: const EdgeInsets.symmetric(
                        vertical: 13,
                        horizontal: 40,
                      ),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(25),
                      ),
                      elevation: 0,
                    ),
                    child: const Text(
                      "Release Code",
                      style: TextStyle(
                        color: Colors.white,
                        fontWeight: FontWeight.bold,
                        fontSize: 15,
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

  Widget _buildCenteredInfoRow(String text) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 3),
      child: Text(
        text,
        textAlign: TextAlign.center,
        style: const TextStyle(fontSize: 13, color: Colors.black87),
      ),
    );
  }
}