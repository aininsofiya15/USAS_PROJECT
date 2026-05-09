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
    // FORCE TEST ID 1
    Provider.of<AttendanceProvider>(context, listen: false).fetchLecturerSubjects(1);
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
            return const Center(child: Text("No assigned subjects found."));
          }

          // FIX: Group the flat subjects into a Map so we can show 1 Card per Subject
          final Map<int, List<Subject>> groupedSubjects = {};
          for (var s in provider.subjects) {
            groupedSubjects.putIfAbsent(s.subjectId, () => []).add(s);
          }

          return SingleChildScrollView(
            padding: const EdgeInsets.all(20.0),
            child: Column(
              children: [
                const Text(
                  "Attendance",
                  style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold),
                ),
                const SizedBox(height: 25),
                
                // Use the entries of the grouped Map to build cards
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

  // FIX: This now accepts a List of Subject objects (all belonging to the same ID)
  Widget _buildSubjectCard(List<Subject> sections) {
    final first = sections.first;

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
          Container(
            width: double.infinity,
            padding: const EdgeInsets.symmetric(vertical: 20, horizontal: 15),
            decoration: BoxDecoration(
              border: Border(bottom: BorderSide(color: Colors.grey.shade100)),
            ),
            child: Text(
              "${first.subjectCode} ${first.subjectName}",
              textAlign: TextAlign.center,
              style: const TextStyle(
                color: Color(0xFF3F51B5),
                fontWeight: FontWeight.bold,
                fontSize: 14,
              ),
            ),
          ),
          
          Padding(
            padding: const EdgeInsets.all(15.0),
            child: Column(
              // FIX: We map the 'sections' list we created in the build method
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
                        padding: const EdgeInsets.symmetric(vertical: 12),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(10),
                        ),
                        elevation: 0,
                      ),
                      child: Text(
                        "SECTION ${sec.sectionNo}",
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