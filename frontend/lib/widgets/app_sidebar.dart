import 'package:USAS/pages/dashboard.dart';
import 'package:flutter/material.dart';
import '../pages/pusatAdab/addModule_page.dart';

class AppSidebar extends StatelessWidget {
  final String name;
  final String role;

  const AppSidebar({super.key, required this.name, required this.role});

  // 🎨 Sidebar Main Body Color
  Color getSidebarColor() {
    switch (role) {
      case 'treasury': return const Color(0xFF11B754); 
      case 'faculty': return const Color(0xFFD4AF00);  
      case 'lecturer': return const Color(0xFFC8908D); 
      case 'pusat_adab': return const Color(0xFFD5FFF7); 
      default: return const Color(0xFF007BFF);          
    }
  }

  // 🎨 Sidebar Header Color
  Color getSidebarHeaderColor() {
    switch (role) {
      case 'treasury': return const Color(0xFF0E9A46);
      case 'faculty': return const Color(0xFFB89800);
      case 'lecturer': return const Color(0xFFB57A77);
      case 'pusat_adab': return const Color(0xFFB2EBF2);
      default: return const Color(0xFF0056D2);
    }
  }

  // 🎨 Text and Icon Color Logic
  Color getTextColor() {
    return (role == 'pusat_adab' || role == 'lecturer') ? Colors.black : Colors.white;
  }

  @override
  Widget build(BuildContext context) {
    return Drawer(
      child: Container(
        color: getSidebarColor(),
        child: Column(
          children: [
            // 1. Profile Header
            DrawerHeader(
              margin: EdgeInsets.zero,
              padding: EdgeInsets.zero,
              decoration: BoxDecoration(
                color: getSidebarHeaderColor(),
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
                        color: getTextColor(),
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
                    _buildMenuItem(context, Icons.home_outlined, "Home"),
                    const Divider(color: Color.fromARGB(184, 255, 255, 255), height: 10),
                    _buildMenuItem(context, Icons.monetization_on_outlined, "Tuition Fees"),
                    _buildSubMenuItem(context, "Block Settings"),
                    const Divider(color: Colors.white24, height: 5),
                    _buildMenuItem(context, Icons.analytics_outlined, "Reports"),
                  ] 
                  else if (role == 'faculty') ...[
                    _buildMenuItem(context, Icons.home_outlined, "Home"),
                    const Divider(color: Color.fromARGB(184, 255, 255, 255), height: 10),
                    _buildMenuItem(context, Icons.grid_view, "Subject Registration"),
                    _buildSubMenuItem(context, "Add Subject"),
                  ] 
                  else if (role == 'lecturer') ...[
                    _buildMenuItem(context, Icons.home_outlined, "Home"),
                    const Divider(color: Color.fromARGB(184, 255, 255, 255), height: 10),
                    _buildMenuItem(context, Icons.list, "Attendance"),
                    _buildSubMenuItem(context, "Attendance"),
                    _buildSubMenuItem(context, "View Attendance"),
                  ] 
                  else if (role == 'pusat_adab') ...[
                    _buildMenuItem(context, Icons.home_outlined, "Home",destination: DashboardPage(name: name, role: role)),
                    const Divider(color: Color.fromARGB(184, 255, 255, 255), height: 10),
                    _buildMenuItem(context, Icons.list_alt, "Module List"),
                    _buildSubMenuItem(context, "View Module"),
                    _buildSubMenuItem(
                      context, 
                      "Add Module", 
                      destination: AddModulePage(name: name, role: role)
                    ),
                    _buildSubMenuItem(context, "Edit Module"),
                    const Divider(color: Colors.black12, height: 10),
                    _buildMenuItem(context, Icons.description_outlined, "Credit Claim Application"),
                    _buildSubMenuItem(context, "View Student Application"),
                  ] 
                  else ...[
                    _buildMenuItem(context, Icons.home_outlined, "Home"),
                    const Divider(color: Color.fromARGB(184, 255, 255, 255), height: 10),
                    _buildMenuItem(context, Icons.grid_view, "Subject Registration"),
                    _buildSubMenuItem(context, "List of Registered Subjects"),
                    const Divider(color: Colors.white24, height: 10),
                    _buildMenuItem(context, Icons.menu_book, "Curriculum Activity"),
                    _buildSubMenuItem(context, "View My Module"),
                    _buildSubMenuItem(context, "Module Booking"),
                    _buildSubMenuItem(context, "Claim Credit"),
                    const Divider(color: Colors.white24, height: 10),
                    _buildMenuItem(context, Icons.assignment_turned_in, "Attendance"),
                    _buildSubMenuItem(context, "Attendance"),
                    _buildSubMenuItem(context, "Attendance History"),
                  ],
                ],
              ),
            ),

            const Divider(color: Color.fromARGB(184, 255, 255, 255), height: 20),
            _buildMenuItem(context, Icons.logout, "Log Out", isLogout: true),
            const SizedBox(height: 10),
          ],
        ),
      ),
    );
  }

  Widget _buildMenuItem(BuildContext context, IconData icon, String title, {bool isLogout = false, Widget? destination}) {
    return ListTile(
      dense: true,
      visualDensity: const VisualDensity(vertical: -2),
      leading: Icon(icon, color: getTextColor(), size: 22),
      title: Text(
        title,
        style: TextStyle(
          color: getTextColor(),
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
  Widget _buildSubMenuItem(BuildContext context, String title, {Widget? destination}) {
    return ListTile(
      dense: true,
      visualDensity: const VisualDensity(vertical: -4),
      contentPadding: const EdgeInsets.only(left: 45.0),
      title: Text(
        "• $title",
        style: TextStyle(
          color: getTextColor().withOpacity(0.85),
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