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

  const ReleaseAttendanceCodePage({
    super.key,
    required this.subjectName,
    required this.sectionNo,
    required this.date,
    required this.time,
    required this.code,
  });

  // --- TIME CALCULATION HELPER ---
  /// Captures the current live clock time, adds 2 hours, and returns a string range.
  String _generateLiveTwoHourWindow() {
    // 1. Get the current active device time (Time of creation)
    DateTime currentTimeCreated = DateTime.now();
    
    // 2. Add exactly 2 hours to get the expiration deadline
    DateTime expirationTime = currentTimeCreated.add(const Duration(hours: 2));
    
    // 3. Format into a clean presentation style (e.g., "6:56 AM")
    DateFormat displayFormat = DateFormat("h:mm a");
    String startTimeStr = displayFormat.format(currentTimeCreated);
    String endTimeStr = displayFormat.format(expirationTime);
    
    return "$startTimeStr – $endTimeStr";
  }

  // --- POPUP SYSTEM BUILDERS ---

  void _showSuccessPopup(BuildContext context) {
    // Generate the window dynamically from the current click execution timestamp
    final String explicitValidityRange = _generateLiveTwoHourWindow();

    showDialog(
      context: context,
      barrierDismissible: false, // User must explicitly tap OK
      builder: (BuildContext context) {
        return Dialog(
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 25),
            child: Column(
              mainAxisSize: MainAxisSize.min, // Wrap content tightly
              children: [
                // Custom Checkmark Logo Icon
                Container(
                  padding: const EdgeInsets.all(8),
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    border: Border.all(color: Colors.black, width: 2),
                  ),
                  child: const Icon(
                    Icons.check,
                    color: Colors.black,
                    size: 32,
                  ),
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
                // Displays validation window calculated from live action creation + 2 hours
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
                // "OK" Action Button
                SizedBox(
                  width: double.infinity,
                  child: ElevatedButton(
                    onPressed: () {
                      Navigator.pop(context); // Dismiss the popup dialog
                      Navigator.popUntil(context, (route) => route.isFirst); // Go back to Dashboard
                    },
                    style: ElevatedButton.styleFrom(
                      backgroundColor: const Color(0xFF24D163), // Vibrant Success Green
                      padding: const EdgeInsets.symmetric(vertical: 12),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(10),
                      ),
                      elevation: 0,
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

  void _showErrorPopup(BuildContext context) {
    // Falls back to showing the expiration boundary marking based on the calculated live window
    final String activeWindowEnd = _generateLiveTwoHourWindow().split(' – ').last;

    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (BuildContext context) {
        return Dialog(
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 25),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                // Warning Alert Triangle Icon
                const Icon(
                  Icons.warning_rounded,
                  color: Color(0xFFE53935), // Warning Red
                  size: 55,
                ),
                const SizedBox(height: 15),
                Text(
                  "An attendance code for this class session has already been released and is still active until $activeWindowEnd.",
                  textAlign: TextAlign.center,
                  style: const TextStyle(
                    fontSize: 15,
                    fontWeight: FontWeight.bold,
                    color: Colors.black,
                    height: 1.3,
                  ),
                ),
                const SizedBox(height: 25),
                // Action Routing Button
                SizedBox(
                  width: double.infinity,
                  child: ElevatedButton(
                    onPressed: () {
                      Navigator.pop(context); // Dismiss dialog
                      Navigator.popUntil(context, (route) => route.isFirst); // Go back to Dashboard
                    },
                    style: ElevatedButton.styleFrom(
                      backgroundColor: const Color(0xFF24D163), // Green Action Match
                      padding: const EdgeInsets.symmetric(vertical: 12),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(10),
                      ),
                      elevation: 0,
                    ),
                    child: const Text(
                      "Back to Dashboard",
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

  // --- CORE UI PAGE LAYOUT ---

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF3D8DA), 
      appBar: const UsasHeader(),
      drawer: const AppSidebar(),
      bottomNavigationBar: const UsasBottomNav(),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20.0),
        child: Column(
          children: [
            const Text(
              "Release Attendance",
              style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 20),
            
            Container(
              padding: const EdgeInsets.all(25),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(25),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withOpacity(0.05),
                    blurRadius: 10,
                    offset: const Offset(0, 4),
                  )
                ],
              ),
              child: Column(
                children: [
                  _buildDisplayRow("Subject:", subjectName),
                  _buildDisplayRow("Section:", sectionNo.split('-').last),
                  _buildDisplayRow("Date:", date),
                  _buildDisplayRow("Time:", time),
                  
                  const Padding(
                    padding: EdgeInsets.symmetric(vertical: 20),
                    child: Divider(thickness: 1, color: Color(0xFFEEEEEE)),
                  ),
                  
                  const Text(
                    "STUDENT ATTENDANCE CODE",
                    style: TextStyle(
                      fontWeight: FontWeight.bold, 
                      color: Colors.black54,
                      fontSize: 12,
                    ),
                  ),
                  const SizedBox(height: 15),
                  
                  // Generated Code display box
                  Container(
                    width: double.infinity,
                    padding: const EdgeInsets.symmetric(vertical: 25),
                    decoration: BoxDecoration(
                      color: const Color(0xFFF8F9FA),
                      borderRadius: BorderRadius.circular(15),
                      border: Border.all(color: const Color(0xFF007BFF).withOpacity(0.1)),
                    ),
                    child: Text(
                      code,
                      textAlign: TextAlign.center,
                      style: const TextStyle(
                        fontSize: 42,
                        fontWeight: FontWeight.bold,
                        color: Color(0xFF007BFF), 
                        letterSpacing: 10,
                      ),
                    ),
                  ),
                  
                  const SizedBox(height: 35),
                  
                  // Release Interactive Action Button
                  SizedBox(
                    width: double.infinity,
                    child: ElevatedButton(
                      onPressed: () {
                        // Triggers success popup tracking exact click-instantiation timeline limits
                        _showSuccessPopup(context);
                      },
                      style: ElevatedButton.styleFrom(
                        backgroundColor: const Color(0xFF28A745), 
                        padding: const EdgeInsets.symmetric(vertical: 16),
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(15)),
                        elevation: 0,
                      ),
                      child: const Text(
                        "RELEASE CODE",
                        style: TextStyle(
                          color: Colors.white, 
                          fontWeight: FontWeight.bold,
                          fontSize: 16,
                        ),
                      ),
                    ),
                  ),
                  
                  const SizedBox(height: 10),
                  TextButton(
                    onPressed: () => Navigator.pop(context),
                    child: const Text(
                      "Back to Edit",
                      style: TextStyle(color: Colors.black38, fontSize: 13),
                    ),
                  )
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildDisplayRow(String label, String value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 6.0),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(label, style: const TextStyle(fontWeight: FontWeight.w600, color: Colors.black54)),
          Flexible(
            child: Text(
              value,
              textAlign: TextAlign.right,
              style: const TextStyle(
                fontWeight: FontWeight.bold, 
                color: Color(0xFF3F51B5), 
              ),
            ),
          ),
        ],
      ),
    );
  }
}