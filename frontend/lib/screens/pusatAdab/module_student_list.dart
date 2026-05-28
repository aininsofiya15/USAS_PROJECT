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

    final dynamic rawData = moduleProvider.registeredStudents;
    final List<dynamic> studentList = (rawData is List) ? rawData : [];

    final List<dynamic> filteredList = searchQuery.isEmpty
        ? studentList
        : studentList.where((s) {
            final String matricId =
                (s['matric_id'] ?? "").toString().toLowerCase();
            final String name =
                (s['student_name'] ?? "").toString().toLowerCase();
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
            margin: const EdgeInsets.symmetric(horizontal: 16),
            padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 18),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(20),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withOpacity(0.06),
                  blurRadius: 10,
                  offset: const Offset(0, 3),
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
                    fontSize: 16,
                    color: Colors.black87,
                  ),
                ),
                const SizedBox(height: 10),
                _infoText(
                    "Current Registration: ${studentList.length} / ${widget.module.capacity} Students"),
                _infoText("Class Date: ${widget.module.dateTime}"),
                _infoText("Venue: ${widget.module.venue}"),
                _infoText("Lecturer Name: ${widget.module.lecturerName}"),
              ],
            ),
          ),

          const SizedBox(height: 14),

          // ── STUDENT LIST PANEL ────────────────────────────────────────
          Expanded(
            child: Container(
              width: double.infinity,
              margin: const EdgeInsets.fromLTRB(16, 0, 16, 16),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(20),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withOpacity(0.05),
                    blurRadius: 10,
                  )
                ],
              ),
              child: Column(
                children: [
                  const SizedBox(height: 14),

                  // 🔍 Search Bar
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 16),
                    child: SizedBox(
                      height: 40,
                      child: TextField(
                        onChanged: (val) => setState(() => searchQuery = val),
                        style: const TextStyle(fontSize: 13),
                        decoration: InputDecoration(
                          hintText: "Search name or matric ID",
                          hintStyle: const TextStyle(
                            color: Colors.grey,
                            fontSize: 13,
                          ),
                          prefixIcon: const Icon(
                            Icons.search,
                            color: Colors.grey,
                            size: 18,
                          ),
                          contentPadding:
                              const EdgeInsets.symmetric(vertical: 10),
                          enabledBorder: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(10),
                            borderSide: BorderSide(
                              color: Colors.grey.shade300,
                              width: 1,
                            ),
                          ),
                          focusedBorder: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(10),
                            borderSide: BorderSide(
                              color: Colors.teal.shade300,
                              width: 1.2,
                            ),
                          ),
                          filled: true,
                          fillColor: const Color(0xFFF8F8F8),
                        ),
                      ),
                    ),
                  ),

                  const SizedBox(height: 10),

                  // 📋 Column Headers
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 16),
                    child: Row(
                      children: const [
                        SizedBox(width: 36), // avatar space
                        SizedBox(width: 10),
                        Text(
                          "Student Name",
                          style: TextStyle(
                            fontWeight: FontWeight.bold,
                            fontSize: 13,
                            color: Colors.black87,
                          ),
                        ),
                        Spacer(),
                        Text(
                          "Matric ID",
                          style: TextStyle(
                            fontWeight: FontWeight.bold,
                            fontSize: 13,
                            color: Colors.black87,
                          ),
                        ),
                        SizedBox(width: 36), // delete icon space
                      ],
                    ),
                  ),

                  const SizedBox(height: 6),
                  const Divider(height: 1, thickness: 1, indent: 16, endIndent: 16),

                  // 📝 Student List
                  Expanded(
                    child: moduleProvider.isLoading
                        ? const Center(child: CircularProgressIndicator())
                        : filteredList.isEmpty
                            ? Center(
                                child: Column(
                                  mainAxisAlignment: MainAxisAlignment.center,
                                  children: [
                                    Icon(Icons.person_off_outlined,
                                        size: 40, color: Colors.grey[400]),
                                    const SizedBox(height: 8),
                                    Text(
                                      "No students found",
                                      style: TextStyle(
                                          color: Colors.grey[500],
                                          fontSize: 13),
                                    ),
                                  ],
                                ),
                              )
                            : ListView.separated(
                                padding:
                                    const EdgeInsets.only(top: 4, bottom: 12),
                                itemCount: filteredList.length,
                                separatorBuilder: (_, __) => const Divider(
                                  height: 1,
                                  thickness: 0.8,
                                  indent: 16,
                                  endIndent: 16,
                                ),
                                itemBuilder: (context, index) {
                                  final student = filteredList[index];
                                  return _buildStudentRow(student);
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

  Widget _buildStudentRow(dynamic student) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8, horizontal: 16),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          // Avatar
          Container(
            width: 36,
            height: 36,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              color: const Color(0xFFF0F0F0),
              border: Border.all(color: Colors.grey.shade300, width: 1),
            ),
            child: const Icon(
              Icons.person_outline,
              size: 20,
              color: Colors.grey,
            ),
          ),
          const SizedBox(width: 10),

          // Student Name
          Expanded(
            child: Text(
              student['student_name'] ?? "Unknown",
              style: const TextStyle(
                fontSize: 13,
                fontWeight: FontWeight.w500,
                color: Colors.black87,
              ),
              overflow: TextOverflow.ellipsis,
            ),
          ),
          const SizedBox(width: 8),

          // Matric ID
          Text(
            student['matric_id'] ?? "-",
            style: const TextStyle(
              fontSize: 12,
              color: Colors.black54,
            ),
          ),

          // Delete button
          SizedBox(
            width: 36,
            height: 36,
            child: IconButton(
              icon: const Icon(
                Icons.delete_outline,
                color: Colors.redAccent,
                size: 20,
              ),
              padding: EdgeInsets.zero,
              onPressed: () => _confirmDelete(student),
            ),
          ),
        ],
      ),
    );
  }

  Widget _infoText(String text) {
    return Padding(
      padding: const EdgeInsets.only(top: 3),
      child: Text(
        text,
        textAlign: TextAlign.center,
        style: const TextStyle(fontSize: 13, color: Colors.black54),
      ),
    );
  }

  void _confirmDelete(dynamic student) async {
    bool? confirm = await showDialog<bool>(
      context: context,
      builder: (context) => Dialog(
        shape:
            RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        child: Padding(
          padding: const EdgeInsets.all(24),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              const Icon(Icons.warning_amber_rounded,
                  color: Colors.red, size: 64),
              const SizedBox(height: 16),
              const Text(
                "Are you sure to remove this student?",
                textAlign: TextAlign.center,
                style:
                    TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
              ),
              const SizedBox(height: 24),
              Row(
                children: [
                  Expanded(
                    child: ElevatedButton(
                      onPressed: () => Navigator.pop(context, false),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.blue,
                        shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(10)),
                        padding:
                            const EdgeInsets.symmetric(vertical: 12),
                        elevation: 0,
                      ),
                      child: const Text("Back",
                          style: TextStyle(
                              color: Colors.white,
                              fontWeight: FontWeight.bold)),
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: ElevatedButton(
                      onPressed: () => Navigator.pop(context, true),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.red,
                        shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(10)),
                        padding:
                            const EdgeInsets.symmetric(vertical: 12),
                        elevation: 0,
                      ),
                      child: const Text("Confirm",
                          style: TextStyle(
                              color: Colors.white,
                              fontWeight: FontWeight.bold)),
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
