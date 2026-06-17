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
    _loadLecturerData();
  }

  // Extracted core fetch routine for re-usability on pull-to-refresh action
  void _loadLecturerData() {
    WidgetsBinding.instance.addPostFrameCallback((_) {
      final authProvider = Provider.of<UserProvider>(context, listen: false);
      final int? currentLecturerId = authProvider.userId;

      if (currentLecturerId != null) {
        debugPrint("🔔 ATTEMPTING NETWORK FETCH FOR LECTURER ID: $currentLecturerId");
        debugPrint("💡 REMINDER: Ensure your backend uses the 10.0.2.2 endpoint inside Emulators rather than localhost/127.0.0.1!");
        
        Provider.of<AttendanceProvider>(context, listen: false)
            .fetchLecturerSubjects(currentLecturerId);
      } else {
        debugPrint("❌ Error: No valid logged-in lecturer profile identified.");
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
          // 1. Loading State
          if (provider.isLoading) {
            return const Center(child: CircularProgressIndicator());
          }

          // 2. Network/API Connection Failure Fallback
          // (Checks an error message property if you added one to your provider class)
          final bool hasNetworkError = provider.subjects.isEmpty && 
              (provider.toString().toLowerCase().contains('error') || 
               provider.toString().toLowerCase().contains('exception'));

          if (hasNetworkError) {
            return Center(
              child: Padding(
                padding: const EdgeInsets.all(25.0),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    const Icon(Icons.signal_cellular_connected_no_internet_4_bar, size: 50, color: Colors.redAccent),
                    const SizedBox(height: 15),
                    const Text(
                      "API Network Connection Failed",
                      style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: Colors.black87),
                    ),
                    const SizedBox(height: 8),
                    const Text(
                      "Could not communicate with the backend application. Verify that your Laravel service is actively running and that your base endpoint URL matches your local setup.",
                      textAlign: TextAlign.center,
                      style: TextStyle(fontSize: 13, color: Colors.black54),
                    ),
                    const SizedBox(height: 20),
                    ElevatedButton.icon(
                      onPressed: _loadLecturerData,
                      icon: const Icon(Icons.refresh),
                      label: const Text("Retry Connection"),
                      style: ElevatedButton.styleFrom(backgroundColor: const Color(0xFF007BFF), foregroundColor: Colors.white),
                    )
                  ],
                ),
              ),
            );
          }

          // 3. Database Evaluation Empty State
          if (provider.subjects.isEmpty) {
            return RefreshIndicator(
              onRefresh: () async => _loadLecturerData(),
              child: ListView(
                physics: const AlwaysScrollableScrollPhysics(), // Allows pull-to-refresh even when empty
                children: [
                  SizedBox(height: MediaQuery.of(context).size.height * 0.35),
                  const Center(
                    child: Padding(
                      padding: EdgeInsets.symmetric(horizontal: 20.0),
                      child: Text(
                        "No assigned subjects or sections found.",
                        textAlign: TextAlign.center,
                        style: TextStyle(fontSize: 14, color: Colors.black54, fontWeight: FontWeight.w500),
                      ),
                    ),
                  ),
                ],
              ),
            );
          }

          // 4. Content State (Group flat backend records by unique subject IDs)
          final Map<int, List<Subject>> groupedSubjects = {};
          for (var s in provider.subjects) {
            groupedSubjects.putIfAbsent(s.subjectId, () => []).add(s);
          }

          return RefreshIndicator(
            onRefresh: () async => _loadLecturerData(),
            child: SingleChildScrollView(
              physics: const AlwaysScrollableScrollPhysics(),
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