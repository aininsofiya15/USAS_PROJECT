import 'package:flutter/material.dart';
import '../widgets/app_sidebar.dart';
import '../widgets/header.dart';
import '../widgets/navigationBar.dart';
// Import your role-specific dashboards
import 'pusatAdab/adabDashboard.dart';

class DashboardPage extends StatelessWidget {
  final String name;
  final String role;

  const DashboardPage({super.key, required this.name, required this.role});

  // Role-based background colors
  Color getBackgroundColor() {
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
    return Scaffold(
      backgroundColor: getBackgroundColor(),
      // Using your reusable Header
      appBar: const UsasHeader(),
      
      // Using your shared Sidebar
      drawer: AppSidebar(name: name, role: role),
      
      // Using your reusable Bottom Nav
      bottomNavigationBar: const UsasBottomNav(),

      // Decide which body to show
      body: _buildRoleSpecificBody(),
    );
  }

  Widget _buildRoleSpecificBody() {
    if (role == 'pusat_adab') {
      return PusatAdabBody(name: name);
    } 
    // You can add more roles here later (e.g. if (role == 'student')...)
    return Center(
      child: Text("Welcome back, $name!\nRole: ${role.toUpperCase()}",
          textAlign: TextAlign.center,
          style: const TextStyle(fontSize: 18)),
    );
  }
}