import 'package:USAS/screens/dashboard.dart';
import 'package:USAS/screens/student/attendance_dashboard.dart';
import 'package:flutter/material.dart';
import '../screens/pusatAdab/module_form.dart';
import '../screens/pusatAdab/view_module.dart';
import 'package:provider/provider.dart';
import '../provider/user_provider.dart';
import '../screens/student/module_booking.dart';
import 'package:USAS/screens/faculty/subject_registration_page.dart';
import '../screens/student/my_module_booking.dart';
import '../screens/pusatAdab/attendance_record_list.dart';
import '../screens/pusatAdab/module_attendance.dart';
import '../screens/pusatAdab/attendance_for_module.dart';
import '../screens/student/student_dashboard.dart';
import '../screens/student/subject_registration.dart';
import '../screens/student/credit_claim_status.dart';
import '../screens/pusatAdab/credit_application.dart';
import 'package:USAS/screens/faculty/subject_form_page.dart';
import '../screens/student/list_registered_subjects.dart';
import '../screens/student/financial_info.dart'; // ✅ Used for Tuition Fees
import '../screens/payment_history.dart'; // ✅ Used for Payment History

class AppSidebar extends StatelessWidget {
  const AppSidebar({super.key});

  // 🎨 Sidebar Main Body Color
  Color getSidebarColor(String role) {
    switch (role) {
      case 'treasury':  return const Color(0xFF11B754);
      case 'faculty':   return const Color(0xFFD4AF00);
      case 'lecturer':  return const Color(0xFFC8908D);
      case 'pusat_adab': return const Color(0xFFD5FFF7);
      default:          return const Color(0xFF007BFF);
    }
  }

  // 🎨 Sidebar Header Color
  Color getSidebarHeaderColor(String role) {
    switch (role) {
      case 'treasury':  return const Color(0xFF0E9A46);
      case 'faculty':   return const Color(0xFFB89800);
      case 'lecturer':  return const Color(0xFFB57A77);
      case 'pusat_adab': return const Color(0xFFB2EBF2);
      default:          return const Color(0xFF0056D2);
    }
  }

  // 🎨 Text and Icon Color
  Color getTextColor(String role) {
    return (role == 'pusat_adab' || role == 'lecturer') ? Colors.black : Colors.white;
  }

  // Divider color per role
  Color getDividerColor(String role) {
    return (role == 'pusat_adab' || role == 'lecturer')
        ? Colors.black26
        : const Color.fromARGB(100, 255, 255, 255);
  }

