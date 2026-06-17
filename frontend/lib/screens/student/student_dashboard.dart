import 'package:USAS/screens/student/attendance_dashboard.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../widgets/header.dart';
import '../../widgets/navigation_bar.dart';
import '../../widgets/app_sidebar.dart';
import 'financial_info.dart';
import '../../provider/manage_fees_provider.dart';
import '../../provider/module_provider.dart';
import '../../provider/student_subject_provider.dart';
import '../../provider/user_provider.dart';
import 'attendance_records.dart';
import 'module_booking.dart';
import 'subject_registration.dart';

// Student dashboard main page
class StudentDashboard extends StatefulWidget {
   // Logged-in student name
  final String name;
  const StudentDashboard({super.key, required this.name});

  @override
  State<StudentDashboard> createState() => _StudentDashboardState();
}

class _StudentDashboardState extends State<StudentDashboard> {
  final StudentSubjectProvider _studentSubjectProvider = StudentSubjectProvider();
  int _registeredSubjectCredits = 0;

  @override
  void initState() {

     // Load dashboard data after page is rendered
    super.initState();

    // Retrieve dashboard information
    WidgetsBinding.instance.addPostFrameCallback((_) {
      final userId = Provider.of<UserProvider>(context, listen: false).userId;
      final feesProvider = Provider.of<FeesManagementProvider>(context, listen: false);
      feesProvider.fetchBlockDate();
      feesProvider.fetchStudentPortalDashboardData(userId.toString());
      Provider.of<ModuleProvider>(context, listen: false)
          .fetchStudentBookings(userId.toString());
      _loadRegisteredSubjectCredits(userId);
    });
  }

