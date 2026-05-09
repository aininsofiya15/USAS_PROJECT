import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../widgets/header.dart';
import '../../widgets/navigation_bar.dart';
import '../../widgets/app_sidebar.dart';
import '../../provider/user_provider.dart'; 
import '../../provider/attendance_provider.dart';
import '../../domain/attendance.dart';
import 'generate_attendance_code.dart';

class AddAttendancePage extends StatefulWidget {
  const AddAttendancePage({super.key});

  @override
  State<AddAttendancePage> createState() => _AddAttendancePageState();
}

class _AddAttendancePageState extends State<AddAttendancePage> {
  @override
  void initState() {
    super.initState();
    
    WidgetsBinding.instance.addPostFrameCallback((_) {
      // 1. Get the current logged-in user from your Auth/User Provider
      final authProvider = Provider.of<UserProvider>(context, listen: false);
      final int? currentLecturerId = authProvider.user?.id;

      // 2. Pass that dynamic ID to the fetch function
      if (currentLecturerId != null) {
        Provider.of<AttendanceProvider>(context, listen: false)
            .fetchLecturerSubjects(currentLecturerId);
      } else {
        debugPrint("Error: No logged-in user found.");
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF3D8DA), // Matches the pastel pink in your image
      appBar: const UsasHeader(),
      drawer: const AppSidebar(),
      bottomNavigationBar: const UsasBottomNav(),
      body: Consumer<AttendanceProvider>(
        builder: (context, provider, child) {
          if (provider.isLoading) {
            return const Center(child: CircularProgressIndicator());
          }

          if (provider.subjects.isEmpty) {
            return const Center(child: Text("No assigned subjects found."));
          }

          return SingleChildScrollView(
            padding: const EdgeInsets.all(20.0),
            child: Column(
              children: [
                const Text(
                  "Attendance",
                  style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold),
                ),
                const SizedBox(height: 10),
                const Text(
                  "Semester:  252026 SEM II",
                  style: TextStyle(fontSize: 16, fontWeight: FontWeight.w600),
                ),
                const SizedBox(height: 25),
                
                // Generates a Card for every Subject in your DB
                ...provider.subjects.map((subject) => _buildSubjectCard(subject)),
              ],
            ),
          );
        },
      ),
    );
  }

  Widget _buildSubjectCard(AttendanceSubject subject) {
    return Container(
      margin: const EdgeInsets.only(bottom: 20),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(15),
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
          // Header: Subject Code & Name
          Container(
            width: double.infinity,
            padding: const EdgeInsets.symmetric(vertical: 20, horizontal: 15),
            decoration: BoxDecoration(
              border: Border(bottom: BorderSide(color: Colors.grey.shade100)),
            ),
            child: Text(
              "${subject.subjectCode} ${subject.subjectName}",
              textAlign: TextAlign.center,
              style: const TextStyle(
                color: Color(0xFF3F51B5), // Indigo blue text
                fontWeight: FontWeight.bold,
                fontSize: 14,
              ),
            ),
          ),
          
          // Section Buttons
          Padding(
            padding: const EdgeInsets.all(15.0),
            child: Column(
              children: subject.sections.map((section) {
                return Padding(
                  padding: const EdgeInsets.only(bottom: 10),
                  child: SizedBox(
                    width: double.infinity,
                    child: ElevatedButton(
                      onPressed: () {
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (context) => GenerateAttendanceCode(
                              subjectName: subject.subjectName,
                              sectionNo: section.sectionNo,
                              sectionId: section.sectionId,
                            ),
                          ),
                        );
                      },
                      style: ElevatedButton.styleFrom(
                        backgroundColor: const Color(0xFF007BFF), // Bright blue
                        foregroundColor: Colors.white,
                        padding: const EdgeInsets.symmetric(vertical: 12),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(10),
                        ),
                        elevation: 0,
                      ),
                      child: Text(
                        "SECTION ${section.sectionNo.split('-').last}", // Displays "01", "02" etc
                        style: const TextStyle(fontWeight: FontWeight.bold),
                      ),
                    ),
                  ),
                );
              }).toList(),
            ),
          ),
        ],
      ),
    );
  }
}