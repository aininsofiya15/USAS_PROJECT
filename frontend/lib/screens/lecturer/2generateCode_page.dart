import 'package:flutter/material.dart';
import 'dart:convert';
import 'package:http/http.dart' as http;
import '3releaseAttendance_page.dart';

class GenerateCodePage extends StatefulWidget {
  // These variables catch the data passed from the previous page!
  final String subjectName;
  final String section;

  const GenerateCodePage({
    super.key, 
    required this.subjectName, 
    required this.section
  });

  @override
  State<GenerateCodePage> createState() => _GenerateCodePageState();
}

class _GenerateCodePageState extends State<GenerateCodePage> {
  // Variables to store the user's input
  String? selectedClassType;
  DateTime? selectedDate;
  TimeOfDay? selectedTime;

  // Function to show the Calendar Date Picker
  Future<void> _selectDate(BuildContext context) async {
    final DateTime? picked = await showDatePicker(
      context: context,
      initialDate: DateTime.now(),
      firstDate: DateTime(2020),
      lastDate: DateTime(2030),
    );
    if (picked != null && picked != selectedDate) {
      setState(() {
        selectedDate = picked;
      });
    }
  }

  // Function to show the Clock Time Picker
  Future<void> _selectTime(BuildContext context) async {
    final TimeOfDay? picked = await showTimePicker(
      context: context,
      initialTime: TimeOfDay.now(),
    );
    if (picked != null && picked != selectedTime) {
      setState(() {
        selectedTime = picked;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      // 1. The App Bar
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

      // 2. The Main Body Layout
      body: Container(
        width: double.infinity,
        color: const Color(0xFFF3E1E1), // The outer light pink background
        child: Padding(
          padding: const EdgeInsets.all(20.0),
          child: Column(
            children: [
              const Text(
                "Attendance",
                style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 15),

              // 3. The White Card Form
              Expanded(
                child: Container(
                  width: double.infinity,
                  padding: const EdgeInsets.all(20.0),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(15),
                    boxShadow: const [
                      BoxShadow(color: Colors.black12, blurRadius: 10, offset: Offset(0, 5)),
                    ],
                  ),
                  child: SingleChildScrollView(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        // Subject Display
                        Row(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            const Text("Subject: ", style: TextStyle(fontWeight: FontWeight.bold, fontSize: 14)),
                            const SizedBox(width: 10),
                            Expanded(
                              child: Text(
                                widget.subjectName, // Displaying the passed data
                                textAlign: TextAlign.right,
                                style: const TextStyle(fontSize: 14, fontWeight: FontWeight.w500),
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 15),

                        // Section Display
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            const Text("Section: ", style: TextStyle(fontWeight: FontWeight.bold, fontSize: 14)),
                            Text(widget.section, style: const TextStyle(fontSize: 14, fontWeight: FontWeight.w500)),
                          ],
                        ),
                        const SizedBox(height: 20),

                        // Class Type Dropdown
                        Row(
                          children: [
                            const SizedBox(width: 100, child: Text("Lecture/Lab: ", style: TextStyle(fontWeight: FontWeight.bold))),
                            Expanded(
                              child: Container(
                                padding: const EdgeInsets.symmetric(horizontal: 10),
                                decoration: BoxDecoration(
                                  color: const Color(0xFFF0F0F0),
                                  borderRadius: BorderRadius.circular(5),
                                ),
                                child: DropdownButtonHideUnderline(
                                  child: DropdownButton<String>(
                                    value: selectedClassType,
                                    isExpanded: true,
                                    icon: const Icon(Icons.keyboard_arrow_down),
                                    items: <String>['Lecture', 'Lab'].map((String value) {
                                      return DropdownMenuItem<String>(
                                        value: value,
                                        child: Text(value),
                                      );
                                    }).toList(),
                                    onChanged: (String? newValue) {
                                      setState(() {
                                        selectedClassType = newValue;
                                      });
                                    },
                                  ),
                                ),
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 15),

                        // Date Picker
                        Row(
                          children: [
                            const SizedBox(width: 100, child: Text("Date: ", style: TextStyle(fontWeight: FontWeight.bold))),
                            Expanded(
                              child: GestureDetector(
                                onTap: () => _selectDate(context),
                                child: Container(
                                  height: 40,
                                  padding: const EdgeInsets.symmetric(horizontal: 10),
                                  decoration: BoxDecoration(
                                    color: const Color(0xFFF0F0F0),
                                    borderRadius: BorderRadius.circular(5),
                                  ),
                                  child: Row(
                                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                    children: [
                                      Text(selectedDate == null 
                                          ? "" 
                                          : "${selectedDate!.day}/${selectedDate!.month}/${selectedDate!.year}"),
                                      const Icon(Icons.calendar_today, size: 18, color: Colors.grey),
                                    ],
                                  ),
                                ),
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 15),

                        // Time Picker
                        Row(
                          children: [
                            const SizedBox(width: 100, child: Text("Time: ", style: TextStyle(fontWeight: FontWeight.bold))),
                            Expanded(
                              child: GestureDetector(
                                onTap: () => _selectTime(context),
                                child: Container(
                                  height: 40,
                                  padding: const EdgeInsets.symmetric(horizontal: 10),
                                  decoration: BoxDecoration(
                                    color: const Color(0xFFF0F0F0),
                                    borderRadius: BorderRadius.circular(5),
                                  ),
                                  child: Row(
                                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                    children: [
                                      Text(selectedTime == null 
                                          ? "" 
                                          : selectedTime!.format(context)),
                                      const Icon(Icons.access_time, size: 18, color: Colors.grey),
                                    ],
                                  ),
                                ),
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 20),

                        // Geolocation Map Placeholder
                        const Text("Geolocation:", style: TextStyle(fontWeight: FontWeight.bold)),
                        const Text("(Select on Map)", style: TextStyle(fontSize: 12)),
                        const SizedBox(height: 10),
                        Container(
                          height: 120,
                          width: double.infinity,
                          decoration: BoxDecoration(
                            color: Colors.grey[300],
                            borderRadius: BorderRadius.circular(8),
                            border: Border.all(color: Colors.grey),
                          ),
                          child: const Center(
                            child: Text("Map Integration Goes Here", style: TextStyle(color: Colors.black54)),
                          ),
                        ),
                        const SizedBox(height: 25),

                        // Generate Button
                        SizedBox(
                          width: double.infinity,
                          child: ElevatedButton(
                            style: ElevatedButton.styleFrom(
                              backgroundColor: const Color(0xFF0066FF),
                              padding: const EdgeInsets.symmetric(vertical: 15),
                              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                            ),
                            onPressed: () async {
                              // 1. Check if user filled out the form
                              if (selectedClassType == null || selectedDate == null || selectedTime == null) {
                                ScaffoldMessenger.of(context).showSnackBar(
                                  const SnackBar(content: Text("Please fill in all fields!")),
                                );
                                return;
                              }

                              // 2. Format the date and time for Laravel
                              String formattedDate = "${selectedDate!.year}-${selectedDate!.month.toString().padLeft(2, '0')}-${selectedDate!.day.toString().padLeft(2, '0')}";
                              String formattedTime = "${selectedTime!.hour.toString().padLeft(2, '0')}:${selectedTime!.minute.toString().padLeft(2, '0')}:00";

                              // 3. Send the data to Laravel
                              print("🔍 FLUTTER IS SENDING: [${widget.subjectName}]");
                              try {
                                final url = Uri.parse('http://127.0.0.1:8000/api/generate-attendance');
                                final response = await http.post(
                                  url,
                                  body: {
                                    'subject_name': widget.subjectName,
                                    'section': widget.section,
                                    'class_type': selectedClassType,
                                    'class_date': formattedDate,
                                    'class_time': formattedTime,
                                  },
                                );

                                if (response.statusCode == 200) {
                                  final responseData = json.decode(response.body);
                                  
                                  // 4. Success! Open the new page and pass the database info
                                  if (!context.mounted) return;
                                  Navigator.push(
                                    context,
                                    MaterialPageRoute(
                                      builder: (context) => CodeDisplayPage(attendanceData: responseData['data']),
                                    ),
                                  );
                                } else {
                                  print("Error generating code: ${response.body}");
                                }
                              } catch (e) {
                                print("Failed to connect to server: $e");
                              }
                            },
                            child: const Text("GENERATE CODE", style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 16)),
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),

      // 4. Bottom Nav Bar Placeholder
      bottomNavigationBar: Container(
        height: 70,
        decoration: const BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.only(topLeft: Radius.circular(30), topRight: Radius.circular(30)),
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
}