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
  String searchQuery = "";

  @override
  void initState() {
    super.initState();
    Future.microtask(() =>
        Provider.of<ModuleProvider>(context, listen: false)
            .fetchRegisteredStudents(widget.module.id!));
  }

  @override
  Widget build(BuildContext context) {
    final moduleProvider = Provider.of<ModuleProvider>(context);

    // Safety guard so null/non-list data doesn't crash the app
    final dynamic rawData = moduleProvider.registeredStudents;
    final List<dynamic> studentList = (rawData is List) ? rawData : [];

    // Filter by matric ID or name
    final List<dynamic> filteredList = searchQuery.isEmpty
        ? studentList
        : studentList.where((s) {
            final String matricId = (s['matric_id'] ?? "").toString().toLowerCase();
            final String name = (s['student_name'] ?? "").toString().toLowerCase();
            return matricId.contains(searchQuery.toLowerCase()) ||
                   name.contains(searchQuery.toLowerCase());
          }).toList();

    return Scaffold(
      backgroundColor: const Color(0xFFD1FFF3),
      appBar: const UsasHeader(),
      drawer: const AppSidebar(),
      bottomNavigationBar: const UsasBottomNav(),
      body: Column(
        children: [
          const SizedBox(height: 20),

          // ── MODULE INFO CARD ──────────────────────────────────────────
          Container(
            width: double.infinity,
            margin: const EdgeInsets.symmetric(horizontal: 20),
            padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 22),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(30),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withOpacity(0.07),
                  blurRadius: 12,
                  offset: const Offset(0, 4),
                )
              ],
            ),
            child: Column(
              children: [
                Text(
                  widget.module.activityName.toUpperCase(),
                  textAlign: TextAlign.center,
                  style: const TextStyle(
                    fontWeight: FontWeight.bold,
                    fontSize: 17,
                    color: Colors.black87,
                  ),
                ),
                const SizedBox(height: 12),
                _infoText("Current Registration: ${studentList.length} / ${widget.module.capacity} Students"),
                _infoText("Class Date: ${widget.module.dateTime}"),
                _infoText("Venue: ${widget.module.venue}"),
                _infoText("Lecturer Name: ${widget.module.lecturerName}"),
              ],
            ),
          ),

          const SizedBox(height: 18),

          // ── STUDENT LIST PANEL ────────────────────────────────────────
          Expanded(
            child: Container(
              width: double.infinity,
              margin: const EdgeInsets.fromLTRB(14, 0, 14, 14),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(36),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withOpacity(0.06),
                    blurRadius: 10,
                  )
                ],
              ),
              child: Column(
                children: [
                  const SizedBox(height: 18),

                  // 🔍 Search Bar — outlined style, icon on RIGHT (Figma style)
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 22),
                    child: TextField(
                      onChanged: (val) => setState(() => searchQuery = val),
                      style: const TextStyle(fontSize: 14),
                      decoration: InputDecoration(
                        hintText: "Matric ID",
                        hintStyle: const TextStyle(
                          color: Colors.grey,
                          fontSize: 14,
                        ),
                        suffixIcon: const Icon(
                          Icons.search,
                          color: Colors.grey,
                          size: 20,
                        ),
                        contentPadding: const EdgeInsets.symmetric(
                          horizontal: 18,
                          vertical: 12,
                        ),
                        enabledBorder: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(25),
                          borderSide: BorderSide(
                            color: Colors.grey.shade300,
                            width: 1.2,
                          ),
                        ),
                        focusedBorder: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(25),
                          borderSide: BorderSide(
                            color: Colors.teal.shade300,
                            width: 1.5,
                          ),
                        ),
                        filled: false,
                      ),
                    ),
                  ),

                  const SizedBox(height: 14),

                  // 📋 Column Headers
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 22),
                    child: Row(
                      children: const [
                        SizedBox(width: 46), // avatar space
                        Expanded(
                          flex: 5,
                          child: Text(
                            "Student Name",
                            style: TextStyle(
                              fontWeight: FontWeight.bold,
                              fontSize: 13.5,
                              color: Colors.black87,
                            ),
                          ),
                        ),
                        Text(
                          "Matric ID",
                          style: TextStyle(
                            fontWeight: FontWeight.bold,
                            fontSize: 13.5,
                            color: Colors.black87,
                          ),
                        ),
                        SizedBox(width: 42), // delete icon space
                      ],
                    ),
                  ),

                  const SizedBox(height: 4),
                  const Divider(height: 1, thickness: 1, indent: 16, endIndent: 16),

                  // 📝 Student List
                  Expanded(
                    child: moduleProvider.isLoading
                        ? const Center(child: CircularProgressIndicator())
                        : filteredList.isEmpty
                            ? const Center(
                                child: Text(
                                  "No students found",
                                  style: TextStyle(color: Colors.grey, fontSize: 14),
                                ),
                              )
                            : ListView.separated(
                                padding: const EdgeInsets.only(bottom: 16),
                                itemCount: filteredList.length,
                                separatorBuilder: (_, __) => const Divider(
                                  height: 1,
                                  thickness: 0.8,
                                  indent: 16,
                                  endIndent: 16,
                                ),
                                itemBuilder: (context, index) {
                                  final student = filteredList[index];
                                  return Padding(
                                    padding: const EdgeInsets.symmetric(
                                      vertical: 6,
                                      horizontal: 16,
                                    ),
                                    child: Row(
                                      children: [
                                        // Avatar — thin outline style matching Figma
                                        Container(
                                          width: 38,
                                          height: 38,
                                          decoration: BoxDecoration(
                                            shape: BoxShape.circle,
                                            border: Border.all(
                                              color: Colors.grey.shade400,
                                              width: 1.5,
                                            ),
                                          ),
                                          child: const Icon(
                                            Icons.person_outline,
                                            size: 22,
                                            color: Colors.grey,
                                          ),
                                        ),
                                        const SizedBox(width: 10),
                                        // Student Name
                                        Expanded(
                                          flex: 5,
                                          child: Text(
                                            student['student_name'] ?? "Unknown",
                                            style: const TextStyle(
                                              fontSize: 13,
                                              fontWeight: FontWeight.w500,
                                              color: Colors.black87,
                                            ),
                                          ),
                                        ),
                                        // Matric ID
                                        Text(
                                          student['matric_id'] ?? "-",
                                          style: const TextStyle(
                                            fontSize: 13,
                                            color: Colors.black54,
                                          ),
                                        ),
                                        // Delete button
                                        IconButton(
                                          icon: const Icon(
                                            Icons.delete_outline,
                                            color: Colors.redAccent,
                                            size: 22,
                                          ),
                                          padding: EdgeInsets.zero,
                                          constraints: const BoxConstraints(
                                            minWidth: 36,
                                            minHeight: 36,
                                          ),
                                          onPressed: () => _confirmDelete(student),
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

  // Helper for uniform info text styling
  Widget _infoText(String text) {
    return Padding(
      padding: const EdgeInsets.only(top: 3),
      child: Text(
        text,
        textAlign: TextAlign.center,
        style: const TextStyle(fontSize: 13.5, color: Colors.black54),
      ),
    );
  }

  void _confirmDelete(dynamic student) async {
    bool? confirm = await showDialog<bool>(
      context: context,
      builder: (context) => Dialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        child: Padding(
          padding: const EdgeInsets.all(25),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              const Icon(Icons.warning_amber_rounded, color: Colors.red, size: 80),
              const SizedBox(height: 20),
              const Text(
                "Are you sure to remove this student?",
                textAlign: TextAlign.center,
                style: TextStyle(fontWeight: FontWeight.bold, fontSize: 18),
              ),
              const SizedBox(height: 30),
              Row(
                children: [
                  Expanded(
                    child: ElevatedButton(
                      onPressed: () => Navigator.pop(context, false),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.blue,
                        shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(10)),
                        padding: const EdgeInsets.symmetric(vertical: 12),
                      ),
                      child: const Text("Back",
                          style: TextStyle(
                              color: Colors.white, fontWeight: FontWeight.bold)),
                    ),
                  ),
                  const SizedBox(width: 15),
                  Expanded(
                    child: ElevatedButton(
                      onPressed: () => Navigator.pop(context, true),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.red,
                        shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(10)),
                        padding: const EdgeInsets.symmetric(vertical: 12),
                      ),
                      child: const Text("Confirm",
                          style: TextStyle(
                              color: Colors.white, fontWeight: FontWeight.bold)),
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );

    if (confirm == true && context.mounted) {
      await Provider.of<ModuleProvider>(context, listen: false)
          .removeStudentFromModule(
        bookingId: student['booking_id'],
        moduleId: widget.module.id!,
      );

      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text("Student removed successfully")),
        );
      }
    }
  }
}