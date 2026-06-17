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
                  prefixIcon: SizedBox(), // Keeps spacer layout clean
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

            // Horizontal Categories Cards Row
            Row(
              children: [
                Expanded(
                  child: _buildCategoryCard(
                    context,
                    imageAsset: 'assets/student_attendance_icon.png', // Update with your local image asset path
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
                const SizedBox(width: 15),
                Expanded(
                  child: _buildCategoryCard(
                    context,
                    imageAsset: 'assets/attendance_records_icon.png', // Update with your local image asset path
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
              padding: const EdgeInsets.all(15),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(15),
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
                  const SizedBox(height: 10),
                  // Displays your analytical chart graphic asset
                  Image.asset(
                    'assets/attendance_chart.png', // Update with your chart image asset path
                    height: 180,
                    fit: BoxFit.contain,
                    errorBuilder: (context, error, stackTrace) {
                      // Fallback placeholder widget if chart asset is unlinked
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

  // Helper builder for custom rounded Category Selection layout panels
  Widget _buildCategoryCard(
    BuildContext context, {
    required String imageAsset,
    required IconData fallbackIcon,
    required String title,
    required Color iconColor,
    required VoidCallback onTap,
  }) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(20),
      child: Container(
        padding: const EdgeInsets.all(15),
        decoration: BoxDecoration(
          color: const Color(0xFFFFEAEA), // Light tinted background context layout accent
          borderRadius: BorderRadius.circular(20),
          border: Border.all(color: Colors.black.withOpacity(0.05)),
        ),
        child: Container(
          padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 8),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(15),
          ),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Image.asset(
                imageAsset,
                height: 45,
                errorBuilder: (context, error, stackTrace) => Icon(
                  fallbackIcon, 
                  size: 40, 
                  color: iconColor,
                ),
              ),
              const SizedBox(height: 10),
              Text(
                title,
                textAlign: TextAlign.center,
                style: const TextStyle(
                  fontWeight: FontWeight.w600, 
                  fontSize: 13, 
                  color: Color(0xFF1E293B),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}