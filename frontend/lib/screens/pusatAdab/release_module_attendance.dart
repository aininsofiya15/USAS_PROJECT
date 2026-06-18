import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import '../../widgets/header.dart';
import '../../widgets/navigation_bar.dart';
import '../../widgets/app_sidebar.dart';
import '../../domain/module.dart';

class ReleaseModuleAttendanceCodePage extends StatelessWidget {
  final Module module;
  final String code;
  final int capacity;
  final String lecturerName;
  final String venue;
  final String dateTime;
  // FIX: new field so this page can show the real present-student count
  // instead of a hardcoded "0". Defaults to 0 so existing call sites that
  // don't pass it yet still compile.
  final int presentCount;

  const ReleaseModuleAttendanceCodePage({
    super.key,
    required this.module,
    required this.code,
    required this.capacity,
    required this.lecturerName,
    required this.venue,
    required this.dateTime,
    this.presentCount = 0,
  });

  String _generateLiveTwoHourWindow() {
    DateTime currentTimeCreated = DateTime.now();
    DateTime expirationTime =
        currentTimeCreated.add(const Duration(hours: 2));
    DateFormat displayFormat = DateFormat("h:mm a");
    String startTimeStr = displayFormat.format(currentTimeCreated);
    String endTimeStr = displayFormat.format(expirationTime);
    return "$startTimeStr – $endTimeStr";
  }

  void _showSuccessPopup(BuildContext context) {
    final String explicitValidityRange = _generateLiveTwoHourWindow();

    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (BuildContext context) {
        return Dialog(
          shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(20)),
          child: Padding(
            padding: const EdgeInsets.symmetric(
                horizontal: 20, vertical: 25),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Container(
                  padding: const EdgeInsets.all(8),
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    border: Border.all(color: Colors.black, width: 2),
                  ),
                  child: const Icon(Icons.check,
                      color: Colors.black, size: 32),
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
                  "Attendance code validity:\n$explicitValidityRange",
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
                      Navigator.popUntil(
                          context, (route) => route.isFirst);
                    },
                    style: ElevatedButton.styleFrom(
                      backgroundColor: const Color(0xFF24D163),
                      padding:
                          const EdgeInsets.symmetric(vertical: 12),
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
    return Scaffold(
      backgroundColor: const Color(0xFFD1FFF3),
      appBar: const UsasHeader(),
      drawer: const AppSidebar(),
      bottomNavigationBar: const UsasBottomNav(),
      body: SingleChildScrollView(
        padding:
            const EdgeInsets.symmetric(horizontal: 20, vertical: 24),
        child: Column(
          children: [
            // ── Page Title ────────────────────────────────────────────
            const Text(
              "Module Attendance",
              style:
                  TextStyle(fontSize: 22, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 20),

            // ── Card 1: Module Info ───────────────────────────────────
            Container(
              width: double.infinity,
              padding: const EdgeInsets.symmetric(
                  vertical: 20, horizontal: 20),
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
                    (module.activityName ?? "").toUpperCase(),
                    textAlign: TextAlign.center,
                    style: const TextStyle(
                      fontSize: 15,
                      fontWeight: FontWeight.bold,
                      color: Colors.black87,
                    ),
                  ),
                  const SizedBox(height: 10),
                  // ── All values come from DB via constructor ──────────
                  _buildCenteredInfoRow(
                      "Number of Student: $presentCount / $capacity Students"),
                  _buildCenteredInfoRow("Class Date: $dateTime"),
                  _buildCenteredInfoRow("Venue: $venue"),
                  _buildCenteredInfoRow(
                      "Lecturer Name: $lecturerName"),
                ],
              ),
            ),

            const SizedBox(height: 16),

            // ── Card 2: Attendance Code + Release Button ──────────────
            Container(
              width: double.infinity,
              padding: const EdgeInsets.symmetric(
                  vertical: 28, horizontal: 20),
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
                  // ── "Attendance Code:" label ──────────────────────
                  const Text(
                    "Attendance Code:",
                    style: TextStyle(
                      fontSize: 15,
                      fontWeight: FontWeight.w600,
                      color: Colors.black87,
                    ),
                  ),
                  const SizedBox(height: 12),

                  // ── Large bold code ───────────────────────────────
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

                  // ── Release Code button ───────────────────────────
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