import 'package:flutter/material.dart';
import '../../widgets/header.dart';
import '../../widgets/navigationBar.dart';
import '../../widgets/app_sidebar.dart';

class AddModulePage extends StatefulWidget {
  final String name;
  final String role;

  const AddModulePage({super.key, required this.name, required this.role});

  @override
  State<AddModulePage> createState() => _AddModulePageState();
}

class _AddModulePageState extends State<AddModulePage> {
  // 1. Controllers to grab data for Laravel later
  final nameController = TextEditingController();
  final dateController = TextEditingController();
  final capacityController = TextEditingController();
  final venueController = TextEditingController();
  final lecturerController = TextEditingController();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFD5FFF7), 
      appBar: const UsasHeader(),
      drawer: AppSidebar(name: widget.name, role: widget.role),
      bottomNavigationBar: const UsasBottomNav(),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20.0),
        child: Column(
          children: [
            const Text(
              "Add Module",
              style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 20),
            
            Container(
              padding: const EdgeInsets.all(20),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(25),
                boxShadow: [
                  BoxShadow(color: Colors.black.withOpacity(0.05), blurRadius: 10)
                ],
              ),

              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text("Default Fields", style: TextStyle(fontWeight: FontWeight.bold, color: Colors.black54)),
                  const SizedBox(height: 15),
                  
                  _buildInput(Icons.edit_note, "Activity Name*", nameController),
                  _buildInput(Icons.calendar_today, "Date & Time*", dateController),
                  _buildInput(Icons.people_outline, "Capacity*", capacityController, isNumber: true),
                  _buildInput(Icons.location_on_outlined, "Venue*", venueController),
                  _buildInput(Icons.person_outline, "Lecturer's Name*", lecturerController),
                  
                  const SizedBox(height: 20),
                  const Text("Additional Fields", style: TextStyle(fontWeight: FontWeight.bold, color: Colors.black54)),
                  const SizedBox(height: 15),
                  
                  _buildInput(Icons.description_outlined, "Add Description", null),
                  _buildInput(Icons.link, "WhatsApp Group Link", null),
                  
                  const SizedBox(height: 30),
                  
                  // --- BUTTONS ---
                  Row(
                    children: [
                      Expanded(
                        child: OutlinedButton(
                          onPressed: () {},
                          style: OutlinedButton.styleFrom(
                            side: const BorderSide(color: Colors.blue),
                            padding: const EdgeInsets.symmetric(vertical: 15),
                            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(15)),
                          ),
                          child: const Text("Save as Draft"),
                        ),
                      ),

                      const SizedBox(width: 15),
                      Expanded(
                        child: ElevatedButton(
                          onPressed: () {
                            print("Publishing: ${nameController.text}");
                            // Here is where you'll call your Laravel API tomorrow!
                          },
                          style: ElevatedButton.styleFrom(
                            backgroundColor: const Color(0xFF4CAF50),
                            padding: const EdgeInsets.symmetric(vertical: 15),
                            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(15)),
                          ),
                          child: const Text("Publish", style: TextStyle(color: Colors.white)),
                        ),
                      ),
                    ],
                  )
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  // 2. Helper method to create consistent text fields
  Widget _buildInput(IconData icon, String hint, TextEditingController? controller, {bool isNumber = false}) {
    return Container(
      margin: const EdgeInsets.only(bottom: 15),
      decoration: BoxDecoration(
        color: const Color(0xFFF5F5F5),
        borderRadius: BorderRadius.circular(12),
      ),
      child: TextField(
        controller: controller,
        keyboardType: isNumber ? TextInputType.number : TextInputType.text,
        decoration: InputDecoration(
          border: InputBorder.none,
          prefixIcon: Icon(icon, color: Colors.black45),
          hintText: hint,
          hintStyle: const TextStyle(color: Colors.black26, fontSize: 14),
          contentPadding: const EdgeInsets.symmetric(vertical: 15),
        ),
      ),
    );
  }
}