import 'package:USAS/screens/dashboard.dart';
import 'package:flutter/material.dart';
import '../screens/pusatAdab/module_form.dart';
import '../screens/pusatAdab/view_module.dart'; 
import 'package:provider/provider.dart'; 
import '../provider/user_provider.dart';
import '../screens/student/module_booking.dart';
import 'package:USAS/screens/faculty/subject_registration_page.dart';


class AppSidebar extends StatelessWidget {

  const AppSidebar({super.key});
  // 🎨 Sidebar Main Body Color
  Color getSidebarColor(String role) {
    switch (role) {
      case 'treasury': return const Color(0xFF11B754); 
      case 'faculty': return const Color(0xFFD4AF00);  
      case 'lecturer': return const Color(0xFFC8908D); 
      case 'pusat_adab': return const Color(0xFFD5FFF7); 
      default: return const Color(0xFF007BFF);          
    }
  }

  // 🎨 Sidebar Header Color
  Color getSidebarHeaderColor(String role) {
    switch (role) {
      case 'treasury': return const Color(0xFF0E9A46);
      case 'faculty': return const Color(0xFFB89800);
      case 'lecturer': return const Color(0xFFB57A77);
      case 'pusat_adab': return const Color(0xFFB2EBF2);
      default: return const Color(0xFF0056D2);
    }
  }

  // 🎨 Text and Icon Color Logic
  Color getTextColor(String role) {
    return (role == 'pusat_adab' || role == 'lecturer') ? Colors.black : Colors.white;
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
            // 1. Profile Header
            DrawerHeader(
              margin: EdgeInsets.zero,
              padding: EdgeInsets.zero,
              decoration: BoxDecoration(
                color: getSidebarHeaderColor(role),
                border: const Border(bottom: BorderSide(color: Colors.transparent)),
              ),
              child: Center(
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
            ),

            // 2. Role-Specific Menus
            Expanded(
              child: ListView(
                padding: EdgeInsets.zero, 
                children: [
                  if (role == 'treasury') ...[
                    _buildMenuItem(context, Icons.home_outlined, "Home", role),
                    const Divider(color: Color.fromARGB(184, 255, 255, 255), height: 10),
                    _buildMenuItem(context, Icons.monetization_on_outlined, "Tuition Fees", role),
                    _buildSubMenuItem(context, "Block Settings", role),
                    const Divider(color: Colors.white24, height: 5),
                    _buildMenuItem(context, Icons.analytics_outlined, "Reports", role),
                  ] 




                  else if (role == 'faculty') ...[
                    _buildMenuItem(context, Icons.home_outlined, "Home", role),
                    const Divider(color: Color.fromARGB(184, 255, 255, 255), height: 10),
                    _buildMenuItem(context, Icons.grid_view, "Subject Registration", role, destination: const SubjectRegistrationPage(), ),
                    _buildSubMenuItem(context, "Add Subject", role,destination: const SubjectRegistrationPage(),  ),
                  ] 




                  else if (role == 'lecturer') ...[
                    _buildMenuItem(context, Icons.home_outlined, "Home", role),
                    const Divider(color: Color.fromARGB(184, 255, 255, 255), height: 10),
                    _buildMenuItem(context, Icons.list, "Attendance", role),
                    _buildSubMenuItem(context, "Attendance", role),
                    _buildSubMenuItem(context, "View Attendance", role),
                  ] 



                  else if (role == 'pusat_adab') ...[
                    _buildMenuItem(context, Icons.home_outlined, "Home", role, destination: DashboardPage()),

                    const Divider(color: Color.fromARGB(184, 255, 255, 255), height: 10),

                    _buildMenuItem(context, Icons.list_alt, "Module List", role),
                    _buildSubMenuItem(context, "View Module", role, destination:  ViewModulesPage()), //contoh tulis route dia
                    _buildSubMenuItem(context,"Add Module", role, destination:  ModuleFormPage()),

                    const Divider(color: Colors.black12, height: 10),

                    _buildMenuItem(context, Icons.description_outlined, "Credit Claim Application", role),
                    _buildSubMenuItem(context, "View Student Application", role),
                  ] 




                  else ...[ //student
                    _buildMenuItem(context, Icons.home_outlined, "Home", role),
                    const Divider(color: Color.fromARGB(184, 255, 255, 255), height: 10),
                    _buildMenuItem(context, Icons.grid_view, "Subject Registration", role),
                    _buildSubMenuItem(context, "List of Registered Subjects", role),
                    const Divider(color: Colors.white24, height: 10),
                    _buildMenuItem(context, Icons.menu_book, "Curriculum Activity", role),
                    _buildSubMenuItem(context, "View My Module", role),
                    _buildSubMenuItem(context, "Module Booking", role, destination: StudentActivitiesPage()),
                    _buildSubMenuItem(context, "Claim Credit", role),
                    const Divider(color: Colors.white24, height: 10),
                    _buildMenuItem(context, Icons.assignment_turned_in, "Attendance", role),
                    _buildSubMenuItem(context, "Attendance", role),
                    _buildSubMenuItem(context, "Attendance History", role),
                  ],
                ],
              ),
            ),

            const Divider(color: Color.fromARGB(184, 255, 255, 255), height: 20),
            _buildMenuItem(context, Icons.logout, "Log Out", isLogout: true,role),
            const SizedBox(height: 10),
          ],
        ),
      ),
    );
  }

  Widget _buildMenuItem(BuildContext context, IconData icon, String title, String role, {bool isLogout = false, Widget? destination})  {
    return ListTile(
      dense: true,
      visualDensity: const VisualDensity(vertical: -2),
      leading: Icon(icon, color: getTextColor(role), size: 22),
      title: Text(
        title,
        style: TextStyle(
          color: getTextColor(role),
          fontSize: 18,
          fontWeight: isLogout ? FontWeight.bold : FontWeight.w600,
        ),
      ),
      onTap: () {
        if (isLogout) {
          Navigator.pushReplacementNamed(context, '/');
        } else if (destination != null) {
          Navigator.pop(context); // Close the drawer first
          Navigator.push(
            context,
            MaterialPageRoute(builder: (context) => destination),
          );
        }
      },
    );
  }

  // 🛠️ UPDATED: Added destination parameter to handle navigation
  Widget _buildSubMenuItem(BuildContext context, String title, String role, {Widget? destination}) {    
    return ListTile(
      dense: true,
      visualDensity: const VisualDensity(vertical: -4),
      contentPadding: const EdgeInsets.only(left: 45.0),
      title: Text(
        "• $title",
        style: TextStyle(
          color: getTextColor(role).withOpacity(0.85),
          fontSize: 15,
          fontWeight: FontWeight.w400,
        ),
      ),

      onTap: () {
        if (destination != null) {
          Navigator.pop(context); // Close the drawer
          Navigator.push(
            context,
            MaterialPageRoute(builder: (context) => destination),
          );
        }
      },
    );
  }
}