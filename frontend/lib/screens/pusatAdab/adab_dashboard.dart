import 'package:flutter/material.dart';
import 'module_form.dart'; // Make sure the name matches your file

class PusatAdabBody extends StatelessWidget {
  
  final String name;
  const PusatAdabBody({super.key, required this.name});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(25.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            "Hello, $name!",
            style: const TextStyle(fontSize: 26, fontWeight: FontWeight.bold),
          ),
          const Text("Pusat ADAB Administrative Portal", 
            style: TextStyle(fontSize: 16, color: Colors.black54)),
          const SizedBox(height: 30),
          
          Expanded(
            child: GridView.count(
              crossAxisCount: 2,
              crossAxisSpacing: 20,
              mainAxisSpacing: 20,
              children: [
                _buildMenuCard(
                  context,
                  Icons.add_circle_outline, 
                  "Add Module", 
                  const Color(0xFF4CAF50),
                  () => Navigator.push(
                    context, 
                    MaterialPageRoute(builder: (context) => ModuleFormPage())
                  ),
                ),
                _buildMenuCard(context, Icons.fact_check, "Approvals", Colors.blue, () {}),
                _buildMenuCard(context, Icons.trending_up, "Merit Points", Colors.orange, () {}),
                _buildMenuCard(context, Icons.description, "Reports", Colors.redAccent, () {}),
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
            BoxShadow(color: Colors.black.withOpacity(0.05), blurRadius: 10, offset: const Offset(0, 5))
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
            Text(title, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
          ],
        ),
      ),
    );
  }
}