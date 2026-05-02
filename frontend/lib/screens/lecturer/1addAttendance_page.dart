import 'package:flutter/material.dart';
import 'dart:convert';
import 'package:http/http.dart' as http;
import '2generateCode_page.dart'; 

// 1. Changed to StatefulWidget
class AddAttendancePage extends StatefulWidget {
  const AddAttendancePage({super.key});

  @override
  State<AddAttendancePage> createState() => _AddAttendancePageState();
}

class _AddAttendancePageState extends State<AddAttendancePage> {
  // 2. Variables to hold our database data
  bool isLoading = true; // Controls the loading spinner
  String semester = "";
  List<dynamic> subjectsList = [];

  // 3. This runs automatically when the page first opens
  @override
  void initState() {
    super.initState();
    fetchAttendanceData();
  }

  // 4. The function to fetch data from your Laravel API
  Future<void> fetchAttendanceData() async {
    try {
      // Make sure this IP is correct! Use 10.0.2.2 for Android Studio Emulator.
      // Use 127.0.0.1 if you are testing on Chrome/Web!
      final url = Uri.parse('http://127.0.0.1:8000/api/lecturer/2213455/attendance'); 
      
      final response = await http.get(url);

      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        
        setState(() {
          semester = data['semester'];
          subjectsList = data['subjects'];
          isLoading = false;
        });
      } else {
        // If the server connects but finds an error (like a 404 Route Not Found)
        print("🔴 SERVER ERROR: Status Code ${response.statusCode}");
        print("Server Response: ${response.body}");
        setState(() { isLoading = false; });
      }
    } catch (e) {
      // If Flutter completely fails to connect to Laravel
      print("🔴 CONNECTION CRASHED: $e");
      setState(() { isLoading = false; });
    }
  }

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
        title: Center(
          child: const Text(
            "USAS", 
            style: TextStyle(
              color: Color(0xFF2A528A), 
              fontWeight: FontWeight.bold,
              fontSize: 24,
            ),
          ),
        ),
        actions: const [SizedBox(width: 48)],
      ),

      // 5. Show a loading spinner if data is still fetching!
      body: isLoading 
        ? const Center(child: CircularProgressIndicator()) 
        : Padding(
            padding: const EdgeInsets.symmetric(horizontal: 20.0, vertical: 10.0),
            child: Container(
              width: double.infinity,
              decoration: BoxDecoration(
                color: const Color(0xFFEEDDDB),
                border: Border.all(color: Colors.blueAccent, width: 1.5),
                borderRadius: BorderRadius.circular(15),
              ),
              padding: const EdgeInsets.all(20.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Center(
                    child: Text(
                      "Attendance",
                      style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold),
                    ),
                  ),
                  const SizedBox(height: 25),
                  
                  // Dynamic Semester Text
                  Row(
                    children: [
                      const Text(
                        "Semester: ",
                        style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                      ),
                      const SizedBox(width: 15),
                      Text(
                        semester, // <--- Using the variable from database
                        style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                      ),
                    ],
                  ),
                  const SizedBox(height: 25),

                  // 6. Generate the Subject Cards dynamically!
                  Expanded(
                    child: ListView.builder(
                      itemCount: subjectsList.length,
                      itemBuilder: (context, index) {
                        final subject = subjectsList[index];
                        // Convert dynamic list to List<String> for the sections
                        List<String> sections = List<String>.from(subject['sections']);
                        
                        return Padding(
                          padding: const EdgeInsets.only(bottom: 20.0),
                          child: _buildSubjectCard(
                            subjectName: subject['subject_name'],
                            sections: sections,
                          ),
                        );
                      },
                    ),
                  ),
                ],
              ),
            ),
          ),

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
            IconButton(icon: const Icon(Icons.home, size: 35), onPressed: () {}),
            IconButton(icon: const Icon(Icons.notifications, size: 35), onPressed: () {}),
            IconButton(icon: const Icon(Icons.person, size: 35), onPressed: () {}),
          ],
        ),
      ),
    );
  }

  // --- Reusable Widget for the Subject Cards ---
  Widget _buildSubjectCard({required String subjectName, required List<String> sections}) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(15),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(10),
        boxShadow: const [
          BoxShadow(color: Colors.black12, blurRadius: 8, offset: Offset(0, 4)),
        ],
      ),
      child: Column(
        children: [
          Text(
            subjectName,
            textAlign: TextAlign.center,
            style: const TextStyle(
              color: Color(0xFF3F4E7A),
              fontWeight: FontWeight.bold,
              fontSize: 14,
            ),
          ),
          const SizedBox(height: 15),
          
          ...sections.map((section) => Padding(
            padding: const EdgeInsets.only(bottom: 10.0),
            child: SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color(0xFF0066FF),
                  elevation: 3,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(8),
                  ),
                  padding: const EdgeInsets.symmetric(vertical: 12),
                ),
                onPressed: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) => GenerateCodePage(
                        subjectName: subjectName, 
                        section: section,
                      ),
                    ),
                  );
                },
                child: Text(
                  section,
                  style: const TextStyle(
                    color: Colors.white, 
                    fontWeight: FontWeight.bold,
                    fontSize: 15,
                  ),
                ),
              ),
            ),
          )),
        ],
      ),
    );
  }
}