import 'package:flutter/material.dart';
import 'package:provider/provider.dart'; //
import '../provider/UserProvider.dart'; //
import '../widgets/app_sidebar.dart';
import '../widgets/header.dart';
import '../widgets/navigationBar.dart';
import 'pusatAdab/adab_dashboard.dart';
import 'lecturer/lecturerDashboard.dart';
import 'treasurer/treasurerDashboard.dart';


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

    return Scaffold(
      backgroundColor: getBackgroundColor(role),
      appBar: const UsasHeader(),
      drawer: const AppSidebar(), // Sidebar also uses Provider now!
      bottomNavigationBar: const UsasBottomNav(),
      body: _buildRoleSpecificBody(name, role),
    );
  }

  Widget _buildRoleSpecificBody(String name, String role) {
    if (role == 'pusat_adab') {
      return PusatAdabBody(name: name);
    } 
    else if (role == 'lecturer') {
      return LecturerBody(name: name);
    } 
    else if (role == 'treasury') {
      return TreasuryDashboardBody(name: name);
    }
    return Center(
      child: Text(
        "Welcome back, $name!\nRole: ${role.toUpperCase()}",
        textAlign: TextAlign.center,
        style: const TextStyle(fontSize: 18),
      ),
    );
    
  }
  
}