import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../provider/attendance_provider.dart';
import '../../provider/user_provider.dart';
import '../../widgets/header.dart';
import '../../widgets/app_sidebar.dart';
import '../../widgets/navigation_bar.dart';
import 'student_dashboard.dart';



class AttendanceDashboard extends StatefulWidget {
  const AttendanceDashboard({super.key});

  @override
  State<AttendanceDashboard> createState() => _AttendanceDashboardState();
}

class _AttendanceDashboardState extends State<AttendanceDashboard> {
  @override
  void initState() {
    super.initState();
    // Fetch student data on load
    WidgetsBinding.instance.addPostFrameCallback((_) {
      final userId = Provider.of<UserProvider>(context, listen: false).userId;
      Provider.of<AttendanceProvider>(context, listen: false)
          .fetchStudentClassModule(userId.toString());
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFE3F2FD), // Light blue background
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

                // Search Bar
                _buildSearchBar(),
                const SizedBox(height: 25),

                // Curriculum Section
                const Text(
                  "Curriculum",
                  style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                ),
                const SizedBox(height: 15),
                provider.isLoading
                    ? const Center(child: CircularProgressIndicator())
                    : _buildCurriculumGrid(provider.studentCurriculum),

                const SizedBox(height: 30),

                // Co-Curriculum Section
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
        boxShadow: [
          BoxShadow(color: Colors.black.withOpacity(0.05), blurRadius: 10)
        ],
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
    if (subjects.isEmpty) {
      return const Text("No registered subjects found.");
    }

    return GridView.builder(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: 2,
        crossAxisSpacing: 15,
        mainAxisSpacing: 15,
        childAspectRatio: 0.9, // Adjust card height
      ),
      itemCount: subjects.length,
      itemBuilder: (context, index) {
        final subject = subjects[index];
        return Container(
          padding: const EdgeInsets.all(12),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(15),
            boxShadow: [BoxShadow(color: Colors.black12, blurRadius: 4)],
          ),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const Icon(Icons.code_rounded, size: 40, color: Colors.blue),
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
        );
      },
    );
  }

  Widget _buildCoCurriculumList(List<dynamic> modules) {
    if (modules.isEmpty) {
      return const Text("No registered co-curriculum modules found.");
    }

    return ListView.builder(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      itemCount: modules.length,
      itemBuilder: (context, index) {
        final module = modules[index];
        return Container(
          margin: const EdgeInsets.only(bottom: 15),
          padding: const EdgeInsets.all(20),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(20),
            boxShadow: [BoxShadow(color: Colors.black12, blurRadius: 4)],
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
                "Class Date: ${module['date_time']}",
                style: const TextStyle(fontSize: 12, color: Colors.black54),
              ),
              const SizedBox(height: 15),
              Align(
                alignment: Alignment.centerRight,
                child: ElevatedButton(
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color(0xFF007AFF),
                    shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(10)),
                    padding: const EdgeInsets.symmetric(horizontal: 20),
                  ),
                  onPressed: () {
                    // Navigate to Attendance Submission logic
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