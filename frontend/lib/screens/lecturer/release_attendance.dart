import 'package:flutter/material.dart';
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

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF3D8DA), // Consistent Pink
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
                  // Retrieved Data Display
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
                  
                  // Generated Code Box
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
                        color: Color(0xFF007BFF), // Vibrant blue for the code
                        letterSpacing: 10,
                      ),
                    ),
                  ),
                  
                  const SizedBox(height: 35),
                  
                  // Release Button
                  SizedBox(
                    width: double.infinity,
                    child: ElevatedButton(
                      onPressed: () {
                        // Action to finalize release
                        ScaffoldMessenger.of(context).showSnackBar(
                          const SnackBar(content: Text("Attendance Released to Students!")),
                        );
                        // Return to the first page (Dashboard)
                        Navigator.popUntil(context, (route) => route.isFirst);
                      },
                      style: ElevatedButton.styleFrom(
                        backgroundColor: const Color(0xFF28A745), // Success Green
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

  // Helper widget to display the saved info clearly
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
                color: Color(0xFF3F51B5), // Indigo blue
              ),
            ),
          ),
        ],
      ),
    );
  }
}