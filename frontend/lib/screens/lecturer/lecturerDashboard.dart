import 'package:flutter/material.dart';
import 'add_attendance.dart';

class LecturerBody extends StatelessWidget {
  final String name;
  const LecturerBody({super.key, required this.name});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(25.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            "Welcome, $name!",
            style: const TextStyle(fontSize: 26, fontWeight: FontWeight.bold, color: Color(0xFF1A2C3E)),
          ),
          const Text(
            "Manage your classes and monitor attendance", 
            style: TextStyle(fontSize: 16, color: Colors.black54),
          ),
          const SizedBox(height: 30),
          
          Expanded(
            child: GridView.count(
              crossAxisCount: 2,
              crossAxisSpacing: 20,
              mainAxisSpacing: 20,
              children: [
                _buildMenuCard(
                  context,
                  Icons.how_to_reg, 
                  "Take Attendance", 
                  const Color(0xFF2E7D32), // Using the green from your original theme
                  () {
                    Navigator.push(context, MaterialPageRoute(builder: (context) => AddAttendancePage()));
                  },
                ),
                _buildMenuCard(
                  context, 
                  Icons.history_edu, 
                  "Records", 
                  Colors.blue, 
                  () {}
                ),
                _buildMenuCard(
                  context, 
                  Icons.bar_chart, 
                  "Insights", 
                  Colors.orange, 
                  () {}
                ),
                _buildMenuCard(
                  context, 
                  Icons.class_, 
                  "My Classes", 
                  Colors.redAccent, 
                  () {}
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildMenuCard(BuildContext context, IconData icon, String title, Color color, VoidCallback onTap) {
    return InkWell(
      onTap: onTap,
      child: Container(
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(25),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.05), 
              blurRadius: 10, 
              offset: const Offset(0, 5),
            )
          ],
        ),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            CircleAvatar(
              radius: 30,
              backgroundColor: color.withOpacity(0.1),
              child: Icon(icon, size: 35, color: color),
            ),
            const SizedBox(height: 15),
            Text(
              title, 
              style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
            ),
          ],
        ),
      ),
    );
  }
}