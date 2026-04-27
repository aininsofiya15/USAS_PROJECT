import 'package:flutter/material.dart';
import '../widgets/app_sidebar.dart'; // Make sure this path is correct

class DashboardPage extends StatelessWidget {
  final String name;
  final String role;

  const DashboardPage({super.key, required this.name, required this.role});

  // 🎨 Role-based Page Background Color
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
      
      // 1. App Bar with Logo
      appBar: PreferredSize(
        preferredSize: const Size.fromHeight(100.0),
        child: AppBar(
          backgroundColor: Colors.white,
          elevation: 0,
          toolbarHeight: 100,
          centerTitle: true,
          leading: Builder(
            builder: (context) => IconButton(
              icon: const Icon(Icons.menu, color: Colors.black, size: 35),
              onPressed: () => Scaffold.of(context).openDrawer(),
            ),
          ),
          title: Padding(
            padding: const EdgeInsets.only(top: 25.0),
            child: SizedBox(
              height: 250, 
              child: Image.asset('assets/usas_logo.png', fit: BoxFit.contain),
            ),
          ),
          actions: const [SizedBox(width: 55)],
        ),
      ),

      // 2. The Shared Sidebar
      drawer: AppSidebar(name: name, role: role),

      // 3. The Pill Bottom Navigation Bar
      bottomNavigationBar: Padding(
        padding: const EdgeInsets.fromLTRB(20, 0, 20, 20),
        child: Container(
          height: 70,
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(40),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withOpacity(0.1),
                blurRadius: 10,
                offset: const Offset(0, 5),
              ),
            ],
          ),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
            children: [
              IconButton(
                icon: const Icon(Icons.home, size: 40, color: Colors.black),
                onPressed: () {},
              ),
              IconButton(
                icon: const Icon(Icons.notifications, size: 40, color: Colors.black),
                onPressed: () {},
              ),
              IconButton(
                icon: const Icon(Icons.person, size: 40, color: Colors.black),
                onPressed: () {
                   Scaffold.of(context).openDrawer(); 
                },
              ),
            ],
          ),
        ),
      ),

      // 4. Main Body Content
      body: Center(
        child: Text(
          "Logged in as: ${role.toUpperCase()}",
          style: const TextStyle(fontSize: 20, fontWeight: FontWeight.w500),
        ),
      ),
    );
  }
}