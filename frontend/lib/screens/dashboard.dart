import 'package:flutter/material.dart';
import 'package:provider/provider.dart'; //
import '../provider/user_provider.dart'; //
import '../widgets/app_sidebar.dart';
import '../widgets/header.dart';
import '../widgets/navigation_bar.dart';
import 'pusatAdab/adab_dashboard.dart';
import 'lecturer/lecturerDashboard.dart';
import 'treasurer/treasurer_dashboard.dart';
import 'student/student_dashboard.dart';

class DashboardPage extends StatelessWidget {
  // Notice: No variables passed in constructor anymore!
  const DashboardPage({super.key});

  // Color logic moved here for cleanliness
  Color getBackgroundColor(String role) {
    switch (role) {
      case 'student': return const Color(0xFFE3EFF8);
      case 'faculty': return const Color(0xFFFDF9EC);
      case 'treasury': return const Color(0xFFE8F8E3);
      case 'pusat_adab': return const Color(0xFFD5FFF7);
      case 'lecturer': return const Color(0xFFFBEBEB);
      default: return Colors.white;
    }
  }

  @override
  Widget build(BuildContext context) {
    // Grab the data from the Provider
    final user = Provider.of<UserProvider>(context);
    final String name = user.name;
    final String role = user.role;

    return _buildRoleSpecificBody(name, role);
  }

  Widget _buildRoleSpecificBody(String name, String role) {
  switch (role) {
    case 'student':
      return StudentDashboard(name: name);
    case 'pusat_adab':
      return Scaffold(
        backgroundColor: const Color(0xFFD5FFF7),
        appBar: const UsasHeader(),
        drawer: const AppSidebar(),
        bottomNavigationBar: const UsasBottomNav(),
        body: PusatAdabBody(name: name),
      );
    case 'lecturer':
      return Scaffold(
        backgroundColor: const Color(0xFFFBEBEB),
        appBar: const UsasHeader(),
        drawer: const AppSidebar(),
        bottomNavigationBar: const UsasBottomNav(),
        body: LecturerBody(name: name),
      );
    case 'treasury':
      return Scaffold(
        backgroundColor: const Color(0xFFE8F8E3),
        appBar: const UsasHeader(),
        drawer: const AppSidebar(),
        bottomNavigationBar: const UsasBottomNav(),
        body: TreasuryDashboardBody(name: name),
      );
    default:
      return Scaffold(
        appBar: const UsasHeader(),
        body: Center(child: Text("Welcome back, $name!\nRole: ${role.toUpperCase()}")),
      );
  }
  }
}