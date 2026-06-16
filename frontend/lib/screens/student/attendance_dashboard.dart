import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../provider/attendance_provider.dart';
import '../../provider/user_provider.dart';
import '../../widgets/header.dart';
import '../../widgets/app_sidebar.dart';
import '../../widgets/navigation_bar.dart';
import 'attendance_list.dart';
import 'attendance_submission.dart';

class AttendanceDashboard extends StatefulWidget {
  const AttendanceDashboard({super.key});

  @override
  State<AttendanceDashboard> createState() => _AttendanceDashboardState();
}

class _AttendanceDashboardState extends State<AttendanceDashboard> {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      final userId = Provider.of<UserProvider>(context, listen: false).userId;
      Provider.of<AttendanceProvider>(context, listen: false)
          .fetchStudentClassModule(userId.toString());
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFE3F2FD),
      appBar: const UsasHeader(),
      drawer: const AppSidebar(),
      bottomNavigationBar: const UsasBottomNav(),
      body: Consumer<AttendanceProvider>(
        builder: (context, provider, child) {
          return SingleChildScrollView(
            padding: const EdgeInsets.all(20.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Center(
                  child: Text(
                    "Attendance",
                    style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold),
                  ),
                ),
                const SizedBox(height: 20),
                _buildSearchBar(),
                const SizedBox(height: 25),
                const Text(
                  "Curriculum",
                  style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                ),
                const SizedBox(height: 15),
                provider.isLoading
                    ? const Center(child: CircularProgressIndicator())
                    : _buildCurriculumGrid(provider.studentCurriculum),
                const SizedBox(height: 30),
                const Text(
                  "Co-Curriculum",
                  style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                ),
                const SizedBox(height: 15),
                provider.isLoading
                    ? const Center(child: CircularProgressIndicator())
                    : _buildCoCurriculumList(provider.studentCoCurriculum),
              ],
            ),
          );
        },
      ),
    );
  }

  Widget _buildSearchBar() {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(30),
        boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.05), blurRadius: 10)],
      ),
      child: const TextField(
        decoration: InputDecoration(
          hintText: "Search",
          prefixIcon: Icon(Icons.search),
          border: InputBorder.none,
          contentPadding: EdgeInsets.symmetric(vertical: 15),
        ),
      ),
    );
  }

  Widget _buildCurriculumGrid(List<dynamic> subjects) {
    if (subjects.isEmpty) return const Text("No registered subjects found.");

    return GridView.builder(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: 2,
        crossAxisSpacing: 15,
        mainAxisSpacing: 15,
        childAspectRatio: 0.9,
      ),
      itemCount: subjects.length,
      itemBuilder: (context, index) {
        final subject = subjects[index];
        return InkWell(
          onTap: () {
            int sectionId = int.tryParse(subject['section_id'].toString()) ?? 0;
            Navigator.push(
              context,
              MaterialPageRoute(
                builder: (context) => AttendanceListPage(
                  sectionId: sectionId,
                  subjectCode: subject['subject_code'] ?? 'N/A',
                  subjectName: subject['subject_name'] ?? 'N/A',
                ),
              ),
            );
          },
          child: Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(15),
              boxShadow: [BoxShadow(color: Colors.black12, blurRadius: 4)],
            ),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                const Icon(Icons.computer, size: 40, color: Colors.blue),
                const SizedBox(height: 10),
                Text(
                  subject['subject_code'] ?? "",
                  textAlign: TextAlign.center,
                  style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 11),
                ),
                const SizedBox(height: 4),
                Text(
                  subject['subject_name'] ?? "",
                  textAlign: TextAlign.center,
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                  style: const TextStyle(fontSize: 10, color: Colors.black87),
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  Widget _buildCoCurriculumList(List<dynamic> modules) {
    if (modules.isEmpty) return const Text("No registered co-curriculum modules found.");

    return ListView.builder(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      itemCount: modules.length,
      itemBuilder: (context, index) {
        final module = modules[index];

        // Debug logger to trace your DB response keys
        debugPrint("📊 DASHBOARD CO-CURRICULUM ROW: $module");

        return Container(
          margin: const EdgeInsets.only(bottom: 15),
          padding: const EdgeInsets.all(20),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(20),
            boxShadow: const [BoxShadow(color: Colors.black12, blurRadius: 4)],
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                module['activity_name']?.toString().toUpperCase() ?? "",
                style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 14),
              ),
              const SizedBox(height: 8),
              Text(
                "Class Date: ${module['date_time'] ?? 'N/A'}",
                style: const TextStyle(fontSize: 12, color: Colors.black54),
              ),
              const SizedBox(height: 15),
              Align(
                alignment: Alignment.centerRight,
                child: ElevatedButton(
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color(0xFF007AFF),
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                  ),
                  onPressed: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) => AttendanceSubmissionPage(
                          sessionData: {
                            'id': module['id'],
                            'session_id': module['session_id'],
                            'attendance_id': module['attendance_id'] ?? module['id'] ?? module['session_id'] ?? 0,
                            'date': module['date'] ?? module['date_time'] ?? 'N/A',
                            'time': module['time'] ?? '', 
                            'venue': module['venue'] ?? module['location_name'] ?? 'N/A',
                            'lecturer_name': module['lecturer_name'] ?? module['instructor_name'] ?? module['lecturer'] ?? 'N/A',
                            'enrolled': module['enrolled'] ?? '0',
                            'capacity': module['capacity'] ?? '60',
                            'activity_name': module['activity_name'],
                          },
                          sectionId: int.tryParse(module['module_id']?.toString() ?? '0') ?? 0,
                          subjectCode: module['module_code'] ?? 'CO-CURR',
                          subjectName: module['activity_name'] ?? 'Unknown Activity',
                          isCoCurriculum: true, // Forces layout switch
                        ),
                      ),
                    );
                  },
                  child: const Text(
                    "Submit Attendance",
                    style: TextStyle(color: Colors.white, fontSize: 11),
                  ),
                ),
              )
            ],
          ),
        );
      },
    );
  }
}