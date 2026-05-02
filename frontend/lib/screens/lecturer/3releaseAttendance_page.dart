import 'package:flutter/material.dart';

class CodeDisplayPage extends StatelessWidget {
  // We require the data from the database to build this screen
  final Map<String, dynamic> attendanceData;

  const CodeDisplayPage({super.key, required this.attendanceData});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.menu, color: Colors.black, size: 35),
          onPressed: () => Navigator.pop(context),
        ),
        title: const Center(
          child: Text(
            "USAS",
            style: TextStyle(color: Color(0xFF2A528A), fontWeight: FontWeight.bold, fontSize: 24),
          ),
        ),
        actions: const [SizedBox(width: 48)],
      ),
      
      body: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 20.0, vertical: 10.0),
        child: Container(
          width: double.infinity,
          decoration: BoxDecoration(
            color: const Color(0xFFF3E1E1), // Pink background
            border: Border.all(color: Colors.blueAccent, width: 2), // Blue border
            borderRadius: BorderRadius.circular(15),
          ),
          padding: const EdgeInsets.all(20.0),
          child: Column(
            children: [
              const Text(
                "Attendance",
                style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 20),

              // --- TOP CARD: Class Info ---
              Container(
                width: double.infinity,
                padding: const EdgeInsets.all(20),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(15),
                  boxShadow: const [BoxShadow(color: Colors.black12, blurRadius: 10, offset: Offset(0, 5))],
                ),
                child: Column(
                  children: [
                    Text(
                      attendanceData['subject_name'] ?? "Subject Name", // Changed to subject_name
                    textAlign: TextAlign.center,
                    style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
                  ),
                    const SizedBox(height: 10),
                    Text("Section: ${attendanceData['section_name']}", style: const TextStyle(fontSize: 14)),
                    const SizedBox(height: 5),
                    Text("Lecture/Lab: ${attendanceData['class_type']}", style: const TextStyle(fontSize: 14)),
                    const SizedBox(height: 5),
                    Text("Class Date: ${attendanceData['class_date']} ${attendanceData['class_time']}", style: const TextStyle(fontSize: 14)),
                    const SizedBox(height: 5),
                    const Text("Geolocation: BZ-03-076", style: TextStyle(fontSize: 14)), // Hardcoded placeholder
                  ],
                ),
              ),
              const SizedBox(height: 20),

              // --- BOTTOM CARD: The Code ---
              Container(
                width: double.infinity,
                padding: const EdgeInsets.all(30),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(15),
                  boxShadow: const [BoxShadow(color: Colors.black12, blurRadius: 10, offset: Offset(0, 5))],
                ),
                child: Column(
                  children: [
                    const Text("Attendance Code:", style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
                    const SizedBox(height: 10),
                    Text(
                      attendanceData['generated_code'] ?? "000000",
                      style: const TextStyle(fontSize: 45, fontWeight: FontWeight.bold, letterSpacing: 2),
                    ),
                    const SizedBox(height: 20),
                    ElevatedButton(
                      style: ElevatedButton.styleFrom(
                        backgroundColor: const Color(0xFF22C55E), // Green Button
                        padding: const EdgeInsets.symmetric(horizontal: 30, vertical: 12),
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                      ),
                      onPressed: () {
                        // Action for Release Code
                      },
                      child: const Text("Release Code", style: TextStyle(color: Colors.white, fontSize: 16, fontWeight: FontWeight.bold)),
                    )
                  ],
                ),
              ),
            ],
          ),
        ),
      ),

      // Bottom Nav Bar
      bottomNavigationBar: Container(
        height: 70,
        decoration: const BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.only(
            topLeft: Radius.circular(30),
            topRight: Radius.circular(30),
          ),
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceEvenly,
          children: [
            IconButton(
              icon: const Icon(Icons.home, size: 35, color: Colors.black),
              onPressed: () {},
            ),
            IconButton(
              icon: const Icon(Icons.notifications, size: 35, color: Colors.black),
              onPressed: () {},
            ),
            IconButton(
              icon: const Icon(Icons.person, size: 35, color: Colors.black),
              onPressed: () {},
            ),
          ],
        ),
      ),
    );
  }
}