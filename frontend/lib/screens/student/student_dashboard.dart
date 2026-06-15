import 'package:USAS/screens/student/attendance_dashboard.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../widgets/header.dart'; 
import '../../widgets/navigation_bar.dart';
import '../../widgets/app_sidebar.dart';
import 'financial_info.dart';
import '../../provider/manage_fees_provider.dart'; // Ensure this matches your directory structures
import '../../provider/user_provider.dart';
import 'attendance_records.dart'; // IMPORT YOUR NEW HISTORICAL PAGE HERE
import 'subject_registration.dart';

class StudentDashboard extends StatefulWidget {
  final String name;
  const StudentDashboard({super.key, required this.name});

  @override
  State<StudentDashboard> createState() => _StudentDashboardState();
}

class _StudentDashboardState extends State<StudentDashboard> {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      final userId = Provider.of<UserProvider>(context, listen: false).userId;
      Provider.of<FeesManagementProvider>(context, listen: false)
          .fetchStudentPortalDashboardData(userId.toString());
    });
  }

  // Exact blueprint structural replication of the overlay warning dialog from image_89beba.png
  void _showAccessBlockedDialog(BuildContext context) {
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (BuildContext context) {
        return Dialog(
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
          child: Padding(
            padding: const EdgeInsets.all(20.0),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                const SizedBox(height: 10),
                const Icon(
                  Icons.do_not_disturb_on_rounded,
                  color: Colors.red,
                  size: 44,
                ),
                const SizedBox(height: 15),
                const Text(
                  "ACCESS BLOCKED",
                  style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold, letterSpacing: 0.5),
                ),
                const SizedBox(height: 15),
                const Text(
                  "Your academic access has been blocked due to unpaid tuition fees.",
                  textAlign: TextAlign.center,
                  style: TextStyle(fontSize: 13, color: Colors.black54, height: 1.4),
                ),
                const Text(
                  "You will be redirected to Tuition Fees page.",
                  textAlign: TextAlign.center,
                  style: TextStyle(fontSize: 13, color: Colors.black54, height: 1.4),
                ),
                const SizedBox(height: 20),
                SizedBox(
                  width: double.infinity,
                  height: 45,
                  child: ElevatedButton(
                    onPressed: () {
                      Navigator.pop(context); // Dismiss overlay route pop
                      Navigator.push(
                        context,
                        MaterialPageRoute(builder: (context) => const FinancialInfoPage()),
                      );
                    },
                    style: ElevatedButton.styleFrom(
                      backgroundColor: const Color(0xFF0066FF),
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                      elevation: 0,
                    ),
                    child: const Text(
                      "Go to Tuition Fees",
                      style: TextStyle(color: Colors.white, fontSize: 14, fontWeight: FontWeight.bold),
                    ),
                  ),
                ),
                const SizedBox(height: 5),
              ],
            ),
          ),
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF0F7FF), 
      appBar: const UsasHeader(),
      drawer: const AppSidebar(),
      bottomNavigationBar: const UsasBottomNav(),
      body: Consumer<FeesManagementProvider>(
        builder: (context, provider, child) {
          if (provider.isLoading) {
            return const Center(child: CircularProgressIndicator());
          }

          return SingleChildScrollView(
            padding: const EdgeInsets.all(20.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  "Welcome, ${widget.name}!",
                  style: const TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
                ),
                const SizedBox(height: 15),
                
                // Search Bar
                _buildSearchBar(),
                const SizedBox(height: 25),

                // FIXED: Passed context here to allow navigation from the header text action button
            _buildSectionTitle("Categories", context),
                const SizedBox(height: 10),

                // Categories Grid (2x2)
                GridView.count(
                  shrinkWrap: true,
                  physics: const NeverScrollableScrollPhysics(),
                  crossAxisCount: 2,
                  crossAxisSpacing: 15,
                  mainAxisSpacing: 15,
                  childAspectRatio: 1.1,
                  children: [
                    _buildCategoryCard(
                      "Subject Registration",
                      "assets/icons/sub_reg.png",
                      provider.studentIsBlocked,
                      () {
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (context) => const StudentSubjectRegistrationPage(),
                          ),
                        );
                      },
                    ),
                    _buildCategoryCard("Curriculum Activity", "assets/icons/curriculum.png", provider.studentIsBlocked, () {}),
                    _buildCategoryCard("Attendance", "assets/icons/attendance.png", provider.studentIsBlocked, () {
                      Navigator.push(context, MaterialPageRoute(builder: (context) => const AttendanceDashboard()));
                    
                }),
                    // Tuition Fees card stays false under block rules to allow student payments
                    _buildCategoryCard("Tuition Fees", "assets/icons/tuition.png", false, () {
                      Navigator.push(context, MaterialPageRoute(builder: (context) => const FinancialInfoPage()));
                    }),
                  ],
                ),

                const SizedBox(height: 30),
                _buildSectionTitle("Recent Updates", context),
                const SizedBox(height: 10),

                // Recent Updates Horizontal List
                SizedBox(
                  height: 180,
                  child: ListView(
                    scrollDirection: Axis.horizontal,
                    physics: const BouncingScrollPhysics(), 
                    children: [
                      _buildProgressCard("Curriculum Progress", provider.curriculumProgress),
                      _buildStatCard("Total Credit Current Sem", provider.totalCreditsCurrentSem.toString()),
                      _buildStatCard("Upcoming Due Date", provider.upcomingDueDateStr, isDate: true),
                      const SizedBox(width: 10), 
                    ],
                  ),
                ),
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

  // FIXED: Added BuildContext parameter to navigate straight to your history list view page
  Widget _buildSectionTitle(String title, BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(title, style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
        if (title == "Categories")
          TextButton(
            onPressed: () {
              // NAVIGATES TO ATTENDANCE RECORDS HISTORY PAGE
              Navigator.push(
                context, 
                MaterialPageRoute(builder: (context) => const AttendanceRecordsPage())
              );
            }, 
            child: const Text(
              "Attendance History", 
              style: TextStyle(color: Colors.green, fontWeight: FontWeight.bold)
            ),
          ),
      ],
    );
  }

  Widget _buildCategoryCard(String title, String iconPath, bool isBlocked, VoidCallback onTap) {
    return InkWell(
      onTap: () {
        if (isBlocked) {
          _showAccessBlockedDialog(context);
        } else {
          onTap();
        }
      },
      child: Container(
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(15),
          boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.05), blurRadius: 8)],
        ),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            title == "Subject Registration"
    ? Image.asset(
        iconPath,
        width: 100,
        height: 100,
      )
    : Icon(
        Icons.apps,
        size: 40,
        color: isBlocked ? Colors.grey : Colors.blue,
      ),
            const SizedBox(height: 8),
            Text(
              title, 
              textAlign: TextAlign.center, 
              style: TextStyle(
                fontSize: 12, 
                fontWeight: FontWeight.w600, 
                color: isBlocked ? Colors.grey : const Color(0xFF3F51B5),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildProgressCard(String title, double progress) {
    return Container(
      width: 150,
      margin: const EdgeInsets.only(right: 15),
      padding: const EdgeInsets.all(15),
      decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(15)),
      child: Column(
        children: [
          Text(title, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 12), textAlign: TextAlign.center),
          const Spacer(),
          Stack(
            alignment: Alignment.center,
            children: [
              CircularProgressIndicator(value: progress, strokeWidth: 8, backgroundColor: Colors.grey.shade200),
              Text("${(progress * 100).toInt()}%", style: const TextStyle(fontWeight: FontWeight.bold)),
            ],
          ),
          const Spacer(),
          ElevatedButton(
            onPressed: () {},
            style: ElevatedButton.styleFrom(backgroundColor: Colors.green, shape: const StadiumBorder(), padding: const EdgeInsets.symmetric(horizontal: 10)),
            child: const Text("Add Module", style: TextStyle(fontSize: 10, color: Colors.white)),
          )
        ],
      ),
    );
  }

  Widget _buildStatCard(String title, String value, {bool isDate = false}) {
    return Container(
      width: 150,
      margin: const EdgeInsets.only(right: 15),
      padding: const EdgeInsets.all(15),
      decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(15)),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Text(title, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 12), textAlign: TextAlign.center),
          const SizedBox(height: 20),
          Text(
            value, 
            style: TextStyle(
              fontSize: isDate ? 14 : 40, 
              fontWeight: FontWeight.bold,
            ), 
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );
  }
}
