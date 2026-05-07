import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../provider/module_provider.dart';
import '../../domain/module.dart';
import '../../widgets/header.dart';
import '../../widgets/app_sidebar.dart';
import '../../widgets/navigation_bar.dart';

class StudentListPage extends StatefulWidget {
  final Module module;

  const StudentListPage({super.key, required this.module});

  @override
  State<StudentListPage> createState() => _StudentListPageState();
}

class _StudentListPageState extends State<StudentListPage> {
  @override
  void initState() {
    super.initState();
    // Fetch students registered for this specific module ID on load
    Future.microtask(() =>
        Provider.of<ModuleProvider>(context, listen: false)
            .fetchRegisteredStudents(widget.module.id!));
  }

  @override
  Widget build(BuildContext context) {
    final moduleProvider = Provider.of<ModuleProvider>(context);
    
    // 🔥 SAFETY GUARD: Ensures the app doesn't crash if data is still loading or null
    final dynamic rawData = moduleProvider.registeredStudents;
    final List<dynamic> studentList = (rawData is List) ? rawData : [];

    return Scaffold(
      backgroundColor: const Color(0xFFD1FFF3), // Light mint background
      appBar: const UsasHeader(),
      drawer: const AppSidebar(),
      bottomNavigationBar: const UsasBottomNav(),
      body: Column(
        children: [
          const SizedBox(height: 20),
          
          // 1. TOP MODULE INFO CARD
          Container(
            width: double.infinity,
            margin: const EdgeInsets.symmetric(horizontal: 25),
            padding: const EdgeInsets.all(25),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(35),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withOpacity(0.08),
                  blurRadius: 15,
                  offset: const Offset(0, 5),
                )
              ],
            ),
            child: Column(
              children: [
                Text(
                  widget.module.activityName.toUpperCase(),
                  textAlign: TextAlign.center,
                  style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 18),
                ),
                const SizedBox(height: 12),
                Text("Current Registration: ${widget.module.registeredCount} / ${widget.module.capacity} Students"),
                Text("Class Date: ${widget.module.dateTime}"),
                Text("Venue: ${widget.module.venue}"),
                Text("Lecturer Name: ${widget.module.lecturerName}"),
              ],
            ),
          ),

          const SizedBox(height: 25),

          // 2. STUDENT LIST PANEL
          Expanded(
            child: Container(
              width: double.infinity,
              margin: const EdgeInsets.fromLTRB(15, 0, 15, 15),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(40),
              ),
              child: Column(
                children: [
                  const SizedBox(height: 20),
                  const Text(
                    "Registered Students", 
                    style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16, color: Colors.black87)
                  ),
                  const Divider(indent: 30, endIndent: 30),

                  Expanded(
                    child: moduleProvider.isLoading
                        ? const Center(child: CircularProgressIndicator())
                        : studentList.isEmpty
                            ? const Center(
                                child: Text(
                                  "No students registered yet",
                                  style: TextStyle(color: Colors.grey, fontSize: 14),
                                ),
                              )
                            : ListView.builder(
                                padding: const EdgeInsets.only(bottom: 20),
                                itemCount: studentList.length,
                                itemBuilder: (context, index) {
                                  final student = studentList[index];
                                  return Container(
                                    // Striped row effect: alternating light mint and white
                                    color: index.isEven ? const Color(0xFFF1FEFB) : Colors.white,
                                    padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 25),
                                    child: Row(
                                      children: [
                                        const Icon(Icons.account_circle_outlined, size: 40, color: Colors.grey),
                                        const SizedBox(width: 15),
                                        Expanded(
                                          child: Text(
                                            student['student_name'] ?? "Unknown Student",
                                            style: const TextStyle(
                                              fontSize: 15, 
                                              fontWeight: FontWeight.w500,
                                              color: Colors.black87
                                            ),
                                          ),
                                        ),
                                        IconButton(
                                            icon: const Icon(Icons.delete_outline, color: Colors.redAccent),
                                            onPressed: () async {
                                              final bId = student['booking_id']; // The ID from the select query
                                              final mId = widget.module.id!;     // The current module ID

                                              if (bId != null) {
                                                bool success = await moduleProvider.removeStudentFromModule(
                                                  bookingId: bId, 
                                                  moduleId: mId
                                                );

                                                if (success && context.mounted) {
                                                  ScaffoldMessenger.of(context).showSnackBar(
                                                    const SnackBar(content: Text("Student removed from module")),
                                                  );
                                                }
                                              }
                                            },
                                          ),
                                      ],
                                    ),
                                  );
                                },
                              ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}