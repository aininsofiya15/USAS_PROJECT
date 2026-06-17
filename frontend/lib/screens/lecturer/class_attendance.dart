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
      final authProvider = Provider.of<UserProvider>(context, listen: false);
      final int? currentLecturerId = authProvider.userId;

      if (currentLecturerId != null) {
        Provider.of<AttendanceProvider>(context, listen: false)
            .fetchLecturerSubjects(currentLecturerId);
      } else {
        debugPrint("Error: No valid logged-in lecturer profile identified.");
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF3D8DA),
      appBar: const UsasHeader(),
      drawer: const AppSidebar(),
      bottomNavigationBar: const UsasBottomNav(),
      body: Consumer<AttendanceProvider>(
        builder: (context, provider, child) {
          if (provider.isLoading) {
            return const Center(child: CircularProgressIndicator());
          }

          if (provider.subjects.isEmpty) {
            return const Center(
              child: Text(
                "No assigned subjects or sections found.",
                style: TextStyle(fontSize: 14, color: Colors.black54, fontWeight: FontWeight.w500),
              ),
            );
          }

          // Group flat backend records by unique subject IDs
          final Map<int, List<Subject>> groupedSubjects = {};
          for (var s in provider.subjects) {
            groupedSubjects.putIfAbsent(s.subjectId, () => []).add(s);
          }

          return SingleChildScrollView(
            padding: const EdgeInsets.all(20.0),
            child: Column(
              children: [
                const Text(
                  "Attendance Panel",
                  style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold, color: Colors.black87),
                ),
                const SizedBox(height: 25),
                
                // Build subject cards dynamically
                ...groupedSubjects.entries.map((entry) {
                  final List<Subject> subjectSections = entry.value;
                  return _buildSubjectCard(subjectSections);
                }),
              ],
            ),
          );
        },
      ),
    );
  }

  Widget _buildSubjectCard(List<Subject> sections) {
    final firstSubject = sections.first;

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
          // Header Row for Subject Metadata
          Container(
            width: double.infinity,
            padding: const EdgeInsets.symmetric(vertical: 20, horizontal: 15),
            decoration: BoxDecoration(
              border: Border(bottom: BorderSide(color: Colors.grey.shade100)),
            ),
            child: Text(
              "${firstSubject.subjectCode} ${firstSubject.subjectName}".toUpperCase(),
              textAlign: TextAlign.center,
              style: const TextStyle(
                color: Color(0xFF3F51B5),
                fontWeight: FontWeight.bold,
                fontSize: 14,
                letterSpacing: 0.5,
              ),
            ),
          ),
          
          // Section interaction buttons
          Padding(
            padding: const EdgeInsets.all(15.0),
            child: Column(
              children: sections.map((sec) {
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
                              subjectName: sec.subjectName,
                              sectionNo: sec.sectionNo,
                              sectionId: sec.sectionId,
                            ),
                          ),
                        );
                      },
                      style: ElevatedButton.styleFrom(
                        backgroundColor: const Color(0xFF007BFF),
                        foregroundColor: Colors.white,
                        padding: const EdgeInsets.symmetric(vertical: 14),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(10),
                        ),
                        elevation: 0,
                      ),
                      child: Text(
                        "SECTION ${sec.sectionNo}",
                        style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 13, letterSpacing: 1.0),
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