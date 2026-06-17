import 'package:flutter/material.dart';
import 'class_attendance.dart';
import 'view_attendance_records.dart';

class LecturerBody extends StatelessWidget {
  final String name;
  const LecturerBody({super.key, required this.name});

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      physics: const BouncingScrollPhysics(),
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 20.0, vertical: 25.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Welcome Title Section
            Text(
              "Welcome, $name!",
              style: const TextStyle(
                fontSize: 24, 
                fontWeight: FontWeight.bold, 
                color: Colors.black,
              ),
            ),
            const SizedBox(height: 15),

            // Search Bar
            Container(
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(30),
                border: Border.all(color: const Color(0xFFCBAAAA), width: 1.5), 
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withOpacity(0.03),
                    blurRadius: 10,
                    offset: const Offset(0, 4),
                  ),
                ],
              ),
              child: const TextField(
                decoration: InputDecoration(
                  hintText: 'Search',
                  hintStyle: TextStyle(color: Colors.grey),
                  prefixIcon: SizedBox(), 
                  suffixIcon: Icon(Icons.search, color: Colors.black54),
                  border: InputBorder.none,
                  contentPadding: EdgeInsets.symmetric(horizontal: 20, vertical: 15),
                ),
              ),
            ),
            const SizedBox(height: 25),

            // Categories Section Title
            const Text(
              "Categories",
              style: TextStyle(
                fontSize: 18, 
                fontWeight: FontWeight.bold, 
                color: Colors.black,
              ),
            ),
            const SizedBox(height: 15),

            // --- FIGMA FIXED MATCH: Deeper, High-Contrast Dark Pink Panel ---
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 18),
              decoration: BoxDecoration(
                color: const Color(0xFFDEC3C3), // Noticeably darker base pink background fill
                borderRadius: BorderRadius.circular(28), 
                border: Border.all(
                  color: const Color(0xFFCBAAAA), // Stronger matching border outline framing
                  width: 1.5,
                ),
              ),
              child: Row(
                children: [
                  Expanded(
                    child: _buildFigmaCategoryCard(
                      context,
                      imageAsset: 'assets/student_attendance_icon.png', 
                      fallbackIcon: Icons.calendar_month,
                      title: "Student Attendance",
                      iconColor: Colors.orange,
                      onTap: () {
                        Navigator.push(
                          context, 
                          MaterialPageRoute(builder: (context) => const AddAttendancePage()),
                        );
                      },
                    ),
                  ),
                  const SizedBox(width: 14),
                  Expanded(
                    child: _buildFigmaCategoryCard(
                      context,
                      imageAsset: 'assets/attendance_records_icon.png', 
                      fallbackIcon: Icons.assignment_turned_in_outlined,
                      title: "Attendance Records",
                      iconColor: Colors.purple,
                      onTap: () {
                        Navigator.push(
                          context, 
                          MaterialPageRoute(builder: (context) => const ViewAttendanceRecords()),
                        );
                      },
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 30),

            // Attendance Insights Section
            const Text(
              "Attendance Insights",
              style: TextStyle(
                fontSize: 18, 
                fontWeight: FontWeight.bold, 
                color: Colors.black,
              ),
            ),
            const SizedBox(height: 15),

            // Insights Graph Container
            Container(
              width: double.infinity,
              padding: const EdgeInsets.symmetric(vertical: 20, horizontal: 15),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(15),
                border: Border.all(color: const Color(0xFFCBAAAA), width: 1.5), 
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withOpacity(0.04),
                    blurRadius: 10,
                    offset: const Offset(0, 4),
                  ),
                ],
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  const Text(
                    "Student Attendance Rate",
                    style: TextStyle(
                      fontWeight: FontWeight.bold, 
                      fontSize: 14, 
                      color: Colors.black87,
                    ),
                  ),
                  const SizedBox(height: 15),
                  
                  Image.asset(
                    'assets/attendance_chart.png', 
                    height: 180,
                    fit: BoxFit.contain,
                    errorBuilder: (context, error, stackTrace) {
                      return Container(
                        height: 180,
                        color: Colors.grey.withOpacity(0.1),
                        child: const Center(
                          child: Icon(Icons.show_chart, size: 50, color: Colors.grey),
                        ),
                      );
                    },
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildFigmaCategoryCard(
    BuildContext context, {
    required String imageAsset,
    required IconData fallbackIcon,
    required String title,
    required Color iconColor,
    required VoidCallback onTap,
  }) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(18),
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 16, horizontal: 8),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(18),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.06),
              blurRadius: 8,
              offset: const Offset(0, 3), // Stronger clean drop pop over the dark container background background
            ),
          ],
        ),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Image.asset(
              imageAsset,
              height: 55, 
              width: 55,
              fit: BoxFit.contain,
              errorBuilder: (context, error, stackTrace) => Icon(
                fallbackIcon, 
                size: 42, 
                color: iconColor,
              ),
            ),
            const SizedBox(height: 10),
            Text(
              title,
              textAlign: TextAlign.center,
              style: const TextStyle(
                fontWeight: FontWeight.bold, 
                fontSize: 11.5, 
                color: Color(0xFF1E293B),
              ),
            ),
          ],
        ),
      ),
    );
  }
}