  Future<void> _loadRegisteredSubjectCredits(int userId) async {
    try {
      final subjects = await _studentSubjectProvider.fetchRegisteredSubjects(userId);
      final totalCredit = subjects.fold<int>(
        0,
        (sum, subject) => sum + subject.creditHours,
      );

      if (!mounted) return;
      setState(() => _registeredSubjectCredits = totalCredit);
    } catch (e) {
      debugPrint("Failed to load registered subject credits: $e");
    }
  }

// Display access blocked dialog for students with unpaid fees
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
                const Icon(Icons.do_not_disturb_on_rounded, color: Colors.red, size: 44),
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
                      Navigator.pop(context);
                      Navigator.push(context,
                          MaterialPageRoute(builder: (_) => const FinancialInfoPage()));
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
      // Listen for dashboard updates
      body: Consumer<FeesManagementProvider>(
        builder: (context, provider, child) {
          // Show loading indicator while data is loading
          if (provider.isLoading) {
            return const Center(child: CircularProgressIndicator());
          }

          final moduleProvider = Provider.of<ModuleProvider>(context);
          final claimedModules = moduleProvider.bookedModules
              .where((module) => module.isClaimed == 1)
              .length;
          final curriculumProgress = (claimedModules / 4).clamp(0.0, 1.0).toDouble();

          return SingleChildScrollView(
            physics: const BouncingScrollPhysics(),
            padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 18),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // ── Welcome ──
                Text(
                  "Welcome, ${widget.name}!",
                  style: const TextStyle(
                      fontSize: 22, fontWeight: FontWeight.bold, color: Colors.black87),
                ),
                const SizedBox(height: 12),

                // ── Search Bar ──
                _buildSearchBar(),
                const SizedBox(height: 20),

                // ── Categories Header ──
                _buildSectionTitle("Categories", context),
                const SizedBox(height: 10),

                // ── Categories Grid ──
                Container(
                  padding: const EdgeInsets.fromLTRB(10, 14, 10, 10),
                  decoration: BoxDecoration(
                    color: const Color(0xFFBBD6FF),
                    borderRadius: BorderRadius.circular(22),
                  ),
                  child: GridView.count(
                    shrinkWrap: true,
                    physics: const NeverScrollableScrollPhysics(),
                    crossAxisCount: 2,
                    crossAxisSpacing: 10,
                    mainAxisSpacing: 10,
                    childAspectRatio: 1.5,
                    children: [
                      _buildCategoryCard(
                        "Subject Registration",
                        "assets/icons/sub_reg.png",
                        provider.studentIsBlocked,
                        () => Navigator.push(context,
                            MaterialPageRoute(builder: (_) => const StudentSubjectRegistrationPage())),
                      ),
                      _buildCategoryCard(
                        "Curriculum Activity",
                        "assets/icons/curriculum.png",
                        provider.studentIsBlocked,
                        () => Navigator.push(context,
                            MaterialPageRoute(builder: (_) => const StudentActivitiesPage())),
                      ),
                      _buildCategoryCard(
                        "Attendance",
                        "assets/icons/attendance.png",
                        provider.studentIsBlocked,
                        () => Navigator.push(context,
                            MaterialPageRoute(builder: (_) => const AttendanceDashboard())),
                      ),
                      _buildCategoryCard(
                        "Tuition Fees",
                        "assets/icons/tuition.png",
                        false,
                        () => Navigator.push(context,
                            MaterialPageRoute(builder: (_) => const FinancialInfoPage())),
                      ),
                    ],
                  ),
                ),

                const SizedBox(height: 24),

                // ── Recent Updates Header ──
                _buildSectionTitle("Recent Updates", context),
                const SizedBox(height: 10),

                // ── Recent Updates Row ──
                SizedBox(
                  height: 235,
                  child: ListView(
                    scrollDirection: Axis.horizontal,
                    physics: const BouncingScrollPhysics(),
                    children: [
                      _buildProgressCard("Curriculum Progress", curriculumProgress),
                      _buildStatCard(
                          "Total Credit\nCurrent Sem",
                          _registeredSubjectCredits.toString()),
                      _buildUpcomingDueDateCard(provider.upcomingDueDateStr), // ✅ Use new method
                    ],
                  ),
                ),
                
                const SizedBox(height: 16),
              ],
            ),
          );
        },
      ),
    );
  }

  Widget _buildUpcomingDueDateCard(String value) {
    return Container(
      width: 155,
      margin: const EdgeInsets.only(right: 12),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(18),
        border: Border.all(color: Colors.black.withOpacity(0.07), width: 0.5),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          Padding(
            padding: const EdgeInsets.fromLTRB(12, 14, 12, 0),
            child: const Text(
              "Upcoming\nDue Date",
              style: TextStyle(
                fontWeight: FontWeight.w600,
                fontSize: 12,
                color: Colors.black87,
              ),
              textAlign: TextAlign.center,
            ),
          ),
          const Padding(
            padding: EdgeInsets.symmetric(horizontal: 12, vertical: 8),
            child: Divider(thickness: 0.5, height: 1, color: Color(0x22000000)),
          ),
          Expanded(
            child: Center(
              child: Text(
                value,
                style: const TextStyle(
                  fontSize: 15,
                  fontWeight: FontWeight.w700,
                  color: Color(0xFF1565C0),
                  height: 1.2,
                ),
                textAlign: TextAlign.center,
              ),
            ),
          ),
        ],
      ),
    );
  }

  // ── Search Bar ──────────────────────────────────────────────────────────
  Widget _buildSearchBar() {
    return Center(
      child: FractionallySizedBox(
        widthFactor: 0.74,
        child: Container(
          height: 36,
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(30),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withOpacity(0.06),
                blurRadius: 8,
                offset: const Offset(0, 2),
              ),
            ],
          ),
          child: const TextField(
            style: TextStyle(fontSize: 13, color: Colors.black87),
            decoration: InputDecoration(
              hintText: "Search",
              hintStyle: TextStyle(color: Colors.black38, fontSize: 13),
              suffixIcon: Icon(Icons.search, color: Colors.black45, size: 19),
              suffixIconConstraints: BoxConstraints(minWidth: 42, minHeight: 36),
              isDense: true,
              border: InputBorder.none,
              contentPadding: EdgeInsets.fromLTRB(18, 10, 0, 10),
            ),
          ),
        ),
      ),
    );
  }

  // ── Section Title ───────────────────────────────────────────────────────
  Widget _buildSectionTitle(String title, BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(title,
            style: const TextStyle(
                fontSize: 19, fontWeight: FontWeight.bold, color: Colors.black87)),
        if (title == "Categories")
          TextButton(
            onPressed: () => Navigator.push(context,
                MaterialPageRoute(builder: (_) => const AttendanceRecordsPage())),
            child: const Text("Attendance History",
                style: TextStyle(
                    color: Colors.green, fontWeight: FontWeight.bold, fontSize: 12)),
          ),
      ],
    );
  }

  // ── Category Card ───────────────────────────────────────────────────────
  Widget _buildCategoryCard(
      String title, String iconPath, bool isBlocked, VoidCallback onTap) {
    return InkWell(
      onTap: () => isBlocked ? _showAccessBlockedDialog(context) : onTap(),
      borderRadius: BorderRadius.circular(14),
      child: Container(
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(14),
          boxShadow: [
            BoxShadow(
                color: Colors.black.withOpacity(0.04),
                blurRadius: 6,
                offset: const Offset(0, 2))
          ],
        ),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Image.asset(
              iconPath,
              width: 70,
              height: 70,
              errorBuilder: (_, error, ___) {
                debugPrint('Failed to load icon: $iconPath — $error');
                return Icon(
                  Icons.apps,
                  size: 40,
                  color: isBlocked ? Colors.grey : const Color(0xFF3F51B5),
                );
              },
            ),
            const SizedBox(height: 6),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 6),
              child: Text(
                title,
                textAlign: TextAlign.center,
                style: TextStyle(
                  fontSize: 11,
                  fontWeight: FontWeight.w600,
                  color: isBlocked ? Colors.grey : const Color(0xFF1565C0),
                  height: 1.2,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  // ── Progress Card ───────────────────────────────────────────────────────
  Widget _buildProgressCard(String title, double progress) {
    final int percent = (progress * 100).toInt();
    final bool isComplete = percent >= 100;
    final Color progressColor =
        isComplete ? const Color(0xFF1565C0) : const Color(0xFF2196F3);

    return Container(
      width: 155,
      margin: const EdgeInsets.only(right: 12),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(18),
        border: Border.all(color: Colors.black.withOpacity(0.07), width: 0.5),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          Padding(
            padding: const EdgeInsets.fromLTRB(12, 14, 12, 0),
            child: Text(
              title,
              style: const TextStyle(
                  fontWeight: FontWeight.w600, fontSize: 12, color: Colors.black87),
              textAlign: TextAlign.center,
            ),
          ),
          const Padding(
            padding: EdgeInsets.symmetric(horizontal: 12, vertical: 8),
            child: Divider(thickness: 0.5, height: 1, color: Color(0x22000000)),
          ),
          Expanded(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Stack(
                  alignment: Alignment.center,
                  children: [
                    SizedBox(
                      width: 84,
                      height: 84,
                      child: CircularProgressIndicator(
                        value: 1.0,
                        strokeWidth: 9,
                        valueColor: AlwaysStoppedAnimation<Color>(
                            progressColor.withOpacity(0.15)),
                      ),
                    ),
                    SizedBox(
                      width: 84,
                      height: 84,
                      child: CircularProgressIndicator(
                        value: progress,
                        strokeWidth: 9,
                        strokeCap: StrokeCap.round,
                        backgroundColor: Colors.transparent,
                        valueColor: AlwaysStoppedAnimation<Color>(progressColor),
                      ),
                    ),
                    Text(
                      "$percent%",
                      style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.w700,
                        color: progressColor,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 10),
                if (!isComplete)
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 14),
                    child: SizedBox(
                      width: double.infinity,
                      height: 30,
                      child: ElevatedButton(
                        onPressed: () => Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (_) => const StudentActivitiesPage(),
                          ),
                        ),
                        style: ElevatedButton.styleFrom(
                          backgroundColor: const Color(0xFF2196F3),
                          elevation: 0,
                          padding: EdgeInsets.zero,
                          shape: const StadiumBorder(),
                        ),
                        child: const Text(
                          "Add Module",
                          style: TextStyle(
                              fontSize: 10,
                              color: Colors.white,
                              fontWeight: FontWeight.w600),
                        ),
                      ),
                    ),
                  )
                else
                  const Text(
                    "Completed!",
                    style: TextStyle(
                        fontSize: 11,
                        color: Color(0xFF2196F3),
                        fontWeight: FontWeight.bold),
                  ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  // ── Stat Card ───────────────────────────────────────────────────────────
  Widget _buildStatCard(String title, String value, {bool isDate = false}) {
    return Container(
      width: 155,
      margin: const EdgeInsets.only(right: 12),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(18),
        border: Border.all(color: Colors.black.withOpacity(0.07), width: 0.5),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          Padding(
            padding: const EdgeInsets.fromLTRB(12, 14, 12, 0),
            child: Text(
              title,
              style: const TextStyle(
                  fontWeight: FontWeight.w600, fontSize: 12, color: Colors.black87),
              textAlign: TextAlign.center,
            ),
          ),
          const Padding(
            padding: EdgeInsets.symmetric(horizontal: 12, vertical: 8),
            child: Divider(thickness: 0.5, height: 1, color: Color(0x22000000)),
          ),
          Expanded(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                if (isDate)
                  const Icon(Icons.calendar_today_rounded,
                      size: 28, color: Color(0xFF1565C0)),
                if (isDate) const SizedBox(height: 8),
                Text(
                  value,
                  style: TextStyle(
                    fontSize: isDate ? 15 : 46,
                    fontWeight: FontWeight.w700,
                    color: const Color(0xFF1565C0),
                    height: 1.0,
                  ),
                  textAlign: TextAlign.center,
                ),
                if (!isDate) ...[
                  const SizedBox(height: 4),
                  const Text(
                    "credits enrolled",
                    style: TextStyle(fontSize: 11, color: Colors.black38),
                  ),
                ],
              ],
            ),
          ),
        ],
      ),
    );
  }
}
