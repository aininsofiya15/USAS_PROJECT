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

  void _loadLecturerData() {
    WidgetsBinding.instance.addPostFrameCallback((_) {
      final authProvider = Provider.of<UserProvider>(context, listen: false);
      final int? currentLecturerId = authProvider.userId;

      if (currentLecturerId != null) {
        debugPrint("🔔 ATTEMPTING NETWORK FETCH FOR LECTURER ID: $currentLecturerId");
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
      backgroundColor: const Color(0xFFFDF2F2), 
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
                      "Could not communicate with the backend application. Verify that your Laravel service is actively running.",
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
                physics: const AlwaysScrollableScrollPhysics(),
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

          // 4. Content State
          final Map<int, List<Subject>> groupedSubjects = {};
          for (var s in provider.subjects) {
            groupedSubjects.putIfAbsent(s.subjectId, () => []).add(s);
          }

          return RefreshIndicator(
            onRefresh: () async => _loadLecturerData(),
            child: SingleChildScrollView(
              physics: const AlwaysScrollableScrollPhysics(),
              padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 20.0),
              child: Column(
                children: [
                  // Main Content Panel enclosing everything up to the Attendance Header title
                  Container(
                    width: double.infinity,
                    padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 24.0),
                    decoration: BoxDecoration(
                      color: const Color(0xFFDEC3C3), // Darker pink background fill
                      borderRadius: BorderRadius.circular(24),
                      border: null, // No outer border line outline
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.center,
                      children: [
                        // Title now inside the pink background container
                        const Text(
                          "Attendance",
                          style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold, color: Colors.black),
                        ),
                        const SizedBox(height: 20),

                        // Semester details text row layout now inside the pink container
                        Padding(
                          padding: const EdgeInsets.symmetric(horizontal: 12.0),
                          child: Row(
                            children: const [
                              Text(
                                "Semester:",
                                style: TextStyle(fontSize: 15, fontWeight: FontWeight.bold, color: Colors.black),
                              ),
                              SizedBox(width: 20),
                              Text(
                                "252026 SEM II",
                                style: TextStyle(fontSize: 15, fontWeight: FontWeight.bold, color: Colors.black),
                              ),
                            ],
                          ),
                        ),
                        const SizedBox(height: 25),

                        // Dynamic generation of inside white subject cards
                        ...groupedSubjects.entries.map((entry) {
                          final List<Subject> subjectSections = entry.value;
                          return _buildSubjectCard(subjectSections);
                        }),
                      ],
                    ),
                  ),
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
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 6,
            offset: const Offset(0, 3),
          )
        ],
      ),
      child: Column(
        children: [
          Container(
            width: double.infinity,
            padding: const EdgeInsets.symmetric(vertical: 20, horizontal: 14),
            alignment: Alignment.center,
            child: Text(
              "${firstSubject.subjectCode} ${firstSubject.subjectName}".toUpperCase(),
              textAlign: TextAlign.center,
              style: const TextStyle(
                color: Color(0xFF3F51B5), 
                fontWeight: FontWeight.w800, // Clean extra bold text
                fontSize: 16.0,              // Clear large subject font text size
                letterSpacing: 0.5,
              ),
            ),
          ),
          const Divider(height: 1, color: Color(0xFFEEEEEE)),
          
          Padding(
            padding: const EdgeInsets.all(14.0),
            child: Column(
              children: sections.map((sec) {
                return Padding(
                  padding: const EdgeInsets.only(bottom: 8.0),
                  child: SizedBox(
                    width: double.infinity,
                    height: 42,
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
                        backgroundColor: const Color(0xFF007AFF), 
                        foregroundColor: Colors.white,
                        elevation: 2,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(10),
                        ),
                      ),
                      child: Text(
                        "${sec.sectionNo}",
                        style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 13, letterSpacing: 0.5),
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