  @override
  Widget build(BuildContext context) {
    final user = Provider.of<UserProvider>(context);
    final String name = user.name;
    final String role = user.role;

    return Drawer(
      child: Container(
        color: getSidebarColor(role),
        child: Column(
          children: [
            // ── Profile Header ──────────────────────────────────────
            DrawerHeader(
              margin: EdgeInsets.zero,
              padding: EdgeInsets.zero,
              decoration: BoxDecoration(
                color: getSidebarHeaderColor(role),
                border: const Border(bottom: BorderSide(color: Colors.transparent)),
              ),
              child: Stack(
                children: [
                  // 🔔 Notification button — shown for ALL roles
                  Positioned(
                    top: 8,
                    right: 8,
                    child: IconButton(
                      icon: Icon(Icons.notifications_outlined,
                          color: getTextColor(role)),
                      onPressed: () {
                        Navigator.pop(context);
                        Navigator.pushNamed(context, '/notifications');
                      },
                    ),
                  ),
                  Center(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        const CircleAvatar(
                          radius: 35,
                          backgroundColor: Colors.white,
                          child: Icon(Icons.person, size: 45, color: Colors.black),
                        ),
                        const SizedBox(height: 10),
                        Text(
                          name,
                          style: TextStyle(
                            color: getTextColor(role),
                            fontSize: 18,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),

            // ── Role-Specific Menus ──────────────────────────────────
            Expanded(
              child: ListView(
                padding: EdgeInsets.zero,
                children: [

                  // ── TREASURY ────────────────────────────────────────
                  if (role == 'treasury') ...[
                    _buildMenuItem(context, Icons.home_outlined, "Home", role),
                    _buildDivider(role),
                    _buildMenuItem(context, Icons.monetization_on_outlined, "Tuition Fees", role),
                    _buildSubMenuItem(context, "Block Settings", role),
                    _buildDivider(role),
                    _buildMenuItem(context, Icons.analytics_outlined, "Reports", role),
                  ]

                  // ── FACULTY ─────────────────────────────────────────
                  else if (role == 'faculty') ...[
                    _buildMenuItem(context, Icons.home_outlined, "Home", role,
                        destination: const DashboardPage()),
                    _buildDivider(role),
                    _buildMenuItem(context, Icons.grid_view, "Subject Registration", role,
                        destination: const SubjectRegistrationPage()),
                    _buildSubMenuItem(context, "Add Subject", role,
                        destination: const SubjectFormPage()),
                  ]

                  // ── LECTURER ────────────────────────────────────────
                  else if (role == 'lecturer') ...[
                    _buildMenuItem(context, Icons.home_outlined, "Home", role),
                    _buildDivider(role),
                    _buildMenuItem(context, Icons.checklist_outlined, "Attendance", role),
                    _buildSubMenuItem(context, "Take Attendance", role),
                    _buildSubMenuItem(context, "View Attendance", role),
                  ]

                  // ── PUSAT ADAB ──────────────────────────────────────
                  else if (role == 'pusat_adab') ...[
                    _buildMenuItem(context, Icons.home_outlined, "Home", role,
                        destination: const DashboardPage()),
                    _buildDivider(role),

                    _buildMenuItem(context, Icons.menu_book_outlined, "Module List", role),
                    _buildSubMenuItem(context, "View Module", role,
                        destination: ViewModulesPage()),
                    _buildSubMenuItem(context, "Add Module", role,
                        destination: ModuleFormPage()),
                    _buildSubMenuItem(context, "Edit Module", role,
                        destination: ViewModulesPage()),
                    _buildDivider(role),

                    _buildMenuItem(context, Icons.note_alt_outlined, "Credit Claim Application", role),
                    _buildSubMenuItem(context, "View Student Application", role,
                        destination: AdminCreditStatusPage()),
                    _buildDivider(role),

                    _buildMenuItem(context, Icons.edit_note_outlined, "Attendance", role),
                    _buildSubMenuItem(context, "Module Attendance", role,
                        destination: const AddModuleAttendancePage()),
                    _buildSubMenuItem(context, "Attendance Records", role,
                        destination: const ModuleAttendanceSelectionPage()),
                    _buildDivider(role),
                  ]

                  // ── STUDENT (default) ────────────────────────────────
                  else ...[
                    // Home
                    _buildMenuItem(context, Icons.home_outlined, "Home", role,
                        destination: const DashboardPage()),
                    _buildDivider(role),

                    // Subject Registration
                    _buildMenuItem(context, Icons.grid_view, "Subject Registration", role,
                        destination: const StudentSubjectRegistrationPage()),
                    _buildSubMenuItem(context, "List of Registered Subjects", role,
                        destination: const ListRegisteredSubjectsPage()),
                    _buildDivider(role),

                    // Curriculum Activity
                    _buildMenuItem(context, Icons.menu_book, "Curriculum Activity", role),
                    _buildSubMenuItem(context, "View My Module", role,
                        destination: MyBookingsPage()),
                    _buildSubMenuItem(context, "Module Booking", role,
                        destination: StudentActivitiesPage()),
                    _buildSubMenuItem(context, "Claim Credit Status", role,
                        destination: CreditClaimStatusPage()),
                    _buildDivider(role),

                    // Attendance
                    _buildMenuItem(context, Icons.assignment_turned_in, "Attendance", role),
                    _buildSubMenuItem(context, "Take Attendance", role),
                    _buildSubMenuItem(context, "Attendance History", role,
                        destination: AttendanceDashboard()),
                    _buildDivider(role),

                    // ✅ Tuition Fees - WITH destination to FinancialInfoPage
                    _buildMenuItem(
                      context, 
                      Icons.payment, 
                      "Tuition Fees", 
                      role,
                      destination: const FinancialInfoPage(), // ✅ Now used!
                    ),
                    _buildSubMenuItem(
                      context, 
                      "Payment History", 
                      role,
                      destination: const PaymentHistoryPage(),
                    ),
                  ],
                ],
              ),
            ),

            // ── Log Out ─────────────────────────────────────────────
            _buildDivider(role),
            _buildMenuItem(context, Icons.logout, "LOG OUT", role, isLogout: true),
            const SizedBox(height: 10),
          ],
        ),
      ),
    );
  }

  // ── Helpers ─────────────────────────────────────────────────────────────

  Widget _buildDivider(String role) => Divider(
        color: getDividerColor(role),
        height: 16,
        thickness: 1,
        indent: 16,
        endIndent: 16,
      );

  /// Parent menu item with icon
  Widget _buildMenuItem(
    BuildContext context,
    IconData icon,
    String title,
    String role, {
    bool isLogout = false,
    Widget? destination,
  }) {
    final color = getTextColor(role);

    return ListTile(
      dense: true,
      visualDensity: const VisualDensity(vertical: -2),
      leading: Icon(icon, color: color, size: 22),
      title: Text(
        title,
        style: TextStyle(
          color: color,
          fontSize: 20,
          fontWeight: isLogout ? FontWeight.bold : FontWeight.w600,
          letterSpacing: isLogout ? 0.5 : 0,
        ),
      ),
      onTap: () {
        if (isLogout) {
          Navigator.pushReplacementNamed(context, '/');
        } else if (destination != null) {
          Navigator.pop(context);
          Navigator.push(
            context,
            MaterialPageRoute(builder: (_) => destination),
          );
        }
      },
    );
  }

  /// Sub-menu item with |--- tree-branch pattern
  Widget _buildSubMenuItem(
    BuildContext context,
    String title,
    String role, {
    Widget? destination,
  }) {
    final color = getTextColor(role);

    return InkWell(
      onTap: () {
        if (destination != null) {
          Navigator.pop(context);
          Navigator.push(
            context,
            MaterialPageRoute(builder: (_) => destination),
          );
        }
      },
      child: Padding(
        padding: const EdgeInsets.only(left: 40.0, top: 2, bottom: 2, right: 16),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            // Vertical bar
            Container(
              width: 2,
              height: 36,
              color: color.withOpacity(0.45),
            ),
            // Horizontal branch line
            Container(
              width: 14,
              height: 2,
              color: color.withOpacity(0.45),
            ),
            const SizedBox(width: 8),
            Expanded(
              child: Text(
                title,
                style: TextStyle(
                  color: color,
                  fontSize: 13.5,
                  fontWeight: FontWeight.w500,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}