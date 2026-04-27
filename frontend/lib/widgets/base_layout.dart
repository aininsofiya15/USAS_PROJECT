import 'package:flutter/material.dart';

// 1. Define the roles clearly
enum UsasRole { student, registrar, treasury, pusatAdab }

class UsasBaseLayout extends StatelessWidget {
  final UsasRole role;
  final String title;
  final Widget body;

  const UsasBaseLayout({
    super.key,
    required this.role,
    required this.title,
    required this.body,
  });

  @override
  Widget build(BuildContext context) {
    // 2. Logic for Colors (Based on your Figma)
    Color backgroundColor;
    switch (role) {
      case UsasRole.student: backgroundColor = const Color(0xFFE3EFF8); break;
      case UsasRole.registrar: backgroundColor = const Color(0xFFFFF9E7); break;
      case UsasRole.treasury: backgroundColor = const Color(0xFFE8F5E9); break;
      case UsasRole.pusatAdab: backgroundColor = const Color(0xFFE0F7FA); break;
    }

    return Scaffold(
      backgroundColor: backgroundColor,
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        centerTitle: true,
        title: Image.asset('assets/usas_logo.jpeg', height: 40), // Put logo in assets
        leading: Builder(
          builder: (context) => IconButton(
            icon: const Icon(Icons.menu, color: Colors.black),
            onPressed: () => Scaffold.of(context).openDrawer(),
          ),
        ),
      ),
      drawer: _buildSidebar(context),
      body: body,
    );
  }

  // 3. Logic for Sidebar Menu (Based on Role)
  Widget _buildSidebar(BuildContext context) {
    return Drawer(
      child: ListView(
        children: [
          DrawerHeader(
            decoration: const BoxDecoration(color: Color(0xFF004D73)),
            child: Text("USAS - ${role.name.toUpperCase()}", 
                  style: const TextStyle(color: Colors.white)),
          ),
          if (role == UsasRole.student) ...[
            ListTile(leading: const Icon(Icons.book), title: const Text("Registration"), onTap: () {}),
            ListTile(leading: const Icon(Icons.event), title: const Text("Attendance"), onTap: () {}),
          ],
          if (role == UsasRole.treasury) ...[
            ListTile(leading: const Icon(Icons.payments), title: const Text("Fee Payment"), onTap: () {}),
          ],
          // Add other roles here...
          const Divider(),
          ListTile(
            leading: const Icon(Icons.logout, color: Colors.red),
            title: const Text("Logout"),
            onTap: () => Navigator.pop(context),
          ),
        ],
      ),
    );
  }
}